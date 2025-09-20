import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../l10n/app_localizations.dart';

class APIBindingDialog extends StatefulWidget {
  final String serviceType;
  final VoidCallback? onBindingComplete;

  const APIBindingDialog({
    Key? key,
    required this.serviceType,
    this.onBindingComplete,
  }) : super(key: key);

  @override
  State<APIBindingDialog> createState() => _APIBindingDialogState();
}

class _APIBindingDialogState extends State<APIBindingDialog> {
  bool _isBinding = false;
  bool _bindingSuccess = false;
  String _currentStep = '';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 標題
            Row(
              children: [
                _getServiceIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getServiceTitle(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A4D3A),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // 描述
            Text(
              _getServiceDescription(),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // 綁定步驟
            if (!_bindingSuccess) ...[
              _buildBindingSteps(),
              const SizedBox(height: 24),
              _buildBindingButton(),
            ] else ...[
              _buildSuccessMessage(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _getServiceIcon() {
    switch (widget.serviceType) {
      case 'e_invoice':
        return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Icon(
            Icons.receipt,
            color: Colors.orange,
            size: 24,
          ),
        );
      case 'food_delivery':
        return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Icon(
            Icons.delivery_dining,
            color: Colors.purple,
            size: 24,
          ),
        );
      case 'bank':
        return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Icon(
            Icons.account_balance,
            color: Colors.blue,
            size: 24,
          ),
        );
      default:
        return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Icon(
            Icons.link,
            color: Colors.green,
            size: 24,
          ),
        );
    }
  }

  String _getServiceTitle() {
    switch (widget.serviceType) {
      case 'e_invoice':
        return '綁定電子發票';
      case 'food_delivery':
        return '綁定外送平台';
      case 'bank':
        return '綁定銀行帳戶';
      default:
        return '綁定服務';
    }
  }

  String _getServiceDescription() {
    switch (widget.serviceType) {
      case 'e_invoice':
        return '綁定電子發票後，系統會自動讀取您的購物記錄，智能計算購物碳足跡。\n\n支援：全聯、家樂福、7-ELEVEN、全家等';
      case 'food_delivery':
        return '綁定外送平台後，系統會自動獲取您的訂餐記錄，智能計算飲食碳足跡。\n\n支援：Uber Eats、Foodpanda、foodomo等';
      case 'bank':
        return '綁定銀行帳戶後，系統會自動分析您的消費記錄，智能計算相關碳足跡。\n\n支援：各大銀行信用卡、行動支付';
      default:
        return '綁定此服務後，系統會自動偵測相關活動並計算碳足跡。';
    }
  }

  Widget _buildBindingSteps() {
    List<Map<String, String>> steps = [];
    
    switch (widget.serviceType) {
      case 'e_invoice':
        steps = [
          {'icon': '📱', 'text': '輸入手機條碼'},
          {'icon': '🔐', 'text': '輸入驗證碼'},
          {'icon': '✅', 'text': '確認綁定'},
        ];
        break;
      case 'food_delivery':
        steps = [
          {'icon': '🍽️', 'text': '選擇外送平台'},
          {'icon': '🔑', 'text': '登入帳號'},
          {'icon': '✅', 'text': '授權存取'},
        ];
        break;
      case 'bank':
        steps = [
          {'icon': '🏦', 'text': '選擇銀行'},
          {'icon': '🔐', 'text': '輸入帳號密碼'},
          {'icon': '✅', 'text': '確認授權'},
        ];
        break;
    }

    return Column(
      children: steps.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, String> step = entry.value;
        bool isCurrentStep = _currentStep == step['text'];
        bool isCompleted = _bindingSuccess;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCurrentStep 
                ? const Color(0xFFE8F5E8)
                : isCompleted 
                    ? const Color(0xFFD4EDDA)
                    : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCurrentStep 
                  ? const Color(0xFF00E676)
                  : isCompleted 
                      ? Colors.green
                      : Colors.grey.shade300,
              width: isCurrentStep ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(
                step['icon']!,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step['text']!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isCurrentStep ? FontWeight.bold : FontWeight.normal,
                    color: isCurrentStep 
                        ? const Color(0xFF1A4D3A)
                        : isCompleted 
                            ? Colors.green.shade700
                            : Colors.grey.shade600,
                  ),
                ),
              ),
              if (isCurrentStep && _isBinding)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E676)),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBindingButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isBinding ? null : _startBinding,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00E676),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isBinding
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('綁定中...'),
                ],
              )
            : Text('開始綁定${_getServiceTitle()}'),
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFD4EDDA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 48,
          ),
          const SizedBox(height: 12),
          const Text(
            '綁定成功！',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_getServiceTitle()}已成功綁定，系統將開始自動偵測相關碳足跡。',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onBindingComplete?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('完成'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startBinding() async {
    setState(() {
      _isBinding = true;
    });

    // 模擬綁定流程
    List<String> steps = [];
    
    switch (widget.serviceType) {
      case 'e_invoice':
        steps = ['輸入手機條碼', '輸入驗證碼', '確認綁定'];
        break;
      case 'food_delivery':
        steps = ['選擇外送平台', '登入帳號', '授權存取'];
        break;
      case 'bank':
        steps = ['選擇銀行', '輸入帳號密碼', '確認授權'];
        break;
    }

    for (String step in steps) {
      setState(() {
        _currentStep = step;
      });
      
      // 模擬每個步驟的處理時間
      await Future.delayed(const Duration(seconds: 2));
    }

    setState(() {
      _isBinding = false;
      _bindingSuccess = true;
      _currentStep = '';
    });
  }
}
