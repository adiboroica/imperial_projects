import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:keep_playing_frontend/models/event.dart';
import 'package:keep_playing_frontend/models/user.dart';
import 'package:keep_playing_frontend/widgets/app_theme.dart';

enum UserInfoType { user, coach, organiser }

extension UserInfoTypeLabel on UserInfoType {
  String get label => switch (this) {
        UserInfoType.user => 'User',
        UserInfoType.coach => 'Coach',
        UserInfoType.organiser => 'Organiser',
      };
}

class UserInfoListTile extends StatelessWidget {
  final User user;
  final Event event;
  final UserInfoType type;

  const UserInfoListTile({
    super.key,
    required this.user,
    required this.event,
    required this.type,
  });

  void _launchEmail() async {
    if (user.email.isEmpty) return;
    // Encode both the email and subject so a user-registered string like
    // "a@b.com?cc=evil@example.com" can't smuggle extra mailto headers.
    final encodedEmail = Uri.encodeComponent(user.email);
    final subject = Uri.encodeComponent('${event.name}, on: ${DateFormat.MMMEd().format(event.date)}');
    final url = 'mailto:$encodedEmail?subject=$subject';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(
        '${type.label}\nInformation',
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppTheme.primaryColor),
      ),
      title: Text(user.fullName),
      trailing: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
        onPressed: _launchEmail,
        child: const Icon(Icons.email, color: Colors.white),
      ),
      onTap: () => showDialog(
        context: context,
        builder: (_) => UserInfoDialog(user: user, type: type),
      ),
    );
  }
}

class UserInfoDialog extends StatelessWidget {
  final User user;
  final UserInfoType type;

  const UserInfoDialog({super.key, required this.user, required this.type});

  static const _titleStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: AppTheme.primaryColor,
  );

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: const EdgeInsets.all(AppTheme.paddingMedium),
      title: Center(
        child: Text('${type.label} Information', style: _titleStyle.copyWith(fontSize: 20)),
      ),
      children: [
        ListTile(leading: const Icon(Icons.person), title: const Text('Name', style: _titleStyle), subtitle: Text(user.fullName)),
        ListTile(leading: const Icon(Icons.email), title: const Text('Email', style: _titleStyle), subtitle: Text(user.email)),
        ListTile(leading: const Icon(Icons.location_on), title: const Text('Location', style: _titleStyle), subtitle: Text(user.location)),
      ],
    );
  }
}