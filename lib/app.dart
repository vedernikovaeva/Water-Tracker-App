import 'package:flutter/material.dart';
import 'ui/home_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF4F8EF7),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Drink Tracker',
      theme: base.copyWith(
        scaffoldBackgroundColor: base.colorScheme.surface,
        cardTheme: CardThemeData(
          elevation: 0,
          color: base.colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      home: const HomePage(),
    );
  }
}
