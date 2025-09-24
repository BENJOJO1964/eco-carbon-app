import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/carbon_record.dart';
import '../services/carbon_calculator.dart';

class CarbonProvider extends ChangeNotifier {
  // 簡化的本地數據存儲，不依賴Firebase
  
  List<CarbonRecord> _records = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = false;
  String? _errorMessage;

  List<CarbonRecord> get records => _records;
  Map<String, dynamic> get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadRecords(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 從本地存儲加載記錄
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = prefs.getString('carbon_records_$userId');
      
      if (recordsJson != null) {
        final List<dynamic> recordsList = json.decode(recordsJson);
        _records = recordsList
            .map((recordData) => CarbonRecord.fromMap(recordData))
            .toList();
      } else {
        _records = [];
      }

      _calculateStats();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addRecord(CarbonRecord record) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _records.insert(0, record);
      
      // 儲存到本地存儲
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = json.encode(_records.map((r) => r.toMap()).toList());
      await prefs.setString('carbon_records_${record.userId}', recordsJson);
      
      _calculateStats();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateRecord(String recordId, CarbonRecord record) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final index = _records.indexWhere((r) => r.id == recordId);
      if (index != -1) {
        _records[index] = record;
        
        // 儲存到本地存儲
        final prefs = await SharedPreferences.getInstance();
        final recordsJson = json.encode(_records.map((r) => r.toMap()).toList());
        await prefs.setString('carbon_records_${record.userId}', recordsJson);
        
        _calculateStats();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteRecord(String recordId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final record = _records.firstWhere((r) => r.id == recordId);
      _records.removeWhere((r) => r.id == recordId);
      
      // 儲存到本地存儲
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = json.encode(_records.map((r) => r.toMap()).toList());
      await prefs.setString('carbon_records_${record.userId}', recordsJson);
      
      _calculateStats();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _calculateStats() {
    if (_records.isEmpty) {
      _stats = {
        'totalRecords': 0,
        'totalCarbon': 0.0,
        'averageDaily': 0.0,
        'averageWeekly': 0.0,
      };
      return;
    }

    final totalRecords = _records.length;
    final totalCarbon = _records.fold(0.0, (sum, record) => sum + record.carbonFootprint);
    
    // 計算平均每日排放
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final weekRecords = _records.where((r) => r.timestamp.isAfter(weekAgo)).toList();
    final weekCarbon = weekRecords.fold(0.0, (sum, record) => sum + record.carbonFootprint);
    final averageDaily = weekRecords.isNotEmpty ? weekCarbon / 7 : 0.0;
    
    // 計算平均每週排放
    final monthAgo = now.subtract(const Duration(days: 30));
    final monthRecords = _records.where((r) => r.timestamp.isAfter(monthAgo)).toList();
    final monthCarbon = monthRecords.fold(0.0, (sum, record) => sum + record.carbonFootprint);
    final averageWeekly = monthRecords.isNotEmpty ? monthCarbon / 4 : 0.0;

    _stats = {
      'totalRecords': totalRecords,
      'totalCarbon': totalCarbon,
      'averageDaily': averageDaily,
      'averageWeekly': averageWeekly,
    };
  }

  List<CarbonRecord> getRecordsByType(RecordType type) {
    return _records.where((record) => record.type == type).toList();
  }

  List<CarbonRecord> getRecordsByDateRange(DateTime start, DateTime end) {
    return _records.where((record) => 
      record.timestamp.isAfter(start) && record.timestamp.isBefore(end)
    ).toList();
  }

  double getTotalCarbonByType(RecordType type) {
    return _records
        .where((record) => record.type == type)
        .fold(0.0, (sum, record) => sum + record.carbonFootprint);
  }

  Future<void> initialize(String userId) async {
    await loadRecords(userId);
  }

  void startListening(String userId) {
    // Real-time listener implementation would go here
    // 不重複調用 loadRecords，因為 initialize 已經調用了
  }

  List<String> getEcoSuggestions() {
    if (_records.isEmpty) {
      return ['開始記錄您的碳足跡，了解環保生活方式'];
    }

    final totalCarbon = _records.fold(0.0, (sum, record) => sum + record.carbonFootprint);
    final suggestions = <String>[];

    if (totalCarbon > 10) {
      suggestions.add('您的碳排放較高，建議多使用公共交通');
    }

    final transportRecords = _records.where((r) => r.type == RecordType.transport).length;
    if (transportRecords > 5) {
      suggestions.add('考慮步行或騎行，減少交通碳排放');
    }

    suggestions.add('記錄更多活動，獲得個性化建議');
    return suggestions;
  }

  Future<bool> addTransportRecord({
    required String userId,
    required TransportType transportType,
    required double distance,
    String? description,
    String? startLocation,
    String? endLocation,
  }) async {
    final carbonFootprint = CarbonCalculator.calculateTransportCarbon(transportType, distance);
    final record = CarbonRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      type: RecordType.transport,
      transportType: transportType,
      distance: distance,
      carbonFootprint: carbonFootprint,
      description: description,
      startLocation: startLocation,
      endLocation: endLocation,
      timestamp: DateTime.now(),
    );
    return await addRecord(record);
  }

  Future<bool> addShoppingRecord({
    required String userId,
    required double amount,
    String? description,
  }) async {
    final carbonFootprint = CarbonCalculator.calculateShoppingCarbon(amount);
    final record = CarbonRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      type: RecordType.shopping,
      distance: 0,
      carbonFootprint: carbonFootprint,
      description: description,
      timestamp: DateTime.now(),
    );
    return await addRecord(record);
  }

  Future<bool> addEnergyRecord({
    required String userId,
    required double consumption,
    String? description,
  }) async {
    final carbonFootprint = CarbonCalculator.calculateEnergyCarbon(consumption);
    final record = CarbonRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      type: RecordType.energy,
      distance: 0,
      carbonFootprint: carbonFootprint,
      description: description,
      timestamp: DateTime.now(),
    );
    return await addRecord(record);
  }

