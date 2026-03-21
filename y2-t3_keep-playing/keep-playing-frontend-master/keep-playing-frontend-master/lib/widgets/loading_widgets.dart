import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:keep_playing_frontend/constants.dart';

import 'dialogs.dart';

const Widget LOADING_CIRCLE = SpinKitCircle(
  color: APP_COLOR,
  size: 50.0,
);

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: LOADING_CIRCLE,
    );
  }
}

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SimpleDialog(
      contentPadding: EdgeInsets.all(DIALOG_PADDING),
      children: [LOADING_CIRCLE],
    );
  }
}

showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => const LoadingDialog(),
    barrierDismissible: false,
  );
}
