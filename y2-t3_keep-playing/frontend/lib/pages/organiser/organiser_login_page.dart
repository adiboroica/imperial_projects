import 'package:flutter/material.dart';

import 'package:keep_playing_frontend/pages/shared_login_page.dart';
import 'package:keep_playing_frontend/pages/organiser/organiser_home_page.dart';
import 'package:keep_playing_frontend/pages/organiser/organiser_sign_up_page.dart';

class OrganiserLoginPage extends StatelessWidget {
  const OrganiserLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SharedLoginPage(
      title: 'Organiser Login',
      roleCheck: (user) => user.isOrganiser,
      roleErrorMessage: 'This account is not registered as an organiser.',
      buildSignUpPage: () => const OrganiserSignUpPage(),
      buildHomePage: () => const OrganiserHomePage(),
    );
  }
}
