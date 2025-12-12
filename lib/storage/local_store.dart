import 'package:shared_preferences/shared_preferences.dart';
import '../models/drink_entry.dart';

class LocalStore {
  static const _kEntries = 'entries_v1';
  static const _kGoal = 'daily_goal_ml_v1';
  static const _kUnlocked = 'ach_unlocked_v1';

  Future<(List<DrinkEntry>, int, Set<String>)> loadAll() async {
    final sp = await SharedPreferences.getInstance();
    final s = sp.getString(_kEntries);
    final entries = (s == null || s.isEmpty) ? <DrinkEntry>[] : DrinkEntry.decodeList(s);
    final goal = sp.getInt(_kGoal) ?? 2000;
    final unlocked = sp.getStringList(_kUnlocked)?.toSet() ?? <String>{};
    entries.sort((a, b) => b.at.compareTo(a.at));
    return (entries, goal, unlocked);
  }

  Future<void> saveEntries(List<DrinkEntry> entries) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kEntries, DrinkEntry.encodeList(entries));
  }

  Future<void> saveGoal(int goal) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kGoal, goal);
  }

  Future<void> saveUnlocked(Set<String> keys) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setStringList(_kUnlocked, keys.toList()..sort());
  }
}
