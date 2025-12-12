import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/achievements.dart';
import '../state/tracker_state.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TrackerState>();
    final unlocked = state.unlocked;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events_outlined),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${unlocked.length} / ${allAchievements.length} unlocked',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...allAchievements.map((a) {
            final ok = unlocked.contains(a.key);
            return Card(
              child: ListTile(
                leading: Icon(ok ? Icons.check_circle : Icons.lock_outline),
                title: Text(a.title),
                subtitle: Text(a.description),
                trailing: ok ? const Text('Unlocked') : const Text('Locked'),
              ),
            );
          }),
        ],
      ),
    );
  }
}
