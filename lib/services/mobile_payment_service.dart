import 'dart:async';
import 'dart:math';

// 行動支付API整合服務
class MobilePaymentService {
  static final MobilePaymentService _instance = MobilePaymentService._internal();
  factory MobilePaymentService() => _instance;
  MobilePaymentService._internal();

  // 支援的行動支付平台
  final List<String> _supportedPlatforms = [
    'LINE Pay',
    '街口支付',
    '台灣Pay',
    'Pi拍錢包',
    '悠遊付',
    '一卡通MONEY',
    '全支付',
    'icash Pay',
    'Apple Pay',
    'Google Pay',
    'Samsung Pay',
  ];

  // 綁定的平台
  final Map<String, bool> _boundPlatforms = {};
  
  // 回調函數
  Function(Map<String, dynamic>)? onPaymentDetected;

  // 獲取支援的平台列表
  List<String> getSupportedPlatforms() {
    return List.from(_supportedPlatforms);
  }

  // 綁定平台
  Future<bool> bindPlatform(String platform, String phoneNumber) async {
    print('🔗 開始綁定 $platform...');
    
    // 模擬API調用
    await Future.delayed(Duration(seconds: 2));
    
    // 模擬綁定成功
    _boundPlatforms[platform] = true;
    
    print('✅ $platform 綁定成功！');
    return true;
  }

  // 解綁平台
  Future<bool> unbindPlatform(String platform) async {
    _boundPlatforms[platform] = false;
    print('❌ $platform 已解綁');
    return true;
  }

  // 檢查平台是否已綁定
  bool isPlatformBound(String platform) {
    return _boundPlatforms[platform] ?? false;
  }

