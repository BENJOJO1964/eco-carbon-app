import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? _currentPosition;
  StreamSubscription<Position>? _positionStream;
  final List<Position> _locationHistory = [];
  Timer? _movementTimer;
  
  // 位置變化閾值（米）
  static const double _movementThreshold = 10.0;
  
  // 獲取當前位置
  Future<Position?> getCurrentLocation() async {
    try {
      // 檢查位置權限
      final permission = await _checkLocationPermission();
      if (!permission) {
        print('❌ 位置權限被拒絕');
        return null;
      }

      // 獲取位置
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      print('📍 當前位置: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');
      return _currentPosition;
    } catch (e) {
      print('❌ 獲取位置失敗: $e');
      return null;
    }
  }

  // 開始位置追蹤
  Future<void> startLocationTracking() async {
    try {
      final permission = await _checkLocationPermission();
      if (!permission) {
        print('❌ 位置權限被拒絕，無法開始追蹤');
        return;
      }

      // 設置位置更新設置
      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: _movementThreshold.toInt(),
      );

      // 開始位置流
      _positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          _onLocationUpdate(position);
        },
        onError: (error) {
          print('❌ 位置追蹤錯誤: $error');
        },
      );

      print('🚀 開始GPS位置追蹤');
    } catch (e) {
      print('❌ 開始位置追蹤失敗: $e');
    }
  }

  // 停止位置追蹤
  void stopLocationTracking() {
    _positionStream?.cancel();
    _positionStream = null;
    _movementTimer?.cancel();
    _movementTimer = null;
    print('⏹️ 停止GPS位置追蹤');
  }

  // 位置更新回調
  void _onLocationUpdate(Position position) {
    _currentPosition = position;
    _locationHistory.add(position);
    
    // 限制歷史記錄數量
    if (_locationHistory.length > 100) {
      _locationHistory.removeAt(0);
    }

    // 計算移動距離和速度
    if (_locationHistory.length > 1) {
      final previousPosition = _locationHistory[_locationHistory.length - 2];
      final distance = Geolocator.distanceBetween(
        previousPosition.latitude,
        previousPosition.longitude,
        position.latitude,
        position.longitude,
      );
      
      final speed = position.speed * 3.6; // 轉換為 km/h
      
      print('🚗 移動距離: ${distance.toStringAsFixed(1)}m, 速度: ${speed.toStringAsFixed(1)}km/h');
      
      // 如果移動距離超過閾值，記錄為交通活動
      if (distance > _movementThreshold && speed > 1.0) {
        _detectTransportActivity(distance, speed, position);
      }
    }
  }

  // 偵測交通活動
  void _detectTransportActivity(double distance, double speed, Position position) {
    String transportMode;
    double carbonFactor;
    
    if (speed > 50) {
      transportMode = '開車';
      carbonFactor = 0.2; // kg CO2/km
    } else if (speed > 15) {
      transportMode = '騎車';
      carbonFactor = 0.05; // kg CO2/km
    } else if (speed > 5) {
      transportMode = '步行';
      carbonFactor = 0.0; // 步行無碳足跡
    } else {
      transportMode = '靜止';
      carbonFactor = 0.0;
    }

    if (carbonFactor > 0) {
      final carbonFootprint = (distance / 1000) * carbonFactor; // 轉換為公里
      
      print('🚗 偵測到交通活動: $transportMode, 距離: ${(distance/1000).toStringAsFixed(2)}km, 碳足跡: ${carbonFootprint.toStringAsFixed(3)}kg CO2');
      
      // 這裡可以觸發回調或事件來通知主應用程式
      _onTransportDetected({
        'type': '交通',
        'transportMode': transportMode,
        'distance': distance / 1000, // 轉換為公里
        'speed': speed,
        'carbonFootprint': carbonFootprint,
        'timestamp': DateTime.now(),
        'location': {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
      });
    }
  }

  // 交通活動偵測回調
  void Function(Map<String, dynamic>)? onTransportDetected;
  
  void _onTransportDetected(Map<String, dynamic> activity) {
    onTransportDetected?.call(activity);
  }

  // 檢查位置權限
  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('❌ 位置服務未啟用');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('❌ 位置權限被拒絕');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('❌ 位置權限被永久拒絕');
      return false;
    }

    return true;
  }

  // 獲取地址信息
  Future<String> getAddressFromLocation(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return '${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}';
      }
    } catch (e) {
      print('❌ 獲取地址失敗: $e');
    }
    return '未知位置';
  }

  // 計算兩點間距離
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // 獲取位置歷史
  List<Position> getLocationHistory() {
    return List.from(_locationHistory);
  }

  // 獲取當前位置
  Position? get currentPosition => _currentPosition;

  // 檢查是否正在追蹤
  bool get isTracking => _positionStream != null;
}