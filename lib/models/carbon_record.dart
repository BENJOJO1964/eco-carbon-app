enum TransportType {
  walking,
  cycling,
  bus,
  subway,
  car,
  motorcycle,
  plane,
  train,
}

enum RecordType {
  transport,      // 交通出行
  shopping,       // 购物消费
  energy,         // 用电消耗
  food,           // 饮食消费
  delivery,       // 外送服务
  express,        // 快递物流
  accommodation,  // 住宿服务
  other,          // 其他
}

class CarbonRecord {
  final String id;
  final String userId;
  final RecordType type;
  final TransportType? transportType;
  final double distance; // 距离 (km)
  final double carbonFootprint; // 碳足迹 (kg CO2)
  final String? description;
  final String? startLocation;
  final String? endLocation;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  CarbonRecord({
    required this.id,
    required this.userId,
    required this.type,
    this.transportType,
    required this.distance,
    required this.carbonFootprint,
    this.description,
    this.startLocation,
    this.endLocation,
    required this.timestamp,
    this.metadata,
  });

  // 从Firestore文档创建CarbonRecord
  factory CarbonRecord.fromMap(Map<String, dynamic> data) {
    return CarbonRecord(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      type: RecordType.values.firstWhere(
        (e) => e.toString() == 'RecordType.${data['type']}',
        orElse: () => RecordType.other,
      ),
      transportType: data['transportType'] != null
          ? TransportType.values.firstWhere(
              (e) => e.toString() == 'TransportType.${data['transportType']}',
              orElse: () => TransportType.walking,
            )
          : null,
      distance: (data['distance'] ?? 0).toDouble(),
      carbonFootprint: (data['carbonFootprint'] ?? 0).toDouble(),
      description: data['description'],
      startLocation: data['startLocation'],
      endLocation: data['endLocation'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp'] ?? 0),
      metadata: data['metadata'],
    );
  }

  // 转换为Firestore文档
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString().split('.').last,
      'transportType': transportType?.toString().split('.').last,
      'distance': distance,
      'carbonFootprint': carbonFootprint,
      'description': description,
      'startLocation': startLocation,
      'endLocation': endLocation,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'metadata': metadata,
    };
  }

  // 复制并更新字段
  CarbonRecord copyWith({
    String? id,
    String? userId,
    RecordType? type,
    TransportType? transportType,
    double? distance,
    double? carbonFootprint,
    String? description,
    String? startLocation,
    String? endLocation,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return CarbonRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      transportType: transportType ?? this.transportType,
      distance: distance ?? this.distance,
      carbonFootprint: carbonFootprint ?? this.carbonFootprint,
      description: description ?? this.description,
      startLocation: startLocation ?? this.startLocation,
      endLocation: endLocation ?? this.endLocation,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }
}
