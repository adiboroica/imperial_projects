import 'package:flutter/material.dart';

import 'pages/landing_page.dart';
import 'widgets/app_theme.dart';

class KeepPlayingApp extends StatelessWidget {
  const KeepPlayingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Keep Playing',
      theme: AppTheme.themeData,
      home: const LandingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
