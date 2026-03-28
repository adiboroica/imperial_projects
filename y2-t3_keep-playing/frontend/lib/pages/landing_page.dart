import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../state/auth_cubit.dart';
import '../state/auth_state.dart';
import 'coach/coach_home_page.dart';
import 'coach/coach_login_page.dart';
import 'organiser/organiser_home_page.dart';
import 'organiser/organiser_login_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  static const _bannerDismissedKey = 'SERVICE_BANNER_DISMISSED_v1';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowBanner();
      _waitForSessionRestore();
    });
  }

  Future<void> _waitForSessionRestore() async {
    final authCubit = context.read<AuthCubit>();
    // Wait for restoreSession to complete
    await authCubit.sessionRestored;
    if (!mounted) return;
    final state = authCubit.state;
    if (state is AuthAuthenticated) {
      _navigateForUser(state.user);
    }
  }

  void _navigateForUser(User user) {
    if (user.isOrganiser) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OrganiserHomePage()),
      );
    } else if (user.isCoach) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CoachHomePage()),
      );
    }
  }

  Future<void> _maybeShowBanner() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_bannerDismissedKey) == true) return;
    if (!mounted) return;

    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        padding: const EdgeInsets.all(16),
        leading: const Icon(Icons.info_outline, color: Colors.orange),
        backgroundColor: Colors.amber.shade50,
        content: const Text(
          'Some features are temporarily unavailable while we upgrade '
          'our systems.\n\n'
          '- Email notifications (job offers, acceptances, cancellations) '
          'are paused. Please check the app directly for updates.\n'
          '- Cloud storage for qualification images is temporarily disabled.',
        ),
        actions: [
          TextButton(
            onPressed: _dismissBanner,
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Future<void> _dismissBanner() async {
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_bannerDismissedKey, true);
  }

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
