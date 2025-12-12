import 'drink_entry.dart';

class Achievement {
  final String key;
  final String title;
  final String description;

  const Achievement(this.key, this.title, this.description);
}

class AchievementResult {
  final Set<String> unlocked;
  final List<Achievement> newlyUnlocked;

  const AchievementResult({
    required this.unlocked,
    required this.newlyUnlocked,
  });
}

const allAchievements = <Achievement>[
  Achievement('first_log', 'First sip', 'Add your first drink.'),
  Achievement('water_1000_day', '1L day', 'Reach 1000 ml of water in a day.'),
  Achievement('water_2000_day', '2L day', 'Reach 2000 ml of water in a day.'),
  Achievement('hydr_2000_day', 'Hydration hero', 'Reach 2000 ml hydration in a day.'),
  Achievement('7_day_streak', '7-day streak', 'Log drinks 7 days in a row.'),
  Achievement('30_logs', 'Regular', 'Add 30 entries total.'),
  Achievement('variety_4', 'Variety', 'Use 4 different drink types in one day.'),
];

AchievementResult evaluateAchievements({
  required List<DrinkEntry> entries,
  required Set<String> alreadyUnlocked,
  required DateTime now,
  required int dailyGoalMl,
}) {
  final unlocked = {...alreadyUnlocked};
  final newly = <Achievement>[];

  bool unlock(String key) {
    if (unlocked.contains(key)) return false;
    unlocked.add(key);
    final a = allAchievements.firstWhere((x) => x.key == key);
    newly.add(a);
    return true;
  }

  if (entries.isNotEmpty) unlock('first_log');
  if (entries.length >= 30) unlock('30_logs');

  final today = DateTime(now.year, now.month, now.day);
  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  final todayEntries = entries.where((e) => isSameDay(e.at, today)).toList();

  final waterToday = todayEntries
      .where((e) => e.type == DrinkType.water)
      .fold<int>(0, (s, e) => s + e.ml);

  final hydrationToday = todayEntries.fold<int>(0, (s, e) {
    final k = hydrationFactorPercent(e.type);
    return s + ((e.ml * k) ~/ 100);
  });

  if (waterToday >= 1000) unlock('water_1000_day');
  if (waterToday >= 2000) unlock('water_2000_day');
  if (hydrationToday >= 2000) unlock('hydr_2000_day');

  final typesToday = todayEntries.map((e) => e.type).toSet();
  if (typesToday.length >= 4) unlock('variety_4');

  final daysWithLogs = entries
      .map((e) => DateTime(e.at.year, e.at.month, e.at.day))
      .toSet()
      .toList()
    ..sort((a, b) => a.compareTo(b));

  int streak = 0;
  DateTime? prev;
  for (final d in daysWithLogs.reversed) {
    if (prev == null) {
      if (d.isAfter(today)) continue;
      if (d.difference(today).inDays == 0) {
        streak = 1;
        prev = d;
      } else {
        break;
      }
      continue;
    }
    final diff = prev.difference(d).inDays;
    if (diff == 1) {
      streak += 1;
      prev = d;
    } else {
      break;
    }
  }

  if (streak >= 7) unlock('7_day_streak');

  return AchievementResult(unlocked: unlocked, newlyUnlocked: newly);
}
