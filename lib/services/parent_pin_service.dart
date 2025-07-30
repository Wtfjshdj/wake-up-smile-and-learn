import 'package:shared_preferences/shared_preferences.dart';

class ParentPinService {
  static const String _pinKey = 'parent_mode_pin';
  static const String _attemptsKey = 'parent_mode_attempts';

  Future<void> setPin(String pin) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, pin);
    await prefs.setInt(_attemptsKey, 0);
  }

  Future<String?> getPin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pinKey);
  }

  Future<bool> validatePin(String pin) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedPin = prefs.getString(_pinKey);
    if (savedPin == pin) {
      await prefs.setInt(_attemptsKey, 0);
      return true;
    } else {
      int attempts = prefs.getInt(_attemptsKey) ?? 0;
      attempts++;
      await prefs.setInt(_attemptsKey, attempts);
      return false;
    }
  }

  Future<int> getAttempts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_attemptsKey) ?? 0;
  }

  Future<void> resetAttempts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_attemptsKey, 0);
  }

  Future<void> changePin(String newPin) async {
    await setPin(newPin);
  }

  Future<void> clearPin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinKey);
    await prefs.setInt(_attemptsKey, 0);
  }
} 