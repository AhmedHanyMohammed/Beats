import 'package:shared_preferences/shared_preferences.dart';
import 'package:beats/components/notifiers.dart';

class UserPrefs {
  UserPrefs._();
  static final UserPrefs instance = UserPrefs._();

  static const _firstNameKey = 'user_first_name';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_firstNameKey);
    if (saved != null && saved.trim().isNotEmpty) {
      userFirstNameNotifier.value = saved.trim();
    }
  }

  Future<void> setFirstName(String first) async {
    final val = first.trim();
    if (val.isEmpty) return;
    userFirstNameNotifier.value = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_firstNameKey, val);
  }
}

