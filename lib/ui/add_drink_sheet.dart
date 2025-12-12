import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/drink_entry.dart';
import '../state/tracker_state.dart';

class AddDrinkSheet extends StatefulWidget {
  const AddDrinkSheet({super.key});

  @override
  State<AddDrinkSheet> createState() => _AddDrinkSheetState();
}

class _AddDrinkSheetState extends State<AddDrinkSheet> {
  DrinkType _type = DrinkType.water;
  final _ml = TextEditingController(text: '250');
  final _title = TextEditingController();

  @override
  void dispose() {
    _ml.dispose();
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 6, 16, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Add drink',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _TypeChips(
            value: _type,
            onChanged: (v) {
              setState(() => _type = v);
              if (_title.text.trim().isEmpty) {
                _title.text = defaultTitleForType(v);
                _title.selection = TextSelection.fromPosition(TextPosition(offset: _title.text.length));
              }
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _title,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _ml,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount (ml)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                final ml = int.tryParse(_ml.text.trim());
                if (ml == null || ml <= 0) return;
                await context.read<TrackerState>().addEntry(
                      type: _type,
                      ml: ml,
                      title: _title.text.trim(),
                    );
                if (context.mounted) Navigator.of(context).pop();
              },
              icon: const Icon(Icons.check),
              label: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeChips extends StatelessWidget {
  final DrinkType value;
  final ValueChanged<DrinkType> onChanged;

  const _TypeChips({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final items = DrinkType.values;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((t) {
        final selected = t == value;
        return ChoiceChip(
          selected: selected,
          label: Text(defaultTitleForType(t)),
          onSelected: (_) => onChanged(t),
        );
      }).toList(),
    );
  }
}
