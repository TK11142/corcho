import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/boards/presentation/corkboard_page.dart';

void main() => runApp(const ProviderScope(child: CorchoApp()));

class CorchoApp extends StatelessWidget {
  const CorchoApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Corcho',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xffc65e3f)),
          fontFamily: 'sans-serif',
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xffd8ad64),
            brightness: Brightness.dark,
          ),
        ),
        themeMode: ThemeMode.system,
        home: const CorkboardPage(),
      );
}
