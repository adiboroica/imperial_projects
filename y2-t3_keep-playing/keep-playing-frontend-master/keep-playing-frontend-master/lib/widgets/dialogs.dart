import 'package:flutter/material.dart';
import 'package:keep_playing_frontend/widgets/buttons.dart';

import '../constants.dart';

const double DIALOG_PADDING = 16;

class ConfirmationDialog extends StatelessWidget {
  final String title;

  const ConfirmationDialog({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final Widget yesButton = Container(
      padding: const EdgeInsets.all(BUTTON_PADDING),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: APP_COLOR,
          textStyle: const TextStyle(fontSize: BUTTON_FONT_SIZE),
        ),
        onPressed: () => Navigator.of(context).pop(true),
        child: const Text('Yes'),
      ),
    );

    final Widget noButton = Container(
      padding: const EdgeInsets.all(BUTTON_PADDING),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: BUTTON_GRAY_COLOR,
          textStyle: const TextStyle(fontSize: BUTTON_FONT_SIZE),
        ),
        onPressed: () => Navigator.of(context).pop(false),
        child: const Text('No'),
      ),
    );

    return SimpleDialog(
      contentPadding: const EdgeInsets.all(DIALOG_PADDING),
      title: Center(child: Text(title)),
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [yesButton, noButton],
        ),
      ],
    );
  }
}

class ExitDialog extends StatelessWidget {
  final String title;
  final String text;

  const ExitDialog({
    super.key,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final Widget yesButton = Container(
      padding: const EdgeInsets.all(BUTTON_PADDING),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: APP_COLOR,
          textStyle: const TextStyle(fontSize: BUTTON_FONT_SIZE),
        ),
        onPressed: () => Navigator.of(context).pop(true),
        child: const Text('Yes'),
      ),
    );

    final Widget noButton = Container(
      padding: const EdgeInsets.all(BUTTON_PADDING),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: BUTTON_GRAY_COLOR,
          textStyle: const TextStyle(fontSize: BUTTON_FONT_SIZE),
        ),
        onPressed: () => Navigator.of(context).pop(false),
        child: const Text('No'),
      ),
    );

    return SimpleDialog(
      contentPadding: const EdgeInsets.all(DIALOG_PADDING),
      title: Center(child: Text(title)),
      children: <Widget>[
        Container(padding: const EdgeInsets.all(10), child: Text(text)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [yesButton, noButton],
        ),
      ],
    );
  }
}

// **************************************************************************
// **************** REQUESTS
// **************************************************************************

class RequestFailedDialog extends StatelessWidget {
  const RequestFailedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final Widget okButton = Container(
      padding: const EdgeInsets.all(BUTTON_PADDING),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: APP_COLOR,
          textStyle: const TextStyle(fontSize: BUTTON_FONT_SIZE),
        ),
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Ok'),
      ),
    );

    return SimpleDialog(
      contentPadding: const EdgeInsets.all(DIALOG_PADDING),
      title: const Center(child: Text('Request Failed')),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(10),
          child: const Text('Please try again'),
        ),
        Center(child: okButton),
      ],
    );
  }
}

showRequestFailedDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => const RequestFailedDialog(),
    barrierDismissible: false,
  );
}
