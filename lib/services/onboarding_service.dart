import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/onboarding_dialog.dart';
import '../widgets/permission_dialog.dart';

class OnboardingService {
  static final OnboardingService _instance = OnboardingService._internal();
  factory OnboardingService() => _instance;
  OnboardingService._internal();

  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _gpsPermissionRequestedKey = 'gps_permission_requested';
  static const String _gpsEnabledKey = 'gps_enabled';
  static const String _autoDetectionEnabledKey = 'auto_detection_enabled';
  static const String _eInvoicePermissionRequestedKey = 'e_invoice_permission_requested';
  static const String _foodDeliveryPermissionRequestedKey = 'food_delivery_permission_requested';

  // 檢查是否需要顯示引導流程
  Future<bool> shouldShowOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_onboardingCompletedKey) ?? false);
  }

  // 標記引導流程已完成
  Future<void> markOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, true);
  }

  // 顯示引導流程
  Future<void> showOnboarding(BuildContext context) async {
    if (await shouldShowOnboarding()) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const OnboardingDialog(),
      );
      await markOnboardingCompleted();
    }
  }

  // 檢查GPS權限請求（每次都可以請求）
  Future<bool> shouldRequestGPSPermission() async {
    return true; // 每次都允許請求權限
  }

  // 標記GPS權限已請求
  Future<void> markGPSPermissionRequested() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_gpsPermissionRequestedKey, true);
  }

  // 檢查GPS是否已啟用
  Future<bool> isGPSEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_gpsEnabledKey) ?? false;
  }

  // 設置GPS啟用狀態
  Future<void> setGPSEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_gpsEnabledKey, enabled);
  }

  // 檢查自動偵測是否已啟用
  Future<bool> isAutoDetectionEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoDetectionEnabledKey) ?? false;
  }

  // 設置自動偵測啟用狀態
  Future<void> setAutoDetectionEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoDetectionEnabledKey, enabled);
  }

  // 顯示GPS權限請求
  Future<bool> showGPSPermissionDialog(BuildContext context) async {
    if (await shouldRequestGPSPermission()) {
      bool? result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => GPSPermissionDialog(
          onAllow: () {
            Navigator.of(context).pop(true);
          },
          onDeny: () {
            Navigator.of(context).pop(false);
          },
        ),
      );
      
      await markGPSPermissionRequested();
      return result ?? false;
    }
    return false;
  }

  // 檢查電子發票權限請求
  Future<bool> shouldRequestEInvoicePermission() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_eInvoicePermissionRequestedKey) ?? false);
  }

  // 標記電子發票權限已請求
  Future<void> markEInvoicePermissionRequested() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_eInvoicePermissionRequestedKey, true);
  }

  // 顯示電子發票權限請求
  Future<bool> showEInvoicePermissionDialog(BuildContext context) async {
    if (await shouldRequestEInvoicePermission()) {
      bool? result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => EInvoicePermissionDialog(
          onAllow: () {
            Navigator.of(context).pop(true);
          },
          onDeny: () {
            Navigator.of(context).pop(false);
          },
        ),
      );
      
      await markEInvoicePermissionRequested();
      return result ?? false;
    }
    return false;
  }

  // 檢查外送平台權限請求
  Future<bool> shouldRequestFoodDeliveryPermission() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_foodDeliveryPermissionRequestedKey) ?? false);
  }

  // 標記外送平台權限已請求
  Future<void> markFoodDeliveryPermissionRequested() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_foodDeliveryPermissionRequestedKey, true);
  }

  // 顯示外送平台權限請求
  Future<bool> showFoodDeliveryPermissionDialog(BuildContext context) async {
    if (await shouldRequestFoodDeliveryPermission()) {
      bool? result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => FoodDeliveryPermissionDialog(
          onAllow: () {
            Navigator.of(context).pop(true);
          },
          onDeny: () {
            Navigator.of(context).pop(false);
          },
        ),
      );
      
      await markFoodDeliveryPermissionRequested();
      return result ?? false;
    }
    return false;
  }

  // 顯示功能介紹提示
  Future<void> showFeatureIntroduction(BuildContext context, String feature) async {
    String title = '';
    String description = '';
    List<String> benefits = [];
    IconData icon = Icons.info;

    switch (feature) {
      case 'gps':
        title = 'GPS自動定位已開啟';
        description = '系統現在會自動追蹤您的移動軌跡，智能識別交通工具並計算交通碳足跡。';
        benefits = [
          '🚗 自動記錄開車距離和碳足跡',
          '🚴 識別騎車和步行活動',
          '📍 精確計算移動距離',
          '⚡ 節省手動輸入時間',
        ];
        icon = Icons.gps_fixed;
        break;
      case 'e_invoice':
        title = '電子發票整合已開啟';
        description = '系統現在會自動讀取您的購物記錄，識別商品類型並計算購物碳足跡。';
        benefits = [
          '🛒 自動記錄全聯、家樂福等購物',
          '📱 識別商品類型和碳足跡',
          '🧾 整合財政部電子發票平台',
          '💰 根據消費金額自動計算',
        ];
        icon = Icons.receipt;
        break;
      case 'food_delivery':
        title = '外送平台整合已開啟';
        description = '系統現在會自動獲取您的訂餐記錄，識別食物類型並計算飲食碳足跡。';
        benefits = [
          '🍽️ 自動記錄Uber Eats、Foodpanda訂餐',
          '🍔 識別食物類型和碳足跡',
          '🏪 整合各大外送平台',
          '📦 包含包裝材料碳足跡',
        ];
        icon = Icons.delivery_dining;
        break;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(icon, color: Colors.green),
            const SizedBox(width: 10),
            Expanded(child: Text(title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            const SizedBox(height: 15),
            const Text(
              '主要功能：',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...benefits.map((benefit) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(benefit, style: const TextStyle(fontSize: 14)),
            )).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  // 重置所有引導狀態（用於測試）
  Future<void> resetOnboardingState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingCompletedKey);
    await prefs.remove(_gpsPermissionRequestedKey);
    await prefs.remove(_eInvoicePermissionRequestedKey);
    await prefs.remove(_foodDeliveryPermissionRequestedKey);
  }
}
