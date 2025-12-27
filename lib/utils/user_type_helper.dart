import 'package:hunt_property/services/storage_service.dart';

/// Helper class for user type operations
class UserTypeHelper {
  /// Get the current user type (user/agent)
  static Future<String?> getUserType() async {
    return await StorageService.getUserType();
  }

  /// Check if the current user is an agent
  static Future<bool> isAgent() async {
    return await StorageService.isAgent();
  }

  /// Check if the current user is a regular user
  static Future<bool> isUser() async {
    return await StorageService.isUser();
  }

  /// Get user type display name (capitalized)
  static Future<String> getUserTypeDisplay() async {
    final userType = await getUserType();
    if (userType == null || userType.isEmpty) {
      return 'User';
    }
    return userType[0].toUpperCase() + userType.substring(1).toLowerCase();
  }

  /// Check if user type is available
  static Future<bool> hasUserType() async {
    final userType = await getUserType();
    return userType != null && userType.isNotEmpty;
  }
}

