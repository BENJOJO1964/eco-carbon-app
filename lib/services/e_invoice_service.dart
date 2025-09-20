import 'dart:async';
import 'dart:convert';
import 'dart:math';

class EInvoiceService {
  static final EInvoiceService _instance = EInvoiceService._internal();
  factory EInvoiceService() => _instance;
  EInvoiceService._internal();

  Timer? _invoiceCheckTimer;
  final List<Map<String, dynamic>> _recentInvoices = [];

  // 商品碳足跡數據庫
  static const Map<String, double> _productCarbonFactors = {
    // 肉類
    '牛肉': 15.0,
    '豬肉': 7.0,
    '雞肉': 3.0,
    '羊肉': 12.0,
    '魚類': 4.0,
    '海鮮': 5.0,
    
    // 乳製品
    '牛奶': 1.0,
    '起司': 8.0,
    '優格': 2.0,
    '奶油': 6.0,
    
    // 蔬果
    '有機蔬菜': 0.5,
    '一般蔬菜': 0.3,
    '水果': 0.4,
    '根莖類': 0.2,
    
    // 穀物
    '米': 1.2,
    '麵包': 1.2,
    '麵條': 1.0,
    '麥片': 1.5,
    
    // 飲料
    '咖啡': 2.0,
    '茶': 0.5,
    '果汁': 1.0,
    '汽水': 0.8,
    
    // 零食
    '巧克力': 3.0,
    '餅乾': 1.5,
    '糖果': 1.0,
    '堅果': 2.0,
    
    // 日用品
    '洗髮精': 2.5,
    '沐浴乳': 2.0,
    '牙膏': 1.5,
    '洗衣精': 3.0,
    '清潔劑': 2.5,
    
    // 電子產品
    '手機': 50.0,
    '筆電': 200.0,
    '平板': 100.0,
    '耳機': 20.0,
    
    // 服飾
    'T恤': 5.0,
    '牛仔褲': 15.0,
    '外套': 25.0,
    '鞋子': 20.0,
  };

