import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../services/camera_scanning_service.dart';
import '../l10n/app_localizations.dart';

class CameraScanningScreen extends StatefulWidget {
  const CameraScanningScreen({super.key});

  @override
  State<CameraScanningScreen> createState() => _CameraScanningScreenState();
}

class _CameraScanningScreenState extends State<CameraScanningScreen> {
  late CameraScanningService _cameraService;

  @override
  void initState() {
    super.initState();
    _cameraService = CameraScanningService();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await _cameraService.initialize();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.invoiceScanning),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: _pickImageFromGallery,
            tooltip: '從相簿選擇',
          ),
        ],
      ),
      body: Consumer<CameraScanningService>(
        builder: (context, service, child) {
          if (!service.isInitialized) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('正在初始化相機...'),
                ],
              ),
            );
          }

          if (service.cameraController == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('無法初始化相機'),
                ],
              ),
            );
          }

          return Stack(
            children: [
              // 相機預覽
              Positioned.fill(
                child: CameraPreview(service.cameraController!),
              ),
              
              // 掃描框
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                  ),
                  child: Center(
                    child: Container(
                      width: 250,
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          '將發票對準此框',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // 底部控制按鈕
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 取消按鈕
                    FloatingActionButton(
                      onPressed: () => Navigator.of(context).pop(),
                      backgroundColor: Colors.red,
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                    
                    // 拍照按鈕
                    FloatingActionButton(
                      onPressed: service.isScanning ? null : _takePicture,
                      backgroundColor: Colors.green,
                      child: service.isScanning
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.camera_alt, color: Colors.white),
                    ),
                    
                    // 閃光燈按鈕
                    FloatingActionButton(
                      onPressed: _toggleFlash,
                      backgroundColor: Colors.blue,
                      child: const Icon(Icons.flash_on, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _takePicture() async {
    final result = await _cameraService.scanTextFromCamera();
    if (result != null && mounted) {
      _showScanResult(result);
    }
  }

  Future<void> _pickImageFromGallery() async {
    final result = await _cameraService.scanTextFromImagePicker();
    if (result != null && mounted) {
      _showScanResult(result);
    }
  }

  void _toggleFlash() {
    // 閃光燈切換功能
    // 這裡可以實現閃光燈的開關
  }

  void _showScanResult(String scannedText) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.invoiceScanning),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '掃描結果：',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    scannedText,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '分析結果：',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ..._cameraService.scannedRecords
                    .where((record) => record.metadata?['source'] == 'camera_scanning')
                    .map((record) => Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('商店：${record.metadata?['store_name'] ?? '未知'}'),
                                Text('金額：NT\$ ${record.distance.toStringAsFixed(2)}'),
                                Text('碳足跡：${record.carbonFootprint.toStringAsFixed(2)} kg CO₂'),
                                Text('描述：${record.description}'),
                              ],
                            ),
                          ),
                        )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('重新掃描'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // 返回上一頁
                // 這裡可以將掃描結果添加到碳足跡記錄中
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('發票掃描結果已保存')),
                );
              },
              child: const Text('保存記錄'),
            ),
          ],
        );
      },
    );
  }
}
