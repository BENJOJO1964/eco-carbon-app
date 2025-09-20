import 'dart:async';
import 'dart:math';

// 傳統發票偵測服務
class TraditionalInvoiceService {
  static final TraditionalInvoiceService _instance = TraditionalInvoiceService._internal();
  factory TraditionalInvoiceService() => _instance;
  TraditionalInvoiceService._internal();

  Timer? _monitoringTimer;
  bool _isMonitoring = false;
  
  // 回調函數
  Function(Map<String, dynamic>)? onNewInvoice;

  // 開始監控傳統發票（僅用於掃描，不自動監控）
  void startTraditionalInvoiceMonitoring() {
    // 傳統發票不需要自動監控，只提供掃描功能
    print('📄 傳統發票掃描服務已啟動（僅手動掃描）');
  }

  // 停止監控傳統發票
  void stopTraditionalInvoiceMonitoring() {
    // 傳統發票掃描服務不需要停止
    print('⏹️ 傳統發票掃描服務已停止');
  }

  // 傳統發票不需要自動監控功能，只提供手動掃描

  // 獲取隨機付款方式
  String _getRandomPaymentMethod() {
    final methods = [
      '現金',
      '信用卡',
      'LINE Pay',
      '街口支付',
      '台灣Pay',
      '悠遊卡',
      '一卡通',
    ];
    return methods[Random().nextInt(methods.length)];
  }

  // 獲取隨機地點
  String _getRandomLocation() {
    final locations = [
      '台北市信義區',
      '台北市大安區',
      '新北市板橋區',
      '新北市新店區',
      '桃園市中壢區',
      '台中市西區',
      '台中市北區',
      '高雄市前金區',
      '高雄市苓雅區',
      '台南市東區',
    ];
    return locations[Random().nextInt(locations.length)];
  }

  // 掃描發票（OCR + AI識別）
  Future<Map<String, dynamic>?> scanInvoice(String imagePath) async {
    print('📷 開始掃描發票: $imagePath');
    
    // 模擬OCR文字識別過程
    await Future.delayed(Duration(seconds: 1));
    print('🔍 OCR文字識別中...');
    
    // 模擬AI商品識別過程
    await Future.delayed(Duration(seconds: 2));
    print('🤖 AI商品識別中...');
    
    // 模擬碳足跡計算過程
    await Future.delayed(Duration(seconds: 1));
    print('🌱 計算碳足跡中...');
    
    // 模擬真實的發票掃描結果
    final random = Random();
    final scannedInvoice = _generateScannedInvoice(random);
    
    print('✅ 發票掃描完成: ${scannedInvoice['store']} - \$${scannedInvoice['amount']}');
    print('📊 識別到 ${scannedInvoice['items'].length} 項商品');
    print('🌱 總碳足跡: ${scannedInvoice['carbonFootprint']} kg CO2');
    
    // 觸發回調
    if (onNewInvoice != null) {
      onNewInvoice!(scannedInvoice);
    }
    
    return scannedInvoice;
  }

  // 生成掃描的發票數據（模擬真實OCR結果）
  Map<String, dynamic> _generateScannedInvoice(Random random) {
    final stores = [
      {
        'name': '全聯福利中心',
        'address': '台北市信義區信義路五段7號',
        'phone': '02-2345-6789',
        'taxId': '12345678',
      },
      {
        'name': '7-ELEVEN',
        'address': '台北市大安區敦化南路二段216號',
        'phone': '02-2700-0000',
        'taxId': '23456789',
      },
      {
        'name': '全家便利商店',
        'address': '台北市中山區南京東路二段100號',
        'phone': '02-2500-0000',
        'taxId': '34567890',
      },
      {
        'name': '家樂福',
        'address': '台北市內湖區民權東路六段208號',
        'phone': '02-2790-0000',
        'taxId': '45678901',
      },
      {
        'name': '屈臣氏',
        'address': '台北市萬華區西門町成都路10號',
        'phone': '02-2388-0000',
        'taxId': '56789012',
      },
    ];

    final store = stores[random.nextInt(stores.length)];
    final invoiceNumber = '${random.nextInt(90000000) + 10000000}';
    final date = DateTime.now().subtract(Duration(days: random.nextInt(7)));
    
    // 生成商品清單（模擬OCR識別結果）
    final items = _generateScannedItems(random);
    
    // 計算總金額和碳足跡
    double totalAmount = 0;
    double totalCarbonFootprint = 0;
    
    for (final item in items) {
      totalAmount += item['price'] as double;
      totalCarbonFootprint += item['carbonFootprint'] as double;
    }
    
    return {
      'invoiceNumber': invoiceNumber,
      'store': store['name'],
      'storeAddress': store['address'],
      'storePhone': store['phone'],
      'storeTaxId': store['taxId'],
      'invoiceType': '統一發票',
      'date': date,
      'amount': totalAmount,
      'tax': totalAmount * 0.05, // 5% 營業稅
      'totalAmount': totalAmount * 1.05,
      'items': items,
      'carbonFootprint': totalCarbonFootprint,
      'timestamp': DateTime.now(),
      'source': '發票掃描',
      'paymentMethod': _getRandomPaymentMethod(),
      'location': '用戶位置',
      'scanQuality': '${random.nextInt(20) + 80}%', // 80-100% 識別準確度
      'ocrConfidence': '${random.nextInt(15) + 85}%', // 85-100% OCR信心度
    };
  }

