import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'services/language_service.dart';
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            cardTheme: CardThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.green, width: 2),
              ),
            ),
          ),
          home: const HomeScreen(),
          debugShowCheckedModeBanner: false,
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
  int _currentIndex = 0;
  final List<Map<String, dynamic>> _records = [];
  double _totalCarbonFootprint = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateTotalCarbonFootprint();
  }

  void _calculateTotalCarbonFootprint() {
    _totalCarbonFootprint = 0.0;
    for (var record in _records) {
      _totalCarbonFootprint += record['carbonFootprint'] ?? 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.appTitle ?? 'Eco - 碳足迹追踪'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: (String languageCode) {
              print('Language selected: $languageCode');
              final languageService = Provider.of<LanguageService>(context, listen: false);
              final parts = languageCode.split('_');
              final locale = parts.length == 2 
                  ? Locale(parts[0], parts[1])
                  : Locale(parts[0], '');
              print('Creating locale: $locale');
              languageService.changeLanguage(locale);
            },
            itemBuilder: (BuildContext context) {
              final languageService = Provider.of<LanguageService>(context, listen: false);
              return languageService.languageOptions.map((option) {
                return PopupMenuItem<String>(
                  value: option['code'],
                  child: Row(
                    children: [
                      if (languageService.currentLocale == option['locale'])
                        const Icon(Icons.check, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(option['name']),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: l10n?.home ?? '首頁',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add),
            label: l10n?.addRecord ?? '添加記錄',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.list),
            label: l10n?.recordList ?? '記錄列表',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart),
            label: l10n?.statistics ?? '統計',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRecordDialog(),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildAddRecordTab();
      case 2:
        return _buildRecordsTab();
      case 3:
        return _buildStatsTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    final l10n = AppLocalizations.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 今日碳足跡卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.todayCarbonFootprint ?? '今日碳足跡',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_totalCarbonFootprint.toStringAsFixed(2)} ${l10n?.kgCO2 ?? 'kg CO₂'}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // 快速添加標題
          Text(
            l10n?.quickAdd ?? '快速添加',
            style: const TextStyle(
              fontSize: 20,
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
            childAspectRatio: 1.5,
            children: [
              _buildQuickAddCard('🚗', l10n?.transportation ?? '交通', Colors.blue),
              _buildQuickAddCard('🛒', l10n?.shopping ?? '購物', Colors.orange),
              _buildQuickAddCard('⚡', l10n?.electricity ?? '用電', Colors.yellow),
              _buildQuickAddCard('🍽️', l10n?.diet ?? '飲食', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddCard(String emoji, String title, Color color) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _showAddRecordDialog(type: title),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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
    final l10n = AppLocalizations.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.add_circle_outline,
            size: 80,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          Text(
            l10n?.clickPlusToAdd ?? '點擊右下角 "+" 按鈕添加您的第一筆碳足跡記錄！',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsTab() {
    final l10n = AppLocalizations.of(context);
    
    if (_records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.list_alt,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              '${l10n?.noRecords ?? '沒有記錄'}\n${l10n?.clickToAddFirstRecord ?? '點擊 "+" 添加您的第一筆記錄！'}',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
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
            leading: const Icon(Icons.eco, color: Colors.green),
            title: Text(record['type'] ?? ''),
            subtitle: Text(record['description'] ?? ''),
            trailing: Text(
              '${record['carbonFootprint']?.toStringAsFixed(2) ?? '0.00'} ${l10n?.kgCO2 ?? 'kg CO₂'}',
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

  Widget _buildStatsTab() {
    final l10n = AppLocalizations.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.statisticsInfo ?? '碳足跡統計信息',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(l10n?.totalRecords ?? '總記錄數', '${_records.length}'),
                      ),
                      Expanded(
                        child: _buildStatItem(l10n?.totalCarbonFootprint ?? '總碳足跡',
                            '${_totalCarbonFootprint.toStringAsFixed(2)} ${l10n?.kgCO2 ?? 'kg CO₂'}'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // 環保建議
          Text(
            l10n?.ecoAdvice ?? '環保建議',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.reduceCarbonTips ?? '減少碳足跡小貼士：',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(l10n?.tip1 ?? '1. 多步行、騎自行車或搭乘公共交通工具。'),
                  Text(l10n?.tip2 ?? '2. 減少購買不必要的商品，選擇環保產品。'),
                  Text(l10n?.tip3 ?? '3. 節約用電，隨手關燈，拔掉不用的電器插頭。'),
                  Text(l10n?.tip4 ?? '4. 減少肉類消費，多吃蔬菜水果。'),
                  Text(l10n?.tip5 ?? '5. 支持可再生能源，參與環保活動。'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  void _showAddRecordDialog({String? type}) {
    final l10n = AppLocalizations.of(context);
    String selectedType = type ?? l10n?.transportation ?? '交通';
    final amountController = TextEditingController();
    double carbonFootprint = 0.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(l10n?.addCarbonRecord ?? '添加碳足跡記錄'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(labelText: l10n?.type ?? '類型'),
                  items: [
                    DropdownMenuItem(value: l10n?.transportation ?? '交通', child: Text(l10n?.transportation ?? '交通')),
                    DropdownMenuItem(value: l10n?.shopping ?? '購物', child: Text(l10n?.shopping ?? '購物')),
                    DropdownMenuItem(value: l10n?.electricity ?? '用電', child: Text(l10n?.electricity ?? '用電')),
                    DropdownMenuItem(value: l10n?.diet ?? '飲食', child: Text(l10n?.diet ?? '飲食')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                      carbonFootprint = _calculateCarbonFootprint(selectedType, double.tryParse(amountController.text) ?? 0);
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: _getAmountLabel(selectedType, l10n),
                    hintText: _getAmountHint(selectedType, l10n),
                  ),
                  onChanged: (value) {
                    setState(() {
                      carbonFootprint = _calculateCarbonFootprint(selectedType, double.tryParse(value) ?? 0);
                    });
                  },
                ),
                if (carbonFootprint > 0) ...[
                  const SizedBox(height: 16),
                  Text(
                    '${l10n?.estimatedCarbonFootprint ?? '預計碳足跡'}: ${carbonFootprint.toStringAsFixed(2)} ${l10n?.kgCO2 ?? 'kg CO₂'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n?.cancel ?? '取消'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (amountController.text.isNotEmpty) {
                    setState(() {
                      _records.add({
                        'type': selectedType,
                        'amount': double.tryParse(amountController.text) ?? 0,
                        'carbonFootprint': carbonFootprint,
                        'description': '${selectedType}: ${amountController.text}${_getAmountUnit(selectedType, l10n)}',
                        'date': DateTime.now(),
                      });
                      _calculateTotalCarbonFootprint();
                    });
                    Navigator.of(context).pop();
                  }
                },
                child: Text(l10n?.add ?? '添加'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getAmountLabel(String type, AppLocalizations? l10n) {
    if (type == l10n?.shopping) return '金額 (元)';
    if (type == l10n?.electricity) return '用電量 (kWh)';
    if (type == l10n?.diet) return '食物重量 (公斤)';
    return l10n?.distance ?? '距離 (公里)';
  }

  String _getAmountHint(String type, AppLocalizations? l10n) {
    if (type == l10n?.shopping) return '輸入購物金額';
    if (type == l10n?.electricity) return '輸入用電量';
    if (type == l10n?.diet) return '輸入食物重量';
    return '輸入距離';
  }

  String _getAmountUnit(String type, AppLocalizations? l10n) {
    if (type == l10n?.shopping) return ' 元';
    if (type == l10n?.electricity) return ' kWh';
    if (type == l10n?.diet) return ' 公斤';
    return ' 公里';
  }

  double _calculateCarbonFootprint(String type, double amount) {
    final l10n = AppLocalizations.of(context);
    if (type == l10n?.transportation) {
      return amount * 0.2; // 每公里約0.2kg CO2
    } else if (type == l10n?.shopping) {
      return amount * 0.01; // 每元約0.01kg CO2
    } else if (type == l10n?.electricity) {
      return amount * 0.5; // 每kWh約0.5kg CO2
    } else if (type == l10n?.diet) {
      return amount * 2.0; // 每公斤食物約2kg CO2
    }
    return 0.0;
  }
}
