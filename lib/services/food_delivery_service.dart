import 'dart:async';
import 'dart:math';

class FoodDeliveryService {
  static final FoodDeliveryService _instance = FoodDeliveryService._internal();
  factory FoodDeliveryService() => _instance;
  FoodDeliveryService._internal();

  Timer? _deliveryCheckTimer;
  final List<Map<String, dynamic>> _recentOrders = [];

  // 食物碳足跡數據庫
  static const Map<String, double> _foodCarbonFactors = {
    // 肉類主菜
    '牛肉漢堡': 15.0,
    '牛排': 20.0,
    '牛肉麵': 12.0,
    '豬排': 8.0,
    '豬肉便當': 6.0,
    '雞排': 4.0,
    '雞肉便當': 3.0,
    '炸雞': 5.0,
    '羊肉串': 10.0,
    '魚排': 4.0,
    '生魚片': 3.0,
    '蝦仁': 5.0,
    
    // 素食
    '素食便當': 0.8,
    '素食沙拉': 0.5,
    '豆腐料理': 1.0,
    '素食漢堡': 1.2,
    '素食義大利麵': 1.5,
    
    // 麵食
    '義大利麵': 2.0,
    '拉麵': 3.0,
    '烏龍麵': 2.5,
    '炒麵': 2.0,
    '湯麵': 1.5,
    
    // 飯類
    '炒飯': 2.5,
    '燴飯': 2.0,
    '咖哩飯': 2.5,
    '丼飯': 3.0,
    '壽司': 2.0,
    
    // 飲料
    '咖啡': 2.0,
    '奶茶': 1.5,
    '果汁': 1.0,
    '汽水': 0.8,
    '茶類': 0.5,
    '手搖飲': 1.2,
    
    // 甜點
    '蛋糕': 3.0,
    '冰淇淋': 2.5,
    '布丁': 1.5,
    '餅乾': 1.0,
    
    // 小食
    '薯條': 1.5,
    '雞塊': 3.0,
    '春捲': 1.0,
    '餃子': 1.5,
    '包子': 1.2,
  };

  // 外送平台列表
  static const List<String> _deliveryPlatforms = [
    'Uber Eats',
    'Foodpanda',
    'foodomo',
    '有無外送',
    '戶戶送',
    'GrabFood',
  ];

  // 餐廳類型
  static const Map<String, List<String>> _restaurantTypes = {
    '速食店': ['麥當勞', '肯德基', '摩斯漢堡', '漢堡王', 'Subway'],
    '中式餐廳': ['八方雲集', '四海遊龍', '三商巧福', '鬍鬚張', '老先覺'],
    '日式料理': ['爭鮮', '壽司郎', '藏壽司', '吉野家', '松屋'],
    '韓式料理': ['韓式炸雞', '韓式烤肉', '韓式拌飯', '韓式湯鍋'],
    '義式料理': ['必勝客', '達美樂', '拿坡里', '義大利麵專賣'],
    '咖啡廳': ['星巴克', '85度C', '路易莎', 'cama', '丹堤'],
    '飲料店': ['50嵐', '清心福全', '茶湯會', '迷客夏', '可不可'],
  };

  // 開始外送訂單監控
  void startDeliveryMonitoring() {
    print('🍽️ 開始外送訂單監控...');
    
    // 每45秒檢查一次新的外送訂單
    _deliveryCheckTimer = Timer.periodic(const Duration(seconds: 45), (timer) {
      _checkNewOrders();
    });
    
    // 立即檢查一次
    _checkNewOrders();
  }

  // 停止外送訂單監控
  void stopDeliveryMonitoring() {
    _deliveryCheckTimer?.cancel();
    _deliveryCheckTimer = null;
    print('⏹️ 停止外送訂單監控');
  }

  // 檢查新的外送訂單
  void _checkNewOrders() {
    // 模擬從各外送平台獲取新訂單
    final newOrders = _simulateNewOrders();
    
    for (final order in newOrders) {
      _processOrder(order);
    }
  }

