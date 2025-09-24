import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/carbon_record.dart';
import 'invoice_carrier_service.dart';
import 'payment_binding_service.dart';

class AutoDetectionManager extends ChangeNotifier {
  static final AutoDetectionManager _instance = AutoDetectionManager._internal();
  factory AutoDetectionManager() => _instance;
  AutoDetectionManager._internal();

  // 服务实例 - 简化实现
  // final LocationService _locationService = LocationService();
  // final SensorService _sensorService = SensorService();
  // final EInvoiceService _eInvoiceService = EInvoiceService();
  // final MobilePaymentService _paymentService = MobilePaymentService();
  
  // 發票載具服務
  final InvoiceCarrierService _invoiceCarrierService = InvoiceCarrierService();
  final PaymentBindingService _paymentBindingService = PaymentBindingService();

  // 状态管理
  bool _isAutoDetectionEnabled = false;
  bool _isGpsEnabled = false;
  bool _isInvoiceScanningEnabled = false;
  bool _isPaymentMonitoringEnabled = false;
  bool _isSensorDetectionEnabled = false;

  // 权限状态
  bool _locationPermissionGranted = false;
  bool _cameraPermissionGranted = false;
  bool _notificationPermissionGranted = false;

  // 检测到的活动记录
  final List<CarbonRecord> _detectedRecords = [];
  Timer? _detectionTimer;

  // Getters
  bool get isAutoDetectionEnabled => _isAutoDetectionEnabled;
  bool get isGpsEnabled => _isGpsEnabled;
  bool get isInvoiceScanningEnabled => _isInvoiceScanningEnabled;
  bool get isPaymentMonitoringEnabled => _isPaymentMonitoringEnabled;
  bool get isSensorDetectionEnabled => _isSensorDetectionEnabled;
  bool get locationPermissionGranted => _locationPermissionGranted;
  bool get cameraPermissionGranted => _cameraPermissionGranted;
  bool get notificationPermissionGranted => _notificationPermissionGranted;
  List<CarbonRecord> get detectedRecords => List.unmodifiable(_detectedRecords);

  // 初始化自动检测系统
  Future<void> initialize() async {
    await _checkPermissions();
    await _loadSettings();
    await _initializeServices();
    notifyListeners();
  }

