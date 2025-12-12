import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/drink_entry.dart';
import '../models/achievements.dart';
import '../storage/local_store.dart';

class TrackerState extends ChangeNotifier {
  final _store = LocalStore();

  List<DrinkEntry> _entries = [];
  int _dailyGoalMl = 2000;
  Set<String> _unlocked = {};
  List<Achievement> _lastNewlyUnlocked = [];

  List<DrinkEntry> get entries => _entries;
  int get dailyGoalMl => _dailyGoalMl;
  Set<String> get unlocked => _unlocked;
  List<Achievement> get lastNewlyUnlocked => _lastNewlyUnlocked;

  Future<void> load() async {
    final (e, goal, unlocked) = await _store.loadAll();
    _entries = e;
    _dailyGoalMl = goal;
    _unlocked = unlocked;
    _recomputeAchievements(DateTime.now(), persist: false);
    notifyListeners();
  }

  int hydrationForEntry(DrinkEntry e) {
    final k = hydrationFactorPercent(e.type);
    return ((e.ml * k) ~/ 100);
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  int waterToday(DateTime now) {
    final d = DateTime(now.year, now.month, now.day);
    return _entries
        .where((e) => _isSameDay(e.at, d) && e.type == DrinkType.water)
        .fold<int>(0, (s, e) => s + e.ml);
  }

  int hydrationToday(DateTime now) {
    final d = DateTime(now.year, now.month, now.day);
    return _entries.where((e) => _isSameDay(e.at, d)).fold<int>(0, (s, e) => s + hydrationForEntry(e));
  }

  int totalToday(DateTime now) {
    final d = DateTime(now.year, now.month, now.day);
    return _entries.where((e) => _isSameDay(e.at, d)).fold<int>(0, (s, e) => s + e.ml);
  }

  List<DrinkEntry> entriesForDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return _entries.where((e) => _isSameDay(e.at, d)).toList()..sort((a, b) => b.at.compareTo(a.at));
  }

  Future<void> addEntry({
    required DrinkType type,
    required int ml,
    String? title,
    DateTime? at,
  }) async {
    final now = DateTime.now();
    final entry = DrinkEntry(
      id: _id(),
      at: at ?? now,
      type: type,
      ml: max(1, ml),
      title: (title == null || title.trim().isEmpty) ? defaultTitleForType(type) : title.trim(),
    );
    _entries = [entry, ..._entries];
    await _store.saveEntries(_entries);
    _recomputeAchievements(now, persist: true);
    notifyListeners();
  }

  Future<void> deleteEntry(String id) async {
    _entries = _entries.where((e) => e.id != id).toList();
    await _store.saveEntries(_entries);
    _recomputeAchievements(DateTime.now(), persist: true);
    notifyListeners();
  }

  Future<void> setGoal(int ml) async {
    _dailyGoalMl = max(250, min(10000, ml));
    await _store.saveGoal(_dailyGoalMl);
    _recomputeAchievements(DateTime.now(), persist: true);
    notifyListeners();
  }

  void clearNewlyUnlocked() {
    _lastNewlyUnlocked = [];
    notifyListeners();
  }

  void _recomputeAchievements(DateTime now, {required bool persist}) {
    final res = evaluateAchievements(
      entries: _entries,
      alreadyUnlocked: _unlocked,
      now: now,
      dailyGoalMl: _dailyGoalMl,
    );
    _unlocked = res.unlocked;
    _lastNewlyUnlocked = res.newlyUnlocked;
    if (persist) {
      _store.saveUnlocked(_unlocked);
    }
  }

  String _id() {
    final t = DateTime.now().microsecondsSinceEpoch;
    final r = Random().nextInt(1 << 20);
    return '$t$r';
  }
}