  // 模擬新的外送訂單
  List<Map<String, dynamic>> _simulateNewOrders() {
    final random = Random();
    final orders = <Map<String, dynamic>>[];
    
    // 只有在真正綁定API後才生成數據，避免預設數據
    // 暫時不生成任何模擬數據，等待真實API整合
    if (false && random.nextDouble() < 0.15) {
      final platform = _deliveryPlatforms[random.nextInt(_deliveryPlatforms.length)];
      final order = _generateRandomOrder(platform);
      orders.add(order);
    }
    
    return orders;
  }

  // 生成隨機外送訂單
  Map<String, dynamic> _generateRandomOrder(String platform) {
    final random = Random();
    final restaurantType = _restaurantTypes.keys.toList()[random.nextInt(_restaurantTypes.length)];
    final restaurants = _restaurantTypes[restaurantType]!;
    final restaurant = restaurants[random.nextInt(restaurants.length)];
    
    final foods = _getRandomFoods(restaurantType);
    
    double totalAmount = 0;
    double totalCarbonFootprint = 0;
    final items = <Map<String, dynamic>>[];
    
    for (final food in foods) {
      final quantity = random.nextInt(2) + 1; // 1-2份
      final unitPrice = (random.nextDouble() * 150 + 50).toStringAsFixed(0);
      final amount = double.parse(unitPrice) * quantity;
      final carbonFactor = _foodCarbonFactors[food] ?? 2.0;
      final weight = _estimateFoodWeight(food);
      final carbonFootprint = weight * carbonFactor;
      
      items.add({
        'food': food,
        'quantity': quantity,
        'unitPrice': double.parse(unitPrice),
        'amount': amount,
        'weight': weight,
        'carbonFactor': carbonFactor,
        'carbonFootprint': carbonFootprint,
      });
      
      totalAmount += amount;
      totalCarbonFootprint += carbonFootprint;
    }
    
    // 添加外送費和包裝碳足跡
    final deliveryFee = random.nextDouble() * 50 + 30;
    final packagingCarbon = 0.1; // 包裝材料碳足跡
    
    return {
      'orderNumber': 'ORD${DateTime.now().millisecondsSinceEpoch}',
      'platform': platform,
      'restaurant': restaurant,
      'restaurantType': restaurantType,
      'date': DateTime.now(),
      'totalAmount': totalAmount + deliveryFee,
      'deliveryFee': deliveryFee,
      'totalCarbonFootprint': totalCarbonFootprint + packagingCarbon,
      'packagingCarbon': packagingCarbon,
      'items': items,
      'deliveryTime': random.nextInt(30) + 15, // 15-45分鐘
      'autoDetected': true,
    };
  }

  // 根據餐廳類型獲取隨機食物
  List<String> _getRandomFoods(String restaurantType) {
    final random = Random();
    final foods = <String>[];
    
    switch (restaurantType) {
      case '速食店':
        foods.addAll(['牛肉漢堡', '雞排', '薯條', '汽水']);
        break;
      case '中式餐廳':
        foods.addAll(['豬肉便當', '炒飯', '湯麵', '奶茶']);
        break;
      case '日式料理':
        foods.addAll(['壽司', '拉麵', '生魚片', '茶類']);
        break;
      case '韓式料理':
        foods.addAll(['韓式炸雞', '韓式拌飯', '韓式湯鍋']);
        break;
      case '義式料理':
        foods.addAll(['義大利麵', '披薩', '咖啡']);
        break;
      case '咖啡廳':
        foods.addAll(['咖啡', '蛋糕', '三明治']);
        break;
      case '飲料店':
        foods.addAll(['手搖飲', '奶茶', '果汁']);
        break;
    }
    
    // 隨機選擇1-3個食物
    final selectedCount = random.nextInt(3) + 1;
    foods.shuffle();
    return foods.take(selectedCount).toList();
  }