  // 獲取已綁定的平台
  List<String> getBoundPlatforms() {
    return _boundPlatforms.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  // 開始監控所有綁定的平台
  void startMonitoring() {
    print('🚀 開始監控行動支付平台...');
    
    // 每30秒檢查一次新的支付記錄
    Timer.periodic(Duration(seconds: 30), (timer) {
      _checkNewPayments();
    });
  }

  // 停止監控
  void stopMonitoring() {
    print('⏹️ 停止監控行動支付平台');
  }

  // 檢查新的支付記錄
  Future<void> _checkNewPayments() async {
    final boundPlatforms = getBoundPlatforms();
    
    for (final platform in boundPlatforms) {
      await _checkPlatformPayments(platform);
    }
  }

  // 檢查特定平台的支付記錄
  Future<void> _checkPlatformPayments(String platform) async {
    try {
      // 模擬API調用獲取支付記錄
      final payments = await _fetchPaymentsFromAPI(platform);
      
      for (final payment in payments) {
        // 處理每筆支付記錄
        await _processPayment(payment);
      }
    } catch (e) {
      print('❌ 檢查 $platform 支付記錄時發生錯誤: $e');
    }
  }

  // 模擬從API獲取支付記錄
  Future<List<Map<String, dynamic>>> _fetchPaymentsFromAPI(String platform) async {
    // 模擬API延遲
    await Future.delayed(Duration(milliseconds: 500));
    
    // 隨機生成一些支付記錄
    final random = Random();
    final paymentCount = random.nextInt(3); // 0-2筆記錄
    
    List<Map<String, dynamic>> payments = [];
    
    for (int i = 0; i < paymentCount; i++) {
      payments.add(_generateRandomPayment(platform));
    }
    
    return payments;
  }

  // 生成隨機支付記錄
  Map<String, dynamic> _generateRandomPayment(String platform) {
    final random = Random();
    final stores = _getStoresForPlatform(platform);
    final store = stores[random.nextInt(stores.length)];
    
    final items = _generateRandomItems();
    final totalAmount = items.fold<double>(0, (sum, item) => sum + item['price']);
    final carbonFootprint = _calculateCarbonFootprint(items);
    
    return {
      'id': 'payment_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(1000)}',
      'platform': platform,
      'store': store['name'],
      'storeType': store['type'],
      'amount': totalAmount,
      'items': items,
      'carbonFootprint': carbonFootprint,
      'timestamp': DateTime.now(),
      'paymentMethod': '行動支付',
    };
  }

  // 獲取平台對應的商店
  List<Map<String, String>> _getStoresForPlatform(String platform) {
    switch (platform) {
      case 'LINE Pay':
        return [
          {'name': '7-ELEVEN', 'type': '便利商店'},
          {'name': '全家便利商店', 'type': '便利商店'},
          {'name': '星巴克', 'type': '咖啡店'},
          {'name': '麥當勞', 'type': '速食店'},
        ];
      case '街口支付':
        return [
          {'name': '全聯福利中心', 'type': '超市'},
          {'name': '家樂福', 'type': '量販店'},
          {'name': '屈臣氏', 'type': '藥妝店'},
          {'name': '康是美', 'type': '藥妝店'},
        ];
      case '台灣Pay':
        return [
          {'name': '台灣銀行ATM', 'type': '銀行'},
          {'name': '郵局', 'type': '郵政'},
          {'name': '中油加油站', 'type': '加油站'},
        ];
      case 'Apple Pay':
        return [
          {'name': 'Apple Store', 'type': '電子產品'},
          {'name': '誠品書店', 'type': '書店'},
          {'name': '無印良品', 'type': '生活用品'},
        ];
      default:
        return [
          {'name': '一般商店', 'type': '零售'},
          {'name': '餐廳', 'type': '餐飲'},
        ];
    }
  }

  // 生成隨機商品
  List<Map<String, dynamic>> _generateRandomItems() {
    final random = Random();
    final itemCount = random.nextInt(3) + 1; // 1-3個商品
    
    final allItems = [
      {'name': '咖啡', 'category': '飲品', 'price': 45.0, 'carbonFactor': 0.5},
      {'name': '三明治', 'category': '食品', 'price': 35.0, 'carbonFactor': 1.2},
      {'name': '牛奶', 'category': '乳製品', 'price': 65.0, 'carbonFactor': 1.0},
      {'name': '麵包', 'category': '食品', 'price': 25.0, 'carbonFactor': 0.8},
      {'name': '礦泉水', 'category': '飲品', 'price': 20.0, 'carbonFactor': 0.3},
      {'name': '水果', 'category': '食品', 'price': 80.0, 'carbonFactor': 0.6},
    ];
    
    List<Map<String, dynamic>> selectedItems = [];
    for (int i = 0; i < itemCount; i++) {
      final item = allItems[random.nextInt(allItems.length)];
      selectedItems.add({
        ...item,
        'quantity': random.nextInt(2) + 1, // 1-2個
      });
    }
    
    return selectedItems;
  }

  // 計算碳足跡
  double _calculateCarbonFootprint(List<Map<String, dynamic>> items) {
    double totalCarbon = 0;
    
    for (final item in items) {
      final quantity = item['quantity'] as int;
      final carbonFactor = item['carbonFactor'] as double;
      totalCarbon += quantity * carbonFactor;
    }
    
    return totalCarbon;
  }

  // 處理支付記錄
  Future<void> _processPayment(Map<String, dynamic> payment) async {
    print('💳 偵測到行動支付: ${payment['platform']} - ${payment['store']} - \$${payment['amount']}');
    
    // 觸發回調函數
    if (onPaymentDetected != null) {
      onPaymentDetected!(payment);
    }
  }

  // 獲取平台圖標
  String getPlatformIcon(String platform) {
    switch (platform) {
      case 'LINE Pay':
        return '💚';
      case '街口支付':
        return '🟢';
      case '台灣Pay':
        return '🔵';
      case 'Pi拍錢包':
        return '🟣';
      case '悠遊付':
        return '🟡';
      case '一卡通MONEY':
        return '🟠';
      case '全支付':
        return '🔴';
      case 'icash Pay':
        return '🟤';
      case 'Apple Pay':
        return '🍎';
      case 'Google Pay':
        return '🔍';
      case 'Samsung Pay':
        return '📱';
      default:
        return '💳';
    }
  }

  // 獲取平台顏色
  String getPlatformColor(String platform) {
    switch (platform) {
      case 'LINE Pay':
        return '#00C300';
      case '街口支付':
        return '#00B04F';
      case '台灣Pay':
        return '#0066CC';
      case 'Pi拍錢包':
        return '#8B5CF6';
      case '悠遊付':
        return '#FFD700';
      case '一卡通MONEY':
        return '#FF6B35';
      case '全支付':
        return '#E53E3E';
      case 'icash Pay':
        return '#8B4513';
      case 'Apple Pay':
        return '#000000';
      case 'Google Pay':
        return '#4285F4';
      case 'Samsung Pay':
        return '#1428A0';
      default:
        return '#6B7280';
    }
  }
}
