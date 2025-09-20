import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../l10n/app_localizations.dart';
import '../services/onboarding_service.dart';
import '../services/api_binding_service.dart';

class SetupWizard extends StatefulWidget {
  final VoidCallback? onComplete;

  const SetupWizard({
    Key? key,
    this.onComplete,
  }) : super(key: key);

  @override
  State<SetupWizard> createState() => _SetupWizardState();
}

class _SetupWizardState extends State<SetupWizard> {
  int _currentStep = 0;
  final PageController _pageController = PageController();
  final OnboardingService _onboardingService = OnboardingService();
  final APIBindingService _apiBindingService = APIBindingService();
  
  // 綁定狀態
  bool _gpsEnabled = false;
  bool _eInvoiceBound = false;
  bool _foodDeliveryBound = false;
  bool _bankBound = false;

  @override
  void initState() {
    super.initState();
    _loadBindingStatus();
  }

  void _loadBindingStatus() async {
    // 載入當前的綁定狀態
    final eInvoiceBound = await _apiBindingService.isEInvoiceBound();
    final foodDeliveryBound = await _apiBindingService.isFoodDeliveryBound();
    final bankBound = await _apiBindingService.isBankBound();
    
    setState(() {
      _eInvoiceBound = eInvoiceBound;
      _foodDeliveryBound = foodDeliveryBound;
      _bankBound = bankBound;
    });
  }

  // 檢查是否可以進入完成步驟
  bool _canCompleteSetup() {
    return _gpsEnabled && _eInvoiceBound && _foodDeliveryBound && _bankBound;
  }

  List<SetupStep> get _steps => [
    SetupStep(
      title: '歡迎使用Eco碳足跡追蹤',
      subtitle: '讓我們為您設置自動偵測功能',
      icon: Icons.eco,
      color: Colors.green,
      content: _WelcomeStep(),
    ),
    SetupStep(
      title: '開啟GPS定位',
      subtitle: '自動追蹤您的交通碳足跡',
      icon: Icons.gps_fixed,
      color: Colors.blue,
      content: _GPSStep(
        isEnabled: _gpsEnabled,
        onToggle: _toggleGPS,
      ),
    ),
    SetupStep(
      title: '綁定電子發票',
      subtitle: '自動記錄購物碳足跡',
      icon: Icons.receipt,
      color: Colors.orange,
      content: _EInvoiceStep(
        isBound: _eInvoiceBound,
        onBind: _bindEInvoice,
      ),
    ),
    SetupStep(
      title: '綁定外送平台',
      subtitle: '自動記錄飲食碳足跡',
      icon: Icons.delivery_dining,
      color: Colors.purple,
      content: _FoodDeliveryStep(
        isBound: _foodDeliveryBound,
        onBind: _bindFoodDelivery,
      ),
    ),
    SetupStep(
      title: '綁定銀行帳戶',
      subtitle: '自動分析消費碳足跡',
      icon: Icons.account_balance,
      color: Colors.indigo,
      content: _BankStep(
        isBound: _bankBound,
        onBind: _bindBank,
      ),
    ),
    SetupStep(
      title: _canCompleteSetup() ? '設置完成' : '設置進度',
      subtitle: _canCompleteSetup() ? '開始您的環保生活' : '完成所有設置項目',
      icon: _canCompleteSetup() ? Icons.check_circle : Icons.settings,
      color: _canCompleteSetup() ? Colors.green : Colors.orange,
      content: _CompleteStep(
        canComplete: _canCompleteSetup(),
        gpsEnabled: _gpsEnabled,
        eInvoiceBound: _eInvoiceBound,
        foodDeliveryBound: _foodDeliveryBound,
        bankBound: _bankBound,
      ),
    ),
  ];

  // 綁定方法
  Future<void> _toggleGPS() async {
    if (!_gpsEnabled) {
      final gpsAllowed = await _onboardingService.showGPSPermissionDialog(context);
      if (gpsAllowed) {
        await _onboardingService.showFeatureIntroduction(context, 'gps');
        setState(() {
          _gpsEnabled = true;
        });
      }
    } else {
      setState(() {
        _gpsEnabled = false;
      });
    }
  }

