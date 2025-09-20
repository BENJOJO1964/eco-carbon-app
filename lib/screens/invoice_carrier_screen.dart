import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/invoice_carrier_service.dart';

class InvoiceCarrierScreen extends StatefulWidget {
  const InvoiceCarrierScreen({super.key});

  @override
  State<InvoiceCarrierScreen> createState() => _InvoiceCarrierScreenState();
}

class _InvoiceCarrierScreenState extends State<InvoiceCarrierScreen> {
  late InvoiceCarrierService _invoiceCarrierService;
  final _carrierCodeController = TextEditingController();
  final _carrierNameController = TextEditingController();
  final _invoiceTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _invoiceCarrierService = InvoiceCarrierService();
    _invoiceCarrierService.initialize();
  }

  @override
  void dispose() {
    _carrierCodeController.dispose();
    _carrierNameController.dispose();
    _invoiceTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('發票載具設置'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Consumer<InvoiceCarrierService>(
        builder: (context, service, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 電子發票載具綁定
                _buildElectronicInvoiceCard(service),
                const SizedBox(height: 16),
                
                // 傳統發票掃描
                _buildTraditionalInvoiceCard(service),
                const SizedBox(height: 16),
                
                // 檢測記錄
                _buildDetectedInvoicesCard(service),
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

  Widget _buildElectronicInvoiceCard(InvoiceCarrierService service) {
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
                  color: service.isCarrierBound ? Colors.green : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '電子發票載具',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        service.isCarrierBound 
                            ? '已綁定: ${service.carrierName}' 
                            : '未綁定載具',
                        style: TextStyle(
                          color: service.isCarrierBound ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (service.isCarrierBound)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showBindCarrierDialog(),
                  ),
              ],
            ),
            
            if (service.isCarrierBound) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '載具條碼: ${service.carrierCode}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
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
              const SizedBox(height: 8),
              Text(
                service.isMonitoring 
                    ? '正在監控電子發票，自動追蹤碳足跡' 
                    : '監控已停用',
                style: TextStyle(
                  fontSize: 12,
                  color: service.isMonitoring ? Colors.green : Colors.grey,
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showBindCarrierDialog(),
                  child: const Text('綁定發票載具'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTraditionalInvoiceCard(InvoiceCarrierService service) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt,
                  color: Colors.blue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '傳統發票掃描',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '掃描傳統發票識別購買內容',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _invoiceTextController,
              decoration: const InputDecoration(
                labelText: '發票內容 (OCR識別結果)',
                border: OutlineInputBorder(),
                hintText: '請輸入發票上的商店名稱、金額、商品等資訊',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _scanTraditionalInvoice(),
                icon: const Icon(Icons.camera_alt),
                label: const Text('掃描發票'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectedInvoicesCard(InvoiceCarrierService service) {
    final invoices = service.detectedInvoices;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '檢測到的發票記錄',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (invoices.isNotEmpty)
                  TextButton(
                    onPressed: () => service.clearDetectedInvoices(),
                    child: const Text('清除'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (invoices.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    '暫無發票記錄\n請綁定載具或掃描發票',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...invoices.take(5).map((invoice) => _buildInvoiceItem(invoice)),
            if (invoices.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '還有 ${invoices.length - 5} 條記錄...',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceItem(dynamic invoice) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            _getInvoiceIcon(invoice.type.toString()),
            size: 16,
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice.description ?? '發票記錄',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  '${invoice.metadata?['store'] ?? ''} - ¥${invoice.distance.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${invoice.carbonFootprint.toStringAsFixed(2)} kg CO₂',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getInvoiceIcon(String type) {
    switch (type) {
      case 'RecordType.food':
        return Icons.restaurant;
      case 'RecordType.shopping':
        return Icons.shopping_cart;
      default:
        return Icons.receipt;
    }
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
            _buildInstructionItem(
              '1. 電子發票載具',
              '綁定財政部電子發票載具，系統會自動監控您的電子發票並追蹤碳足跡',
            ),
            _buildInstructionItem(
              '2. 傳統發票掃描',
              '使用相機掃描傳統發票，系統會識別購買內容並計算碳足跡',
            ),
            _buildInstructionItem(
              '3. 自動追蹤',
              '啟用監控後，系統會自動收集發票數據，無需手動輸入',
            ),
            _buildInstructionItem(
              '4. 碳足跡計算',
              '根據購買的商品類型和金額，自動計算相應的碳足跡',
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

  void _showBindCarrierDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('綁定發票載具'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _carrierCodeController,
              decoration: const InputDecoration(
                labelText: '載具條碼',
                border: OutlineInputBorder(),
                hintText: '請輸入8位數載具條碼',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => _bindCarrier(),
            child: const Text('綁定'),
          ),
        ],
      ),
    );
  }

  Future<void> _bindCarrier() async {
    final code = _carrierCodeController.text.trim();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('請輸入載具條碼'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 使用載具條碼作為名稱
    final success = await _invoiceCarrierService.bindCarrier(code, code);
    if (success) {
      Navigator.of(context).pop();
      _carrierCodeController.clear();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('載具綁定成功'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('載具綁定失敗，請檢查條碼格式'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _scanTraditionalInvoice() async {
    // 開啟相機進行發票掃描
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('發票掃描'),
          content: const Text('正在開啟相機進行發票掃描...\n\n請將發票對準相機，系統將自動識別購買內容並計算碳足跡。'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // 模擬相機掃描過程
                _simulateInvoiceScanning();
              },
              child: const Text('開始掃描'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  void _simulateInvoiceScanning() {
    // 模擬發票掃描過程
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('掃描完成'),
          content: const Text('已成功識別發票內容：\n\n• 商店：7-ELEVEN\n• 金額：NT\$ 85\n• 商品：咖啡、麵包\n• 預估碳足跡：0.12 kg CO₂\n\n已自動記錄到您的碳足跡追蹤中。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('確定'),
            ),
          ],
        );
      },
    );
  }
}
