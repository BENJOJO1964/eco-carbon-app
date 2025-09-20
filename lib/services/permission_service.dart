import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class PermissionService extends ChangeNotifier {
  // 權限狀態
  Map<Permission, PermissionStatus> _permissionStatuses = {};
  bool _isInitialized = false;

  // Getters
  bool get isInitialized => _isInitialized;
  Map<Permission, PermissionStatus> get permissionStatuses => Map.unmodifiable(_permissionStatuses);

  // 需要的主要權限
  static const List<Permission> requiredPermissions = [
    Permission.location,
    Permission.camera,
    Permission.notification,
  ];

  // 可選權限
  static const List<Permission> optionalPermissions = [
    Permission.storage,
    Permission.microphone,
  ];

  Future<void> initialize() async {
    await _checkAllPermissions();
    _isInitialized = true;
    notifyListeners();
  }

  // 檢查所有權限狀態
  Future<void> _checkAllPermissions() async {
    final allPermissions = [...requiredPermissions, ...optionalPermissions];
    
    for (final permission in allPermissions) {
      _permissionStatuses[permission] = await permission.status;
    }
    
    debugPrint('權限狀態檢查完成');
    _logPermissionStatuses();
  }

  // 請求單個權限
  Future<PermissionStatus> requestPermission(Permission permission) async {
    try {
      final status = await permission.request();
      _permissionStatuses[permission] = status;
      notifyListeners();
      
      debugPrint('權限請求結果: ${permission.toString()} -> $status');
      return status;
    } catch (e) {
      debugPrint('請求權限失敗: $e');
      return PermissionStatus.denied;
    }
  }

  // 請求所有必要權限
  Future<Map<Permission, PermissionStatus>> requestAllRequiredPermissions() async {
    final results = <Permission, PermissionStatus>{};
    
    for (final permission in requiredPermissions) {
      final status = await requestPermission(permission);
      results[permission] = status;
    }
    
    return results;
  }

  // 檢查特定權限是否已授予
  bool isPermissionGranted(Permission permission) {
    final status = _permissionStatuses[permission];
    return status == PermissionStatus.granted || status == PermissionStatus.limited;
  }

  // 檢查所有必要權限是否已授予
  bool areAllRequiredPermissionsGranted() {
    return requiredPermissions.every((permission) => isPermissionGranted(permission));
  }

  // 獲取權限狀態描述
  String getPermissionStatusDescription(Permission permission) {
    final status = _permissionStatuses[permission];
    switch (status) {
      case PermissionStatus.granted:
        return '已授予';
      case PermissionStatus.denied:
        return '已拒絕';
      case PermissionStatus.permanentlyDenied:
        return '永久拒絕';
      case PermissionStatus.restricted:
        return '受限制';
      case PermissionStatus.limited:
        return '有限權限';
      case PermissionStatus.provisional:
        return '臨時權限';
      default:
        return '未知';
    }
  }

  // 獲取權限名稱
  String getPermissionName(Permission permission) {
    switch (permission) {
      case Permission.location:
        return '位置權限';
      case Permission.camera:
        return '相機權限';
      case Permission.notification:
        return '通知權限';
      case Permission.storage:
        return '儲存權限';
      case Permission.microphone:
        return '麥克風權限';
      default:
        return permission.toString();
    }
  }

  // 獲取權限描述
  String getPermissionDescription(Permission permission) {
    switch (permission) {
      case Permission.location:
        return '用於GPS追蹤和交通活動檢測';
      case Permission.camera:
        return '用於掃描傳統發票，識別購買內容追蹤碳足跡';
      case Permission.notification:
        return '用於發送檢測到的新活動通知';
      case Permission.storage:
        return '用於保存發票圖片和數據';
      case Permission.microphone:
        return '用於語音輸入功能';
      default:
        return '應用程式功能所需';
    }
  }

  // 獲取權限圖標
  IconData getPermissionIcon(Permission permission) {
    switch (permission) {
      case Permission.location:
        return Icons.location_on;
      case Permission.camera:
        return Icons.camera_alt;
      case Permission.notification:
        return Icons.notifications;
      case Permission.storage:
        return Icons.storage;
      case Permission.microphone:
        return Icons.mic;
      default:
        return Icons.security;
    }
  }

  // 獲取權限顏色
  Color getPermissionColor(Permission permission) {
    if (isPermissionGranted(permission)) {
      return Colors.green;
    } else if (_permissionStatuses[permission] == PermissionStatus.permanentlyDenied) {
      return Colors.red;
    } else {
      return Colors.orange;
    }
  }

  // 檢查位置服務是否啟用
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      debugPrint('檢查位置服務狀態失敗: $e');
      return false;
    }
  }

  // 請求開啟位置服務
  Future<bool> requestLocationService() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      debugPrint('請求開啟位置服務失敗: $e');
      return false;
    }
  }

  // 請求開啟應用程式設定
  Future<bool> openAppSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      debugPrint('開啟應用程式設定失敗: $e');
      return false;
    }
  }

  // 獲取權限設定建議
  Future<List<String>> getPermissionRecommendations() async {
    final recommendations = <String>[];
    
    if (!isPermissionGranted(Permission.location)) {
      recommendations.add('建議授予位置權限以啟用GPS追蹤功能');
    }
    
    if (!isPermissionGranted(Permission.camera)) {
      recommendations.add('建議授予相機權限以啟用發票掃描功能');
    }
    
    if (!isPermissionGranted(Permission.notification)) {
      recommendations.add('建議授予通知權限以接收活動提醒');
    }
    
    if (!await isLocationServiceEnabled()) {
      recommendations.add('請在系統設定中開啟位置服務');
    }
    
    return recommendations;
  }

  // 記錄權限狀態
  void _logPermissionStatuses() {
    debugPrint('=== 權限狀態 ===');
    for (final entry in _permissionStatuses.entries) {
      debugPrint('${getPermissionName(entry.key)}: ${getPermissionStatusDescription(entry.key)}');
    }
    debugPrint('位置服務啟用: ${isLocationServiceEnabled()}');
    debugPrint('===============');
  }

  // 重新檢查權限狀態
  Future<void> refreshPermissions() async {
    await _checkAllPermissions();
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