  Future<void> _bindEInvoice() async {
    if (!_eInvoiceBound) {
      // 顯示綁定對話框
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => _EInvoiceBindingDialog(),
      );
      
      if (result == true) {
        await _onboardingService.showEInvoicePermissionDialog(context);
        // 模擬綁定成功
        await Future.delayed(Duration(seconds: 1));
        setState(() {
          _eInvoiceBound = true;
        });
        
        // 顯示成功提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('電子發票綁定成功！'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _bindFoodDelivery() async {
    if (!_foodDeliveryBound) {
      // 顯示綁定對話框
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => _FoodDeliveryBindingDialog(),
      );
      
      if (result == true) {
        await _onboardingService.showFoodDeliveryPermissionDialog(context);
        // 模擬綁定成功
        await Future.delayed(Duration(seconds: 1));
        setState(() {
          _foodDeliveryBound = true;
        });
        
        // 顯示成功提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('外送平台綁定成功！'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _bindBank() async {
    if (!_bankBound) {
      // 顯示綁定對話框
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => _BankBindingDialog(),
      );
      
      if (result == true) {
        // 模擬綁定成功
        await Future.delayed(Duration(seconds: 1));
        setState(() {
          _bankBound = true;
        });
        
        // 顯示成功提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('銀行帳戶綁定成功！'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            // 標題欄
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _currentStep < _steps.length - 1 
                      ? _steps[_currentStep].color 
                      : (_canCompleteSetup() ? Colors.green : Colors.orange),
                    (_currentStep < _steps.length - 1 
                      ? _steps[_currentStep].color 
                      : (_canCompleteSetup() ? Colors.green : Colors.orange)).withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _steps[_currentStep].icon,
                    color: Colors.white,
                    size: 30,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _steps[_currentStep].title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _steps[_currentStep].subtitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 返回按鈕
                  if (_currentStep > 0)
                    IconButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  // 關閉按鈕
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close, color: Colors.white),
                    tooltip: '關閉設置',
                  ),
                ],
              ),
            ),
            
            // 進度指示器
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Row(
                children: List.generate(
                  _steps.length,
                  (index) => Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                        right: index < _steps.length - 1 ? 8 : 0,
                      ),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= _currentStep
                            ? (_currentStep < _steps.length - 1 
                                ? _steps[_currentStep].color 
                                : (_canCompleteSetup() ? Colors.green : Colors.orange))
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // 漸進式設置提示
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '您可以隨時關閉設置，已設定的功能會繼續自動偵測碳足跡',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // 頁面內容
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  return _steps[index].content;
                },
              ),
            ),
            
            // 底部按鈕
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text('上一步'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentStep < _steps.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          // 只有當所有服務都綁定後才能完成設置
                          if (_canCompleteSetup()) {
                            Navigator.of(context).pop();
                            widget.onComplete?.call();
                          } else {
                            // 點擊"開始設置"時跳轉到GPS步驟
                            setState(() {
                              _currentStep = 1; // 更新當前步驟
                            });
                            _pageController.animateToPage(
                              1, // GPS步驟
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentStep < _steps.length - 1 
                          ? _steps[_currentStep].color 
                          : (_canCompleteSetup() ? Colors.green : Colors.orange),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(_currentStep < _steps.length - 1 ? '下一步' : (_canCompleteSetup() ? '完成設置' : '開始設置')),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SetupStep {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget content;

  SetupStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.content,
  });
}

// 歡迎步驟
class _WelcomeStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.eco,
              size: 30,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '歡迎使用Eco碳足跡追蹤',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            '我們將引導您完成設置，讓系統能夠自動偵測並追蹤您的碳足跡。',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Column(
              children: [
                Text(
                  '設置完成後，系統將自動偵測：',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 6),
                _FeatureItem('🚗', '交通移動距離和方式'),
                _FeatureItem('🛒', '購物活動和碳足跡'),
                _FeatureItem('🍽️', '飲食記錄和碳足跡'),
                _FeatureItem('⚡', '用電設備使用情況'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// GPS步驟
class _GPSStep extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onToggle;

  const _GPSStep({
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.gps_fixed,
              size: 25,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '開啟GPS定位',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'GPS定位可以自動追蹤您的移動軌跡，智能識別交通工具並計算交通碳足跡。',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                Text(
                  'GPS功能包括：',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 3),
                const _FeatureItem('📍', '自動記錄移動距離'),
                const _FeatureItem('🚗', '識別交通工具'),
                const _FeatureItem('⚡', '即時計算碳足跡'),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onToggle,
                    icon: Icon(isEnabled ? Icons.gps_off : Icons.gps_fixed, size: 14),
                    label: Text(isEnabled ? '關閉GPS' : '開啟GPS', style: TextStyle(fontSize: 11)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEnabled ? Colors.red : Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                  ),
                ),
                if (isEnabled)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 14),
                        const SizedBox(width: 4),
                        const Text(
                          'GPS已開啟',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 電子發票步驟
class _EInvoiceStep extends StatelessWidget {
  final bool isBound;
  final VoidCallback onBind;

  const _EInvoiceStep({
    required this.isBound,
    required this.onBind,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.receipt,
              size: 25,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '綁定電子發票',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            '綁定電子發票後，系統會自動讀取您的購物記錄，智能計算購物碳足跡。',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                const Text(
                  '支援的商店：',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 4),
                const _FeatureItem('🏪', '全聯福利中心'),
                const _FeatureItem('🏬', '家樂福'),
                const _FeatureItem('🏪', '7-ELEVEN'),
                const _FeatureItem('🏪', '全家便利商店'),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isBound ? null : onBind,
                    icon: Icon(isBound ? Icons.check : Icons.link, size: 14),
                    label: Text(isBound ? '已綁定' : '開始綁定', style: TextStyle(fontSize: 11)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isBound ? Colors.grey : Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                  ),
                ),
                if (isBound)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 14),
                        const SizedBox(width: 4),
                        const Text(
                          '電子發票已綁定',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 外送平台步驟
class _FoodDeliveryStep extends StatelessWidget {
  final bool isBound;
  final VoidCallback onBind;

  const _FoodDeliveryStep({
    required this.isBound,
    required this.onBind,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.delivery_dining,
              size: 30,
              color: Colors.purple,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '綁定外送平台',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            '綁定外送平台後，系統會自動獲取您的訂餐記錄，智能計算飲食碳足跡。',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Text(
                  '支援的平台：',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 4),
                const _FeatureItem('🍽️', 'Uber Eats'),
                const _FeatureItem('🍽️', 'Foodpanda'),
                const _FeatureItem('🍽️', 'foodomo'),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isBound ? null : onBind,
                    icon: Icon(isBound ? Icons.check : Icons.link, size: 12),
                    label: Text(isBound ? '已綁定' : '開始綁定', style: TextStyle(fontSize: 10)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isBound ? Colors.grey : Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                  ),
                ),
                if (isBound)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 14),
                        const SizedBox(width: 4),
                        const Text(
                          '外送平台已綁定',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 銀行帳戶步驟
class _BankStep extends StatelessWidget {
  final bool isBound;
  final VoidCallback onBind;

  const _BankStep({
    required this.isBound,
    required this.onBind,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.account_balance,
              size: 30,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '綁定銀行帳戶',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            '綁定銀行帳戶後，系統會自動分析您的消費記錄，智能計算相關碳足跡。',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Text(
                  '支援的服務：',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 6),
                const _FeatureItem('💳', '信用卡消費記錄'),
                const _FeatureItem('📱', '行動支付記錄'),
                const _FeatureItem('🏦', '各大銀行帳戶'),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isBound ? null : onBind,
                    icon: Icon(isBound ? Icons.check : Icons.link, size: 14),
                    label: Text(isBound ? '已綁定' : '開始綁定', style: TextStyle(fontSize: 11)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isBound ? Colors.grey : Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                if (isBound)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                        const SizedBox(width: 6),
                        const Text(
                          '銀行帳戶已綁定',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 完成步驟
class _CompleteStep extends StatelessWidget {
  final bool canComplete;
  final bool gpsEnabled;
  final bool eInvoiceBound;
  final bool foodDeliveryBound;
  final bool bankBound;

  const _CompleteStep({
    required this.canComplete,
    required this.gpsEnabled,
    required this.eInvoiceBound,
    required this.foodDeliveryBound,
    required this.bankBound,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: canComplete ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              canComplete ? Icons.check_circle : Icons.settings,
              size: 25,
              color: canComplete ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            canComplete ? '設置完成！' : '設置進度',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: canComplete ? Colors.green : Colors.orange,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            canComplete 
              ? '恭喜！您已成功完成所有設置。系統現在會自動偵測並追蹤您的碳足跡。'
              : '請完成以下設置項目才能開始使用自動偵測功能：',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: canComplete ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                Text(
                  canComplete ? '現在您可以：' : '設置狀態：',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: canComplete ? Colors.green : Colors.orange,
                  ),
                ),
                const SizedBox(height: 4),
                if (canComplete) ...[
                  const _FeatureItem('📊', '查看自動記錄的碳足跡'),
                  const _FeatureItem('📈', '查看統計圖表'),
                  const _FeatureItem('🎯', '設定環保目標'),
                  const _FeatureItem('🌱', '開始您的環保生活'),
                ] else ...[
                  _StatusItem('GPS定位', gpsEnabled, '🚗'),
                  _StatusItem('電子發票', eInvoiceBound, '🛒'),
                  _StatusItem('外送平台', foodDeliveryBound, '🍽️'),
                  _StatusItem('銀行帳戶', bankBound, '🏦'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 功能項目組件
class _FeatureItem extends StatelessWidget {
  final String icon;
  final String text;

  const _FeatureItem(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 9,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 狀態項目組件
class _StatusItem extends StatelessWidget {
  final String text;
  final bool isCompleted;
  final String icon;

  const _StatusItem(this.text, this.isCompleted, this.icon);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black87,
              ),
            ),
          ),
          Icon(
            isCompleted ? Icons.check_circle : Icons.cancel,
            color: isCompleted ? Colors.green : Colors.red,
            size: 12,
          ),
        ],
      ),
    );
  }
}

// 電子發票綁定對話框
class _EInvoiceBindingDialog extends StatefulWidget {
  @override
  State<_EInvoiceBindingDialog> createState() => _EInvoiceBindingDialogState();
}

class _EInvoiceBindingDialogState extends State<_EInvoiceBindingDialog> {
  final TextEditingController _mobileBarcodeController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _verificationCodeController = TextEditingController();
  bool _isBinding = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.receipt, color: Colors.orange),
          SizedBox(width: 8),
          Text('綁定電子發票'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('請輸入您的發票載具手機條碼、手機號碼和驗證碼來綁定電子發票服務'),
          SizedBox(height: 16),
          TextField(
            controller: _mobileBarcodeController,
            decoration: InputDecoration(
              labelText: '發票載具手機條碼',
              hintText: '例如：/ABC1234',
              prefixIcon: Icon(Icons.qr_code),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 12),
          TextField(
            controller: _phoneNumberController,
            decoration: InputDecoration(
              labelText: '手機號碼',
              hintText: '例如：0912345678',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 12),
          TextField(
            controller: _verificationCodeController,
            decoration: InputDecoration(
              labelText: '驗證碼',
              hintText: '請輸入6位數驗證碼',
              prefixIcon: Icon(Icons.lock),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            maxLength: 6,
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('支援的商店：', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• 全聯福利中心\n• 家樂福\n• 7-ELEVEN\n• 全家便利商店'),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('取消'),
        ),
        ElevatedButton(
          onPressed: _isBinding ? null : _performBinding,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: _isBinding 
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text('確認綁定'),
        ),
      ],
    );
  }

  Future<void> _performBinding() async {
    if (_mobileBarcodeController.text.isEmpty || 
        _phoneNumberController.text.isEmpty || 
        _verificationCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('請填寫完整資訊')),
      );
      return;
    }

    setState(() {
      _isBinding = true;
    });

    // 模擬綁定過程
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isBinding = false;
    });

    Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _mobileBarcodeController.dispose();
    _phoneNumberController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }
}

// 外送平台綁定對話框
class _FoodDeliveryBindingDialog extends StatefulWidget {
  @override
  State<_FoodDeliveryBindingDialog> createState() => _FoodDeliveryBindingDialogState();
}

class _FoodDeliveryBindingDialogState extends State<_FoodDeliveryBindingDialog> {
  final Map<String, TextEditingController> _emailControllers = {
    'Uber Eats': TextEditingController(),
    'Foodpanda': TextEditingController(),
    'foodomo': TextEditingController(),
    '有無外送': TextEditingController(),
  };
  final Map<String, TextEditingController> _passwordControllers = {
    'Uber Eats': TextEditingController(),
    'Foodpanda': TextEditingController(),
    'foodomo': TextEditingController(),
    '有無外送': TextEditingController(),
  };
  final Map<String, bool> _platformBindings = {
    'Uber Eats': false,
    'Foodpanda': false,
    'foodomo': false,
    '有無外送': false,
  };
  bool _isBinding = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.delivery_dining, color: Colors.purple),
          SizedBox(width: 8),
          Text('綁定外送平台'),
        ],
      ),
      content: Container(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            Text('請綁定您使用的外送平台，可同時綁定多個平台'),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _platformBindings.length,
                itemBuilder: (context, index) {
                  final platform = _platformBindings.keys.elementAt(index);
                  final isBound = _platformBindings[platform]!;
                  
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isBound ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isBound ? Colors.green : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isBound ? Icons.check_circle : Icons.delivery_dining,
                              color: isBound ? Colors.green : Colors.purple,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              platform,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isBound ? Colors.green : Colors.black87,
                              ),
                            ),
                            Spacer(),
                            if (isBound)
                              Text(
                                '已綁定',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                        if (!isBound) ...[
                          SizedBox(height: 8),
                          TextField(
                            controller: _emailControllers[platform],
                            decoration: InputDecoration(
                              labelText: '電子郵件',
                              hintText: '請輸入您的帳號',
                              prefixIcon: Icon(Icons.email, size: 16),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(fontSize: 12),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: _passwordControllers[platform],
                            decoration: InputDecoration(
                              labelText: '密碼',
                              hintText: '請輸入您的密碼',
                              prefixIcon: Icon(Icons.lock, size: 16),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                            obscureText: true,
                            style: TextStyle(fontSize: 12),
                          ),
                          SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isBinding ? null : () => _bindPlatform(platform),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 8),
                              ),
                              child: Text('綁定此平台', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('取消'),
        ),
        ElevatedButton(
          onPressed: _hasAnyBinding() ? () => Navigator.of(context).pop(true) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _hasAnyBinding() ? Colors.green : Colors.grey,
            foregroundColor: Colors.white,
          ),
          child: Text('完成綁定'),
        ),
      ],
    );
  }

  bool _hasAnyBinding() {
    return _platformBindings.values.any((isBound) => isBound);
  }

  Future<void> _bindPlatform(String platform) async {
    final emailController = _emailControllers[platform]!;
    final passwordController = _passwordControllers[platform]!;
    
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('請填寫$platform的完整資訊')),
      );
      return;
    }

    setState(() {
      _isBinding = true;
    });

    // 模擬綁定過程
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _platformBindings[platform] = true;
      _isBinding = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$platform 綁定成功！')),
    );
  }

  @override
  void dispose() {
    _emailControllers.values.forEach((controller) => controller.dispose());
    _passwordControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }
}

// 銀行帳戶綁定對話框
class _BankBindingDialog extends StatefulWidget {
  @override
  State<_BankBindingDialog> createState() => _BankBindingDialogState();
}

class _BankBindingDialogState extends State<_BankBindingDialog> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isBinding = false;
  String _selectedPaymentMethod = '行動支付';
  final Map<String, bool> _selectedPlatforms = {};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.payment, color: Colors.indigo),
          SizedBox(width: 8),
          Text('綁定行動支付'),
        ],
      ),
      content: Container(
        width: double.maxFinite,
        height: 500,
        child: Column(
          children: [
            Text('選擇支付方式偵測，避免與電子發票重疊'),
            SizedBox(height: 16),
            
            // 支付方式選擇
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '偵測方式選擇：',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  _buildPaymentMethodOption('電子發票', '偵測所有有開發票的消費', true),
                  _buildPaymentMethodOption('行動支付', '偵測LINE Pay、街口支付等', false),
                  _buildPaymentMethodOption('信用卡', '偵測信用卡消費記錄', false),
                ],
              ),
            ),
            
            SizedBox(height: 16),
            
            // 行動支付平台選擇
            if (_selectedPaymentMethod == '行動支付') ...[
              Text('選擇要綁定的行動支付平台：', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _getMobilePaymentPlatforms().length,
                  itemBuilder: (context, index) {
                    final platform = _getMobilePaymentPlatforms()[index];
                    return CheckboxListTile(
                      title: Text(platform),
                      subtitle: Text(_getPlatformDescription(platform)),
                      value: _selectedPlatforms[platform] ?? false,
                      onChanged: (value) {
                        setState(() {
                          _selectedPlatforms[platform] = value ?? false;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
            
            // 手機號碼輸入
            if (_selectedPaymentMethod != '電子發票') ...[
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: '手機號碼',
                  hintText: '請輸入您的手機號碼',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
            
            SizedBox(height: 12),
            
            // 說明文字
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '建議選擇一種主要偵測方式，避免重複計算碳足跡',
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
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('取消'),
        ),
        ElevatedButton(
          onPressed: _isBinding ? null : _performBinding,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
          child: _isBinding 
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text('確認綁定'),
        ),
      ],
    );
  }

  Future<void> _performBinding() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('請輸入手機號碼')),
      );
      return;
    }

    setState(() {
      _isBinding = true;
    });

    // 模擬綁定過程
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isBinding = false;
    });

    Navigator.of(context).pop(true);
  }

  Widget _buildPaymentMethodOption(String method, String description, bool isDefault) {
    return RadioListTile<String>(
      title: Text(method),
      subtitle: Text(description),
      value: method,
      groupValue: _selectedPaymentMethod,
      onChanged: (value) {
        setState(() {
          _selectedPaymentMethod = value!;
        });
      },
    );
  }

  List<String> _getMobilePaymentPlatforms() {
    return [
      'LINE Pay',
      '街口支付',
      '台灣Pay',
      'Pi拍錢包',
      '悠遊付',
      '一卡通MONEY',
      '全支付',
      'icash Pay',
      'Apple Pay',
      'Google Pay',
      'Samsung Pay',
    ];
  }

  String _getPlatformDescription(String platform) {
    switch (platform) {
      case 'LINE Pay':
        return 'LINE官方支付服務';
      case '街口支付':
        return '街口網路科技支付';
      case '台灣Pay':
        return '台灣行動支付';
      case 'Pi拍錢包':
        return '網路家庭支付';
      case '悠遊付':
        return '悠遊卡公司支付';
      case '一卡通MONEY':
        return '一卡通公司支付';
      case '全支付':
        return '全聯福利中心支付';
      case 'icash Pay':
        return '統一超商支付';
      case 'Apple Pay':
        return '蘋果支付服務';
      case 'Google Pay':
        return '谷歌支付服務';
      case 'Samsung Pay':
        return '三星支付服務';
      default:
        return '行動支付平台';
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