  // 加载保存的设置
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isAutoDetectionEnabled = prefs.getBool('auto_detection_enabled') ?? false;
    _isGpsEnabled = prefs.getBool('gps_enabled') ?? false;
    _isInvoiceScanningEnabled = prefs.getBool('invoice_scanning_enabled') ?? false;
    _isPaymentMonitoringEnabled = prefs.getBool('payment_monitoring_enabled') ?? false;
    _isSensorDetectionEnabled = prefs.getBool('sensor_detection_enabled') ?? false;
  }

  // 保存设置
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_detection_enabled', _isAutoDetectionEnabled);
    await prefs.setBool('gps_enabled', _isGpsEnabled);
    await prefs.setBool('invoice_scanning_enabled', _isInvoiceScanningEnabled);
    await prefs.setBool('payment_monitoring_enabled', _isPaymentMonitoringEnabled);
    await prefs.setBool('sensor_detection_enabled', _isSensorDetectionEnabled);
  }

  // 检查所需权限
  Future<void> _checkPermissions() async {
    // 检查位置权限
    final locationStatus = await Permission.location.status;
    _locationPermissionGranted = locationStatus.isGranted;

    // 检查相机权限（用于扫描发票）
    final cameraStatus = await Permission.camera.status;
    _cameraPermissionGranted = cameraStatus.isGranted;

    // 检查通知权限
    final notificationStatus = await Permission.notification.status;
    _notificationPermissionGranted = notificationStatus.isGranted;
  }

  // 请求权限
  Future<bool> requestPermissions() async {
    bool allGranted = true;

    // 请求位置权限
    if (!_locationPermissionGranted) {
      final locationStatus = await Permission.location.request();
      _locationPermissionGranted = locationStatus.isGranted;
      if (!_locationPermissionGranted) allGranted = false;
    }

    // 请求相机权限
    if (!_cameraPermissionGranted) {
      final cameraStatus = await Permission.camera.request();
      _cameraPermissionGranted = cameraStatus.isGranted;
      if (!_cameraPermissionGranted) allGranted = false;
    }

    // 请求通知权限
    if (!_notificationPermissionGranted) {
      final notificationStatus = await Permission.notification.request();
      _notificationPermissionGranted = notificationStatus.isGranted;
      if (!_notificationPermissionGranted) allGranted = false;
    }

    notifyListeners();
    return allGranted;
  }

  // 初始化各个服务 - 简化实现
  Future<void> _initializeServices() async {
    try {
      // 初始化發票載具服務
      await _invoiceCarrierService.initialize();
      // 初始化支付綁定服務
      await _paymentBindingService.initialize();
      debugPrint('自动检测服务初始化完成');
    } catch (e) {
      debugPrint('服务初始化失败: $e');
    }
  }

  // 启用/禁用自动检测
  Future<void> setAutoDetectionEnabled(bool enabled) async {
    _isAutoDetectionEnabled = enabled;
    await _saveSettings();
    
    if (enabled) {
      await _startAutoDetection();
    } else {
      await _stopAutoDetection();
    }
    
    notifyListeners();
  }

  // 启用/禁用GPS追踪 - 简化实现
  Future<void> setGpsEnabled(bool enabled) async {
    _isGpsEnabled = enabled;
    await _saveSettings();
    
    if (enabled && _locationPermissionGranted) {
      debugPrint('GPS追踪已启用');
      _startRealGpsTracking(); // Use real tracking
    } else {
      debugPrint('GPS追踪已停用');
      // Stop real GPS tracking
    }
    
    notifyListeners();
  }

  // 启用/禁用发票扫描 - 简化实现
  Future<void> setInvoiceScanningEnabled(bool enabled) async {
    _isInvoiceScanningEnabled = enabled;
    await _saveSettings();
    
    if (enabled && _cameraPermissionGranted) {
      debugPrint('发票扫描已启用');
      // 啟用發票載具監控
      if (_invoiceCarrierService.isCarrierBound) {
        await _invoiceCarrierService.startMonitoring();
      }
    } else {
      debugPrint('发票扫描已停用');
      // 停用發票載具監控
      await _invoiceCarrierService.stopMonitoring();
    }
    
    notifyListeners();
  }

  // 启用/禁用支付监控 - 简化实现
  Future<void> setPaymentMonitoringEnabled(bool enabled) async {
    _isPaymentMonitoringEnabled = enabled;
    await _saveSettings();
    
    if (enabled) {
      debugPrint('支付监控已启用');
      if (_paymentBindingService.hasBoundPlatforms) {
        await _paymentBindingService.startMonitoring();
      }
    } else {
      debugPrint('支付监控已停用');
      await _paymentBindingService.stopMonitoring();
    }
    
    notifyListeners();
  }

  // 启用/禁用传感器检测 - 简化实现
  Future<void> setSensorDetectionEnabled(bool enabled) async {
    _isSensorDetectionEnabled = enabled;
    await _saveSettings();
    
    if (enabled) {
      debugPrint('传感器检测已启用');
      _startRealSensorDetection(); // Use real detection
    } else {
      debugPrint('传感器检测已停用');
      // Stop real sensor detection
    }
    
    notifyListeners();
  }

  // 开始自动检测 - 简化实现
  Future<void> _startAutoDetection() async {
    // 启动定时检测任务
    _detectionTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _performAutoDetection();
    });

    debugPrint('自动检测已启动');
  }

  // 停止自动检测 - 简化实现
  Future<void> _stopAutoDetection() async {
    _detectionTimer?.cancel();
    _detectionTimer = null;

    debugPrint('自动检测已停止');
  }

  // 执行自动检测
  Future<void> _performAutoDetection() async {
    if (!_isAutoDetectionEnabled) return;

    try {
      // 检测交通活动
      await _detectTransportActivity();
      
      // 检测用电活动
      await _detectEnergyActivity();
      
      // 检测饮食活动
      await _detectFoodActivity();
      
    } catch (e) {
      debugPrint('自动检测失败: $e');
    }
  }

  // 真實GPS追踪 - 待實現
  void _startRealGpsTracking() {
    // 實際應用中會使用真實的GPS服務
    debugPrint('GPS追踪已啟用 - 等待真實數據');
  }

  // 真實發票掃描 - 已整合發票載具服務
  void _startRealInvoiceScanning() {
    // 已整合到發票載具服務中
    debugPrint('發票掃描已啟用 - 使用發票載具服務');
  }

  // 真實支付監控 - 待實現
  void _startRealPaymentMonitoring() {
    // 實際應用中會連接支付平台API
    debugPrint('支付監控已啟用 - 等待真實數據');
  }

  // 真實感應器檢測 - 待實現
  void _startRealSensorDetection() {
    // 實際應用中會使用真實的感應器數據
    debugPrint('感應器檢測已啟用 - 等待真實數據');
  }

  // 獲取所有檢測到的記錄 (包括發票載具記錄)
  List<CarbonRecord> getAllDetectedRecords() {
    final allRecords = <CarbonRecord>[];
    
    // 添加發票載具檢測記錄
    allRecords.addAll(_invoiceCarrierService.detectedInvoices);
    
    // 添加支付監控檢測記錄
    allRecords.addAll(_paymentBindingService.detectedPayments);
    
    // 添加其他檢測記錄 (未來擴展)
    allRecords.addAll(_detectedRecords);
    
    // 按時間排序
    allRecords.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return allRecords;
  }

  // 检测交通活动 - 简化实现
  Future<void> _detectTransportActivity() async {
    if (_isGpsEnabled) {
      debugPrint('檢測交通活動');
    }
  }

  // 检测用电活动 - 简化实现
  Future<void> _detectEnergyActivity() async {
    if (_isSensorDetectionEnabled) {
      debugPrint('檢測用電活動');
    }
  }

  // 检测饮食活动 - 简化实现
  Future<void> _detectFoodActivity() async {
    if (_isPaymentMonitoringEnabled) {
      debugPrint('檢測飲食活動');
    }
  }


  // 获取检测到的记录 (包括發票載具記錄)
  List<CarbonRecord> getDetectedRecords() {
    return getAllDetectedRecords();
  }

  // 清除检测到的记录
  void clearDetectedRecords() {
    _detectedRecords.clear();
    _invoiceCarrierService.clearDetectedInvoices();
    _paymentBindingService.clearDetectedPayments();
    notifyListeners();
  }

  // 獲取發票載具服務
  InvoiceCarrierService get invoiceCarrierService => _invoiceCarrierService;
  PaymentBindingService get paymentBindingService => _paymentBindingService;

  // 获取自动检测状态摘要
  Map<String, dynamic> getDetectionStatus() {
    return {
      'autoDetectionEnabled': _isAutoDetectionEnabled,
      'gpsEnabled': _isGpsEnabled,
      'invoiceScanningEnabled': _isInvoiceScanningEnabled,
      'paymentMonitoringEnabled': _isPaymentMonitoringEnabled,
      'sensorDetectionEnabled': _isSensorDetectionEnabled,
      'locationPermissionGranted': _locationPermissionGranted,
      'cameraPermissionGranted': _cameraPermissionGranted,
      'notificationPermissionGranted': _notificationPermissionGranted,
      'detectedRecordsCount': _detectedRecords.length,
    };
  }

  @override
  void dispose() {
    _detectionTimer?.cancel();
    super.dispose();
  }
}
