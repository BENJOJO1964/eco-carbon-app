import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  // 简化的本地认证系统，不依赖Firebase
  
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;
  final Map<String, String> _users = {}; // 简单的用户存储

  UserModel? get user => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _userModel != null;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // 检查本地存储的用户信息
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email');
      final userName = prefs.getString('user_name');
      
      if (userEmail != null && userName != null) {
        _userModel = UserModel(
          id: userEmail,
          email: userEmail,
          name: userName,
          createdAt: DateTime.now(),
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 检查用户是否已存在
      if (_users.containsKey(email)) {
        _errorMessage = '用户已存在';
        return false;
      }

      // 简单的密码验证
      if (password.length < 6) {
        _errorMessage = '密码至少需要6位';
        return false;
      }

      // 创建新用户
      _users[email] = password;
      
      _userModel = UserModel(
        id: email,
        email: email,
        name: name,
        createdAt: DateTime.now(),
      );

      // 保存到本地存储
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);
      await prefs.setString('user_name', name);

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 检查用户是否存在
      if (!_users.containsKey(email)) {
        _errorMessage = '用户不存在';
        return false;
      }

      // 验证密码
      if (_users[email] != password) {
        _errorMessage = '密码错误';
        return false;
      }

      // 创建用户模型
      _userModel = UserModel(
        id: email,
        email: email,
        name: email.split('@')[0], // 使用邮箱前缀作为用户名
        createdAt: DateTime.now(),
      );

      // 保存到本地存储
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);
      await prefs.setString('user_name', _userModel!.name);

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 清除本地存储
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_email');
      await prefs.remove('user_name');
      
      _userModel = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