  // 開始電子發票監控
  void startEInvoiceMonitoring() {
    print('🧾 開始電子發票監控...');
    
    // 每30秒檢查一次新的電子發票
    _invoiceCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkNewInvoices();
    });
    
    // 立即檢查一次
    _checkNewInvoices();
  }

  // 停止電子發票監控
  void stopEInvoiceMonitoring() {
    _invoiceCheckTimer?.cancel();
    _invoiceCheckTimer = null;
    print('⏹️ 停止電子發票監控');
  }

  // 檢查新的電子發票
  void _checkNewInvoices() {
    // 模擬從財政部電子發票平台獲取新發票
    final newInvoices = _simulateNewInvoices();
    
    for (final invoice in newInvoices) {
      _processInvoice(invoice);
    }
  }

  // 模擬新的電子發票數據
  List<Map<String, dynamic>> _simulateNewInvoices() {
    final random = Random();
    final invoices = <Map<String, dynamic>>[];
    
    // 只有在真正綁定API後才生成數據，避免預設數據
    // 暫時不生成任何模擬數據，等待真實API整合
    if (false && random.nextDouble() < 0.2) {
      final stores = [
        '全聯福利中心',
        '家樂福',
        '7-ELEVEN',
        '全家便利商店',
        '頂好超市',
        '愛買',
        '大潤發',
        '屈臣氏',
        '康是美',
        '寶雅',
      ];
      
      final store = stores[random.nextInt(stores.length)];
      final invoice = _generateRandomInvoice(store);
      invoices.add(invoice);
    }
    
    return invoices;
  }

  // 生成隨機發票
  Map<String, dynamic> _generateRandomInvoice(String store) {
    final random = Random();
    final products = _getRandomProducts();
    
    double totalAmount = 0;
    double totalCarbonFootprint = 0;
    final items = <Map<String, dynamic>>[];
    
    for (final product in products) {
      final quantity = random.nextInt(3) + 1;
      final unitPrice = (random.nextDouble() * 200 + 10).toStringAsFixed(0);
      final amount = double.parse(unitPrice) * quantity;
      final carbonFactor = _productCarbonFactors[product] ?? 1.0;
      final carbonFootprint = amount * 0.01 * carbonFactor; // 假設每元對應0.01kg基礎碳足跡
      
      items.add({
        'product': product,
        'quantity': quantity,
        'unitPrice': double.parse(unitPrice),
        'amount': amount,
        'carbonFactor': carbonFactor,
        'carbonFootprint': carbonFootprint,
      });
      
      totalAmount += amount;
      totalCarbonFootprint += carbonFootprint;
    }
    
    return {
      'invoiceNumber': 'INV${DateTime.now().millisecondsSinceEpoch}',
      'store': store,
      'date': DateTime.now(),
      'totalAmount': totalAmount,
      'totalCarbonFootprint': totalCarbonFootprint,
      'items': items,
      'paymentMethod': random.nextBool() ? '信用卡' : '現金',
      'autoDetected': true,
    };
  }

  // 獲取隨機商品
  List<String> _getRandomProducts() {
    final random = Random();
    final allProducts = _productCarbonFactors.keys.toList();
    final productCount = random.nextInt(3) + 1; // 1-3個商品
    
    return List.generate(productCount, (index) {
      return allProducts[random.nextInt(allProducts.length)];
    }).toSet().toList(); // 去重
  }

  // 處理發票
  void _processInvoice(Map<String, dynamic> invoice) {
    _recentInvoices.add(invoice);
    
    print('🧾 偵測到新發票: ${invoice['store']}');
    print('   金額: \$${invoice['totalAmount'].toStringAsFixed(0)}');
    print('   碳足跡: ${invoice['totalCarbonFootprint'].toStringAsFixed(2)} kg CO2');
    print('   商品: ${invoice['items'].map((item) => item['product']).join(', ')}');
    
    // 觸發回調
    onNewInvoice?.call(invoice);
  }

  // 新發票回調
  void Function(Map<String, dynamic>)? onNewInvoice;

  // 獲取最近的發票
  List<Map<String, dynamic>> getRecentInvoices() {
    return List.from(_recentInvoices);
  }

  // 清除已處理的發票
  void clearProcessedInvoices() {
    _recentInvoices.clear();
  }

  // 根據商品名稱獲取碳足跡係數
  double getProductCarbonFactor(String productName) {
    // 模糊匹配商品名稱
    for (final entry in _productCarbonFactors.entries) {
      if (productName.contains(entry.key) || entry.key.contains(productName)) {
        return entry.value;
      }
    }
    return 1.0; // 預設係數
  }

  // 計算發票總碳足跡
  double calculateInvoiceCarbonFootprint(List<Map<String, dynamic>> items) {
    double total = 0;
    for (final item in items) {
      total += item['carbonFootprint'] as double;
    }
    return total;
  }

  // 獲取商品分類
  String getProductCategory(String productName) {
    if (_productCarbonFactors.containsKey(productName)) {
      if (['牛肉', '豬肉', '雞肉', '羊肉', '魚類', '海鮮'].contains(productName)) {
        return '肉類';
      } else if (['牛奶', '起司', '優格', '奶油'].contains(productName)) {
        return '乳製品';
      } else if (['有機蔬菜', '一般蔬菜', '水果', '根莖類'].contains(productName)) {
        return '蔬果';
      } else if (['米', '麵包', '麵條', '麥片'].contains(productName)) {
        return '穀物';
      } else if (['咖啡', '茶', '果汁', '汽水'].contains(productName)) {
        return '飲料';
      } else if (['巧克力', '餅乾', '糖果', '堅果'].contains(productName)) {
        return '零食';
      } else if (['洗髮精', '沐浴乳', '牙膏', '洗衣精', '清潔劑'].contains(productName)) {
        return '日用品';
      } else if (['手機', '筆電', '平板', '耳機'].contains(productName)) {
        return '電子產品';
      } else if (['T恤', '牛仔褲', '外套', '鞋子'].contains(productName)) {
        return '服飾';
      }
    }
    return '其他';
  }

  // 獲取所有商品碳足跡係數
  Map<String, double> getAllProductCarbonFactors() {
    return Map.from(_productCarbonFactors);
  }
}
