import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'state/tracker_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = TrackerState();
  await state.load();
  runApp(
    ChangeNotifierProvider.value(
      value: state,
      child: const App(),
    ),
  );
}
