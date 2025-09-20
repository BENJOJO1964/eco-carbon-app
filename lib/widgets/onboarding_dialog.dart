import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../l10n/app_localizations.dart';

class OnboardingDialog extends StatefulWidget {
  const OnboardingDialog({Key? key}) : super(key: key);

  @override
  State<OnboardingDialog> createState() => _OnboardingDialogState();
}

class _OnboardingDialogState extends State<OnboardingDialog> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.gps_fixed,
      title: 'GPS自動定位',
      description: '開啟GPS定位後，系統會自動追蹤您的移動軌跡，智能識別交通工具（開車、騎車、步行），並自動計算交通碳足跡。',
      benefits: [
        '🚗 自動記錄開車距離和碳足跡',
        '🚴 識別騎車和步行活動',
        '📍 精確計算移動距離',
        '⚡ 節省手動輸入時間',
      ],
    ),
    OnboardingPage(
      icon: Icons.receipt,
      title: '電子發票整合',
      description: '綁定電子發票後，系統會自動讀取您的購物記錄，識別商品類型，並根據商品碳足跡係數自動計算購物碳足跡。',
      benefits: [
        '🛒 自動記錄全聯、家樂福等購物',
        '📱 識別商品類型和碳足跡',
        '🧾 整合財政部電子發票平台',
        '💰 根據消費金額自動計算',
      ],
    ),
    OnboardingPage(
      icon: Icons.delivery_dining,
      title: '外送平台整合',
      description: '綁定外送平台帳號後，系統會自動獲取您的訂餐記錄，識別食物類型，並根據食物碳足跡係數自動計算飲食碳足跡。',
      benefits: [
        '🍽️ 自動記錄Uber Eats、Foodpanda訂餐',
        '🍔 識別食物類型和碳足跡',
        '🏪 整合各大外送平台',
        '📦 包含包裝材料碳足跡',
      ],
    ),
    OnboardingPage(
      icon: Icons.smartphone,
      title: '智能設備監控',
      description: '系統會智能監控您的設備使用情況，包括用電設備、電子產品使用時間等，自動計算相關碳足跡。',
      benefits: [
        '⚡ 監控空調、冰箱等用電設備',
        '📱 追蹤手機、筆電使用時間',
        '🏠 智能家居設備整合',
        '🔋 節能建議和提醒',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // 標題欄
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.eco, color: Colors.white, size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '智能碳足跡追蹤',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
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
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            
            // 頁面指示器
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            
            // 按鈕
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text('上一頁'),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(_currentPage < _pages.length - 1 ? '下一頁' : '開始使用'),
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

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 圖標
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                page.icon,
                size: 40,
                color: Colors.green,
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // 標題
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 20),
          
          // 描述
          Text(
            page.description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 30),
          
          // 功能列表
          Text(
            '主要功能：',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 15),
          
          Expanded(
            child: ListView.builder(
              itemCount: page.benefits.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          page.benefits[index],
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final List<String> benefits;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.benefits,
  });
}
