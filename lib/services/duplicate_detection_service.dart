import 'dart:async';

// 重複偵測防護服務
class DuplicateDetectionService {
  static final DuplicateDetectionService _instance = DuplicateDetectionService._internal();
  factory DuplicateDetectionService() => _instance;
  DuplicateDetectionService._internal();

  // 已處理的交易記錄（用於去重）
  final Map<String, Map<String, dynamic>> _processedTransactions = {};
  
  // 交易去重規則
  final List<DuplicateRule> _duplicateRules = [
    DuplicateRule(
      name: '電子發票優先',
      priority: 1,
      condition: (transaction) => transaction['source'] == '電子發票',
      action: DuplicateAction.keep,
    ),
    DuplicateRule(
      name: '傳統發票次優先',
      priority: 2,
      condition: (transaction) => transaction['source'] == '傳統發票',
      action: DuplicateAction.keepIfNoInvoice,
    ),
    DuplicateRule(
      name: '行動支付第三優先',
      priority: 3,
      condition: (transaction) => transaction['source'] == '行動支付',
      action: DuplicateAction.keepIfNoInvoice,
    ),
    DuplicateRule(
      name: '信用卡最低優先',
      priority: 4,
      condition: (transaction) => transaction['source'] == '信用卡',
      action: DuplicateAction.keepIfNoOther,
    ),
  ];

  // 處理新交易，自動去重
  Future<Map<String, dynamic>?> processTransaction(Map<String, dynamic> transaction) async {
    print('🔍 檢查交易重複性: ${transaction['store']} - \$${transaction['amount']}');
    
    // 生成交易唯一識別碼
    final transactionId = _generateTransactionId(transaction);
    
    // 檢查是否已存在相同交易
    if (_processedTransactions.containsKey(transactionId)) {
      final existingTransaction = _processedTransactions[transactionId]!;
      
      // 應用去重規則
      final result = _applyDuplicateRules(transaction, existingTransaction);
      
      if (result.action == DuplicateAction.keep) {
        print('✅ 保留新交易: ${transaction['source']}');
        _processedTransactions[transactionId] = transaction;
        return transaction;
      } else if (result.action == DuplicateAction.replace) {
        print('🔄 替換舊交易: ${existingTransaction['source']} → ${transaction['source']}');
        _processedTransactions[transactionId] = transaction;
        return transaction;
      } else {
        print('❌ 跳過重複交易: ${transaction['source']}');
        return null; // 跳過重複交易
      }
    } else {
      // 新交易，直接記錄
      print('✅ 記錄新交易: ${transaction['source']}');
      _processedTransactions[transactionId] = transaction;
      return transaction;
    }
  }

  // 生成交易唯一識別碼
  String _generateTransactionId(Map<String, dynamic> transaction) {
    // 基於商店、金額、時間生成唯一ID
    final store = transaction['store'] ?? '';
    final amount = transaction['amount'] ?? 0;
    final timestamp = transaction['timestamp'] ?? DateTime.now();
    
    // 將時間精確到分鐘，避免秒級差異
    final timeKey = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
      timestamp.hour,
      timestamp.minute,
    );
    
