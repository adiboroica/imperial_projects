import 'package:flutter/material.dart';

import 'confirmation_dialog.dart';

class ExitGuard extends StatelessWidget {
  final String title;
  final String content;
  final Widget child;

  const ExitGuard({
    super.key,
    required this.title,
    required this.content,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (_) => ConfirmationDialog(title: title, content: content),
        );
        if (shouldPop == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: child,
    );
  }
}
