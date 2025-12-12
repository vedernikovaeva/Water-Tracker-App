import 'dart:convert';

enum DrinkType { water, tea, coffee, juice, soda, energy, other }

class DrinkEntry {
  final String id;
  final DateTime at;
  final DrinkType type;
  final int ml;
  final String title;

  const DrinkEntry({
    required this.id,
    required this.at,
    required this.type,
    required this.ml,
    required this.title,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'at': at.toIso8601String(),
      'type': type.name,
      'ml': ml,
      'title': title,
    };
  }

  static DrinkEntry fromMap(Map<String, dynamic> m) {
    return DrinkEntry(
      id: m['id'] as String,
      at: DateTime.parse(m['at'] as String),
      type: DrinkType.values.firstWhere((e) => e.name == (m['type'] as String)),
      ml: (m['ml'] as num).toInt(),
      title: m['title'] as String,
    );
  }

  static String encodeList(List<DrinkEntry> items) {
    return jsonEncode(items.map((e) => e.toMap()).toList());
  }

  static List<DrinkEntry> decodeList(String s) {
    final raw = jsonDecode(s) as List<dynamic>;
    return raw.map((e) => DrinkEntry.fromMap(e as Map<String, dynamic>)).toList();
  }
}

String defaultTitleForType(DrinkType t) {
  switch (t) {
    case DrinkType.water:
      return 'Water';
    case DrinkType.tea:
      return 'Tea';
    case DrinkType.coffee:
      return 'Coffee';
    case DrinkType.juice:
      return 'Juice';
    case DrinkType.soda:
      return 'Soda';
    case DrinkType.energy:
      return 'Energy';
    case DrinkType.other:
      return 'Other';
  }
}

int hydrationFactorPercent(DrinkType t) {
  switch (t) {
    case DrinkType.water:
      return 100;
    case DrinkType.tea:
      return 90;
    case DrinkType.coffee:
      return 80;
    case DrinkType.juice:
      return 70;
    case DrinkType.soda:
      return 60;
    case DrinkType.energy:
      return 55;
    case DrinkType.other:
      return 65;
  }
}
