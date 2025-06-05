import 'package:flutter/foundation.dart'; // Required for ChangeNotifier
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isLoggedIn = false;
  static const String _loggedInKey = 'isLoggedIn'; // Key for shared_preferences

  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _auth.currentUser;

  AuthService() {
    // Check login status when the service is created
    _checkLoginStatus();
    // 监听 Firebase Auth 状态变化
    _auth.authStateChanges().listen((User? user) {
      _isLoggedIn = user != null;
      notifyListeners();
    });
  }

  // Check persisted login status
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // Get the stored value, default to false if not found
    _isLoggedIn = prefs.getBool(_loggedInKey) ?? false;
    print('[AuthService] Initial login status: $_isLoggedIn'); // Debug print
    notifyListeners(); // Notify listeners about the initial state
  }

  Future<void> login({required String email, required String password}) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        _isLoggedIn = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_loggedInKey, true);
        print('[AuthService] User logged in successfully.');
        notifyListeners();
      }
    } catch (e) {
      print('[AuthService] Login error: $e');
      rethrow;
    }
  }

  Future<void> register({required String email, required String password}) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        _isLoggedIn = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_loggedInKey, true);
        print('[AuthService] User registered successfully.');
        notifyListeners();
      }
    } catch (e) {
      print('[AuthService] Registration error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      _isLoggedIn = false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_loggedInKey);
      print('[AuthService] User logged out successfully.');
      notifyListeners();
    } catch (e) {
      print('[AuthService] Logout error: $e');
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      print('[AuthService] 开始 Google 登录流程');
      
      // 触发 Google 登录流程
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('[AuthService] Google 登录被用户取消');
        throw Exception('Google 登录被取消');
      }

      print('[AuthService] 获取到 Google 用户信息: ${googleUser.email}');

      // 获取 Google 认证信息
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print('[AuthService] 获取到 Google 认证信息');

      // 创建 Firebase 认证凭证
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print('[AuthService] 创建 Firebase 认证凭证');

      // 使用凭证登录 Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      print('[AuthService] Firebase 登录成功');
      
      if (userCredential.user != null) {
        _isLoggedIn = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_loggedInKey, true);
        print('[AuthService] Google 登录成功，用户: ${userCredential.user?.email}');
        notifyListeners();
      }
    } catch (e) {
      print('[AuthService] Google 登录错误: $e');
      if (e is PlatformException) {
        print('[AuthService] 错误代码: ${e.code}');
        print('[AuthService] 错误信息: ${e.message}');
        print('[AuthService] 错误详情: ${e.details}');
      }
      rethrow;
    }
  }
}