  // 生成掃描的商品清單（模擬OCR識別）
  List<Map<String, dynamic>> _generateScannedItems(Random random) {
    final productDatabase = [
      // 飲品類
      {'name': '美式咖啡', 'category': '飲品', 'carbonFactor': 0.5, 'unit': '杯', 'basePrice': 45.0},
      {'name': '拿鐵咖啡', 'category': '飲品', 'carbonFactor': 0.6, 'unit': '杯', 'basePrice': 55.0},
      {'name': '卡布奇諾', 'category': '飲品', 'carbonFactor': 0.7, 'unit': '杯', 'basePrice': 50.0},
      {'name': '珍珠奶茶', 'category': '飲品', 'carbonFactor': 0.4, 'unit': '杯', 'basePrice': 35.0},
      {'name': '綠茶', 'category': '飲品', 'carbonFactor': 0.2, 'unit': '杯', 'basePrice': 25.0},
      {'name': '可樂', 'category': '飲品', 'carbonFactor': 0.3, 'unit': '瓶', 'basePrice': 20.0},
      
      // 食品類
      {'name': '三明治', 'category': '食品', 'carbonFactor': 1.2, 'unit': '個', 'basePrice': 35.0},
      {'name': '飯糰', 'category': '食品', 'carbonFactor': 0.8, 'unit': '個', 'basePrice': 25.0},
      {'name': '麵包', 'category': '食品', 'carbonFactor': 1.0, 'unit': '個', 'basePrice': 30.0},
      {'name': '蛋糕', 'category': '食品', 'carbonFactor': 2.5, 'unit': '片', 'basePrice': 45.0},
      
      // 生鮮類
      {'name': '牛奶', 'category': '生鮮', 'carbonFactor': 1.0, 'unit': 'L', 'basePrice': 65.0},
      {'name': '雞蛋', 'category': '生鮮', 'carbonFactor': 0.8, 'unit': '盒', 'basePrice': 45.0},
      {'name': '蔬菜', 'category': '生鮮', 'carbonFactor': 0.5, 'unit': 'kg', 'basePrice': 30.0},
      {'name': '水果', 'category': '生鮮', 'carbonFactor': 0.6, 'unit': 'kg', 'basePrice': 40.0},
      {'name': '牛肉', 'category': '生鮮', 'carbonFactor': 15.0, 'unit': 'kg', 'basePrice': 300.0},
      {'name': '豬肉', 'category': '生鮮', 'carbonFactor': 8.0, 'unit': 'kg', 'basePrice': 200.0},
      {'name': '雞肉', 'category': '生鮮', 'carbonFactor': 4.0, 'unit': 'kg', 'basePrice': 120.0},
      
      // 日用品類
      {'name': '衛生紙', 'category': '日用品', 'carbonFactor': 0.2, 'unit': '包', 'basePrice': 25.0},
      {'name': '洗髮精', 'category': '日用品', 'carbonFactor': 0.4, 'unit': '瓶', 'basePrice': 80.0},
      {'name': '牙膏', 'category': '日用品', 'carbonFactor': 0.1, 'unit': '條', 'basePrice': 35.0},
      {'name': '電池', 'category': '日用品', 'carbonFactor': 0.05, 'unit': '顆', 'basePrice': 15.0},
    ];

    final itemCount = random.nextInt(5) + 1; // 1-5個商品
    final items = <Map<String, dynamic>>[];
    
    for (int i = 0; i < itemCount; i++) {
      final product = productDatabase[random.nextInt(productDatabase.length)];
      final quantity = random.nextDouble() * 3 + 0.5; // 0.5-3.5
      final price = (product['basePrice'] as double) * quantity;
      final carbonFootprint = quantity * (product['carbonFactor'] as double);
      
      items.add({
        'name': product['name'],
        'category': product['category'],
        'quantity': quantity,
        'unit': product['unit'],
        'price': price,
        'carbonFactor': product['carbonFactor'],
        'carbonFootprint': carbonFootprint,
        'barcode': '${random.nextInt(9000000000000) + 1000000000000}', // 13位條碼
        'ocrConfidence': '${random.nextInt(10) + 90}%', // 90-100% 識別信心度
      });
    }
    
    return items;
  }

  // 手動輸入發票
  Future<Map<String, dynamic>?> addManualInvoice({
    required String store,
    required double amount,
    required List<Map<String, dynamic>> items,
  }) async {
    print('✏️ 手動輸入發票: $store - \$$amount');
    
    // 計算碳足跡
    double totalCarbonFootprint = 0;
    for (final item in items) {
      final quantity = item['quantity'] as double? ?? 1.0;
      final carbonFactor = item['carbonFactor'] as double? ?? 0.0;
      totalCarbonFootprint += quantity * carbonFactor;
    }
    
    final invoice = {
      'invoiceNumber': 'MN${DateTime.now().millisecondsSinceEpoch}',
      'store': store,
      'invoiceType': '手動輸入',
      'amount': amount,
      'items': items,
      'carbonFootprint': totalCarbonFootprint,
      'timestamp': DateTime.now(),
      'source': '手動輸入',
      'paymentMethod': '未知',
      'location': '用戶位置',
    };
    
    print('✅ 手動發票已記錄: ${invoice['store']} - \$${invoice['amount']}');
    
    // 觸發回調
    if (onNewInvoice != null) {
      onNewInvoice!(invoice);
    }
    
    return invoice;
  }

  // 獲取發票統計
  Map<String, dynamic> getInvoiceStats() {
    return {
      'totalInvoices': Random().nextInt(50) + 10,
      'totalAmount': Random().nextDouble() * 10000 + 1000,
      'totalCarbonFootprint': Random().nextDouble() * 100 + 10,
      'averagePerInvoice': Random().nextDouble() * 2 + 0.5,
    };
  }

  // 檢查是否正在監控
  bool get isMonitoring => _isMonitoring;
}
