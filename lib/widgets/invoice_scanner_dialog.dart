import 'package:flutter/material.dart';
import '../services/traditional_invoice_service.dart';
import '../l10n/app_localizations.dart';

// 發票掃描對話框
class InvoiceScannerDialog extends StatefulWidget {
  final Function(Map<String, dynamic>)? onScanComplete;

  const InvoiceScannerDialog({
    Key? key,
    this.onScanComplete,
  }) : super(key: key);

  @override
  _InvoiceScannerDialogState createState() => _InvoiceScannerDialogState();
}

class _InvoiceScannerDialogState extends State<InvoiceScannerDialog> {
  final TraditionalInvoiceService _invoiceService = TraditionalInvoiceService();
  bool _isScanning = false;
  Map<String, dynamic>? _scanResult;
  String _scanStatus = '準備掃描';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // 標題欄
            Row(
              children: [
                Icon(Icons.qr_code_scanner, color: Colors.green, size: 28),
                SizedBox(width: 12),
                Text(
                  '傳統發票掃描',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: 20),
            
            // 掃描區域
            Expanded(
              child: _buildScanArea(),
            ),
            
            // 操作按鈕
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildScanArea() {
    if (_scanResult != null) {
      return _buildScanResult();
    }
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green, width: 2),
        borderRadius: BorderRadius.circular(12),
        color: Colors.green.withOpacity(0.05),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 掃描圖標
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              _isScanning ? Icons.qr_code_scanner : Icons.camera_alt,
              size: 60,
              color: Colors.green,
            ),
          ),
          SizedBox(height: 20),
          
          // 狀態文字
          Text(
            _scanStatus,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.green,
            ),
          ),
          SizedBox(height: 10),
          
          // 說明文字
          Text(
            '將傳統發票對準掃描框\nAI會自動識別商品和碳足跡',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          
          if (_isScanning) ...[
            SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            SizedBox(height: 10),
            Text(
              '正在識別發票內容...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScanResult() {
    final result = _scanResult!;
    final items = result['items'] as List<dynamic>;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 掃描成功標題
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 24),
                SizedBox(width: 8),
                Text(
                  '掃描成功！',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          
          // 商店資訊
          _buildInfoCard(
            '商店資訊',
            Icons.store,
            [
              '${result['store']}',
              '${result['storeAddress']}',
              '發票號碼: ${result['invoiceNumber']}',
              '掃描時間: ${result['timestamp']}',
            ],
          ),
          SizedBox(height: 12),
          
          // 金額資訊
          _buildInfoCard(
            '金額資訊',
            Icons.attach_money,
            [
              '商品金額: \$${result['amount'].toStringAsFixed(0)}',
              '營業稅: \$${result['tax'].toStringAsFixed(0)}',
              '總金額: \$${result['totalAmount'].toStringAsFixed(0)}',
            ],
          ),
          SizedBox(height: 12),
          
          // 碳足跡資訊
          _buildInfoCard(
            '碳足跡資訊',
            Icons.eco,
            [
              '總碳足跡: ${result['carbonFootprint'].toStringAsFixed(2)} kg CO2',
              '識別準確度: ${result['scanQuality']}',
              'OCR信心度: ${result['ocrConfidence']}',
            ],
          ),
          SizedBox(height: 12),
          
          // 商品清單
          _buildItemsList(items),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<String> items) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.green),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          ...items.map((item) => Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Text(
              item,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildItemsList(List<dynamic> items) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shopping_cart, size: 16, color: Colors.green),
              SizedBox(width: 8),
              Text(
                '商品清單 (${items.length}項)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          ...items.map((item) => _buildItemRow(item)),
        ],
      ),
    );
  }

  Widget _buildItemRow(Map<String, dynamic> item) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // 商品圖標
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getCategoryIcon(item['category']),
              size: 16,
              color: Colors.green,
            ),
          ),
          SizedBox(width: 12),
          
          // 商品資訊
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${item['quantity']} ${item['unit']} × \$${item['price'].toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // 碳足跡
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item['carbonFootprint'].toStringAsFixed(2)} kg CO2',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              Text(
                '${item['ocrConfidence']}',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '飲品':
        return Icons.local_drink;
      case '食品':
        return Icons.restaurant;
      case '生鮮':
        return Icons.eco;
      case '日用品':
        return Icons.home;
      default:
        return Icons.shopping_bag;
    }
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (_scanResult == null) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isScanning ? null : _startScan,
              icon: Icon(Icons.camera_alt),
              label: Text('開始掃描'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ] else ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _rescan,
              icon: Icon(Icons.refresh),
              label: Text('重新掃描'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: BorderSide(color: Colors.green),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _confirmScan,
              icon: Icon(Icons.check),
              label: Text('確認記錄'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _startScan() async {
    setState(() {
      _isScanning = true;
      _scanStatus = '正在掃描發票...';
    });

    // 模擬掃描過程
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _scanStatus = 'OCR文字識別中...';
    });

    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _scanStatus = 'AI商品識別中...';
    });

    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _scanStatus = '計算碳足跡中...';
    });

    // 執行掃描
    final result = await _invoiceService.scanInvoice('scanned_invoice.jpg');
    
    setState(() {
      _isScanning = false;
      _scanResult = result;
    });
  }

  void _rescan() {
    setState(() {
      _scanResult = null;
      _scanStatus = '準備掃描';
    });
  }

  void _confirmScan() {
    if (_scanResult != null && widget.onScanComplete != null) {
      widget.onScanComplete!(_scanResult!);
    }
    Navigator.of(context).pop();
  }
}
