import 'package:flutter/material.dart';

import 'app_theme.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String? content;

  const ConfirmationDialog({super.key, required this.title, this.content});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Center(child: Text(title)),
      contentPadding: const EdgeInsets.all(AppTheme.paddingMedium),
      children: [
        if (content != null)
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(content!),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes', style: TextStyle(color: Colors.white)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.mutedColor),
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class RequestFailedDialog extends StatelessWidget {
  const RequestFailedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Center(child: Text('Request Failed')),
      contentPadding: const EdgeInsets.all(AppTheme.paddingMedium),
      children: [
        const Padding(padding: EdgeInsets.all(10), child: Text('Please try again')),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Ok', style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }
}
