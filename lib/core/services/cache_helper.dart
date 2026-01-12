import 'package:waqty_user_application/core/services/services_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static late SharedPreferences _sharedPreferences;
  static late FlutterSecureStorage _secureStorage;

  static init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _secureStorage = getIt();
  }

  // private constructor as I don't want to allow creating an instance of this class itself.
  CacheHelper._();

  /// Saves a [value] with a [key] in the SharedPreferences.
  static setData(String key, value) async {
    debugPrint("SharedPrefHelper : setData with key : $key and value : $value");
    switch (value.runtimeType) {
      case String:
        await _sharedPreferences.setString(key, value);
        break;
      case int:
        await _sharedPreferences.setInt(key, value);
        break;
      case bool:
        await _sharedPreferences.setBool(key, value);
        break;
      case double:
        await _sharedPreferences.setDouble(key, value);
        break;
      default:
        return null;
    }
  }

  /// Gets a bool value from SharedPreferences with given [key].
  static Future<bool> getBool(String key) async {
    debugPrint('SharedPrefHelper : getBool with key : $key');
    return _sharedPreferences.getBool(key) ?? true;
  }

  /// Gets a double value from SharedPreferences with given [key].
  static double? getDouble(String key) {
    debugPrint('SharedPrefHelper : getDouble with key : $key');
    return _sharedPreferences.getDouble(key);
  }

  /// Gets an int value from SharedPreferences with given [key].
  static getInt(String key) async {
    debugPrint('SharedPrefHelper : getInt with key : $key');
    return _sharedPreferences.getInt(key);
  }

  /// Gets an String value from SharedPreferences with given [key].

  static String? getString(String key) {
    debugPrint('SharedPrefHelper : getString with key : $key');
    return _sharedPreferences.getString(key);
  }

  /// Removes a value from SharedPreferences with given [key].
  static removeData(String key) async {
    debugPrint('SharedPrefHelper : data with key : $key has been removed');
    await _sharedPreferences.remove(key);
  }

  /// Removes all keys and values in the SharedPreferences
  static clearAllData() async {
    debugPrint('SharedPrefHelper : all data has been cleared');
    await _sharedPreferences.clear();
  }

  /// Saves a [value] with a [key] in the FlutterSecureStorage.
  static setSecuredString(String key, String value) async {
    debugPrint(
        "FlutterSecureStorage : setSecuredString with key : $key and value : $value");
    await _secureStorage.write(key: key, value: value);
  }

  /// Gets an String value from FlutterSecureStorage with given [key].
  static getSecuredString(String key) async {
    debugPrint('FlutterSecureStorage : getSecuredString with key :');
    return await _secureStorage.read(key: key) ?? '';
  }

  /// Removes a value from FlutterSecureStorage with given [key]

  static removeSecureData(String key) async {
    debugPrint('FlutterSecureStorage : data has been deleted');
    return await _secureStorage.delete(key: key);
  }

  /// Removes all keys and values in the FlutterSecureStorage
  static clearAllSecuredData() async {
    debugPrint('FlutterSecureStorage : all data has been cleared');
    await _secureStorage.deleteAll();
  }
}
