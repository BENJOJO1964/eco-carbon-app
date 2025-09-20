import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'services/language_service.dart';
import 'services/auto_detection_service.dart';
import 'services/onboarding_service.dart';
import 'services/api_binding_service.dart';
import 'widgets/api_binding_dialog.dart';
import 'widgets/gps_prompt_banner.dart';
import 'widgets/progressive_setup_dialog.dart';
import 'widgets/invoice_scanner_dialog.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => LanguageService(),
      child: const EcoApp(),
    ),
  );
}

class EcoApp extends StatelessWidget {
  const EcoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return MaterialApp(
          title: 'Eco - 碳足迹追踪',
          locale: languageService.currentLocale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: LanguageService.supportedLocales,
          // 強制重新構建應用程式
          key: ValueKey(languageService.currentLocale.toString()),
          theme: ThemeData(
            primarySwatch: Colors.green,
            primaryColor: Colors.green,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.green,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            cardTheme: CardThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  double _totalCarbonFootprint = 0.0;
  final List<Map<String, dynamic>> _records = [];
  final AutoDetectionService _autoDetectionService = AutoDetectionService();
  final OnboardingService _onboardingService = OnboardingService();
  final APIBindingService _apiBindingService = APIBindingService();
  bool _autoDetectionEnabled = false;
  bool _gpsPermissionGranted = false;
  bool _showGPSPrompt = false;
  bool _eInvoiceBound = false;

  @override
  void initState() {
    super.initState();
    // 檢查是否需要顯示引導流程
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOnboarding();
      _loadGPSState();
    });
  }

  // 載入GPS狀態
  Future<void> _loadGPSState() async {
    final gpsEnabled = await _onboardingService.isGPSEnabled();
    final autoDetectionEnabled = await _onboardingService.isAutoDetectionEnabled();
    final eInvoiceBound = await _apiBindingService.isEInvoiceBound();
    
    setState(() {
      _gpsPermissionGranted = gpsEnabled;
      _autoDetectionEnabled = autoDetectionEnabled;
      _eInvoiceBound = eInvoiceBound;
    });
    
    // 如果GPS已啟用，啟動自動偵測
    if (autoDetectionEnabled) {
      _autoDetectionService.startAutoDetection();
    }
  }

  Future<void> _checkOnboarding() async {
    // 不再顯示設置精靈，直接顯示GPS提示橫幅
    if (!_autoDetectionEnabled) {
      setState(() {
        _showGPSPrompt = true;
      });
    }
  }

  Future<void> _checkAndPromptAPIBinding() async {
    final hasAnyService = await _apiBindingService.hasAnyServiceBound();
    
    if (!hasAnyService) {
      // 顯示API綁定提示
      await _showAPIBindingPrompt();
    }
  }

