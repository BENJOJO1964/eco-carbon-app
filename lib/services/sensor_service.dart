import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import '../models/carbon_record.dart';

class SensorService {
  static SensorService? _instance;
  static SensorService get instance => _instance ??= SensorService._();
  
  SensorService._();

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  
  final List<AccelerometerEvent> _accelerometerData = [];
  final List<GyroscopeEvent> _gyroscopeData = [];
  
  Timer? _analysisTimer;

  // 开始监听传感器数据
  void startSensorMonitoring() {
    _startAccelerometerMonitoring();
    _startGyroscopeMonitoring();
    _startPeriodicAnalysis();
  }

  // 停止监听传感器数据
  void stopSensorMonitoring() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _analysisTimer?.cancel();
    _accelerometerData.clear();
    _gyroscopeData.clear();
  }

  // 监听加速度计数据
  void _startAccelerometerMonitoring() {
    _accelerometerSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      _accelerometerData.add(event);
      
      // 只保留最近100个数据点
      if (_accelerometerData.length > 100) {
        _accelerometerData.removeAt(0);
      }
    });
  }

  // 监听陀螺仪数据
  void _startGyroscopeMonitoring() {
    _gyroscopeSubscription = gyroscopeEventStream().listen((GyroscopeEvent event) {
      _gyroscopeData.add(event);
      
      // 只保留最近100个数据点
      if (_gyroscopeData.length > 100) {
        _gyroscopeData.removeAt(0);
      }
    });
  }

  // 定期分析传感器数据
  void _startPeriodicAnalysis() {
    _analysisTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _analyzeSensorData();
    });
  }

  // 分析传感器数据，判断用户活动
  void _analyzeSensorData() {
    if (_accelerometerData.length < 10) return;

    final activity = _detectActivity();
    print('检测到活动: ${_getActivityName(activity)}');
  }

  // 检测用户活动类型
  TransportType? _detectActivity() {
    if (_accelerometerData.length < 10) return null;

    // 计算加速度的方差来判断活动强度
    final variance = _calculateVariance(_accelerometerData);
    final avgAcceleration = _calculateAverageAcceleration(_accelerometerData);
    
    // 根据加速度特征判断活动类型
    if (variance < 0.5 && avgAcceleration < 1.5) {
      return TransportType.walking; // 步行
    } else if (variance > 1.0 && avgAcceleration > 2.0) {
      return TransportType.cycling; // 骑行
    } else if (variance > 2.0) {
      return TransportType.car; // 开车
    }
    
    return null;
  }

  // 计算加速度方差
  double _calculateVariance(List<AccelerometerEvent> data) {
    if (data.isEmpty) return 0.0;
    
    double sum = 0.0;
    for (final event in data) {
      final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      sum += magnitude;
    }
    final mean = sum / data.length;
    
    double varianceSum = 0.0;
    for (final event in data) {
      final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      varianceSum += (magnitude - mean) * (magnitude - mean);
    }
    
    return varianceSum / data.length;
  }

  // 计算平均加速度
  double _calculateAverageAcceleration(List<AccelerometerEvent> data) {
    if (data.isEmpty) return 0.0;
    
    double sum = 0.0;
    for (final event in data) {
      final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      sum += magnitude;
    }
    
    return sum / data.length;
  }

  // 获取当前传感器数据
  Map<String, dynamic>? getCurrentSensorData() {
    if (_accelerometerData.isEmpty) return null;
    
    final latestAccelerometer = _accelerometerData.last;
    final latestGyroscope = _gyroscopeData.isNotEmpty ? _gyroscopeData.last : null;
    
    return {
      'accelerometer': {
        'x': latestAccelerometer.x,
        'y': latestAccelerometer.y,
        'z': latestAccelerometer.z,
      },
      'gyroscope': latestGyroscope != null ? {
        'x': latestGyroscope.x,
        'y': latestGyroscope.y,
        'z': latestGyroscope.z,
      } : null,
      'timestamp': DateTime.now(),
    };
  }

  // 获取活动名称
  String _getActivityName(TransportType? activity) {
    if (activity == null) return '未知';
    
    const Map<TransportType, String> names = {
      TransportType.walking: '步行',
      TransportType.cycling: '骑行',
      TransportType.bus: '公交车',
      TransportType.subway: '地铁',
      TransportType.car: '开车',
      TransportType.motorcycle: '摩托车',
      TransportType.plane: '飞机',
      TransportType.train: '火车',
    };
    
    return names[activity] ?? '未知';
  }


  // 获取传感器数据摘要
  Map<String, dynamic> getSensorDataSummary() {
    return {
      'accelerometerDataCount': _accelerometerData.length,
      'gyroscopeDataCount': _gyroscopeData.length,
      'isMonitoring': _accelerometerSubscription != null,
      'lastUpdate': DateTime.now().toIso8601String(),
    };
  }
}
