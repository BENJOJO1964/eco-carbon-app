import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/carbon_record.dart';

class PaymentBindingService extends ChangeNotifier {
  // 支持的支付平台
  static const List<String> supportedPlatforms = [
    'Line Pay',
    '街口支付',
    '台灣Pay',
    'Pi拍錢包',
    '悠遊付',
    '一卡通Money',
    '全支付',
    'icash Pay',
  ];

  // 綁定的支付平台
  final Map<String, bool> _boundPlatforms = {};
  bool _isMonitoring = false;
  List<CarbonRecord> _detectedPayments = [];
  Timer? _monitoringTimer;

  Map<String, bool> get boundPlatforms => Map.unmodifiable(_boundPlatforms);
  bool get isMonitoring => _isMonitoring;
  List<CarbonRecord> get detectedPayments => List.unmodifiable(_detectedPayments);
  bool get hasBoundPlatforms => _boundPlatforms.values.any((bound) => bound);

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    for (String platform in supportedPlatforms) {
      // 默認所有平台都綁定，消費者不需要設定
      _boundPlatforms[platform] = prefs.getBool('payment_$platform') ?? true;
    }
    // 加載監控狀態
    _isMonitoring = prefs.getBool('payment_monitoring') ?? false;
    notifyListeners();
  }

  Future<bool> bindPlatform(String platform) async {
    if (!supportedPlatforms.contains(platform)) {
      return false;
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('payment_$platform', true);
    _boundPlatforms[platform] = true;
    notifyListeners();
    return true;
  }

  Future<void> unbindPlatform(String platform) async {
    if (!supportedPlatforms.contains(platform)) {
      return;
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('payment_$platform', false);
    _boundPlatforms[platform] = false;
    notifyListeners();
  }

  Future<void> startMonitoring() async {
    if (!hasBoundPlatforms || _isMonitoring) return;

    _isMonitoring = true;
    // 保存監控狀態
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('payment_monitoring', true);
    
    _monitoringTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _simulatePaymentDetection();
    });
    debugPrint('支付監控已啟動');
    notifyListeners();
  }

  Future<void> stopMonitoring() async {
    _isMonitoring = false;
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    
    // 保存監控狀態
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('payment_monitoring', false);
    
    debugPrint('支付監控已停止');
    notifyListeners();
  }

  void _simulatePaymentDetection() {
    // 模擬檢測到支付記錄
    if (DateTime.now().second % 30 == 0) { // 每30秒模擬一次
      final platforms = _boundPlatforms.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();
      
      if (platforms.isNotEmpty) {
        final platform = platforms[DateTime.now().millisecond % platforms.length];
        final record = _createPaymentRecord(platform);
        _detectedPayments.add(record);
        debugPrint('檢測到支付記錄: $platform - ${record.description}');
        notifyListeners();
      }
    }
  }

  CarbonRecord _createPaymentRecord(String platform) {
    final amounts = [50, 120, 200, 350, 80, 150, 300, 450];
    final amount = amounts[DateTime.now().millisecond % amounts.length].toDouble();
    
    // 根據金額和平台推斷消費類型
    String description;
    RecordType type;
    double carbonFootprint;
    
    if (amount < 100) {
      // 小額消費 - 可能是便利商店、咖啡
      description = '$platform - 便利商店消費';
      type = RecordType.shopping;
      carbonFootprint = amount * 0.02;
    } else if (amount < 200) {
      // 中等消費 - 可能是餐廳、外送
      description = '$platform - 餐廳消費';
      type = RecordType.food;
      carbonFootprint = amount * 0.05;
    } else if (amount < 400) {
      // 較大消費 - 可能是購物、外送
      description = '$platform - 購物消費';
      type = RecordType.shopping;
      carbonFootprint = amount * 0.08;
    } else {
      // 大額消費 - 可能是住宿、交通
      description = '$platform - 大額消費';
      type = RecordType.accommodation;
      carbonFootprint = amount * 0.1;
    }

    return CarbonRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'auto_detected',
      type: type,
      distance: amount,
      carbonFootprint: carbonFootprint,
      description: description,
      timestamp: DateTime.now(),
      metadata: {
        'source': 'payment_monitoring',
        'platform': platform,
        'amount': amount,
        'auto_detected': true,
      },
    );
  }

  void clearDetectedPayments() {
    _detectedPayments.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _monitoringTimer?.cancel();
    super.dispose();
  }
}
