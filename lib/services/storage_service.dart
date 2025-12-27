import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class StorageService {
  static const String _keyUserId = 'user_id';
  static const String _keyToken = 'auth_token';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserType = 'user_type';

  // Cache for SharedPreferences instance
  static SharedPreferences? _prefsInstance;
  static bool _isInitializing = false;
  
  // In-memory fallback storage when SharedPreferences fails
  static final Map<String, dynamic> _memoryStorage = {};
  static bool _useMemoryStorage = false;

  // Helper method to get SharedPreferences with retry and error handling
  static Future<SharedPreferences?> _getPreferences({int retries = 5, bool forceRefresh = false}) async {
    // Clear cache if forced refresh (useful after hot restart)
    if (forceRefresh) {
      _prefsInstance = null;
      _isInitializing = false;
    }
    
    // Return cached instance if available
    if (_prefsInstance != null) {
      // Test if the instance is still valid by trying a simple operation
      try {
        _prefsInstance!.getKeys(); // This will throw if the channel is broken
        return _prefsInstance;
      } catch (e) {
        // Cache is stale, clear it and reinitialize
        print('Cached SharedPreferences instance is invalid, clearing cache');
        _prefsInstance = null;
      }
    }

    // If already initializing, wait for it
    if (_isInitializing) {
      int waitCount = 0;
      while (_isInitializing && waitCount < 50) {
        await Future.delayed(const Duration(milliseconds: 100));
        waitCount++;
        if (_prefsInstance != null) {
          return _prefsInstance;
        }
      }
    }

    _isInitializing = true;

    // Initial delay to ensure platform channels are ready
    await Future.delayed(const Duration(milliseconds: 200));

    for (int i = 0; i < retries; i++) {
      try {
        _prefsInstance = await SharedPreferences.getInstance();
        _isInitializing = false;
        return _prefsInstance;
      } on PlatformException catch (e) {
        print('SharedPreferences PlatformException (attempt ${i + 1}/$retries): ${e.message}');
        if (i < retries - 1) {
          // Exponential backoff: wait longer with each retry
          await Future.delayed(Duration(milliseconds: 200 * (i + 1)));
        }
      } catch (e) {
        print('SharedPreferences error (attempt ${i + 1}/$retries): $e');
        if (i < retries - 1) {
          await Future.delayed(Duration(milliseconds: 200 * (i + 1)));
        }
      }
    }

    _isInitializing = false;
    print('Failed to get SharedPreferences after $retries attempts');
    print('⚠️ Using in-memory storage as fallback (data will be lost on app restart)');
    _useMemoryStorage = true;
    return null;
  }

  // Helper to get value from either SharedPreferences or memory
  static dynamic _getValue(String key) {
    if (_useMemoryStorage) {
      return _memoryStorage[key];
    }
    return _prefsInstance?.get(key);
  }

  // Helper to set value in either SharedPreferences or memory
  static Future<void> _setValue(String key, dynamic value) async {
    if (_useMemoryStorage) {
      _memoryStorage[key] = value;
      return;
    }
    if (_prefsInstance != null) {
      if (value is String) {
        await _prefsInstance!.setString(key, value);
      } else if (value is bool) {
        await _prefsInstance!.setBool(key, value);
      } else if (value is int) {
        await _prefsInstance!.setInt(key, value);
      } else if (value is double) {
        await _prefsInstance!.setDouble(key, value);
      }
    }
  }

  // Helper to remove value from either SharedPreferences or memory
  static Future<void> _removeValue(String key) async {
    if (_useMemoryStorage) {
      _memoryStorage.remove(key);
      return;
    }
    if (_prefsInstance != null) {
      await _prefsInstance!.remove(key);
    }
  }

  // Pre-initialize SharedPreferences (call this early in app lifecycle)
  static Future<bool> initialize({bool forceRefresh = false}) async {
    try {
      final prefs = await _getPreferences(forceRefresh: forceRefresh);
      return prefs != null;
    } catch (e) {
      print('Error initializing SharedPreferences: $e');
      return false;
    }
  }

  // Save user ID
  static Future<void> saveUserId(String userId) async {
    try {
      await _getPreferences();
      await _setValue(_keyUserId, userId);
    } catch (e) {
      print('Error saving user ID: $e');
      // Fallback to memory
      _memoryStorage[_keyUserId] = userId;
      _useMemoryStorage = true;
    }
  }

  // Get user ID
  static Future<String?> getUserId() async {
    try {
      await _getPreferences();
      final value = _getValue(_keyUserId);
      return value is String ? value : null;
    } catch (e) {
      print('Error getting user ID: $e');
      return _memoryStorage[_keyUserId] as String?;
    }
  }

  // Save auth token
  static Future<void> saveToken(String token) async {
    try {
      await _getPreferences();
      await _setValue(_keyToken, token);
    } catch (e) {
      print('Error saving token: $e');
      // Fallback to memory
      _memoryStorage[_keyToken] = token;
      _useMemoryStorage = true;
    }
  }

  // Get auth token
  static Future<String?> getToken() async {
    try {
      await _getPreferences();
      final value = _getValue(_keyToken);
      return value is String ? value : null;
    } catch (e) {
      print('Error getting token: $e');
      return _memoryStorage[_keyToken] as String?;
    }
  }

  // Save user phone
  static Future<void> saveUserPhone(String phone) async {
    try {
      await _getPreferences();
      await _setValue(_keyUserPhone, phone);
    } catch (e) {
      print('Error saving user phone: $e');
      // Fallback to memory
      _memoryStorage[_keyUserPhone] = phone;
      _useMemoryStorage = true;
    }
  }

  // Get user phone
  static Future<String?> getUserPhone() async {
    try {
      await _getPreferences();
      final value = _getValue(_keyUserPhone);
      return value is String ? value : null;
    } catch (e) {
      print('Error getting user phone: $e');
      return _memoryStorage[_keyUserPhone] as String?;
    }
  }

  // Set login status
  static Future<void> setLoggedIn(bool isLoggedIn) async {
    try {
      await _getPreferences();
      await _setValue(_keyIsLoggedIn, isLoggedIn);
    } catch (e) {
      print('Error setting login status: $e');
      // Fallback to memory
      _memoryStorage[_keyIsLoggedIn] = isLoggedIn;
      _useMemoryStorage = true;
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      await _getPreferences();
      final value = _getValue(_keyIsLoggedIn);
      return value is bool ? value : false;
    } catch (e) {
      print('Error checking login status: $e');
      return _memoryStorage[_keyIsLoggedIn] as bool? ?? false;
    }
  }

  // Save user type
  static Future<void> saveUserType(String userType) async {
    try {
      await _getPreferences();
      await _setValue(_keyUserType, userType);
    } catch (e) {
      print('Error saving user type: $e');
      // Fallback to memory
      _memoryStorage[_keyUserType] = userType;
      _useMemoryStorage = true;
    }
  }

  // Get user type
  static Future<String?> getUserType() async {
    try {
      await _getPreferences();
      final value = _getValue(_keyUserType);
      return value is String ? value : null;
    } catch (e) {
      print('Error getting user type: $e');
      return _memoryStorage[_keyUserType] as String?;
    }
  }

  // Check if user is agent
  static Future<bool> isAgent() async {
    final userType = await getUserType();
    return userType?.toLowerCase() == 'agent';
  }

  // Check if user is regular user
  static Future<bool> isUser() async {
    final userType = await getUserType();
    return userType?.toLowerCase() == 'user' || userType == null;
  }

  // Clear all stored data (logout)
  static Future<void> clearAll() async {
    try {
      await _getPreferences();
      await _removeValue(_keyUserId);
      await _removeValue(_keyToken);
      await _removeValue(_keyUserPhone);
      await _removeValue(_keyIsLoggedIn);
      await _removeValue(_keyUserType);
    } catch (e) {
      print('Error clearing storage: $e');
    }
    // Also clear memory storage
    _memoryStorage.clear();
    _useMemoryStorage = false;
  }

  // Method to clear cached instance (useful for testing or reset)
  static void clearCache() {
    _prefsInstance = null;
    _memoryStorage.clear();
    _useMemoryStorage = false;
  }
}

