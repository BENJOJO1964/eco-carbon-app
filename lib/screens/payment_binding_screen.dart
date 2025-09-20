import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/payment_binding_service.dart';
import '../l10n/app_localizations.dart';

class PaymentBindingScreen extends StatefulWidget {
  const PaymentBindingScreen({super.key});

  @override
  State<PaymentBindingScreen> createState() => _PaymentBindingScreenState();
}

class _PaymentBindingScreenState extends State<PaymentBindingScreen> {
  @override
  void initState() {
    super.initState();
    // 初始化支付綁定服務
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PaymentBindingService>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('支付平台綁定'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Consumer<PaymentBindingService>(
        builder: (context, paymentService, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 支付平台綁定卡片
                _buildPaymentPlatformsCard(paymentService),
                const SizedBox(height: 16),
                
                // 監控狀態卡片
                _buildMonitoringStatusCard(paymentService),
                const SizedBox(height: 16),
                
                // 檢測到的支付記錄
                _buildDetectedPaymentsCard(paymentService),
                const SizedBox(height: 16),
                
                // 使用說明
                _buildInstructionsCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentPlatformsCard(PaymentBindingService service) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.payment,
                  color: service.hasBoundPlatforms ? Colors.green : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '支付平台綁定',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        service.hasBoundPlatforms 
                            ? '已綁定 ${service.boundPlatforms.values.where((bound) => bound).length} 個平台' 
                            : '未綁定任何支付平台',
                        style: TextStyle(
                          color: service.hasBoundPlatforms ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '已自動綁定的支付平台：',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            ...PaymentBindingService.supportedPlatforms.map((platform) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: Icon(
                    _getPlatformIcon(platform),
                    color: Colors.green,
                  ),
                  title: Text(
                    platform,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                  subtitle: const Text(
                    '已自動綁定',
                    style: TextStyle(
                      color: Colors.green,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMonitoringStatusCard(PaymentBindingService service) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.monitor,
                  color: service.isMonitoring ? Colors.green : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '支付監控狀態',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        service.isMonitoring 
                            ? '正在監控支付活動' 
                            : '監控已停用',
                        style: TextStyle(
                          color: service.isMonitoring ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (service.hasBoundPlatforms)
                  Switch(
                    value: service.isMonitoring,
                    onChanged: (value) {
                      if (value) {
                        service.startMonitoring();
                      } else {
                        service.stopMonitoring();
                      }
                    },
                    activeColor: Colors.green,
                  ),
              ],
            ),
            if (!service.hasBoundPlatforms) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange[600],
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '請先綁定至少一個支付平台才能啟用監控',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetectedPaymentsCard(PaymentBindingService service) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '檢測到的支付記錄',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (service.detectedPayments.isNotEmpty)
                  TextButton(
                    onPressed: service.clearDetectedPayments,
                    child: const Text('清除所有'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (service.detectedPayments.isEmpty)
              Center(
                child: Text(
                  '暫無支付記錄',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              )
            else
              ...service.detectedPayments.map((record) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '• ${record.timestamp.toLocal().toString().split('.')[0]} - ${record.description ?? '未知支付'} (${record.carbonFootprint.toStringAsFixed(2)} kg CO₂)',
                      style: const TextStyle(fontSize: 14),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '使用說明',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '系統已自動綁定所有主要支付平台，將自動監控您的支付活動並計算碳足跡：',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              '• 小額消費（<100元）：便利商店、咖啡等\n'
              '• 中等消費（100-200元）：餐廳、外送等\n'
              '• 較大消費（200-400元）：購物、外送等\n'
              '• 大額消費（>400元）：住宿、交通等',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              '系統會根據消費金額和平台自動推斷消費類型，並計算相應的碳足跡。',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform) {
      case 'Line Pay':
        return Icons.chat;
      case '街口支付':
        return Icons.store;
      case '台灣Pay':
        return Icons.account_balance;
      case 'Pi拍錢包':
        return Icons.wallet;
      case '悠遊付':
        return Icons.card_membership;
      case '一卡通Money':
        return Icons.credit_card;
      case '全支付':
        return Icons.payment;
      case 'icash Pay':
        return Icons.shopping_bag;
      default:
        return Icons.payment;
    }
  }
}
