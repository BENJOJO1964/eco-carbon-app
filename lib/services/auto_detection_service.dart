import 'dart:async';
import 'dart:math';
import 'location_service.dart';
import 'e_invoice_service.dart';
import 'food_delivery_service.dart';
import 'traditional_invoice_service.dart';
import 'duplicate_detection_service.dart';

class AutoDetectionService {
  static final AutoDetectionService _instance = AutoDetectionService._internal();
  factory AutoDetectionService() => _instance;
  AutoDetectionService._internal();

  Timer? _detectionTimer;
  final List<Map<String, dynamic>> _detectedActivities = [];
  final LocationService _locationService = LocationService();
  final EInvoiceService _eInvoiceService = EInvoiceService();
  final FoodDeliveryService _foodDeliveryService = FoodDeliveryService();
  final TraditionalInvoiceService _traditionalInvoiceService = TraditionalInvoiceService();
  final DuplicateDetectionService _duplicateDetectionService = DuplicateDetectionService();

  // 開始真正的自動偵測功能
  void startAutoDetection() {
    print('🚀 啟動完整自動偵測系統...');
    
    // 1. 開始GPS位置追蹤
    _locationService.startLocationTracking();
    
    // 2. 開始電子發票監控
    _eInvoiceService.startEInvoiceMonitoring();
    
    // 3. 啟動傳統發票掃描服務（僅手動掃描，不自動監控）
    _traditionalInvoiceService.startTraditionalInvoiceMonitoring();
    
    // 4. 開始外送訂單監控
    _foodDeliveryService.startDeliveryMonitoring();
    
    // 設置各種回調
    _locationService.onTransportDetected = (activity) {
      _detectedActivities.add(activity);
      print('🚗 自動偵測到交通活動: ${activity['transportMode']} - ${activity['carbonFootprint'].toStringAsFixed(2)} kg CO2');
    };
    
    _eInvoiceService.onNewInvoice = (invoice) {
      _detectedActivities.add({
        'type': '購物',
        'emoji': '🛒',
        'description': '${invoice['store']}購物',
        'amount': invoice['totalAmount'],
        'unit': 'NTD',
        'carbonFootprint': invoice['totalCarbonFootprint'],
        'timestamp': invoice['date'],
        'autoDetected': true,
        'invoiceNumber': invoice['invoiceNumber'],
        'items': invoice['items'],
        'source': '電子發票',
      });
      print('🛒 自動偵測到購物活動: ${invoice['store']} - ${invoice['totalCarbonFootprint'].toStringAsFixed(2)} kg CO2');
    };
    
    // 傳統發票不需要自動回調，只提供手動掃描功能
    
    _foodDeliveryService.onNewOrder = (order) {
      _detectedActivities.add({
        'type': '飲食',
        'emoji': '🍽️',
        'description': '${order['platform']} - ${order['restaurant']}',
        'amount': order['totalAmount'],
        'unit': 'NTD',
        'carbonFootprint': order['totalCarbonFootprint'],
        'timestamp': order['date'],
        'autoDetected': true,
        'orderNumber': order['orderNumber'],
        'platform': order['platform'],
        'restaurant': order['restaurant'],
        'items': order['items'],
      });
      print('🍽️ 自動偵測到飲食活動: ${order['platform']} - ${order['restaurant']} - ${order['totalCarbonFootprint'].toStringAsFixed(2)} kg CO2');
    };
    
    // 開始其他活動的定時偵測（用電等）
    _detectionTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      _detectOtherActivities();
    });
  }

  void stopAutoDetection() {
    print('⏹️ 停止完整自動偵測系統...');
    _detectionTimer?.cancel();
    _detectionTimer = null;
    _locationService.stopLocationTracking();
    _eInvoiceService.stopEInvoiceMonitoring();
    _traditionalInvoiceService.stopTraditionalInvoiceMonitoring();
    _foodDeliveryService.stopDeliveryMonitoring();
  }

  // 偵測其他活動（用電、購物、飲食等）
  void _detectOtherActivities() {
    final random = Random();
    
    // 偵測用電活動 - 暫時禁用模擬數據，等待真實API整合
    if (false && random.nextDouble() < 0.2) { // 20% 機率
      final devices = _detectActiveDevices();
      if (devices.isNotEmpty) {
        final device = devices[random.nextInt(devices.length)];
        final carbonFootprint = device['power'] * device['hours'] * 0.5; // 0.5 kg CO2/kWh
        
        _detectedActivities.add({
          'type': '用電',
          'emoji': '⚡',
          'description': '${device['name']}使用',
          'amount': (device['power'] * device['hours']).toStringAsFixed(1),
          'unit': 'kWh',
          'carbonFootprint': carbonFootprint,
          'timestamp': DateTime.now(),
          'autoDetected': true,
        });
        print('⚡ 自動偵測到用電活動: ${device['name']} - ${carbonFootprint.toStringAsFixed(2)} kg CO2');
      }
    }
    
    // 偵測購物活動（模擬電子發票或信用卡記錄）- 暫時禁用模擬數據
    if (false && random.nextDouble() < 0.15) { // 15% 機率
      final shoppingItems = _detectShoppingActivities();
      if (shoppingItems.isNotEmpty) {
        final item = shoppingItems[random.nextInt(shoppingItems.length)];
        final carbonFootprint = item['amount'] * item['carbonFactor'];
        
        _detectedActivities.add({
          'type': '購物',
          'emoji': '🛒',
          'description': '購買${item['item']}',
          'amount': item['amount'].toString(),
          'unit': item['unit'],
          'carbonFootprint': carbonFootprint,
          'timestamp': DateTime.now(),
          'autoDetected': true,
        });
        print('🛒 自動偵測到購物活動: ${item['item']} - ${carbonFootprint.toStringAsFixed(2)} kg CO2');
      }
    }
    
    // 偵測飲食活動（模擬外送平台或餐廳記錄）- 暫時禁用模擬數據
    if (false && random.nextDouble() < 0.1) { // 10% 機率
      final foodItems = [
        {'name': '牛肉漢堡', 'weight': 0.3, 'carbonFactor': 15.0},
        {'name': '雞肉便當', 'weight': 0.4, 'carbonFactor': 3.0},
        {'name': '素食沙拉', 'weight': 0.2, 'carbonFactor': 0.5},
        {'name': '魚排餐', 'weight': 0.25, 'carbonFactor': 4.0},
      ];
      
      final item = foodItems[random.nextInt(foodItems.length)];
      final carbonFootprint = (item['weight'] as double) * (item['carbonFactor'] as double);
      
      _detectedActivities.add({
        'type': '飲食',
        'emoji': '🍽️',
        'description': '外送${item['name']}',
        'amount': item['weight'].toString(),
        'unit': 'kg',
        'carbonFootprint': carbonFootprint,
        'timestamp': DateTime.now(),
        'autoDetected': true,
      });
      print('🍽️ 自動偵測到飲食活動: ${item['name']} - ${carbonFootprint.toStringAsFixed(2)} kg CO2');
    }
  }

  // 獲取偵測到的活動
  List<Map<String, dynamic>> getDetectedActivities() {
    return List.from(_detectedActivities);
  }

  // 清除已處理的活動
  void clearProcessedActivities() {
    _detectedActivities.clear();
  }

  // 模擬GPS位置追蹤
  Map<String, double> getCurrentLocation() {
    // 模擬台北市範圍內的隨機位置
    final random = Random();
    return {
      'latitude': 25.0330 + (random.nextDouble() - 0.5) * 0.1,
      'longitude': 121.5654 + (random.nextDouble() - 0.5) * 0.1,
    };
  }

  // 模擬交通工具偵測
  String detectTransportMode() {
    final random = Random();
    final modes = ['開車', '騎車', '步行', '大眾運輸'];
    return modes[random.nextInt(modes.length)];
  }

  // 模擬用電設備偵測
  List<Map<String, dynamic>> detectActiveDevices() {
    final random = Random();
    final devices = [
      {'name': '空調', 'power': 2.5, 'hours': random.nextDouble() * 8},
      {'name': '冰箱', 'power': 0.2, 'hours': 24},
      {'name': '電視', 'power': 0.3, 'hours': random.nextDouble() * 4},
      {'name': '電腦', 'power': 0.4, 'hours': random.nextDouble() * 8},
      {'name': '洗衣機', 'power': 1.5, 'hours': random.nextDouble() * 2},
    ];
    
    return devices.where((device) => (device['hours'] as double) > 0).toList();
  }

  // 模擬購物記錄偵測
  List<Map<String, dynamic>> detectShoppingActivities() {
    final random = Random();
    final shoppingItems = [
      {'item': '有機蔬菜', 'amount': 2.0, 'unit': 'kg', 'carbonFactor': 0.5},
      {'item': '牛肉', 'amount': 0.5, 'unit': 'kg', 'carbonFactor': 15.0},
      {'item': '牛奶', 'amount': 1.0, 'unit': 'L', 'carbonFactor': 1.0},
      {'item': '麵包', 'amount': 0.3, 'unit': 'kg', 'carbonFactor': 1.2},
    ];
    
    return shoppingItems.take(random.nextInt(3) + 1).toList();
  }

  // 偵測活躍設備
  List<Map<String, dynamic>> _detectActiveDevices() {
    final random = Random();
    final devices = [
      {'name': '空調', 'power': 2.5, 'hours': random.nextDouble() * 8},
      {'name': '冰箱', 'power': 0.2, 'hours': 24},
      {'name': '電視', 'power': 0.3, 'hours': random.nextDouble() * 4},
      {'name': '電腦', 'power': 0.4, 'hours': random.nextDouble() * 8},
      {'name': '洗衣機', 'power': 1.5, 'hours': random.nextDouble() * 2},
    ];
    
    return devices.where((device) => (device['hours'] as double) > 0).toList();
  }

  // 偵測購物活動
  List<Map<String, dynamic>> _detectShoppingActivities() {
    final random = Random();
    final shoppingItems = [
      {'item': '有機蔬菜', 'amount': 2.0, 'unit': 'kg', 'carbonFactor': 0.5},
      {'item': '牛肉', 'amount': 0.5, 'unit': 'kg', 'carbonFactor': 15.0},
      {'item': '牛奶', 'amount': 1.0, 'unit': 'L', 'carbonFactor': 1.0},
      {'item': '麵包', 'amount': 0.3, 'unit': 'kg', 'carbonFactor': 1.2},
    ];
    
    return shoppingItems.take(random.nextInt(3) + 1).toList();
  }

  // 處理電子發票
  void _onNewInvoice(Map<String, dynamic> invoice) {
    print('📄 偵測到新發票: ${invoice['store']} - \$${invoice['amount']}');
    
    final carbonRecord = {
      'type': '購物',
      'store': invoice['store'],
      'amount': invoice['amount'],
      'carbonFootprint': invoice['carbonFootprint'],
      'items': invoice['items'],
      'autoDetected': true,
      'source': '電子發票',
      'timestamp': DateTime.now(),
    };
    
    // 使用去重服務處理
    _processWithDuplicateDetection(carbonRecord);
  }

  // 處理外送訂單
  void _onNewOrder(Map<String, dynamic> order) {
    print('🍽️ 偵測到新訂單: ${order['restaurant']} - \$${order['amount']}');
    
    final carbonRecord = {
      'type': '飲食',
      'restaurant': order['restaurant'],
      'amount': order['amount'],
      'carbonFootprint': order['carbonFootprint'],
      'items': order['items'],
      'autoDetected': true,
      'source': '外送平台',
      'timestamp': DateTime.now(),
    };
    
    // 使用去重服務處理
    _processWithDuplicateDetection(carbonRecord);
  }

  // 處理交通活動
  void _onTransportDetected(Map<String, dynamic> transport) {
    print('🚗 偵測到交通活動: ${transport['mode']} - ${transport['distance']}km');
    
    final carbonRecord = {
      'type': '交通',
      'mode': transport['mode'],
      'distance': transport['distance'],
      'carbonFootprint': transport['carbonFootprint'],
      'autoDetected': true,
      'source': 'GPS定位',
      'timestamp': DateTime.now(),
    };
    
    // 交通活動通常不會重複，直接添加
    _detectedActivities.add(carbonRecord);
  }

  // 使用去重服務處理交易
  void _processWithDuplicateDetection(Map<String, dynamic> transaction) async {
    final processedTransaction = await _duplicateDetectionService.processTransaction(transaction);
    
    if (processedTransaction != null) {
      _detectedActivities.add(processedTransaction);
      print('✅ 已記錄碳足跡: ${processedTransaction['source']} - ${processedTransaction['carbonFootprint']}kg CO2');
    } else {
      print('❌ 跳過重複交易: ${transaction['source']}');
    }
  }
}
