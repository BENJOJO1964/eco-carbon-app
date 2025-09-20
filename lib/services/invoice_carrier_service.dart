import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/carbon_record.dart';

class InvoiceCarrierService extends ChangeNotifier {
  static final InvoiceCarrierService _instance = InvoiceCarrierService._internal();
  factory InvoiceCarrierService() => _instance;
  InvoiceCarrierService._internal();

  // 發票載具相關狀態
  bool _isCarrierBound = false;
  String? _carrierCode;
  String? _carrierName;
  bool _isMonitoring = false;
  Timer? _monitoringTimer;

  // 檢測到的發票記錄
  final List<CarbonRecord> _detectedInvoices = [];

  // Getters
  bool get isCarrierBound => _isCarrierBound;
  String? get carrierCode => _carrierCode;
  String? get carrierName => _carrierName;
  bool get isMonitoring => _isMonitoring;
  List<CarbonRecord> get detectedInvoices => List.unmodifiable(_detectedInvoices);

  // 初始化服務
  Future<void> initialize() async {
    await _loadCarrierInfo();
    notifyListeners();
  }

  // 載入載具信息
  Future<void> _loadCarrierInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _carrierCode = prefs.getString('invoice_carrier_code');
      _carrierName = prefs.getString('invoice_carrier_name');
      _isCarrierBound = _carrierCode != null && _carrierCode!.isNotEmpty;
    } catch (e) {
      debugPrint('載入發票載具信息失敗: $e');
    }
  }

  // 綁定發票載具
  Future<bool> bindCarrier(String carrierCode, String carrierName) async {
    try {
      // 驗證載具條碼格式 (簡單驗證)
      if (carrierCode.length < 8) {
        return false;
      }

      // 保存載具信息
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('invoice_carrier_code', carrierCode);
      await prefs.setString('invoice_carrier_name', carrierName);

      _carrierCode = carrierCode;
      _carrierName = carrierName;
      _isCarrierBound = true;

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('綁定發票載具失敗: $e');
      return false;
    }
  }

  // 解綁發票載具
  Future<void> unbindCarrier() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('invoice_carrier_code');
      await prefs.remove('invoice_carrier_name');

      _carrierCode = null;
      _carrierName = null;
      _isCarrierBound = false;

      // 停止監控
      await stopMonitoring();

      notifyListeners();
    } catch (e) {
      debugPrint('解綁發票載具失敗: $e');
    }
  }

  // 開始監控電子發票
  Future<void> startMonitoring() async {
    if (!_isCarrierBound) {
      debugPrint('發票載具未綁定，無法開始監控');
      return;
    }

    _isMonitoring = true;
    
    // 模擬監控電子發票 (實際應用中會連接財政部電子發票平台)
    _monitoringTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (!_isMonitoring) {
        timer.cancel();
        return;
      }
      
      _checkForNewInvoices();
    });

    debugPrint('開始監控電子發票載具: $_carrierName');
    notifyListeners();
  }

  // 停止監控
  Future<void> stopMonitoring() async {
    _isMonitoring = false;
    _monitoringTimer?.cancel();
    _monitoringTimer = null;

    debugPrint('停止監控電子發票載具');
    notifyListeners();
  }

  // 檢查新發票 (模擬實現)
  void _checkForNewInvoices() {
    // 實際應用中會查詢財政部電子發票平台
    // 這裡模擬檢測到新發票
    final random = DateTime.now().millisecond % 10;
    if (random < 2) { // 20% 機率檢測到新發票
      _simulateNewInvoice();
    }
  }

  // 模擬新發票檢測
  void _simulateNewInvoice() {
    final invoiceTypes = [
      {'type': 'shopping', 'store': '全聯福利中心', 'amount': 150.0, 'items': ['牛奶', '麵包', '水果']},
      {'type': 'shopping', 'store': '7-ELEVEN', 'amount': 85.0, 'items': ['飲料', '零食']},
      {'type': 'food', 'store': '麥當勞', 'amount': 120.0, 'items': ['漢堡', '薯條', '可樂']},
      {'type': 'shopping', 'store': '家樂福', 'amount': 350.0, 'items': ['日用品', '清潔用品']},
      {'type': 'food', 'store': '星巴克', 'amount': 180.0, 'items': ['咖啡', '蛋糕']},
    ];

    final randomInvoice = invoiceTypes[DateTime.now().millisecond % invoiceTypes.length];
    final invoiceData = randomInvoice as Map<String, dynamic>;

    // 創建碳足跡記錄
    final record = _createInvoiceRecord(invoiceData);
    if (record != null) {
      _detectedInvoices.add(record);
      notifyListeners();
      
      debugPrint('檢測到新發票: ${invoiceData['store']} - ${invoiceData['amount']}元');
    }
  }

  // 從發票數據創建記錄
  CarbonRecord? _createInvoiceRecord(Map<String, dynamic> invoiceData) {
    try {
      final amount = (invoiceData['amount'] as num).toDouble();
      final store = invoiceData['store'] as String;
      final items = invoiceData['items'] as List<String>;
      final type = invoiceData['type'] as String;

      RecordType recordType;
      double carbonFootprint;

      switch (type) {
        case 'food':
          recordType = RecordType.food;
          carbonFootprint = amount * 0.3; // 食物碳足跡係數
          break;
        case 'shopping':
          recordType = RecordType.shopping;
          carbonFootprint = amount * 0.05; // 購物碳足跡係數
          break;
        default:
          recordType = RecordType.other;
          carbonFootprint = amount * 0.1;
      }

      return CarbonRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'invoice_carrier',
        type: recordType,
        distance: amount,
        carbonFootprint: carbonFootprint,
        description: '電子發票 - $store',
        timestamp: DateTime.now(),
        metadata: {
          'source': 'invoice_carrier',
          'carrier_code': _carrierCode,
          'carrier_name': _carrierName,
          'store': store,
          'items': items,
          'invoice_type': 'electronic',
        },
      );
    } catch (e) {
      debugPrint('創建發票記錄失敗: $e');
      return null;
    }
  }

  // 手動掃描傳統發票
  Future<CarbonRecord?> scanTraditionalInvoice(String invoiceText) async {
    try {
      // 解析發票內容 (簡化實現)
      final invoiceData = _parseInvoiceText(invoiceText);
      if (invoiceData == null) return null;

      final record = _createInvoiceRecord(invoiceData);
      if (record != null) {
        // 修改為傳統發票
        record.metadata!['invoice_type'] = 'traditional';
        // Note: description is final, so we can't modify it after creation
        
        _detectedInvoices.add(record);
        notifyListeners();
      }

      return record;
    } catch (e) {
      debugPrint('掃描傳統發票失敗: $e');
      return null;
    }
  }

  // 解析發票文字 (簡化實現)
  Map<String, dynamic>? _parseInvoiceText(String text) {
    // 實際應用中會使用OCR和AI識別發票內容
    // 這裡簡化為模擬數據
    final stores = ['全聯福利中心', '7-ELEVEN', '家樂福', '屈臣氏', '康是美'];
    final randomStore = stores[DateTime.now().millisecond % stores.length];
    final amount = (DateTime.now().millisecond % 500 + 50).toDouble();

    return {
      'type': 'shopping',
      'store': randomStore,
      'amount': amount,
      'items': ['商品'],
    };
  }

  // 獲取檢測到的發票記錄
  List<CarbonRecord> getDetectedInvoices() {
    return List.unmodifiable(_detectedInvoices);
  }

  // 清除檢測記錄
  void clearDetectedInvoices() {
    _detectedInvoices.clear();
    notifyListeners();
  }

  // 獲取載具狀態
  Map<String, dynamic> getCarrierStatus() {
    return {
      'isCarrierBound': _isCarrierBound,
      'carrierCode': _carrierCode,
      'carrierName': _carrierName,
      'isMonitoring': _isMonitoring,
      'detectedInvoicesCount': _detectedInvoices.length,
    };
  }

  @override
  void dispose() {
    _monitoringTimer?.cancel();
    super.dispose();
  }
}