    return '${store}_${amount}_${timeKey.millisecondsSinceEpoch}';
  }

  // 應用去重規則
  DuplicateResult _applyDuplicateRules(
    Map<String, dynamic> newTransaction,
    Map<String, dynamic> existingTransaction,
  ) {
    // 按優先級排序規則
    _duplicateRules.sort((a, b) => a.priority.compareTo(b.priority));
    
    for (final rule in _duplicateRules) {
      // 檢查新交易是否符合規則
      if (rule.condition(newTransaction)) {
        if (rule.action == DuplicateAction.keep) {
          return DuplicateResult(DuplicateAction.keep, rule.name);
        } else if (rule.action == DuplicateAction.keepIfNoInvoice) {
          // 檢查現有交易是否為電子發票
          if (existingTransaction['source'] != '電子發票') {
            return DuplicateResult(DuplicateAction.replace, rule.name);
          } else {
            return DuplicateResult(DuplicateAction.skip, rule.name);
          }
        } else if (rule.action == DuplicateAction.keepIfNoOther) {
          // 檢查現有交易是否為更高優先級
          final existingPriority = _getSourcePriority(existingTransaction['source']);
          final newPriority = _getSourcePriority(newTransaction['source']);
          
          if (newPriority < existingPriority) {
            return DuplicateResult(DuplicateAction.replace, rule.name);
          } else {
            return DuplicateResult(DuplicateAction.skip, rule.name);
          }
        }
      }
    }
    
    // 預設行為：保留第一個交易
    return DuplicateResult(DuplicateAction.skip, '預設規則');
  }

  // 獲取來源優先級（數字越小優先級越高）
  int _getSourcePriority(String source) {
    switch (source) {
      case '電子發票':
        return 1;
      case '傳統發票':
        return 2;
      case '行動支付':
        return 3;
      case '信用卡':
        return 4;
      default:
        return 5;
    }
  }

  // 獲取已處理的交易統計
  Map<String, int> getTransactionStats() {
    final stats = <String, int>{};
    
    for (final transaction in _processedTransactions.values) {
      final source = transaction['source'] ?? '未知';
      stats[source] = (stats[source] ?? 0) + 1;
    }
    
    return stats;
  }

  // 清除過期交易記錄（保留最近24小時）
  void cleanExpiredTransactions() {
    final now = DateTime.now();
    final expiredKeys = <String>[];
    
    for (final entry in _processedTransactions.entries) {
      final transaction = entry.value;
      final timestamp = transaction['timestamp'] as DateTime?;
      
      if (timestamp != null && now.difference(timestamp).inHours > 24) {
        expiredKeys.add(entry.key);
      }
    }
    
    for (final key in expiredKeys) {
      _processedTransactions.remove(key);
    }
    
    print('🧹 清理過期交易記錄: ${expiredKeys.length} 筆');
  }

  // 手動合併交易（用戶確認）
  Future<Map<String, dynamic>?> mergeTransactions(
    Map<String, dynamic> transaction1,
    Map<String, dynamic> transaction2,
  ) async {
    // 合併交易資訊
    final mergedTransaction = Map<String, dynamic>.from(transaction1);
    
    // 合併來源資訊
    final sources = [
      transaction1['source'],
      transaction2['source'],
    ].where((s) => s != null).toList();
    mergedTransaction['source'] = sources.join(' + ');
    
    // 合併商品資訊
    final items1 = transaction1['items'] as List<dynamic>? ?? [];
    final items2 = transaction2['items'] as List<dynamic>? ?? [];
    mergedTransaction['items'] = [...items1, ...items2];
    
    // 重新計算碳足跡
    mergedTransaction['carbonFootprint'] = _calculateTotalCarbonFootprint(
      mergedTransaction['items'] as List<dynamic>,
    );
    
    // 更新記錄
    final transactionId = _generateTransactionId(mergedTransaction);
    _processedTransactions[transactionId] = mergedTransaction;
    
    print('🔗 合併交易: ${mergedTransaction['source']}');
    return mergedTransaction;
  }

  // 計算總碳足跡
  double _calculateTotalCarbonFootprint(List<dynamic> items) {
    double total = 0;
    
    for (final item in items) {
      if (item is Map<String, dynamic>) {
        final quantity = item['quantity'] as int? ?? 1;
        final carbonFactor = item['carbonFactor'] as double? ?? 0;
        total += quantity * carbonFactor;
      }
    }
    
    return total;
  }
}

// 去重規則類別
class DuplicateRule {
  final String name;
  final int priority;
  final bool Function(Map<String, dynamic>) condition;
  final DuplicateAction action;

  DuplicateRule({
    required this.name,
    required this.priority,
    required this.condition,
    required this.action,
  });
}

// 去重動作枚舉
enum DuplicateAction {
  keep,           // 保留
  replace,        // 替換
  skip,           // 跳過
  keepIfNoInvoice, // 如果沒有電子發票則保留
  keepIfNoOther,   // 如果沒有其他更高優先級則保留
}

// 去重結果類別
class DuplicateResult {
  final DuplicateAction action;
  final String ruleName;

  DuplicateResult(this.action, this.ruleName);
}
