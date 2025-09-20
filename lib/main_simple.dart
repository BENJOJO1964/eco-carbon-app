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
  int _selectedIndex = 0;
  double _totalCarbonFootprint = 0.0;

  final List<Map<String, dynamic>> _records = [];

  void _addRecord(Map<String, dynamic> record) {
    setState(() {
      _records.add(record);
      _totalCarbonFootprint += record['carbonFootprint'] ?? 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
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
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add),
            label: l10n.addRecord,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.list),
            label: l10n.recordList,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.analytics),
            label: l10n.statistics,
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
    switch (_selectedIndex) {
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
                    l10n.todayCarbonFootprint,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_totalCarbonFootprint.toStringAsFixed(2)} ${l10n.kgCO2}',
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
          const SizedBox(height: 16),
          Text(
            l10n.quickAdd,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildQuickAddCard('🚗', l10n.transportation, Colors.blue),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickAddCard('🛒', l10n.shopping, Colors.orange),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildQuickAddCard('⚡', l10n.electricity, Colors.yellow),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickAddCard('🍽️', l10n.diet, Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddCard(String emoji, String title, Color color) {
    return Card(
      child: InkWell(
        onTap: () => _showAddRecordDialog(type: title),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
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
      child: Text(
        l10n.clickPlusToAdd,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildRecordsTab() {
    final l10n = AppLocalizations.of(context);
    
    if (_records.isEmpty) {
      return Center(
        child: Text(
          '${l10n.noRecords}\n${l10n.clickToAddFirstRecord}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _records.length,
      itemBuilder: (context, index) {
        final record = _records[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green,
              child: Text(
                record['type']?.substring(0, 1) ?? '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(record['type'] ?? '未知类型'),
            subtitle: Text(record['description'] ?? ''),
            trailing: Text(
              '${record['carbonFootprint']?.toStringAsFixed(2) ?? '0.00'} ${AppLocalizations.of(context).kgCO2}',
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
                      _buildStatItem(l10n.totalRecords, '${_records.length}'),
                      _buildStatItem(l10n.totalCarbonFootprint, '${_totalCarbonFootprint.toStringAsFixed(2)} ${l10n.kgCO2}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.ecoAdvice,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.reduceCarbonTips,
                    style: const TextStyle(fontWeight: FontWeight.bold),
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

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  void _showAddRecordDialog({String? type}) {
    final l10n = AppLocalizations.of(context);
    final TextEditingController amountController = TextEditingController();
    String selectedType = type ?? l10n.transportation;
    double carbonFootprint = 0.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.addCarbonRecord),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: InputDecoration(labelText: l10n.type),
                items: [
                  DropdownMenuItem(value: l10n.transportation, child: Text(l10n.transportation)),
                  DropdownMenuItem(value: l10n.shopping, child: Text(l10n.shopping)),
                  DropdownMenuItem(value: l10n.electricity, child: Text(l10n.electricity)),
                  DropdownMenuItem(value: l10n.diet, child: Text(l10n.diet)),
                ],
                onChanged: (value) {
                  setDialogState(() {
                    selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: _getAmountLabel(selectedType, l10n),
                  hintText: _getAmountHint(selectedType, l10n),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setDialogState(() {
                    carbonFootprint = _calculateCarbonFootprint(
                      selectedType,
                      double.tryParse(value) ?? 0.0,
                    );
                  });
                },
              ),
              const SizedBox(height: 16),
              if (carbonFootprint > 0)
                Text(
                  '${l10n.estimatedCarbonFootprint}: ${carbonFootprint.toStringAsFixed(2)} ${l10n.kgCO2}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (amountController.text.isNotEmpty) {
                  _addRecord({
                    'type': selectedType,
                    'amount': double.tryParse(amountController.text) ?? 0.0,
                    'description': '${selectedType}: ${amountController.text}${_getAmountUnit(selectedType, l10n)}',
                    'carbonFootprint': carbonFootprint,
                    'timestamp': DateTime.now(),
                  });
                  Navigator.pop(context);
                }
              },
              child: Text(l10n.add),
            ),
          ],
        ),
      ),
    );
  }

  String _getAmountLabel(String type, AppLocalizations l10n) {
    if (type == l10n.transportation) return l10n.distance;
    if (type == l10n.shopping) return l10n.amountMoney;
    if (type == l10n.electricity) return l10n.electricityUsage;
    if (type == l10n.diet) return l10n.foodWeight;
    return l10n.amount;
  }

  String _getAmountHint(String type, AppLocalizations l10n) {
    if (type == l10n.transportation) return '例如: 10.5';
    if (type == l10n.shopping) return '例如: 100';
    if (type == l10n.electricity) return '例如: 5.2';
    if (type == l10n.diet) return '例如: 0.5';
    return '輸入數量';
  }

  String _getAmountUnit(String type, AppLocalizations l10n) {
    if (type == l10n.transportation) return '公里';
    if (type == l10n.shopping) return '元';
    if (type == l10n.electricity) return 'kWh';
    if (type == l10n.diet) return 'kg';
    return '';
  }

  double _calculateCarbonFootprint(String type, double amount) {
    final l10n = AppLocalizations.of(context);
    
    if (type == l10n.transportation) {
      return amount * 0.2; // 假設開車，每公里0.2kg CO₂
    } else if (type == l10n.shopping) {
      return amount * 0.01; // 每100元約1kg CO₂
    } else if (type == l10n.electricity) {
      return amount * 0.581; // 每kWh產生0.581kg CO₂
    } else if (type == l10n.diet) {
      return amount * 2.0; // 假設肉類，每kg約2kg CO₂
    }
    return 0.0;
  }
}