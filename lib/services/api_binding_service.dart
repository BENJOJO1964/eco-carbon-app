import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class APIBindingService {
  static final APIBindingService _instance = APIBindingService._internal();
  factory APIBindingService() => _instance;
  APIBindingService._internal();

  static const String _eInvoiceBindingKey = 'e_invoice_binding';
  static const String _foodDeliveryBindingKey = 'food_delivery_binding';
  static const String _bankBindingKey = 'bank_binding';
  static const String _eInvoiceTokenKey = 'e_invoice_token';
  static const String _foodDeliveryTokenKey = 'food_delivery_token';
  static const String _bankTokenKey = 'bank_token';

  // API端點
  static const String _baseUrl = 'https://api.eco-carbon-tracker.com';
  static const String _eInvoiceApiUrl = '$_baseUrl/einvoice';
  static const String _foodDeliveryApiUrl = '$_baseUrl/fooddelivery';
  static const String _bankApiUrl = '$_baseUrl/bank';

  // 檢查電子發票是否已綁定
  Future<bool> isEInvoiceBound() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_eInvoiceBindingKey) ?? false;
  }

  // 檢查外送平台是否已綁定
  Future<bool> isFoodDeliveryBound() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_foodDeliveryBindingKey) ?? false;
  }

  // 檢查銀行帳戶是否已綁定
  Future<bool> isBankBound() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_bankBindingKey) ?? false;
  }

  // 綁定電子發票
  Future<Map<String, dynamic>> bindEInvoice({
    required String phoneNumber,
    required String mobileBarcode,
    required String verificationCode,
  }) async {
    try {
      print('🔗 開始綁定電子發票API...');
      
      // 1. 向財政部API發送綁定請求
      final response = await http.post(
        Uri.parse('$_eInvoiceApiUrl/bind'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'mobileBarcode': mobileBarcode,
          'verificationCode': verificationCode,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['success'] == true) {
          // 2. 保存綁定狀態和Token
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(_eInvoiceBindingKey, true);
          await prefs.setString(_eInvoiceTokenKey, responseData['token']);
          
          print('✅ 電子發票API綁定成功');
          
          return {
            'success': true,
            'message': '電子發票綁定成功',
            'token': responseData['token'],
            'expiresAt': responseData['expiresAt'],
          };
        } else {
          throw Exception(responseData['message'] ?? '綁定失敗');
        }
      } else {
        throw Exception('API請求失敗: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 電子發票API綁定失敗: $e');
      return {
        'success': false,
        'message': '綁定失敗: $e',
      };
    }
  }

  // 發送電子發票驗證碼
  Future<Map<String, dynamic>> sendEInvoiceVerificationCode(String phoneNumber) async {
    try {
      print('📱 發送電子發票驗證碼到: $phoneNumber');
      
      final response = await http.post(
        Uri.parse('$_eInvoiceApiUrl/send-verification'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['success'] == true) {
          print('✅ 驗證碼發送成功');
          return {
            'success': true,
            'message': '驗證碼已發送到您的手機',
            'expiresIn': responseData['expiresIn'], // 秒數
          };
        } else {
          throw Exception(responseData['message'] ?? '發送失敗');
        }
      } else {
        throw Exception('API請求失敗: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 發送驗證碼失敗: $e');
      return {
        'success': false,
        'message': '發送失敗: $e',
      };
    }
  }

  // 綁定外送平台
  Future<Map<String, dynamic>> bindFoodDelivery({
    required String platform,
    required String email,
    required String password,
  }) async {
    try {
      print('🔗 開始綁定外送平台API: $platform');
      
      // 1. 向各平台API發送綁定請求
      final response = await http.post(
        Uri.parse('$_foodDeliveryApiUrl/bind'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'platform': platform,
          'email': email,
          'password': password,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['success'] == true) {
          // 2. 保存綁定狀態和Token
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(_foodDeliveryBindingKey, true);
          await prefs.setString(_foodDeliveryTokenKey, responseData['token']);
          
          print('✅ 外送平台API綁定成功: $platform');
          
          return {
            'success': true,
            'message': '$platform 綁定成功',
            'token': responseData['token'],
            'platform': platform,
            'expiresAt': responseData['expiresAt'],
          };
        } else {
          throw Exception(responseData['message'] ?? '綁定失敗');
        }
      } else {
        throw Exception('API請求失敗: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 外送平台API綁定失敗: $e');
      return {
        'success': false,
        'message': '綁定失敗: $e',
      };
    }
  }

  // 批量綁定多個外送平台
  Future<Map<String, dynamic>> bindMultipleFoodDeliveryPlatforms(
    Map<String, Map<String, String>> platformCredentials,
  ) async {
    try {
      print('🔗 開始批量綁定外送平台...');
      
      final results = <String, Map<String, dynamic>>{};
      int successCount = 0;
      
      for (final entry in platformCredentials.entries) {
        final platform = entry.key;
        final credentials = entry.value;
        
        final result = await bindFoodDelivery(
          platform: platform,
          email: credentials['email']!,
          password: credentials['password']!,
        );
        
        results[platform] = result;
        if (result['success'] == true) {
          successCount++;
        }
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_foodDeliveryBindingKey, successCount > 0);
      
      return {
        'success': successCount > 0,
        'message': '成功綁定 $successCount 個平台',
        'results': results,
        'successCount': successCount,
        'totalCount': platformCredentials.length,
      };
    } catch (e) {
      print('❌ 批量綁定外送平台失敗: $e');
      return {
        'success': false,
        'message': '批量綁定失敗: $e',
      };
    }
  }

  // 綁定銀行/行動支付
  Future<Map<String, dynamic>> bindBank({
    required String paymentMethod,
    required String phoneNumber,
    String? bankName,
    String? verificationCode,
  }) async {
    try {
      print('🔗 開始綁定銀行/行動支付API: $paymentMethod');
      
      // 1. 向銀行/支付API發送綁定請求
      final response = await http.post(
        Uri.parse('$_bankApiUrl/bind'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'paymentMethod': paymentMethod,
          'phoneNumber': phoneNumber,
          'bankName': bankName,
          'verificationCode': verificationCode,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['success'] == true) {
          // 2. 保存綁定狀態和Token
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(_bankBindingKey, true);
          await prefs.setString(_bankTokenKey, responseData['token']);
          
          print('✅ 銀行/行動支付API綁定成功: $paymentMethod');
          
          return {
            'success': true,
            'message': '$paymentMethod 綁定成功',
            'token': responseData['token'],
            'paymentMethod': paymentMethod,
            'expiresAt': responseData['expiresAt'],
          };
        } else {
          throw Exception(responseData['message'] ?? '綁定失敗');
        }
      } else {
        throw Exception('API請求失敗: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 銀行/行動支付API綁定失敗: $e');
      return {
        'success': false,
        'message': '綁定失敗: $e',
      };
    }
  }

  // 發送銀行驗證碼
  Future<Map<String, dynamic>> sendBankVerificationCode(String phoneNumber) async {
    try {
      print('📱 發送銀行驗證碼到: $phoneNumber');
      
      final response = await http.post(
        Uri.parse('$_bankApiUrl/send-verification'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['success'] == true) {
          print('✅ 銀行驗證碼發送成功');
          return {
            'success': true,
            'message': '驗證碼已發送到您的手機',
            'expiresIn': responseData['expiresIn'], // 秒數
          };
        } else {
          throw Exception(responseData['message'] ?? '發送失敗');
        }
      } else {
        throw Exception('API請求失敗: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 發送銀行驗證碼失敗: $e');
      return {
        'success': false,
        'message': '發送失敗: $e',
      };
    }
  }

  // 獲取API Token
  Future<String?> getEInvoiceToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_eInvoiceTokenKey);
  }

  Future<String?> getFoodDeliveryToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_foodDeliveryTokenKey);
  }

  Future<String?> getBankToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_bankTokenKey);
  }

  // 檢查Token是否有效
  Future<bool> isTokenValid(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/validate-token'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['valid'] == true;
      }
      return false;
    } catch (e) {
      print('❌ Token驗證失敗: $e');
      return false;
    }
  }

  // 解除綁定電子發票
  Future<void> unbindEInvoice() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_eInvoiceBindingKey, false);
    await prefs.remove(_eInvoiceTokenKey);
  }

  // 解除綁定外送平台
  Future<void> unbindFoodDelivery() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_foodDeliveryBindingKey, false);
    await prefs.remove(_foodDeliveryTokenKey);
  }

  // 解除綁定銀行帳戶
  Future<void> unbindBank() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_bankBindingKey, false);
    await prefs.remove(_bankTokenKey);
  }

  // 獲取所有綁定狀態
  Future<Map<String, bool>> getAllBindingStatus() async {
    return {
      'e_invoice': await isEInvoiceBound(),
      'food_delivery': await isFoodDeliveryBound(),
      'bank': await isBankBound(),
    };
  }

  // 檢查是否有任何服務已綁定
  Future<bool> hasAnyServiceBound() async {
    final status = await getAllBindingStatus();
    return status.values.any((bound) => bound);
  }

  // 獲取綁定服務數量
  Future<int> getBoundServiceCount() async {
    final status = await getAllBindingStatus();
    return status.values.where((bound) => bound).length;
  }

  // 獲取未綁定服務列表
  Future<List<String>> getUnboundServices() async {
    final status = await getAllBindingStatus();
    return status.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  // 獲取已綁定服務列表
  Future<List<String>> getBoundServices() async {
    final status = await getAllBindingStatus();
    return status.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  // 重置所有綁定狀態（用於測試）
  Future<void> resetAllBindings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_eInvoiceBindingKey);
    await prefs.remove(_foodDeliveryBindingKey);
    await prefs.remove(_bankBindingKey);
  }
}
