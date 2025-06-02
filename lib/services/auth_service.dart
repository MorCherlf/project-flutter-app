import 'package:flutter/foundation.dart'; // Required for ChangeNotifier
import 'package:shared_preferences/shared_preferences.dart';

class AuthService with ChangeNotifier {
  bool _isLoggedIn = false;
  static const String _loggedInKey = 'isLoggedIn'; // Key for shared_preferences

  bool get isLoggedIn => _isLoggedIn;

  AuthService() {
    // Check login status when the service is created
    _checkLoginStatus();
  }

  // Check persisted login status
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // Get the stored value, default to false if not found
    _isLoggedIn = prefs.getBool(_loggedInKey) ?? false;
    print('[AuthService] Initial login status: $_isLoggedIn'); // Debug print
    notifyListeners(); // Notify listeners about the initial state
  }

  // Simulate login
  Future<void> login() async {
    // Simulate network delay or processing
    await Future.delayed(const Duration(milliseconds: 500));

    // In a real app, you would validate credentials here
    _isLoggedIn = true;

    // Persist login state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, true);

    print('[AuthService] User logged in.'); // Debug print
    notifyListeners(); // Notify listeners that login state changed
  }

  // Simulate logout
  Future<void> logout() async {
    // Simulate network delay or processing
    await Future.delayed(const Duration(milliseconds: 200));

    _isLoggedIn = false;

    // Remove persisted state
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedInKey); // Or set to false: await prefs.setBool(_loggedInKey, false);

    print('[AuthService] User logged out.'); // Debug print
    notifyListeners(); // Notify listeners that login state changed
  }
}