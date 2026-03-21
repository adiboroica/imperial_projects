import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:keep_playing_frontend/api_manager/api.dart';
import 'package:keep_playing_frontend/constants.dart';
import 'package:keep_playing_frontend/models/event.dart';
import 'package:keep_playing_frontend/models/user.dart';
import 'package:keep_playing_frontend/widgets/buttons.dart';
import 'package:keep_playing_frontend/widgets/dialogs.dart';
import 'package:keep_playing_frontend/widgets/icons.dart';
import 'package:keep_playing_frontend/widgets/loading_widgets.dart';
import 'package:url_launcher/url_launcher_string.dart';

class UserWidgets {
  final User user;

  UserWidgets({required this.user});

  static const TextStyle _textStyleForTitle =
      TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: APP_COLOR);

  List<Widget> getDetailsAboutUser() {
    return <Widget>[
      ListTile(
        leading: UserIcons.NAME_ICON,
        title: const Text('Name', style: _textStyleForTitle),
        subtitle: Text('${user.firstName} ${user.lastName}'),
      ),
      ListTile(
        leading: UserIcons.EMAIL_ICON,
        title: const Text('Email', style: _textStyleForTitle),
        subtitle: Text(user.email),
      ),
      ListTile(
        leading: UserIcons.LOCATION_ICON,
        title: const Text('Location', style: _textStyleForTitle),
        subtitle: Text(user.location),
      ),
    ];
  }
}

// **************************************************************************
// **************** COACH INFORMATION
// **************************************************************************

enum UserInfoType {
  USER,
  COACH,
  ORGANISER,
}

extension UserInfoTypeExtension on UserInfoType {
  String getString() {
    switch (this) {
      case UserInfoType.USER:
        return 'User';
      case UserInfoType.COACH:
        return 'Coach';
      case UserInfoType.ORGANISER:
        return 'Organiser';
    }
  }
}

class UserInfoListTile extends StatelessWidget {
  final User user;
  final Event event;

  final UserInfoType userInfoType;

  const UserInfoListTile({
    super.key,
    required this.user,
    required this.event,
    required this.userInfoType,
  });

  Future _launchEmail({
    required String toEmail,
    required String subject,
  }) async {
    final url = 'mailto:$toEmail?subject=${Uri.encodeFull(subject)}&body=';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget messageCoachButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: APP_COLOR,
        textStyle: const TextStyle(fontSize: BUTTON_FONT_SIZE),
      ),
      onPressed: () {
        _launchEmail(
          toEmail: user.email,
          subject:
              '${event.name}, on: ${DateFormat.MMMEd().format(event.date)}',
        );
      },
      child: UserIcons.EMAIL_ICON,
    );

    return ListTile(
      leading: Text(
        "${userInfoType.getString()}\nInformation",
        textAlign: TextAlign.center,
        style: const TextStyle(color: APP_COLOR),
      ),
      title: Text(user.getFullName()),
      trailing: messageCoachButton,
      onTap: () {
        showDialog(
          context: context,
          builder: (_) =>
              UserInfoDialog(userInfoType: userInfoType).byUser(user),
        );
      },
    );
  }
}

class UserInfoDialog {
  final UserInfoType userInfoType;

  UserInfoDialog({required this.userInfoType});

  Widget byUser(User user) {
    return SimpleDialog(
      contentPadding: const EdgeInsets.all(DIALOG_PADDING),
      title: Center(
        child: Text(
          '${userInfoType.getString()} Information',
          style: UserWidgets._textStyleForTitle,
          textScaleFactor: 1.5,
        ),
      ),
      children: UserWidgets(user: user).getDetailsAboutUser(),
    );
  }

  Widget byUserPK(int pk) {
    return _UserPKInfoDialog(userPK: pk, userInfoType: userInfoType);
  }
}

class _UserPKInfoDialog extends StatefulWidget {
  final int userPK;
  final UserInfoType userInfoType;

  const _UserPKInfoDialog({
    Key? key,
    required this.userPK,
    required this.userInfoType,
  }) : super(key: key);

  @override
  State<_UserPKInfoDialog> createState() => _UserPKInfoDialogState();
}

class _UserPKInfoDialogState extends State<_UserPKInfoDialog> {
  User? _user;

  @override
  void initState() {
    _retrieveCoachInformation();

    super.initState();
  }

  void _retrieveCoachInformation() async {
    User? retrievedUser = await API.user.getUser(widget.userPK);

    setState(() {
      _user = retrievedUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool userInfoIsNotLoaded = _user == null;

    if (userInfoIsNotLoaded) {
      return const LoadingDialog();
    }

    return UserInfoDialog(userInfoType: widget.userInfoType).byUser(_user!);
  }
}
