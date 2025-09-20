import 'package:flutter/material.dart';
import '../services/onboarding_service.dart';
import '../services/api_binding_service.dart';

class ProgressiveSetupDialog extends StatefulWidget {
  final String currentStep;
  final VoidCallback? onComplete;
  final bool? initialGPSState;

  const ProgressiveSetupDialog({
    super.key,
    required this.currentStep,
    this.onComplete,
    this.initialGPSState,
  });

  @override
  State<ProgressiveSetupDialog> createState() => _ProgressiveSetupDialogState();
}

class _ProgressiveSetupDialogState extends State<ProgressiveSetupDialog> {
  final OnboardingService _onboardingService = OnboardingService();
  final APIBindingService _apiBindingService = APIBindingService();
  
  bool _gpsEnabled = false;
  bool _eInvoiceBound = false;
  bool _foodDeliveryBound = false;
  bool _bankBound = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentStatus();
  }

  Future<void> _loadCurrentStatus() async {
    final eInvoiceBound = await _apiBindingService.isEInvoiceBound();
    final foodDeliveryBound = await _apiBindingService.isFoodDeliveryBound();
    final bankBound = await _apiBindingService.isBankBound();
    final gpsEnabled = await _onboardingService.isGPSEnabled();
    
    setState(() {
      _gpsEnabled = widget.initialGPSState ?? gpsEnabled;
      _eInvoiceBound = eInvoiceBound;
      _foodDeliveryBound = foodDeliveryBound;
      _bankBound = bankBound;
    });
  }

  Future<void> _setupGPS() async {
    setState(() => _isLoading = true);
    
    try {
      // 模擬GPS權限請求
      await Future.delayed(const Duration(seconds: 1));
      setState(() => _gpsEnabled = true);
      
      // 保存GPS狀態到SharedPreferences
      await _onboardingService.setGPSEnabled(true);
      await _onboardingService.setAutoDetectionEnabled(true);
      
      // 通知父組件GPS已開啟
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GPS已開啟！開始自動偵測交通碳足跡'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('GPS設定失敗: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setupEInvoice() async {
    setState(() => _isLoading = true);
    
    try {
      await _onboardingService.showEInvoicePermissionDialog(context);
      // 模擬綁定成功
      await Future.delayed(const Duration(seconds: 1));
      setState(() => _eInvoiceBound = true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('電子發票已綁定！開始自動偵測購物碳足跡'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('電子發票綁定失敗: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setupFoodDelivery() async {
    setState(() => _isLoading = true);
    
    try {
      await _onboardingService.showFoodDeliveryPermissionDialog(context);
      // 模擬綁定成功
      await Future.delayed(const Duration(seconds: 1));
      setState(() => _foodDeliveryBound = true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('外送平台已綁定！開始自動偵測飲食碳足跡'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('外送平台綁定失敗: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setupBank() async {
    setState(() => _isLoading = true);
    
    try {
      // 模擬綁定成功
      await Future.delayed(const Duration(seconds: 1));
      setState(() => _bankBound = true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('行動支付已綁定！開始自動偵測消費碳足跡'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('行動支付綁定失敗: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _skipCurrentStep() {
    Navigator.of(context).pop();
    _showNextStep();
  }

  void _completeSetup() {
    Navigator.of(context).pop();
    if (widget.onComplete != null) {
      widget.onComplete!();
    }
    _showNextStep();
  }

  void _showNextStep() {
    // 根據當前步驟決定下一個步驟
    String nextStep = '';
    switch (widget.currentStep) {
      case 'gps':
        nextStep = 'e_invoice';
        break;
      case 'e_invoice':
        nextStep = 'food_delivery';
        break;
      case 'food_delivery':
        nextStep = 'bank';
        break;
      case 'bank':
        // 所有步驟完成，顯示完成提示
        _showCompletionDialog();
        return;
    }
    
    // 顯示下一個步驟
    Future.delayed(const Duration(milliseconds: 500), () {
      showDialog(
        context: context,
        builder: (context) => ProgressiveSetupDialog(
          currentStep: nextStep,
          initialGPSState: _gpsEnabled,
          onComplete: () {
            if (widget.onComplete != null) {
              widget.onComplete!();
            }
          },
        ),
      );
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text('設定完成！'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('恭喜！您已完成所有自動偵測設定。'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  if (_gpsEnabled) _buildStatusItem('GPS定位', true),
                  if (_eInvoiceBound) _buildStatusItem('電子發票', true),
                  if (_foodDeliveryBound) _buildStatusItem('外送平台', true),
                  if (_bankBound) _buildStatusItem('行動支付', true),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '系統將開始自動偵測您的碳足跡，讓環保生活更簡單！',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('開始使用'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String title, bool isEnabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isEnabled ? Icons.check_circle : Icons.cancel,
            color: isEnabled ? Colors.green : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: isEnabled ? Colors.green : Colors.grey,
              fontWeight: isEnabled ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (widget.currentStep) {
      case 'gps':
        return _buildGPSStep();
      case 'e_invoice':
        return _buildEInvoiceStep();
      case 'food_delivery':
        return _buildFoodDeliveryStep();
      case 'bank':
        return _buildBankStep();
      default:
        return _buildGPSStep();
    }
  }

  Widget _buildGPSStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Icon(
            Icons.gps_fixed,
            size: 40,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '開啟GPS定位',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'GPS定位可以自動追蹤您的移動軌跡，智能識別交通工具並計算交通碳足跡。',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildFeatureItem(Icons.location_on, '自動記錄移動距離'),
              _buildFeatureItem(Icons.directions_car, '識別交通工具'),
              _buildFeatureItem(Icons.flash_on, '即時計算碳足跡'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (_isLoading)
          const CircularProgressIndicator()
        else if (_gpsEnabled)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 12),
                const Text(
                  'GPS已開啟，開始自動偵測交通碳足跡',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        else
          ElevatedButton.icon(
            onPressed: _setupGPS,
            icon: const Icon(Icons.gps_fixed),
            label: const Text('開啟GPS'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildEInvoiceStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Icon(
            Icons.receipt,
            size: 40,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '綁定電子發票',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '綁定電子發票後，系統會自動獲取您的購物記錄，智能計算購物碳足跡。',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildFeatureItem(Icons.store, '全聯福利中心'),
              _buildFeatureItem(Icons.shopping_cart, '家樂福'),
              _buildFeatureItem(Icons.local_convenience_store, '7-ELEVEN'),
              _buildFeatureItem(Icons.storefront, '全家便利商店'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (_isLoading)
          const CircularProgressIndicator()
        else if (_eInvoiceBound)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 12),
                const Text(
                  '電子發票已綁定，開始自動偵測購物碳足跡',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        else
          ElevatedButton.icon(
            onPressed: _setupEInvoice,
            icon: const Icon(Icons.receipt),
            label: const Text('綁定電子發票'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildFoodDeliveryStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Icon(
            Icons.delivery_dining,
            size: 40,
            color: Colors.purple,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '綁定外送平台',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '綁定外送平台後，系統會自動獲取您的訂餐記錄，智能計算飲食碳足跡。',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildFeatureItem(Icons.restaurant, 'Uber Eats'),
              _buildFeatureItem(Icons.delivery_dining, 'Foodpanda'),
              _buildFeatureItem(Icons.fastfood, 'foodomo'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (_isLoading)
          const CircularProgressIndicator()
        else if (_foodDeliveryBound)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 12),
                const Text(
                  '外送平台已綁定，開始自動偵測飲食碳足跡',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        else
          ElevatedButton.icon(
            onPressed: _setupFoodDelivery,
            icon: const Icon(Icons.delivery_dining),
            label: const Text('綁定外送平台'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildBankStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.1),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Icon(
            Icons.payment,
            size: 40,
            color: Colors.indigo,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '綁定行動支付',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '綁定行動支付後，系統會自動分析您的消費記錄，智能計算消費碳足跡。',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildFeatureItem(Icons.credit_card, '信用卡消費記錄'),
              _buildFeatureItem(Icons.phone_android, '行動支付記錄'),
              _buildFeatureItem(Icons.account_balance, '各大銀行帳戶'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (_isLoading)
          const CircularProgressIndicator()
        else if (_bankBound)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 12),
                const Text(
                  '行動支付已綁定，開始自動偵測消費碳足跡',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        else
          ElevatedButton.icon(
            onPressed: _setupBank,
            icon: const Icon(Icons.payment),
            label: const Text('綁定行動支付'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
            // 標題欄
            Row(
              children: [
                Expanded(
                  child: Text(
                    _getStepTitle(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
            
            // 步驟內容
            _buildStepContent(),
            
            const SizedBox(height: 24),
            
            // 底部按鈕
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _skipCurrentStep,
                    child: const Text('跳過'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _completeSetup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('完成設定'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getStepTitle() {
    switch (widget.currentStep) {
      case 'gps':
        return 'GPS定位設定';
      case 'e_invoice':
        return '電子發票設定';
      case 'food_delivery':
        return '外送平台設定';
      case 'bank':
        return '行動支付設定';
      default:
        return '自動偵測設定';
    }
  }
}
