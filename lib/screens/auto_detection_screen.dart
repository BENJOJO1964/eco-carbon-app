import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auto_detection_manager.dart';
import '../l10n/app_localizations.dart';
import 'invoice_carrier_screen.dart';
import 'payment_binding_screen.dart';

class AutoDetectionScreen extends StatefulWidget {
  const AutoDetectionScreen({super.key});

  @override
  State<AutoDetectionScreen> createState() => _AutoDetectionScreenState();
}

class _AutoDetectionScreenState extends State<AutoDetectionScreen> {
  late AutoDetectionManager _autoDetectionManager;

  @override
  void initState() {
    super.initState();
    _autoDetectionManager = AutoDetectionManager();
    _autoDetectionManager.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.autoDetection),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AutoDetectionManager>(
        builder: (context, manager, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 自動偵測總開關
                _buildMainToggleCard(l10n, manager),
                const SizedBox(height: 16),
                
                // 權限狀態卡片
                _buildPermissionStatusCard(l10n, manager),
                const SizedBox(height: 16),
                
                // 發票載具設置
                _buildInvoiceCarrierCard(manager),
                const SizedBox(height: 16),
                
                // 支付平台綁定設置
                _buildPaymentBindingCard(manager),
                const SizedBox(height: 16),
                
                // 偵測功能設置
                _buildDetectionSettingsCard(l10n, manager),
                const SizedBox(height: 16),
                
                // 偵測到的記錄
                _buildDetectedRecordsCard(l10n, manager),
                const SizedBox(height: 16),
                
                // 使用說明
                _buildInstructionsCard(l10n),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainToggleCard(AppLocalizations l10n, AutoDetectionManager manager) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: manager.isAutoDetectionEnabled ? Colors.green : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.autoDetection,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        manager.isAutoDetectionEnabled 
                            ? l10n.autoDetectionEnabled 
                            : l10n.autoDetectionDisabled,
                        style: TextStyle(
                          color: manager.isAutoDetectionEnabled ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: manager.isAutoDetectionEnabled,
                  onChanged: (value) async {
                    if (value && !_hasRequiredPermissions(manager)) {
                      await _requestPermissions(manager);
                    }
                    await manager.setAutoDetectionEnabled(value);
                  },
                  activeColor: Colors.green[800], // 更深的綠色
                  activeTrackColor: Colors.green[300],
                  inactiveThumbColor: Colors.grey[400],
                  inactiveTrackColor: Colors.grey[200],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '自動偵測系統會通過GPS、發票掃描、支付監控等方式自動收集您的碳足跡數據，無需手動輸入。',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionStatusCard(AppLocalizations l10n, AutoDetectionManager manager) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '權限狀態',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildPermissionItem(
              Icons.location_on,
              '位置權限',
              manager.isAutoDetectionEnabled && manager.locationPermissionGranted,
              '用於GPS追蹤和交通活動檢測',
            ),
            _buildCameraPermissionItem(
              Icons.camera_alt,
              '相機權限',
              manager.isAutoDetectionEnabled && manager.cameraPermissionGranted,
              '用於掃描傳統發票，識別購買內容追蹤碳足跡',
              manager,
            ),
            _buildPermissionItem(
              Icons.notifications,
              '通知權限',
              manager.isAutoDetectionEnabled && manager.notificationPermissionGranted,
              '用於發送檢測到的新活動通知',
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionItem(IconData icon, String title, bool granted, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: granted ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: granted ? Colors.black : Colors.grey,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            granted ? Icons.check_circle : Icons.cancel,
            color: granted ? Colors.green : Colors.red,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPermissionItem(IconData icon, String title, bool granted, String description, AutoDetectionManager manager) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: granted ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: granted ? Colors.black : Colors.grey,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (manager.isAutoDetectionEnabled)
            ElevatedButton.icon(
              onPressed: () {
                // 開啟相機功能
                _openCamera();
              },
              icon: const Icon(Icons.camera_alt, size: 16),
              label: const Text('開啟相機'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                textStyle: const TextStyle(fontSize: 12),
              ),
            )
          else
            Icon(
              granted ? Icons.check_circle : Icons.cancel,
              color: granted ? Colors.green : Colors.red,
              size: 20,
            ),
        ],
      ),
    );
  }

  void _openCamera() {
    // 開啟相機的實現
    debugPrint('開啟相機進行發票掃描');
    // 這裡可以添加實際的相機開啟邏輯
  }

  Widget _buildInvoiceCarrierCard(AutoDetectionManager manager) {
    final invoiceService = manager.invoiceCarrierService;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.qr_code,
                  color: invoiceService.isCarrierBound ? Colors.green : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '發票載具設置',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        invoiceService.isCarrierBound 
                            ? '已綁定: ${invoiceService.carrierName}' 
                            : '未綁定發票載具',
                        style: TextStyle(
                          color: invoiceService.isCarrierBound ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const InvoiceCarrierScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            if (invoiceService.isCarrierBound) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '載具條碼: ${invoiceService.carrierCode}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: invoiceService.isMonitoring ? Colors.green[100] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: invoiceService.isMonitoring ? Colors.green : Colors.grey,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.monitor,
                          size: 12,
                          color: invoiceService.isMonitoring ? Colors.green[700] : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          invoiceService.isMonitoring ? '監控中' : '未監控',
                          style: TextStyle(
                            fontSize: 10,
                            color: invoiceService.isMonitoring ? Colors.green[700] : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (invoiceService.detectedInvoices.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.receipt,
                        color: Colors.green[600],
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '已檢測到 ${invoiceService.detectedInvoices.length} 張發票',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ] else ...[
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
                        '綁定發票載具後可自動追蹤電子發票碳足跡',
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

  Widget _buildPaymentBindingCard(AutoDetectionManager manager) {
    final paymentService = manager.paymentBindingService;
    
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
                  color: paymentService.hasBoundPlatforms ? Colors.green : Colors.grey,
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
                        paymentService.hasBoundPlatforms 
                            ? '已綁定 ${paymentService.boundPlatforms.values.where((bound) => bound).length} 個平台' 
                            : '未綁定任何支付平台',
                        style: TextStyle(
                          color: paymentService.hasBoundPlatforms ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PaymentBindingScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            if (paymentService.hasBoundPlatforms) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '綁定平台: ${paymentService.boundPlatforms.entries.where((e) => e.value).map((e) => e.key).join(', ')}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: paymentService.isMonitoring ? Colors.green[100] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: paymentService.isMonitoring ? Colors.green : Colors.grey,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.monitor,
                          size: 12,
                          color: paymentService.isMonitoring ? Colors.green[700] : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          paymentService.isMonitoring ? '監控中' : '未監控',
                          style: TextStyle(
                            fontSize: 10,
                            color: paymentService.isMonitoring ? Colors.green[700] : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (paymentService.detectedPayments.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.payment,
                        color: Colors.green[600],
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '已檢測到 ${paymentService.detectedPayments.length} 筆支付記錄',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ] else ...[
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
                        '綁定支付平台後可自動追蹤消費碳足跡',
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

  Widget _buildDetectionSettingsCard(AppLocalizations l10n, AutoDetectionManager manager) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '檢測功能設置',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetectionToggle(
              Icons.location_on,
              l10n.gpsTracking,
              manager.isGpsEnabled,
              manager.locationPermissionGranted,
              (value) => manager.setGpsEnabled(value),
            ),
            _buildDetectionToggle(
              Icons.receipt,
              l10n.invoiceScanning,
              manager.isInvoiceScanningEnabled,
              manager.cameraPermissionGranted,
              (value) => manager.setInvoiceScanningEnabled(value),
            ),
            _buildDetectionToggle(
              Icons.payment,
              l10n.paymentMonitoring,
              manager.isPaymentMonitoringEnabled,
              true, // 支付監控不需要特殊權限
              (value) => manager.setPaymentMonitoringEnabled(value),
            ),
            _buildDetectionToggle(
              Icons.sensors,
              l10n.sensorDetection,
              manager.isSensorDetectionEnabled,
              true, // 感應器偵測不需要特殊權限
              (value) => manager.setSensorDetectionEnabled(value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectionToggle(
    IconData icon,
    String title,
    bool enabled,
    bool permissionGranted,
    Function(bool) onChanged,
  ) {
    final canEnable = permissionGranted;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: enabled && canEnable ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: canEnable ? Colors.black : Colors.grey,
              ),
            ),
          ),
          Switch(
            value: enabled && canEnable,
            onChanged: canEnable ? onChanged : null,
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildDetectedRecordsCard(AppLocalizations l10n, AutoDetectionManager manager) {
    final records = manager.detectedRecords;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '自動偵測記錄',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (records.isNotEmpty)
                  TextButton(
                    onPressed: () => manager.clearDetectedRecords(),
                    child: const Text('清除'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (records.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    '暫無自動偵測記錄\n請啟用自動檢測功能',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...records.take(5).map((record) => _buildRecordItem(record)),
            if (records.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '還有 ${records.length - 5} 條記錄...',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordItem(dynamic record) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            _getRecordIcon(record.type.toString()),
            size: 16,
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              record.description ?? '自動偵測記錄',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            '${record.carbonFootprint.toStringAsFixed(2)} kg CO₂',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRecordIcon(String type) {
    switch (type) {
      case 'RecordType.transport':
        return Icons.directions_walk;
      case 'RecordType.shopping':
        return Icons.shopping_cart;
      case 'RecordType.energy':
        return Icons.electrical_services;
      case 'RecordType.food':
        return Icons.restaurant;
      case 'RecordType.delivery':
        return Icons.delivery_dining;
      case 'RecordType.express':
        return Icons.local_shipping;
      case 'RecordType.accommodation':
        return Icons.hotel;
      default:
        return Icons.category;
    }
  }

  Widget _buildInstructionsCard(AppLocalizations l10n) {
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
            _buildInstructionItem(
              '1. 啟用自動檢測',
              '開啟自動檢測總開關，系統會自動開始收集您的碳足跡數據',
            ),
            _buildInstructionItem(
              '2. 授權權限',
              '允許位置、相機、通知權限，以確保所有檢測功能正常運作',
            ),
            _buildInstructionItem(
              '3. 選擇檢測方式',
              '根據需要啟用GPS追蹤、發票掃描、支付監控等檢測功能',
            ),
            _buildInstructionItem(
              '4. 自動記錄',
              '系統會自動檢測並記錄您的各項活動，無需手動輸入',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.green,
            ),
          ),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  bool _hasRequiredPermissions(AutoDetectionManager manager) {
    return manager.locationPermissionGranted && 
           manager.cameraPermissionGranted && 
           manager.notificationPermissionGranted;
  }

  Future<void> _requestPermissions(AutoDetectionManager manager) async {
    final granted = await manager.requestPermissions();
    if (!granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('部分權限未授予，某些功能可能無法正常使用'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}
