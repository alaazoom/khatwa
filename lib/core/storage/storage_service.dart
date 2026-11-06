import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

abstract final class StorageKeys {
  static const themeMode = 'theme_mode';
  static const language = 'language_code';
  static const isLoggedIn = 'is_logged_in';
  static const user = 'user_json';
  static const childProfile = 'child_profile_json';
  static const children = 'children_json';
  static const activeChildId = 'active_child_id';
  static String devices(String childId) => 'devices_$childId';
  static String report(String childId) => 'report_$childId';
  static String cards(String childId) => 'cards_$childId';
  static String routine(String childId) => 'routine_$childId';
  static const notifyRoutine = 'notify_routine';
  static const notifyReports = 'notify_reports';
}

/// GetStorage للتفضيلات والبيانات المحلية، وFlutterSecureStorage للرموز الحساسة.
class StorageService extends GetxService {
  final GetStorage _box = GetStorage();
  final FlutterSecureStorage _secure = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const String _tokenKey = 'auth_token';

  T? read<T>(String key) => _box.read<T>(key);

  Future<void> write(String key, Object? value) => _box.write(key, value);

  Future<void> remove(String key) => _box.remove(key);

  Future<void> saveToken(String token) =>
      _secure.write(key: _tokenKey, value: token);

  Future<String?> readToken() => _secure.read(key: _tokenKey);

  Future<void> deleteToken() => _secure.delete(key: _tokenKey);
}