  Future<bool> addFoodRecord({
    required String userId,
    required double weight,
    required String foodType,
    String? description,
  }) async {
    final carbonFootprint = CarbonCalculator.calculateFoodCarbon(weight, foodType);
    final record = CarbonRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      type: RecordType.food,
      distance: 0,
      carbonFootprint: carbonFootprint,
      description: description,
      timestamp: DateTime.now(),
    );
    return await addRecord(record);
  }

  Future<bool> addDeliveryRecord({
    required String userId,
    required double amount,
    String? description,
  }) async {
    // 外送記錄使用購物碳排放計算
    final carbonFootprint = CarbonCalculator.calculateShoppingCarbon(amount);
    final record = CarbonRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      type: RecordType.delivery,
      distance: 0,
      carbonFootprint: carbonFootprint,
      description: description,
      timestamp: DateTime.now(),
    );
    return await addRecord(record);
  }

  Future<bool> addExpressRecord({
    required String userId,
    required double amount,
    String? description,
  }) async {
    // 快遞記錄使用購物碳排放計算
    final carbonFootprint = CarbonCalculator.calculateShoppingCarbon(amount);
    final record = CarbonRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      type: RecordType.express,
      distance: 0,
      carbonFootprint: carbonFootprint,
      description: description,
      timestamp: DateTime.now(),
    );
    return await addRecord(record);
  }

  Future<bool> addAccommodationRecord({
    required String userId,
    required double amount,
    String? description,
  }) async {
    // 住宿記錄使用購物碳排放計算
    final carbonFootprint = CarbonCalculator.calculateShoppingCarbon(amount);
    final record = CarbonRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      type: RecordType.accommodation,
      distance: 0,
      carbonFootprint: carbonFootprint,
      description: description,
      timestamp: DateTime.now(),
    );
    return await addRecord(record);
  }

  Future<bool> addOtherRecord({
    required String userId,
    required double value,
    String? description,
  }) async {
    // 其他記錄使用基礎碳排放計算
    final carbonFootprint = value * 0.05; // 基础系数
    final record = CarbonRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      type: RecordType.other,
      distance: 0,
      carbonFootprint: carbonFootprint,
      description: description,
      timestamp: DateTime.now(),
    );
    return await addRecord(record);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