  // 估算食物重量
  double _estimateFoodWeight(String food) {
    final weightMap = {
      '牛肉漢堡': 0.3,
      '雞排': 0.2,
      '豬肉便當': 0.4,
      '壽司': 0.15,
      '拉麵': 0.3,
      '義大利麵': 0.25,
      '炒飯': 0.3,
      '咖啡': 0.2,
      '奶茶': 0.3,
      '蛋糕': 0.15,
    };
    
    return weightMap[food] ?? 0.2; // 預設200g
  }

  // 處理外送訂單
  void _processOrder(Map<String, dynamic> order) {
    _recentOrders.add(order);
    
    print('🍽️ 偵測到外送訂單: ${order['platform']} - ${order['restaurant']}');
    print('   金額: \$${order['totalAmount'].toStringAsFixed(0)}');
    print('   碳足跡: ${order['totalCarbonFootprint'].toStringAsFixed(2)} kg CO2');
    print('   食物: ${order['items'].map((item) => item['food']).join(', ')}');
    print('   外送時間: ${order['deliveryTime']}分鐘');
    
    // 觸發回調
    onNewOrder?.call(order);
  }

  // 新訂單回調
  void Function(Map<String, dynamic>)? onNewOrder;

  // 獲取最近的訂單
  List<Map<String, dynamic>> getRecentOrders() {
    return List.from(_recentOrders);
  }

  // 清除已處理的訂單
  void clearProcessedOrders() {
    _recentOrders.clear();
  }

  // 根據食物名稱獲取碳足跡係數
  double getFoodCarbonFactor(String foodName) {
    // 模糊匹配食物名稱
    for (final entry in _foodCarbonFactors.entries) {
      if (foodName.contains(entry.key) || entry.key.contains(foodName)) {
        return entry.value;
      }
    }
    return 2.0; // 預設係數
  }

  // 計算訂單總碳足跡
  double calculateOrderCarbonFootprint(List<Map<String, dynamic>> items) {
    double total = 0;
    for (final item in items) {
      total += item['carbonFootprint'] as double;
    }
    return total;
  }

  // 獲取食物分類
  String getFoodCategory(String foodName) {
    if (_foodCarbonFactors.containsKey(foodName)) {
      if (['牛肉漢堡', '牛排', '牛肉麵', '豬排', '豬肉便當', '雞排', '雞肉便當', '炸雞', '羊肉串', '魚排', '生魚片', '蝦仁'].contains(foodName)) {
        return '肉類主菜';
      } else if (['素食便當', '素食沙拉', '豆腐料理', '素食漢堡', '素食義大利麵'].contains(foodName)) {
        return '素食';
      } else if (['義大利麵', '拉麵', '烏龍麵', '炒麵', '湯麵'].contains(foodName)) {
        return '麵食';
      } else if (['炒飯', '燴飯', '咖哩飯', '丼飯', '壽司'].contains(foodName)) {
        return '飯類';
      } else if (['咖啡', '奶茶', '果汁', '汽水', '茶類', '手搖飲'].contains(foodName)) {
        return '飲料';
      } else if (['蛋糕', '冰淇淋', '布丁', '餅乾'].contains(foodName)) {
        return '甜點';
      } else if (['薯條', '雞塊', '春捲', '餃子', '包子'].contains(foodName)) {
        return '小食';
      }
    }
    return '其他';
  }

  // 獲取所有食物碳足跡係數
  Map<String, double> getAllFoodCarbonFactors() {
    return Map.from(_foodCarbonFactors);
  }

  // 獲取外送平台統計
  Map<String, int> getPlatformStats() {
    final stats = <String, int>{};
    for (final order in _recentOrders) {
      final platform = order['platform'] as String;
      stats[platform] = (stats[platform] ?? 0) + 1;
    }
    return stats;
  }

  // 獲取餐廳類型統計
  Map<String, int> getRestaurantTypeStats() {
    final stats = <String, int>{};
    for (final order in _recentOrders) {
      final type = order['restaurantType'] as String;
      stats[type] = (stats[type] ?? 0) + 1;
    }
    return stats;
  }
}
