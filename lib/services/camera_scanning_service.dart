import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/carbon_record.dart';

class CameraScanningService extends ChangeNotifier {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isScanning = false;
  String? _lastScannedText;
  List<CarbonRecord> _scannedRecords = [];

  CameraController? get cameraController => _cameraController;
  bool get isInitialized => _isInitialized;
  bool get isScanning => _isScanning;
  String? get lastScannedText => _lastScannedText;
  List<CarbonRecord> get scannedRecords => List.unmodifiable(_scannedRecords);

  Future<void> initialize() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        _isInitialized = true;
        debugPrint('相機初始化成功');
      } else {
        debugPrint('沒有找到可用的相機');
      }
    } catch (e) {
      debugPrint('相機初始化失敗: $e');
    }
    notifyListeners();
  }

  Future<String?> scanTextFromCamera() async {
    if (!_isInitialized || _cameraController == null) {
      debugPrint('相機未初始化');
      return null;
    }

    try {
      _isScanning = true;
      notifyListeners();

      // 拍照
      final XFile image = await _cameraController!.takePicture();
      
      // 使用 ML Kit 進行文字識別
      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.chinese);
      final recognizedText = await textRecognizer.processImage(inputImage);
      
      _lastScannedText = recognizedText.text;
      debugPrint('識別到的文字: $_lastScannedText');
      
      // 分析發票內容
      final record = _analyzeInvoiceText(_lastScannedText!);
      if (record != null) {
        _scannedRecords.add(record);
        debugPrint('成功分析發票並創建記錄');
      }
      
      await textRecognizer.close();
      _isScanning = false;
      notifyListeners();
      
      return _lastScannedText;
    } catch (e) {
      debugPrint('掃描失敗: $e');
      _isScanning = false;
      notifyListeners();
      return null;
    }
  }

  Future<String?> scanTextFromImagePicker() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (image == null) return null;
      
      _isScanning = true;
      notifyListeners();
      
      // 使用 ML Kit 進行文字識別
      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.chinese);
      final recognizedText = await textRecognizer.processImage(inputImage);
      
      _lastScannedText = recognizedText.text;
      debugPrint('識別到的文字: $_lastScannedText');
      
      // 分析發票內容
      final record = _analyzeInvoiceText(_lastScannedText!);
      if (record != null) {
        _scannedRecords.add(record);
        debugPrint('成功分析發票並創建記錄');
      }
      
      await textRecognizer.close();
      _isScanning = false;
      notifyListeners();
      
      return _lastScannedText;
    } catch (e) {
      debugPrint('掃描失敗: $e');
      _isScanning = false;
      notifyListeners();
      return null;
    }
  }

  CarbonRecord? _analyzeInvoiceText(String text) {
    try {
      // 簡單的發票內容分析邏輯
      // 在實際應用中，這裡會使用更複雜的 NLP 或 AI 模型
      
      // 尋找金額
      final amountRegex = RegExp(r'NT\$\s*(\d+(?:\.\d+)?)|(\d+(?:\.\d+)?)\s*元');
      final amountMatch = amountRegex.firstMatch(text);
      double amount = 0.0;
      if (amountMatch != null) {
        amount = double.tryParse(amountMatch.group(1) ?? amountMatch.group(2) ?? '0') ?? 0.0;
      }
      
      // 尋找商店名稱
      String storeName = '未知商店';
      final storeRegex = RegExp(r'(7-ELEVEN|全家|萊爾富|OK超商|家樂福|全聯|大潤發|愛買|頂好|美聯社)');
      final storeMatch = storeRegex.firstMatch(text);
      if (storeMatch != null) {
        storeName = storeMatch.group(1)!;
      }
      
      // 尋找商品關鍵字
      String description = '發票掃描';
      final productKeywords = ['咖啡', '麵包', '飲料', '便當', '零食', '牛奶', '水果', '蔬菜'];
      for (String keyword in productKeywords) {
        if (text.contains(keyword)) {
          description = '發票掃描 - $keyword';
          break;
        }
      }
      
      if (amount > 0) {
        return CarbonRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: 'current_user', // 實際應用中會使用真實的用戶ID
          type: RecordType.shopping,
          distance: amount,
          carbonFootprint: amount * 0.01, // 簡化的碳排放計算
          description: '$storeName - $description',
          timestamp: DateTime.now(),
          metadata: {
            'source': 'camera_scanning',
            'store_name': storeName,
            'amount': amount,
            'scanned_text': text,
            'auto_detected': true,
          },
        );
      }
      
      return null;
    } catch (e) {
      debugPrint('分析發票文字失敗: $e');
      return null;
    }
  }

  void clearScannedRecords() {
    _scannedRecords.clear();
    _lastScannedText = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}
