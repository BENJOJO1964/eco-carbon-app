import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../l10n/app_localizations.dart';

class PermissionDialog extends StatelessWidget {
  final String title;
  final String description;
  final List<String> benefits;
  final VoidCallback onAllow;
  final VoidCallback onDeny;
  final IconData icon;

  const PermissionDialog({
    Key? key,
    required this.title,
    required this.description,
    required this.benefits,
    required this.onAllow,
    required this.onDeny,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 圖標
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                icon,
                size: 30,
                color: Colors.green,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 標題
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 15),
            
            // 描述
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 20),
            
            // 功能列表
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '開啟後可以：',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...benefits.map((benefit) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('✓ ', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Text(
                            benefit,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 隱私說明
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.security, color: Colors.blue, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '您的數據完全安全，僅用於碳足跡計算，不會分享給第三方',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 按鈕
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDeny,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '稍後再說',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAllow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('立即開啟'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// GPS權限請求對話框
class GPSPermissionDialog extends StatelessWidget {
  final VoidCallback onAllow;
  final VoidCallback onDeny;

  const GPSPermissionDialog({
    Key? key,
    required this.onAllow,
    required this.onDeny,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PermissionDialog(
      icon: Icons.gps_fixed,
      title: '開啟GPS定位',
      description: '為了自動追蹤您的交通碳足跡，需要開啟GPS定位功能。',
      benefits: [
        '自動記錄開車、騎車、步行的距離',
        '智能識別交通工具類型',
        '精確計算交通碳足跡',
        '無需手動輸入移動記錄',
      ],
      onAllow: onAllow,
      onDeny: onDeny,
    );
  }
}

// 電子發票權限請求對話框
class EInvoicePermissionDialog extends StatelessWidget {
  final VoidCallback onAllow;
  final VoidCallback onDeny;

  const EInvoicePermissionDialog({
    Key? key,
    required this.onAllow,
    required this.onDeny,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PermissionDialog(
      icon: Icons.receipt,
      title: '綁定電子發票',
      description: '綁定電子發票後，系統會自動讀取您的購物記錄，智能計算購物碳足跡。',
      benefits: [
        '自動記錄全聯、家樂福等購物',
        '識別商品類型和碳足跡係數',
        '整合財政部電子發票平台',
        '根據消費金額自動計算',
      ],
      onAllow: onAllow,
      onDeny: onDeny,
    );
  }
}

// 外送平台權限請求對話框
class FoodDeliveryPermissionDialog extends StatelessWidget {
  final VoidCallback onAllow;
  final VoidCallback onDeny;

  const FoodDeliveryPermissionDialog({
    Key? key,
    required this.onAllow,
    required this.onDeny,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PermissionDialog(
      icon: Icons.delivery_dining,
      title: '綁定外送平台',
      description: '綁定外送平台帳號後，系統會自動獲取您的訂餐記錄，智能計算飲食碳足跡。',
      benefits: [
        '自動記錄Uber Eats、Foodpanda訂餐',
        '識別食物類型和碳足跡係數',
        '整合各大外送平台',
        '包含包裝材料碳足跡',
      ],
      onAllow: onAllow,
      onDeny: onDeny,
    );
  }
}
