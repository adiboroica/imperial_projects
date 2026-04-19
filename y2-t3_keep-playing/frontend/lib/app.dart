import 'package:flutter/material.dart';

import 'package:keep_playing_frontend/pages/landing_page.dart';
import 'package:keep_playing_frontend/widgets/app_theme.dart';

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
