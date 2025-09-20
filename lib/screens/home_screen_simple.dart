import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/carbon_provider.dart';
import '../l10n/app_localizations.dart';

class HomeScreenSimple extends StatefulWidget {
  const HomeScreenSimple({super.key});

  @override
  State<HomeScreenSimple> createState() => _HomeScreenSimpleState();
}

class _HomeScreenSimpleState extends State<HomeScreenSimple> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final carbonProvider = Provider.of<CarbonProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('通知功能開發中')),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.green,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.list),
            label: l10n.records,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart),
            label: l10n.statistics,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.settings,
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
        return _buildRecordsTab();
      case 2:
        return _buildStatisticsTab();
      case 3:
        return _buildSettingsTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    final l10n = AppLocalizations.of(context)!;
    final carbonProvider = Provider.of<CarbonProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 歡迎卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '歡迎使用碳足跡追蹤APP！',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('開始記錄您的日常活動，追蹤碳足跡，為環保盡一份力！'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 快速記錄按鈕
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAddRecordDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('快速記錄'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('發票掃描功能開發中')),
                    );
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('發票掃描'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 今日統計
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '今日統計',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('記錄數', '${carbonProvider.records.length}', Icons.list),
                      _buildStatItem('總碳足跡', '${carbonProvider.totalCarbonFootprint.toStringAsFixed(2)} kg', Icons.eco),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 最近記錄
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '最近記錄',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (carbonProvider.records.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('還沒有記錄，點擊 + 按鈕開始記錄吧！'),
                      ),
                    )
                  else
                    ...carbonProvider.records.take(5).map((record) =>
                      ListTile(
                        leading: Icon(_getRecordIcon(record.type)),
                        title: Text(record.description ?? '無描述'),
                        subtitle: Text('${record.carbonFootprint.toStringAsFixed(2)} kg CO₂'),
                        trailing: Text(
                          '${record.timestamp.month}/${record.timestamp.day}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.green, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
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

  Widget _buildRecordsTab() {
    final carbonProvider = Provider.of<CarbonProvider>(context);

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: carbonProvider.records.length,
      itemBuilder: (context, index) {
        final record = carbonProvider.records[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            leading: Icon(_getRecordIcon(record.type)),
            title: Text(record.description ?? '無描述'),
            subtitle: Text('${record.carbonFootprint.toStringAsFixed(2)} kg CO₂'),
            trailing: Text(
              '${record.timestamp.month}/${record.timestamp.day} ${record.timestamp.hour}:${record.timestamp.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatisticsTab() {
    final carbonProvider = Provider.of<CarbonProvider>(context);

    return SingleChildScrollView(
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
                    '總計統計',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('總記錄', '${carbonProvider.records.length}', Icons.list),
                      _buildStatItem('總碳足跡', '${carbonProvider.totalCarbonFootprint.toStringAsFixed(2)} kg', Icons.eco),
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
                    '按類型統計',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._buildTypeStatistics(carbonProvider),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTypeStatistics(CarbonProvider carbonProvider) {
    final typeStats = <String, int>{};
    final typeCarbon = <String, double>{};

    for (final record in carbonProvider.records) {
      final type = record.type.toString().split('.').last;
      typeStats[type] = (typeStats[type] ?? 0) + 1;
      typeCarbon[type] = (typeCarbon[type] ?? 0) + record.carbonFootprint;
    }

    return typeStats.entries.map((entry) {
      final type = entry.key;
      final count = entry.value;
      final carbon = typeCarbon[type] ?? 0;
      
      return ListTile(
        leading: Icon(_getTypeIcon(type)),
        title: Text(_getTypeName(type)),
        subtitle: Text('$count 筆記錄'),
        trailing: Text('${carbon.toStringAsFixed(2)} kg'),
      );
    }).toList();
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
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
                    '應用程式設定',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text('語言設定'),
                    subtitle: const Text('繁體中文'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('語言設定功能開發中')),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('通知設定'),
                    subtitle: const Text('開啟'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('通知設定功能開發中')),
                      );
                    },
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
                    '關於',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const ListTile(
                    leading: Icon(Icons.info),
                    title: Text('版本'),
                    subtitle: Text('1.0.0'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.help),
                    title: const Text('使用說明'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('使用說明功能開發中')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddRecordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新增記錄'),
        content: const Text('請選擇記錄類型：'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _addSampleRecord('交通');
            },
            child: const Text('交通'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _addSampleRecord('購物');
            },
            child: const Text('購物'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _addSampleRecord('飲食');
            },
            child: const Text('飲食'),
          ),
        ],
      ),
    );
  }

  void _addSampleRecord(String type) {
    final carbonProvider = Provider.of<CarbonProvider>(context, listen: false);
    final now = DateTime.now();
    
    // 添加示例記錄
    carbonProvider.addRecord({
      'id': now.millisecondsSinceEpoch.toString(),
      'userId': 'demo_user',
      'type': type,
      'distance': 10.0,
      'carbonFootprint': 2.5,
      'description': '示例$type記錄',
      'timestamp': now,
      'metadata': {'source': 'demo'},
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已新增$type記錄')),
    );
  }

  IconData _getRecordIcon(dynamic type) {
    final typeString = type.toString().split('.').last;
    return _getTypeIcon(typeString);
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_cart;
      case 'food':
        return Icons.restaurant;
      case 'energy':
        return Icons.electrical_services;
      default:
        return Icons.category;
    }
  }

  String _getTypeName(String type) {
    switch (type) {
      case 'transport':
        return '交通';
      case 'shopping':
        return '購物';
      case 'food':
        return '飲食';
      case 'energy':
        return '用電';
      default:
        return '其他';
    }
  }
}