  Future<void> _showAPIBindingPrompt() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.link, color: Color(0xFF00E676)),
            SizedBox(width: 10),
            Text('完成自動偵測設置'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '為了實現完整的自動偵測功能，建議您綁定以下服務：',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            _buildServiceItem('🧾', '電子發票', '自動記錄購物碳足跡'),
            _buildServiceItem('🍽️', '外送平台', '自動記錄飲食碳足跡'),
            _buildServiceItem('🏦', '銀行帳戶', '自動分析消費碳足跡'),
            const SizedBox(height: 16),
            const Text(
              '您可以稍後在設置中綁定這些服務。',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('稍後再說'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showAPIBindingDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
              foregroundColor: Colors.white,
            ),
            child: const Text('立即綁定'),
          ),
        ],
      ),
    );
  }

  static Widget _buildServiceItem(String icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAPIBindingDialog() async {
    final unboundServices = await _apiBindingService.getUnboundServices();
    
    if (unboundServices.isNotEmpty) {
      final serviceType = unboundServices.first;
      await showDialog(
        context: context,
        builder: (context) => APIBindingDialog(
          serviceType: serviceType,
          onBindingComplete: () async {
            // 綁定完成後，綁定下一個服務
            await _bindNextService();
          },
        ),
      );
    }
  }

  Future<void> _bindNextService() async {
    final unboundServices = await _apiBindingService.getUnboundServices();
    
    if (unboundServices.isNotEmpty) {
      // 繼續綁定下一個服務
      await _showAPIBindingDialog();
    } else {
      // 所有服務都已綁定
      await _showAllServicesBoundMessage();
    }
  }

  Future<void> _showAllServicesBoundMessage() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text('設置完成！'),
          ],
        ),
        content: const Text(
          '所有服務已成功綁定！\n\n系統現在會自動偵測您的：\n• 交通碳足跡（GPS定位）\n• 購物碳足跡（電子發票）\n• 飲食碳足跡（外送平台）\n• 消費碳足跡（銀行帳戶）',
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

  Future<void> _toggleGPSDetection() async {
    if (!_autoDetectionEnabled) {
      // 開啟GPS偵測
      if (!_gpsPermissionGranted) {
        // 第一次開啟，需要請求權限
        final gpsAllowed = await _onboardingService.showGPSPermissionDialog(context);
        if (!gpsAllowed) {
          return; // 用戶拒絕權限，不開啟
        }
        _gpsPermissionGranted = true;
        await _onboardingService.setGPSEnabled(true);
        await _onboardingService.showFeatureIntroduction(context, 'gps');
      }
      
      setState(() {
        _autoDetectionEnabled = true;
        _showGPSPrompt = false; // 隱藏GPS提示橫幅
      });
      
      // 保存狀態到SharedPreferences
      await _onboardingService.setAutoDetectionEnabled(true);
      
      _autoDetectionService.startAutoDetection();
      _startAutoDetectionTimer();
    } else {
      // 關閉GPS偵測
      setState(() {
        _autoDetectionEnabled = false;
      });
      
      // 保存狀態到SharedPreferences
      await _onboardingService.setAutoDetectionEnabled(false);
      
      _autoDetectionService.stopAutoDetection();
    }
  }


  Future<void> _showProgressiveSetup(String step) async {
    await showDialog(
      context: context,
      builder: (context) => ProgressiveSetupDialog(
        currentStep: step,
        initialGPSState: _autoDetectionEnabled,
        onComplete: () async {
          if (step == 'gps') {
            // 真正開啟GPS功能
            setState(() {
              _autoDetectionEnabled = true;
            });
            await _toggleGPSDetection();
          }
          setState(() {}); // 刷新狀態
        },
      ),
    );
  }

  void _startAutoDetectionTimer() {
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_autoDetectionEnabled) {
        timer.cancel();
        return;
      }
      
      final detectedActivities = _autoDetectionService.getDetectedActivities();
      if (detectedActivities.isNotEmpty) {
        setState(() {
          for (final activity in detectedActivities) {
            _records.add({
              'type': activity['type'],
              'amount': activity['amount'] is String ? double.parse(activity['amount']) : activity['amount'],
              'unit': activity['unit'],
              'carbonFootprint': activity['carbonFootprint'] is String ? double.parse(activity['carbonFootprint']) : activity['carbonFootprint'],
              'emoji': activity['emoji'],
              'color': _getColorForType(activity['type']),
              'timestamp': activity['timestamp'],
              'autoDetected': true,
              'description': activity['description'],
            });
            _totalCarbonFootprint += activity['carbonFootprint'] is String ? double.parse(activity['carbonFootprint']) : activity['carbonFootprint'];
          }
          _autoDetectionService.clearProcessedActivities();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        backgroundColor: const Color(0xFF1A4D3A), // 深綠色科技感
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A4D3A), // 深綠色
                Color(0xFF2D5A47), // 中綠色
                Color(0xFF4A7C59), // 淺綠色
              ],
            ),
          ),
        ),
        actions: [
          // 自動偵測開關
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _autoDetectionEnabled ? 'GPS開啟' : 'GPS關閉',
                style: TextStyle(
                  color: _autoDetectionEnabled ? Colors.white : Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  shadows: _autoDetectionEnabled ? [
                    const Shadow(
                      color: Colors.greenAccent,
                      blurRadius: 4,
                    ),
                  ] : null,
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: _autoDetectionEnabled,
                onChanged: (value) async {
                  await _toggleGPSDetection();
                },
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF00E676), // 科技綠色
                inactiveThumbColor: Colors.grey.shade400,
                inactiveTrackColor: Colors.grey.shade600,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
          const SizedBox(width: 8),
          // 語言切換
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: (String value) {
              final languageService = Provider.of<LanguageService>(context, listen: false);
              final parts = value.split('_');
              final locale = parts.length == 2 
                  ? Locale(parts[0], parts[1])
                  : Locale(parts[0]);
              languageService.changeLanguage(locale);
            },
            itemBuilder: (BuildContext context) {
              final languageService = Provider.of<LanguageService>(context, listen: false);
              return languageService.languageOptions.map((option) {
                return PopupMenuItem<String>(
                  value: option['code'],
                  child: Text(option['name']),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F8F0), // 淺綠色背景
              Color(0xFFE8F5E8), // 更淺的綠色
              Color(0xFFF5F5F5), // 接近白色
            ],
          ),
        ),
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeTab(),
            _buildAddRecordTab(),
            _buildRecordListTab(),
            _buildStatisticsTab(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F8F0),
              Color(0xFFE8F5E8),
            ],
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xFF00E676),
          unselectedItemColor: Colors.grey.shade600,
          elevation: 0,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: AppLocalizations.of(context)!.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add),
            label: AppLocalizations.of(context)!.addRecord,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.list),
            label: AppLocalizations.of(context)!.recordList,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart),
            label: AppLocalizations.of(context)!.statistics,
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GPS提示橫幅
          if (_showGPSPrompt)
            GPSPromptBanner(
              onEnableGPS: () async {
                await _toggleGPSDetection();
              },
              onDismiss: () {
                setState(() {
                  _showGPSPrompt = false;
                });
              },
            ),
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE8F5E8), // 淺綠色
                    Color(0xFFD4EDDA), // 中淺綠色
                    Color(0xFFC3E6CB), // 淺綠色
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.todayCarbonFootprint,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A4D3A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_totalCarbonFootprint.toStringAsFixed(2)} ${l10n.kgCO2}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00E676), // 科技綠色
                      shadows: [
                        Shadow(
                          color: Colors.greenAccent,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 發票載具綁定卡片（當GPS已啟用但電子發票未綁定時顯示）
          if (_autoDetectionEnabled && !_eInvoiceBound)
            _buildInvoiceCarrierCard(),
          
          // GPS狀態指示器
          if (!_autoDetectionEnabled)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.gps_off,
                    color: Colors.orange.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GPS自動追蹤未開啟',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '開啟GPS可自動偵測交通碳足跡',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await _showProgressiveSetup('gps');
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.orange.shade100,
                      foregroundColor: Colors.orange.shade700,
                    ),
                    child: const Text('設定'),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Text(
            l10n.quickAdd,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // 快速添加卡片
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3.6, // 調整為現在高度的3分之1 (1.2 * 3 = 3.6)
            children: [
              _buildQuickAddCard('🚗', l10n.transportation, Colors.blue),
              _buildQuickAddCard('🛒', l10n.shopping, Colors.orange),
              _buildQuickAddCard('⚡', l10n.electricity, Colors.yellow),
              _buildQuickAddCard('🍽️', l10n.diet, Colors.red),
              _buildQuickAddCard('🏠', '居家', Colors.purple),
              _buildQuickAddCard('✈️', '旅行', Colors.teal),
              _buildQuickAddCard('👕', '服飾', Colors.pink),
              _buildQuickAddCard('📱', '電子產品', Colors.indigo),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddCard(String emoji, String title, Color color) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showAddDialog(title),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.15),
                color.withOpacity(0.25),
                color.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddRecordTab() {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_circle_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.clickPlusToAdd,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecordListTab() {
    final l10n = AppLocalizations.of(context)!;

    if (_records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.list_alt,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noRecords,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.clickToAddFirstRecord,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _records.length,
      itemBuilder: (context, index) {
        final record = _records[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: record['color'].withOpacity(0.2),
              child: Text(
                record['emoji'],
                style: const TextStyle(fontSize: 20),
              ),
            ),
            title: Row(
              children: [
                Text(record['type']),
                if (record['autoDetected'] == true) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '自動',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record['description'] ?? '${record['amount']} ${record['unit']}'),
                if (record['autoDetected'] == true) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (record['invoiceNumber'] != null) ...[
                        const Icon(Icons.receipt, size: 12, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text('發票: ${record['invoiceNumber']}', style: const TextStyle(fontSize: 10, color: Colors.blue)),
                      ],
                      if (record['orderNumber'] != null) ...[
                        const Icon(Icons.delivery_dining, size: 12, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text('訂單: ${record['orderNumber']}', style: const TextStyle(fontSize: 10, color: Colors.orange)),
                      ],
                      if (record['transportMode'] != null) ...[
                        const Icon(Icons.directions_car, size: 12, color: Colors.green),
                        const SizedBox(width: 4),
                        Text('${record['transportMode']}', style: const TextStyle(fontSize: 10, color: Colors.green)),
                      ],
                    ],
                  ),
                ],
              ],
            ),
            trailing: Text(
              '${record['carbonFootprint'].toStringAsFixed(2)} ${l10n.kgCO2}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatisticsTab() {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.statisticsInfo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        l10n.totalRecords,
                        '${_records.length}',
                        Icons.list_alt,
                        Colors.blue,
                      ),
                      _buildStatItem(
                        l10n.totalCarbonFootprint,
                        '${_totalCarbonFootprint.toStringAsFixed(2)} ${l10n.kgCO2}',
                        Icons.eco,
                        Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.ecoAdvice,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.reduceCarbonTips,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.tip1),
                  Text(l10n.tip2),
                  Text(l10n.tip3),
                  Text(l10n.tip4),
                  Text(l10n.tip5),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // 顯示購物選項（發票掃描或手動輸入）
  void _showShoppingOptions() {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.shopping_cart, color: Colors.orange),
              SizedBox(width: 8),
              Text('購物碳足跡記錄'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '選擇記錄方式：',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 20),
              
              // 傳統發票掃描選項
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  _showInvoiceScanner();
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(Icons.qr_code_scanner, color: Colors.green, size: 24),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '傳統發票掃描',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              '掃描紙本發票，AI識別商品和碳足跡',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.green, size: 16),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 12),
              
              // 手動輸入選項
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  _showManualShoppingInput();
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(Icons.edit, color: Colors.orange, size: 24),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '手動輸入',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            Text(
                              '手動輸入購物金額和商品資訊',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.orange, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('取消'),
            ),
          ],
        );
      },
    );
  }

  // 顯示發票掃描器
  void _showInvoiceScanner() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return InvoiceScannerDialog(
          onScanComplete: (scanResult) {
            // 將掃描結果添加到記錄中
            _addScannedInvoiceRecord(scanResult);
          },
        );
      },
    );
  }

  // 顯示手動購物輸入
  void _showManualShoppingInput() {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final amountController = TextEditingController();
        final storeController = TextEditingController();
        double estimatedCarbon = 0.0;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('手動輸入購物記錄'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: storeController,
                    decoration: InputDecoration(
                      labelText: '商店名稱',
                      hintText: '例如：7-ELEVEN、全聯福利中心',
                      prefixIcon: Icon(Icons.store),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(
                      labelText: '購物金額',
                      hintText: '輸入金額',
                      suffixText: '元',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final amount = double.tryParse(value) ?? 0.0;
                      estimatedCarbon = _calculateCarbonFootprint(l10n.shopping, amount, l10n);
                      setState(() {});
                    },
                  ),
                  SizedBox(height: 16),
                  if (estimatedCarbon > 0)
                    Text(
                      '預估碳足跡: ${estimatedCarbon.toStringAsFixed(2)} kg CO2',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text);
                    final store = storeController.text.trim();
                    if (amount != null && amount > 0 && store.isNotEmpty) {
                      _addManualShoppingRecord(store, amount, estimatedCarbon, l10n);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('確認'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 添加掃描的發票記錄
  void _addScannedInvoiceRecord(Map<String, dynamic> scanResult) {
    final l10n = AppLocalizations.of(context)!;
    
    final record = {
      'type': l10n.shopping,
      'emoji': '🧾',
      'description': '${scanResult['store']}購物',
      'amount': scanResult['totalAmount'].toString(),
      'unit': '元',
      'carbonFootprint': scanResult['carbonFootprint'],
      'timestamp': DateTime.now(),
      'autoDetected': false,
      'source': '發票掃描',
      'invoiceNumber': scanResult['invoiceNumber'],
      'items': scanResult['items'],
      'store': scanResult['store'],
      'scanQuality': scanResult['scanQuality'],
    };
    
    setState(() {
      _records.add(record);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ 發票掃描完成！已記錄 ${scanResult['items'].length} 項商品'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // 添加手動購物記錄
  void _addManualShoppingRecord(String store, double amount, double carbonFootprint, AppLocalizations l10n) {
    final record = {
      'type': l10n.shopping,
      'emoji': '🛒',
      'description': '$store購物',
      'amount': amount.toString(),
      'unit': '元',
      'carbonFootprint': carbonFootprint,
      'timestamp': DateTime.now(),
      'autoDetected': false,
      'source': '手動輸入',
      'store': store,
    };
    
    setState(() {
      _records.add(record);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ 購物記錄已添加！'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showAddDialog(String type) {
    final l10n = AppLocalizations.of(context)!;
    
    // 如果是購物類型，顯示發票掃描選項
    if (type == l10n.shopping) {
      _showShoppingOptions();
      return;
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final amountController = TextEditingController();
        double estimatedCarbon = 0.0;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.addCarbonRecord),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${l10n.type}: $type'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(
                      labelText: _getAmountLabel(type, l10n),
                      hintText: _getAmountHint(type, l10n),
                      suffixText: _getAmountUnit(type, l10n),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final amount = double.tryParse(value) ?? 0.0;
                      estimatedCarbon = _calculateCarbonFootprint(type, amount, l10n);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  if (estimatedCarbon > 0)
                    Text(
                      '${l10n.estimatedCarbonFootprint}: ${estimatedCarbon.toStringAsFixed(2)} ${l10n.kgCO2}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text);
                    if (amount != null && amount > 0) {
                      _addRecord(type, amount, estimatedCarbon, l10n);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(l10n.add),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getAmountLabel(String type, AppLocalizations l10n) {
    switch (type) {
      case '交通':
      case 'Transportation':
        return l10n.distance;
      case '購物':
      case 'Shopping':
        return l10n.amount_money;
      case '用電':
      case 'Electricity':
        return l10n.electricity_usage;
      case '飲食':
      case 'Diet':
        return l10n.food_weight;
      case '居家':
        return '居家活動';
      case '旅行':
        return '旅行距離';
      case '服飾':
        return '服飾件數';
      case '電子產品':
        return '使用時數';
      default:
        return l10n.amount;
    }
  }

  String _getAmountHint(String type, AppLocalizations l10n) {
    switch (type) {
      case '交通':
      case 'Transportation':
        return '10';
      case '購物':
      case 'Shopping':
        return '100';
      case '用電':
      case 'Electricity':
        return '50';
      case '飲食':
      case 'Diet':
        return '1.5';
      case '居家':
        return '2';
      case '旅行':
        return '500';
      case '服飾':
        return '3';
      case '電子產品':
        return '8';
      default:
        return '1';
    }
  }

  String _getAmountUnit(String type, AppLocalizations l10n) {
    switch (type) {
      case '交通':
      case 'Transportation':
        return 'km';
      case '購物':
      case 'Shopping':
        return 'NTD';
      case '用電':
      case 'Electricity':
        return 'kWh';
      case '飲食':
      case 'Diet':
        return 'kg';
      case '居家':
        return '次';
      case '旅行':
        return 'km';
      case '服飾':
        return '件';
      case '電子產品':
        return '小時';
      default:
        return '';
    }
  }

  double _calculateCarbonFootprint(String type, double amount, AppLocalizations l10n) {
    // 簡化的碳足跡計算公式
    switch (type) {
      case '交通':
      case 'Transportation':
        return amount * 0.2; // 每公里約0.2kg CO2
      case '購物':
      case 'Shopping':
        return amount * 0.01; // 每元約0.01kg CO2
      case '用電':
      case 'Electricity':
        return amount * 0.5; // 每kWh約0.5kg CO2
      case '飲食':
      case 'Diet':
        return amount * 2.0; // 每公斤約2kg CO2
      case '居家':
        return amount * 0.5; // 每次居家活動約0.5kg CO2
      case '旅行':
        return amount * 0.3; // 每公里約0.3kg CO2
      case '服飾':
        return amount * 1.5; // 每件服飾約1.5kg CO2
      case '電子產品':
        return amount * 0.1; // 每小時約0.1kg CO2
      default:
        return amount * 0.1;
    }
  }

  void _addRecord(String type, double amount, double carbonFootprint, AppLocalizations l10n) {
    setState(() {
      _records.add({
        'type': type,
        'amount': amount,
        'unit': _getAmountUnit(type, l10n),
        'carbonFootprint': carbonFootprint,
        'emoji': _getEmojiForType(type),
        'color': _getColorForType(type),
        'timestamp': DateTime.now(),
      });
      _totalCarbonFootprint += carbonFootprint;
    });
  }

  String _getEmojiForType(String type) {
    switch (type) {
      case '交通':
      case 'Transportation':
        return '🚗';
      case '購物':
      case 'Shopping':
        return '🛒';
      case '用電':
      case 'Electricity':
        return '⚡';
      case '飲食':
      case 'Diet':
        return '🍽️';
      case '居家':
        return '🏠';
      case '旅行':
        return '✈️';
      case '服飾':
        return '👕';
      case '電子產品':
        return '📱';
      default:
        return '📊';
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case '交通':
      case 'Transportation':
        return Colors.blue;
      case '購物':
      case 'Shopping':
        return Colors.orange;
      case '用電':
      case 'Electricity':
        return Colors.yellow;
      case '飲食':
      case 'Diet':
        return Colors.red;
      case '居家':
        return Colors.purple;
      case '旅行':
        return Colors.teal;
      case '服飾':
        return Colors.pink;
      case '電子產品':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  // 發票載具綁定卡片
  Widget _buildInvoiceCarrierCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF3E0), // 淺橙色
            Color(0xFFFFE0B2), // 中淺橙色
            Color(0xFFFFCC80), // 淺橙色
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF9800),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 標題行
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: Color(0xFFFF9800),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '綁定發票載具',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE65100),
                      ),
                    ),
                    const Text(
                      '自動偵測購物碳足跡',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 功能說明
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '綁定後可以自動偵測：',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE65100),
                  ),
                ),
                const SizedBox(height: 8),
                _buildFeatureItem('🛒', '全聯、家樂福等購物記錄'),
                _buildFeatureItem('🧾', '自動識別商品和碳足跡'),
                _buildFeatureItem('📱', '整合財政部電子發票平台'),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 按鈕
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _eInvoiceBound = true; // 暫時設為已綁定，隱藏卡片
                    });
                  },
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
                  onPressed: () async {
                    // 顯示發票載具綁定對話框
                    await _showInvoiceCarrierBindingDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('立即綁定'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 發票載具綁定對話框
  Future<void> _showInvoiceCarrierBindingDialog() async {
    final phoneController = TextEditingController();
    final barcodeController = TextEditingController();
    final verificationController = TextEditingController();
    bool isLoading = false;
    bool verificationSent = false;
    int countdown = 0;
    Timer? countdownTimer;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.receipt_long, color: Color(0xFFFF9800)),
                SizedBox(width: 8),
                Text('綁定發票載具'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '請輸入您的發票載具條碼和手機號碼，我們將發送驗證碼到您的手機。',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                // 發票載具手機條碼（移到第一位）
                TextField(
                  controller: barcodeController,
                  decoration: const InputDecoration(
                    labelText: '發票載具手機條碼',
                    prefixIcon: Icon(Icons.qr_code),
                    border: OutlineInputBorder(),
                    hintText: '例如：/ABC1234',
                  ),
                ),
                const SizedBox(height: 12),
                // 手機號碼（移到第二位）
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: '手機號碼',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    // 當手機號碼輸入完成且長度正確時，自動發送驗證碼
                    if (value.length == 10 && !verificationSent) {
                      setState(() {
                        verificationSent = true;
                        countdown = 60; // 60秒倒計時
                      });
                      
                      // 模擬發送驗證碼
                      print('📱 發送驗證碼到: $value');
                      
                      // 開始倒計時
                      countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
                        setState(() {
                          countdown--;
                          if (countdown <= 0) {
                            timer.cancel();
                          }
                        });
                      });
                      
                      // 顯示成功提示
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✅ 驗證碼已發送至 $value'),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
                // 驗證碼欄位
                TextField(
                  controller: verificationController,
                  decoration: InputDecoration(
                    labelText: '驗證碼',
                    prefixIcon: const Icon(Icons.security),
                    border: const OutlineInputBorder(),
                    hintText: verificationSent 
                      ? '請輸入6位數驗證碼' 
                      : '請先輸入手機號碼',
                    suffixIcon: verificationSent && countdown > 0
                      ? TextButton(
                          onPressed: null,
                          child: Text('${countdown}s'),
                        )
                      : verificationSent
                        ? TextButton(
                            onPressed: () {
                              setState(() {
                                countdown = 60; // 重新開始倒計時
                              });
                              
                              // 重新開始倒計時
                              countdownTimer?.cancel();
                              countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
                                setState(() {
                                  countdown--;
                                  if (countdown <= 0) {
                                    timer.cancel();
                                  }
                                });
                              });
                              
                              // 顯示重新發送提示
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('✅ 驗證碼已重新發送至 ${phoneController.text}'),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: const Text('重新發送'),
                          )
                        : null,
                  ),
                  keyboardType: TextInputType.number,
                  enabled: verificationSent,
                ),
                // 驗證碼發送狀態提示
                if (verificationSent)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '驗證碼已發送至 ${phoneController.text}，請查收簡訊',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
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
              onPressed: isLoading ? null : () async {
                if (barcodeController.text.isEmpty || 
                    phoneController.text.isEmpty || 
                    verificationController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('請填寫所有欄位')),
                  );
                  return;
                }
                
                if (!verificationSent) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('請先輸入手機號碼以發送驗證碼')),
                  );
                  return;
                }
                
                if (verificationController.text.length != 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('請輸入6位數驗證碼')),
                  );
                  return;
                }

                setState(() => isLoading = true);
                
                // 模擬綁定過程
                await Future.delayed(const Duration(seconds: 2));
                
                setState(() {
                  _eInvoiceBound = true;
                });
                
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ 發票載具綁定成功！開始自動偵測購物碳足跡'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
                foregroundColor: Colors.white,
              ),
              child: isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('綁定'),
            ),
          ],
        ),
      ),
    );
  }


  // 功能項目建構器
  Widget _buildFeatureItem(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
