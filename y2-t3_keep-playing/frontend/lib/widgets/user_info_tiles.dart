import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../api/client.dart';
import '../api/users.dart';
import '../models/event.dart';
import '../models/user.dart';
import 'app_theme.dart';
import 'loading_indicator.dart';

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
    final subject = Uri.encodeFull('${event.name}, on: ${DateFormat.MMMEd().format(event.date)}');
    final url = 'mailto:${user.email}?subject=$subject';
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

class UserInfoDialogByPk extends StatefulWidget {
  final int userPk;
  final UserInfoType type;
  final ApiClient apiClient;

  const UserInfoDialogByPk({
    super.key,
    required this.userPk,
    required this.type,
    required this.apiClient,
  });

  @override
  State<UserInfoDialogByPk> createState() => _UserInfoDialogByPkState();
}

class _UserInfoDialogByPkState extends State<UserInfoDialogByPk> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await ApiUsers(client: widget.apiClient).getUser(widget.userPk);
    if (mounted) setState(() => _user = user);
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const SimpleDialog(children: [LoadingIndicator()]);
    }
    return UserInfoDialog(user: _user!, type: widget.type);
  }
}
