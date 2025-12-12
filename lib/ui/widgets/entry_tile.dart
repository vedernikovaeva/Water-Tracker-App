import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/drink_entry.dart';
import '../../state/tracker_state.dart';

class EntryTile extends StatelessWidget {
  final DrinkEntry entry;

  const EntryTile({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final state = context.read<TrackerState>();
    final hydration = state.hydrationForEntry(entry);
    final time = DateFormat('HH:mm').format(entry.at);

    return Card(
      child: ListTile(
        leading: _iconFor(entry.type),
        title: Text('${entry.title} • ${entry.ml}ml'),
        subtitle: Text('$time • Hydration ${hydration}ml'),
        trailing: IconButton(
          onPressed: () => state.deleteEntry(entry.id),
          icon: const Icon(Icons.delete_outline),
        ),
      ),
    );
  }

  Widget _iconFor(DrinkType t) {
    switch (t) {
      case DrinkType.water:
        return const Icon(Icons.water_drop_outlined);
      case DrinkType.tea:
        return const Icon(Icons.emoji_food_beverage_outlined);
      case DrinkType.coffee:
        return const Icon(Icons.coffee_outlined);
      case DrinkType.juice:
        return const Icon(Icons.local_bar_outlined);
      case DrinkType.soda:
        return const Icon(Icons.local_drink_outlined);
      case DrinkType.energy:
        return const Icon(Icons.bolt_outlined);
      case DrinkType.other:
        return const Icon(Icons.category_outlined);
    }
  }
}
