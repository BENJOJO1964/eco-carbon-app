import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/permission_service.dart';
import '../services/smart_auto_detection_service.dart';
import '../l10n/app_localizations.dart';

class PermissionSetupScreen extends StatefulWidget {
  const PermissionSetupScreen({super.key});

  @override
  State<PermissionSetupScreen> createState() => _PermissionSetupScreenState();
}

class _PermissionSetupScreenState extends State<PermissionSetupScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePermissions();
    });
  }

  Future<void> _initializePermissions() async {
    final permissionService = Provider.of<PermissionService>(context, listen: false);
    await permissionService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('權限設定'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Consumer<PermissionService>(
        builder: (context, permissionService, child) {
          if (!permissionService.isInitialized) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 標題和說明
                _buildHeader(l10n),
                const SizedBox(height: 24),
                
                // 權限狀態卡片
                _buildPermissionStatusCard(permissionService, l10n),
                const SizedBox(height: 16),
                
                // 位置服務狀態
                _buildLocationServiceCard(permissionService, l10n),
                const SizedBox(height: 16),
                
                // 權限列表
                _buildPermissionList(permissionService, l10n),
                const SizedBox(height: 24),
                
                // 建議和說明
                _buildRecommendationsCard(permissionService, l10n),
                const SizedBox(height: 24),
                
                // 操作按鈕
                _buildActionButtons(permissionService, l10n),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Colors.green, size: 28),
                const SizedBox(width: 12),
                Text(
                  '權限設定',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '為了提供最佳的碳足跡追蹤體驗，應用程式需要以下權限：',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• 位置權限：用於GPS追蹤和交通活動檢測\n'
              '• 相機權限：用於掃描發票和識別購買內容\n'
              '• 通知權限：用於發送活動提醒和更新',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionStatusCard(PermissionService permissionService, AppLocalizations l10n) {
    final allGranted = permissionService.areAllRequiredPermissionsGranted();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  allGranted ? Icons.check_circle : Icons.warning,
                  color: allGranted ? Colors.green : Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  '權限狀態',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: allGranted ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: allGranted ? Colors.green : Colors.orange,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    allGranted ? Icons.check : Icons.info,
                    color: allGranted ? Colors.green : Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      allGranted 
                          ? '所有必要權限已授予，可以開始使用自動偵測功能！'
                          : '部分權限尚未授予，請完成權限設定以啟用完整功能。',
                      style: TextStyle(
                        color: allGranted ? Colors.green[700] : Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildLocationServiceCard(PermissionService permissionService, AppLocalizations l10n) {
    return FutureBuilder<bool>(
      future: permissionService.isLocationServiceEnabled(),
      builder: (context, snapshot) {
        final isEnabled = snapshot.data ?? false;
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.gps_fixed,
                      color: isEnabled ? Colors.green : Colors.red,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '位置服務',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isEnabled ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isEnabled ? '已啟用' : '未啟用',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '系統位置服務狀態：${isEnabled ? "已啟用" : "未啟用"}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                if (!isEnabled) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await permissionService.requestLocationService();
                        setState(() {}); // 重新檢查狀態
                      },
                      icon: const Icon(Icons.settings),
                      label: const Text('開啟位置服務'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPermissionList(PermissionService permissionService, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '權限詳情',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...PermissionService.requiredPermissions.map((permission) => 
                _buildPermissionItem(permissionService, permission)),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionItem(PermissionService permissionService, Permission permission) {
    final isGranted = permissionService.isPermissionGranted(permission);
    final status = permissionService.getPermissionStatusDescription(permission);
    final color = permissionService.getPermissionColor(permission);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            permissionService.getPermissionIcon(permission),
            color: color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  permissionService.getPermissionName(permission),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  permissionService.getPermissionDescription(permission),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '狀態：$status',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (!isGranted)
            ElevatedButton(
              onPressed: _isLoading ? null : () => _requestPermission(permission),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('授予'),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard(PermissionService permissionService, AppLocalizations l10n) {
    return FutureBuilder<List<String>>(
      future: permissionService.getPermissionRecommendations(),
      builder: (context, snapshot) {
        final recommendations = snapshot.data ?? [];
    
        if (recommendations.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.amber[600], size: 24),
                    const SizedBox(width: 12),
                    Text(
                      '建議',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...recommendations.map((recommendation) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.amber[600],
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              recommendation,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(PermissionService permissionService, AppLocalizations l10n) {
    final allGranted = permissionService.areAllRequiredPermissionsGranted();
    
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : () => _requestAllPermissions(permissionService),
            icon: const Icon(Icons.security),
            label: const Text('授予所有權限'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => permissionService.openAppSettings(),
            icon: const Icon(Icons.settings),
            label: const Text('開啟應用程式設定'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        if (allGranted) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _enableAutoDetection(),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('啟用自動偵測'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _requestPermission(Permission permission) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final permissionService = Provider.of<PermissionService>(context, listen: false);
      await permissionService.requestPermission(permission);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${permissionService.getPermissionName(permission)}請求完成'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('請求權限失敗: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _requestAllPermissions(PermissionService permissionService) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await permissionService.requestAllRequiredPermissions();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('所有權限請求完成')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('請求權限失敗: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _enableAutoDetection() async {
    try {
      final smartDetection = Provider.of<SmartAutoDetectionService>(context, listen: false);
      await smartDetection.enableAutoDetection();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('自動偵測已啟用！')),
      );
      
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('啟用自動偵測失敗: $e')),
      );
    }
  }
}
