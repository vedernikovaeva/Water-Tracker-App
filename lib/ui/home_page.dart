import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/tracker_state.dart';
import '../models/drink_entry.dart';
import 'add_drink_sheet.dart';
import 'history_page.dart';
import 'achievements_page.dart';
import 'widgets/stat_card.dart';
import 'widgets/entry_tile.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TrackerState>();
    final now = DateTime.now();
    final hydration = state.hydrationToday(now);
    final goal = state.dailyGoalMl;
    final progress = goal == 0 ? 0.0 : (hydration / goal).clamp(0.0, 1.0);
    final water = state.waterToday(now);
    final total = state.totalToday(now);
    final todayEntries = state.entriesForDay(now);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.lastNewlyUnlocked.isNotEmpty) {
        final a = state.lastNewlyUnlocked.first;
        state.clearNewlyUnlocked();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Achievement unlocked: ${a.title}'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('EEE, d MMM').format(now)),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AchievementsPage())),
            icon: const Icon(Icons.emoji_events_outlined),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HistoryPage())),
            icon: const Icon(Icons.calendar_month_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            builder: (_) => const AddDrinkSheet(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Today hydration',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Text('${hydration}ml / ${goal}ml'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(minHeight: 10, value: progress),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _setGoalDialog(context, state),
                          icon: const Icon(Icons.tune),
                          label: const Text('Goal'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => context.read<TrackerState>().addEntry(type: DrinkType.water, ml: 250),
                          icon: const Icon(Icons.water_drop_outlined),
                          label: const Text('+250ml water'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: StatCard(title: 'Water', value: '${water}ml', icon: Icons.water_drop_outlined)),
              const SizedBox(width: 12),
              Expanded(child: StatCard(title: 'Total drinks', value: '${total}ml', icon: Icons.local_drink_outlined)),
            ],
          ),
          const SizedBox(height: 12),
          Text('Today log', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (todayEntries.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No entries yet. Tap Add or +250ml water.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            )
          else
            ...todayEntries.map((e) => EntryTile(entry: e)),
        ],
      ),
    );
  }

  Future<void> _setGoalDialog(BuildContext context, TrackerState state) async {
    final controller = TextEditingController(text: state.dailyGoalMl.toString());
    final res = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Daily goal (ml)'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'e.g. 2000'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final v = int.tryParse(controller.text.trim());
              if (v == null) return;
              Navigator.of(context).pop(v);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (res != null) {
      await state.setGoal(res);
    }
  }
}
