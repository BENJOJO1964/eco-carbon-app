import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/carbon_provider.dart';
import '../services/auto_detection_manager.dart';
import 'add_record_screen.dart';
import 'records_screen.dart';
import 'stats_screen.dart';
import 'auto_detection_screen.dart';
import 'camera_scanning_screen.dart';
import 'smart_quick_record_screen.dart';
import 'permission_setup_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // 使用 addPostFrameCallback 避免在構建過程中調用狀態更新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _initializeData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final carbonProvider = Provider.of<CarbonProvider>(context, listen: false);
    
    if (authProvider.user != null) {
      // 使用 Future.microtask 確保在當前構建完成後執行
      Future.microtask(() async {
        await carbonProvider.initialize(authProvider.user!.id);
        carbonProvider.startListening(authProvider.user!.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F1419), // 深藍黑色
              Color(0xFF1A2332), // 深藍灰色
              Color(0xFF2D3748), // 中藍灰色
              Color(0xFF1A202C), // 深灰色
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.user == null) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF00D4FF),
                ),
              );
            }

            return Column(
              children: [
                // 頂部導航欄
                _buildTopNavigationBar(context, authProvider),
                // 主要內容區域
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    children: const [
                      DashboardTab(),
                      RecordsTab(),
                      StatsTab(),
                      SettingsTab(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF00D4FF), // 科技藍
              Color(0xFF0099CC), // 深科技藍
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00D4FF).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddRecordScreen()),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildTopNavigationBar(BuildContext context, AuthProvider authProvider) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E293B), // 深藍灰色
            Color(0xFF334155), // 中藍灰色
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4FF).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // 左側導航按鈕
              Expanded(
                child: Row(
                  children: [
                    _buildNavButton(
                      icon: Icons.dashboard,
                      label: '首頁',
                      index: 0,
                      isSelected: _currentIndex == 0,
                    ),
                    const SizedBox(width: 8),
                    _buildNavButton(
                      icon: Icons.list,
                      label: '記錄',
                      index: 1,
                      isSelected: _currentIndex == 1,
                    ),
                    const SizedBox(width: 8),
                    _buildNavButton(
                      icon: Icons.analytics,
                      label: '統計',
                      index: 2,
                      isSelected: _currentIndex == 2,
                    ),
                  ],
                ),
              ),
              // 右側：設定按鈕 + 用戶頭像
              Row(
                children: [
                  _buildNavButton(
                    icon: Icons.settings,
                    label: '設定',
                    index: 3,
                    isSelected: _currentIndex == 3,
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      // 可以添加用戶資料頁面或登出功能
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF00D4FF), // 科技藍
                            Color(0xFF0099CC), // 深科技藍
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF00D4FF).withOpacity(0.5),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00D4FF).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF00D4FF), // 科技藍
                    Color(0xFF0099CC), // 深科技藍
                  ],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: const Color(0xFF00D4FF).withOpacity(0.5),
                  width: 1,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00D4FF).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : const Color(0xFF94A3B8), // 淺灰色
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF94A3B8), // 淺灰色
                fontSize: 12,
                fontWeight: isSelected
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CarbonProvider>(
        builder: (context, carbonProvider, child) {
          if (carbonProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = carbonProvider.stats;
          final dailyCarbon = stats['averageDaily'] ?? 0.0;
          final suggestions = carbonProvider.getEcoSuggestions();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 今日碳足迹卡片
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.eco, color: Colors.green[600], size: 32),
                            const SizedBox(width: 12),
                            Text(
                              '今日碳足跡',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${dailyCarbon.toStringAsFixed(2)} kg CO₂',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.green[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '總記錄: ${stats['totalRecords'] ?? 0} 條',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 自動偵測狀態卡片
                Consumer<AutoDetectionManager>(
                  builder: (context, autoDetectionManager, child) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  color: autoDetectionManager.isAutoDetectionEnabled 
                                      ? Colors.green 
                                      : Colors.grey,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '自動偵測',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        autoDetectionManager.isAutoDetectionEnabled 
                                            ? '已啟用 - 自動收集碳足跡數據' 
                                            : '未啟用 - 點擊設置自動偵測',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: autoDetectionManager.isAutoDetectionEnabled 
                                              ? Colors.green 
                                              : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.security),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => const PermissionSetupScreen(),
                                          ),
                                        );
                                      },
                                      tooltip: '權限設定',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.settings),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => const AutoDetectionScreen(),
                                          ),
                                        );
                                      },
                                      tooltip: '自動偵測設定',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (autoDetectionManager.isAutoDetectionEnabled) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _buildDetectionStatusChip(
                                    'GPS',
                                    autoDetectionManager.isGpsEnabled,
                                    Icons.location_on,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildDetectionStatusChip(
                                    '發票',
                                    autoDetectionManager.isInvoiceScanningEnabled,
                                    Icons.receipt,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildDetectionStatusChip(
                                    '支付',
                                    autoDetectionManager.isPaymentMonitoringEnabled,
                                    Icons.payment,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildDetectionStatusChip(
                                    '感應器',
                                    autoDetectionManager.isSensorDetectionEnabled,
                                    Icons.sensors,
                                  ),
                                ],
                              ),
                              if (autoDetectionManager.detectedRecords.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green[600],
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '已自動偵測 ${autoDetectionManager.detectedRecords.length} 條記錄',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // 智能快速記錄按鈕
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToSmartQuickRecord(context),
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('智能快速記錄'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                // 掃描發票按鈕
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToScanInvoice(context),
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('掃描發票'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                // 快速新增按鈕
                Text(
                  '快速新增',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // 第一行：交通、购物、用电、饮食
                Row(
                  children: [
                    Expanded(
                      child: _QuickAddButton(
                        icon: Icons.directions_walk,
                        label: '交通',
                        color: Colors.blue,
                        onTap: () => _navigateToAddRecord(context, 'transport'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _QuickAddButton(
                        icon: Icons.shopping_cart,
                        label: '購物',
                        color: Colors.orange,
                        onTap: () => _navigateToAddRecord(context, 'shopping'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _QuickAddButton(
                        icon: Icons.electrical_services,
                        label: '用電',
                        color: Colors.purple,
                        onTap: () => _navigateToAddRecord(context, 'energy'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _QuickAddButton(
                        icon: Icons.restaurant,
                        label: '飲食',
                        color: Colors.red,
                        onTap: () => _navigateToAddRecord(context, 'food'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 第二行：外送、快递、住宿、其他
                Row(
                  children: [
                    Expanded(
                      child: _QuickAddButton(
                        icon: Icons.delivery_dining,
                        label: '外送',
                        color: Colors.green,
                        onTap: () => _navigateToAddRecord(context, 'delivery'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _QuickAddButton(
                        icon: Icons.local_shipping,
                        label: '快遞',
                        color: Colors.teal,
                        onTap: () => _navigateToAddRecord(context, 'express'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _QuickAddButton(
                        icon: Icons.hotel,
                        label: '住宿',
                        color: Colors.indigo,
                        onTap: () => _navigateToAddRecord(context, 'accommodation'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _QuickAddButton(
                        icon: Icons.more_horiz,
                        label: '其他',
                        color: Colors.grey,
                        onTap: () => _navigateToAddRecord(context, 'other'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 第三行：發票掃描
                Row(
                  children: [
                    Expanded(
                      child: _QuickAddButton(
                        icon: Icons.receipt_long,
                        label: '發票掃描',
                        color: Colors.amber,
                        onTap: () => _openCameraForInvoiceScanning(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(), // 空白佔位
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(), // 空白佔位
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(), // 空白佔位
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 環保建議
                Text(
                  '環保建議',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (suggestions.isNotEmpty)
                  ...suggestions.map((suggestion) => Card(
                    child: ListTile(
                      leading: Icon(Icons.lightbulb, color: Colors.amber[600]),
                      title: Text(suggestion),
                    ),
                  )),
              ],
            ),
          );
        },
      ),
    );
  }

  void _navigateToAddRecord(BuildContext context, String type) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AddRecordScreen(initialType: type)),
    );
  }

  void _navigateToSmartQuickRecord(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SmartQuickRecordScreen(),
      ),
    );
  }

  void _navigateToScanInvoice(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CameraScanningScreen(),
      ),
    );
  }


  void _openCameraForInvoiceScanning(BuildContext context) {
    // 導航到真正的相機掃描頁面
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CameraScanningScreen(),
      ),
    );
  }

  void _simulateInvoiceScanning(BuildContext context) {
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

class _QuickAddButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAddButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecordsTab extends StatelessWidget {
  const RecordsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const RecordsScreen();
  }
}

class StatsTab extends StatelessWidget {
  const StatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const StatsScreen();
  }
}

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          if (user == null) return const Center(child: CircularProgressIndicator());

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 用户信息卡片
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.green[100],
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.green[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.email ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 自動偵測設置
              Card(
                child: Column(
                  children: [
              _SettingsItem(
                      icon: Icons.auto_awesome,
                      title: '自動偵測設置',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AutoDetectionScreen(),
                          ),
                        );
                      },
                    ),
                    Consumer<AutoDetectionManager>(
                      builder: (context, autoDetectionManager, child) {
                        return _SettingsItem(
                          icon: Icons.location_on,
                          title: 'GPS追蹤',
                          onTap: () {
                            autoDetectionManager.setGpsEnabled(!autoDetectionManager.isGpsEnabled);
                          },
                        );
                      },
                    ),
                    Consumer<AutoDetectionManager>(
                      builder: (context, autoDetectionManager, child) {
                        return _SettingsItem(
                          icon: Icons.receipt,
                          title: '發票掃描',
                          onTap: () {
                            autoDetectionManager.setInvoiceScanningEnabled(!autoDetectionManager.isInvoiceScanningEnabled);
                          },
                        );
                      },
                    ),
                    Consumer<AutoDetectionManager>(
                      builder: (context, autoDetectionManager, child) {
                        return _SettingsItem(
                          icon: Icons.payment,
                          title: '支付監控',
                          onTap: () {
                            autoDetectionManager.setPaymentMonitoringEnabled(!autoDetectionManager.isPaymentMonitoringEnabled);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 其他设置选项
              Card(
                child: Column(
                  children: [
                    _SettingsItem(
                      icon: Icons.language,
                      title: '語言設置',
                      onTap: () {
                        // TODO: 實現語言切換功能
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('語言切換功能開發中...')),
                        );
                      },
                    ),
                    _SettingsItem(
                      icon: Icons.person,
                      title: '個人資料',
                      onTap: () {},
                    ),
                    _SettingsItem(
                      icon: Icons.notifications,
                      title: '通知設置',
                      onTap: () {},
                    ),
                    _SettingsItem(
                      icon: Icons.privacy_tip,
                      title: '隱私設置',
                      onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.help,
                      title: '幫助與反饋',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.info,
                      title: '關於應用',
                onTap: () {},
                    ),
                  ],
                ),
              ),
              const Divider(),
              _SettingsItem(
                icon: Icons.logout,
                title: '退出登錄',
                titleColor: Colors.red,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('確認退出'),
                      content: const Text('您確定要退出登錄嗎？'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('取消'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Provider.of<AuthProvider>(context, listen: false).signOut();
                          },
                          child: const Text('確認'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? titleColor;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: titleColor ?? Colors.grey[600]),
      title: Text(
        title,
        style: TextStyle(color: titleColor),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

// 偵測狀態芯片組件
Widget _buildDetectionStatusChip(String label, bool isActive, IconData icon) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: isActive ? Colors.green[100] : Colors.grey[100],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isActive ? Colors.green : Colors.grey,
        width: 1,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: isActive ? Colors.green[700] : Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? Colors.green[700] : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
