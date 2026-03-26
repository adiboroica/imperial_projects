import 'package:flutter/material.dart';

import 'coach/coach_login_page.dart';
import 'organiser/organiser_login_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _RoleButton(
              label: 'Enter as organiser',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OrganiserLoginPage()),
              ),
            ),
            const SizedBox(height: 50),
            _RoleButton(
              label: 'Enter as coach',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CoachLoginPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _RoleButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 300,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(fontSize: 25),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
