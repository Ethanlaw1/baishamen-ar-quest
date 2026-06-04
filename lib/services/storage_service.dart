import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static Future<Set<String>> getCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('completed') ?? [];
    return list.toSet();
  }

  static Future<void> markCompleted(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('completed') ?? [];
    if (!list.contains(id)) list.add(id);
    await prefs.setStringList('completed', list);
  }

  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('completed');
  }
}
