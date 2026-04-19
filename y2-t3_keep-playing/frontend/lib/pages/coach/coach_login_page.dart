import 'package:flutter/material.dart';

import 'package:keep_playing_frontend/pages/shared_login_page.dart';
import 'package:keep_playing_frontend/pages/coach/coach_home_page.dart';
import 'package:keep_playing_frontend/pages/coach/coach_sign_up_page.dart';

class CoachLoginPage extends StatelessWidget {
  const CoachLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SharedLoginPage(
      title: 'Coach Login',
      roleCheck: (user) => user.isCoach,
      roleErrorMessage: 'This account is not registered as a coach.',
      buildSignUpPage: () => const CoachSignUpPage(),
      buildHomePage: () => const CoachHomePage(),
    );
  }
}
