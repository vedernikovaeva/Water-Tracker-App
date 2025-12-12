import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/tracker_state.dart';
import 'widgets/entry_tile.dart';


class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DateTime _day = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TrackerState>();
    final entries = state.entriesForDay(_day);
    final hydration = entries.fold<int>(0, (s, e) => s + state.hydrationForEntry(e));
    final total = entries.fold<int>(0, (s, e) => s + e.ml);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(DateFormat('EEEE, d MMM y').format(_day))),
                      IconButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            firstDate: DateTime(DateTime.now().year - 3),
                            lastDate: DateTime.now(),
                            initialDate: _day,
                          );
                          if (picked != null) setState(() => _day = picked);
                        },
                        icon: const Icon(Icons.edit_calendar_outlined),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _MiniStat(title: 'Hydration', value: '${hydration}ml')),
                      const SizedBox(width: 12),
                      Expanded(child: _MiniStat(title: 'Total', value: '${total}ml')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('No entries for this day.', style: Theme.of(context).textTheme.bodyMedium),
              ),
            )
          else
            ...entries.map((e) => EntryTile(entry: e)),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String title;
  final String value;

  const _MiniStat({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
