import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  // Firebase認證系統
  
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasInitialized = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? get user => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _userModel != null;

  Future<void> initialize() async {
    if (_hasInitialized) {
      print('AuthProvider: Already initialized, skipping...');
      return;
    }
    
    print('AuthProvider: Starting initialization...');
    _hasInitialized = true;
    _isLoading = true;
    notifyListeners();
    
    try {
      // 檢查當前登入狀態，不強制登出
      final currentUser = _auth.currentUser;
      print('AuthProvider: Current user: ${currentUser?.uid ?? 'null'}');
      
      // 設置認證狀態監聽器
      print('AuthProvider: Setting up auth state listener...');
      _auth.authStateChanges().listen((User? firebaseUser) async {
        print('AuthProvider: Auth state changed: ${firebaseUser?.uid ?? 'null'}');
        if (firebaseUser != null) {
          // 用戶已登入，獲取用戶資料
          await _loadUserFromFirestore(firebaseUser.uid);
        } else {
          // 用戶未登入
          _userModel = null;
        }
        _isLoading = false;
        notifyListeners();
      });
      
      // 完成初始化
      _isLoading = false;
      print('AuthProvider: Initialization complete with auth listener');
      notifyListeners();
      
    } catch (e) {
      print('AuthProvider: Error during initialization: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _userModel = UserModel(
          id: uid,
          email: data['email'] ?? '',
          name: data['name'] ?? '',
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
        print('AuthProvider: User loaded from Firestore: ${_userModel?.email}');
      } else {
        print('AuthProvider: User document not found in Firestore');
        _errorMessage = '用戶資料不存在';
      }
    } catch (e) {
      print('AuthProvider: Error loading user from Firestore: $e');
      _errorMessage = e.toString();
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 使用Firebase創建用戶
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user != null) {
        // 更新用戶顯示名稱
        await user.updateDisplayName(name);
        
        // 保存用戶資料到Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'name': name,
          'createdAt': Timestamp.now(),
        });

        // 創建用戶模型
        _userModel = UserModel(
          id: user.uid,
          email: email,
          name: name,
          createdAt: DateTime.now(),
        );
        
        print('AuthProvider: User registered successfully: ${_userModel?.email}');
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          _errorMessage = '密碼太弱';
          break;
        case 'email-already-in-use':
          _errorMessage = '此電子郵件已被使用';
          break;
        case 'invalid-email':
          _errorMessage = '無效的電子郵件';
          break;
        case 'operation-not-allowed':
          _errorMessage = 'Email/Password 認證未啟用，請檢查Firebase設置';
          break;
        default:
          _errorMessage = '註冊失敗: ${e.code} - ${e.message}';
      }
      return false;
    } catch (e) {
      _errorMessage = '註冊失敗: $e';
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
      // 使用Firebase登入
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user != null) {
        // 從Firestore獲取用戶資料
        await _loadUserFromFirestore(user.uid);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _errorMessage = '用戶不存在';
          break;
        case 'wrong-password':
          _errorMessage = '密碼錯誤';
          break;
        case 'invalid-email':
          _errorMessage = '無效的電子郵件';
          break;
        case 'user-disabled':
          _errorMessage = '用戶已被停用';
          break;
        default:
          _errorMessage = '登入失敗: ${e.message}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = '登入失敗: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 使用Firebase登出
      await _auth.signOut();
      _userModel = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
