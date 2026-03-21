import 'package:flutter/material.dart';
import 'package:keep_playing_frontend/constants.dart';

import 'buttons.dart';
import 'dialogs.dart';

enum LoginStatus {
  INVALID_CREDENTIALS,
  NOT_COACH_CREDENTIALS,
  NOT_ORGANISER_CREDENTIALS,
}

extension LoginStatusExtension on LoginStatus {
  String getTitle() {
    switch (this) {
      case LoginStatus.INVALID_CREDENTIALS:
        return 'Invalid Credentials';
      case LoginStatus.NOT_COACH_CREDENTIALS:
        return 'You tried to log in with a non-coach account';
      case LoginStatus.NOT_ORGANISER_CREDENTIALS:
        return 'You tried to log in with a non-organiser account';
    }
  }

  String getContent() {
    switch (this) {
      case LoginStatus.INVALID_CREDENTIALS:
        return 'Please try again.';
      case LoginStatus.NOT_COACH_CREDENTIALS:
        return 'Please log in with a coach account.';
      case LoginStatus.NOT_ORGANISER_CREDENTIALS:
        return 'Please log in with an organiser account.';
    }
  }
}

class InvalidCredentialsDialog extends StatelessWidget {
  final LoginStatus loginStatus;

  const InvalidCredentialsDialog({
    Key? key,
    required this.loginStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget okButton = Container(
      padding: const EdgeInsets.all(BUTTON_PADDING),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: APP_COLOR,
          textStyle: const TextStyle(fontSize: BUTTON_FONT_SIZE),
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('OK'),
      ),
    );

    return SimpleDialog(
      contentPadding: const EdgeInsets.all(DIALOG_PADDING),
      title: Text(loginStatus.getTitle()),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(10),
          child: Text(loginStatus.getContent()),
        ),
        Center(child: okButton),
      ],
    );
  }
}
