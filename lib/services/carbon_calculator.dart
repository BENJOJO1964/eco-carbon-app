import '../models/carbon_record.dart';

class CarbonCalculator {
  // 碳排放系数 (kg CO2/km)
  static const Map<TransportType, double> _transportFactors = {
    TransportType.walking: 0.0,
    TransportType.cycling: 0.0,
    TransportType.bus: 0.05,
    TransportType.subway: 0.03,
    TransportType.car: 0.2,
    TransportType.motorcycle: 0.1,
    TransportType.plane: 0.285,
    TransportType.train: 0.014,
  };

  // 计算交通出行的碳排放
  static double calculateTransportCarbon(
    TransportType transportType,
    double distance,
  ) {
    final factor = _transportFactors[transportType] ?? 0.0;
    return factor * distance;
  }

  // 计算购物碳排放 (基于金额估算)
  static double calculateShoppingCarbon(double amount) {
    // 假设每100元购物产生1kg CO2
    return (amount / 100) * 1.0;
  }

  // 计算家庭用电碳排放 (基于用电量)
  static double calculateEnergyCarbon(double electricityKWh) {
    // 中国电网平均碳排放因子: 0.581 kg CO2/kWh
    return electricityKWh * 0.581;
  }

  // 计算食物碳排放 (基于重量)
  static double calculateFoodCarbon(double weightKg, String foodType) {
    // 不同食物类型的碳排放因子 (kg CO2/kg)
    const Map<String, double> foodFactors = {
      'beef': 27.0,
      'pork': 12.1,
      'chicken': 6.9,
      'fish': 6.1,
      'dairy': 3.2,
      'vegetables': 2.0,
      'fruits': 1.1,
      'grains': 1.4,
      'rice': 2.5,
    };

    final factor = foodFactors[foodType] ?? 2.0;
    return weightKg * factor;
  }

  // 获取交通方式的中文名称
  static String getTransportTypeName(TransportType type) {
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
    return names[type] ?? '未知';
  }

  // 获取记录类型的中文名称
  static String getRecordTypeName(RecordType type) {
    const Map<RecordType, String> names = {
      RecordType.transport: '交通出行',
      RecordType.shopping: '購物消費',
      RecordType.energy: '用電消耗',
      RecordType.food: '飲食消費',
      RecordType.delivery: '外送服務',
      RecordType.express: '快遞物流',
      RecordType.accommodation: '住宿服務',
      RecordType.other: '其他',
    };
    return names[type] ?? '未知';
  }

  // 计算总碳排放量
  static double calculateTotalCarbon(List<CarbonRecord> records) {
    return records.fold(0.0, (sum, record) => sum + record.carbonFootprint);
  }

  // 按类型统计碳排放
  static Map<RecordType, double> calculateCarbonByType(List<CarbonRecord> records) {
    final Map<RecordType, double> result = {};
    
    for (final record in records) {
      result[record.type] = (result[record.type] ?? 0.0) + record.carbonFootprint;
    }
    
    return result;
  }

  // 按日期统计碳排放
  static Map<DateTime, double> calculateCarbonByDate(List<CarbonRecord> records) {
    final Map<DateTime, double> result = {};
    
    for (final record in records) {
      final date = DateTime(record.timestamp.year, record.timestamp.month, record.timestamp.day);
      result[date] = (result[date] ?? 0.0) + record.carbonFootprint;
    }
    
    return result;
  }

  // 获取环保建议
  static List<String> getEcoSuggestions(List<CarbonRecord> records) {
    final suggestions = <String>[];
    final totalCarbon = calculateTotalCarbon(records);
    final carbonByType = calculateCarbonByType(records);

    // 基于总碳排放量的建议
    if (totalCarbon > 50) {
      suggestions.add('您的碳足迹较高，建议减少不必要的出行');
    }

    // 基于交通碳排放的建议
    final transportCarbon = carbonByType[RecordType.transport] ?? 0;
    if (transportCarbon > 20) {
      suggestions.add('建议多使用公共交通或步行，减少开车出行');
    }

    // 基于购物碳排放的建议
    final shoppingCarbon = carbonByType[RecordType.shopping] ?? 0;
    if (shoppingCarbon > 10) {
      suggestions.add('购物时选择本地产品，减少运输碳排放');
    }

    // 基于能源碳排放的建议
    final energyCarbon = carbonByType[RecordType.energy] ?? 0;
    if (energyCarbon > 15) {
      suggestions.add('注意节约用电，使用节能电器');
    }

    if (suggestions.isEmpty) {
      suggestions.add('您的环保表现很好！继续保持');
    }

    return suggestions;
  }
}
