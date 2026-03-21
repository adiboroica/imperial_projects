import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:keep_playing_frontend/models/user/user_sign_in.dart';
import 'package:keep_playing_frontend/widgets/buttons.dart';
import 'package:keep_playing_frontend/widgets/dialogs.dart';

import '../api_manager/api.dart';

class OrganiserSignUpPage extends StatefulWidget {
  const OrganiserSignUpPage({Key? key}) : super(key: key);

  @override
  State<OrganiserSignUpPage> createState() => _OrganiserSignUpPageState();
}

class _OrganiserSignUpPageState extends State<OrganiserSignUpPage> {
  String _username = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    final Widget usernameForm = ListTile(
      title: TextFormField(
        initialValue: _username,
        readOnly: false,
        decoration: const InputDecoration(
          hintText: 'Enter username',
          labelText: 'Username',
        ),
        onChanged: (text) {
          _username = text;
        },
      ),
    );

    final Widget passwordForm = ListTile(
      title: TextFormField(
        initialValue: _password,
        obscureText: true,
        readOnly: false,
        decoration: const InputDecoration(
          hintText: 'Enter password',
          labelText: 'Password',
        ),
        onChanged: (text) {
          _password = text;
        },
      ),
    );

    final Widget signUpButton = Container(
      padding: const EdgeInsets.all(BUTTON_PADDING),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: SIGN_UP_BUTTON_COLOR,
          textStyle: const TextStyle(fontSize: BUTTON_FONT_SIZE),
        ),
        onPressed: () async {
          NavigatorState navigator = Navigator.of(context);
          OrganiserSignUp organiserSignUp = OrganiserSignUp(
            username: _username,
            password: _password,
          );

          final Response response = await API.user.signUpAsOrganiser(
            organiserSignUp: organiserSignUp,
          );
          if (response.statusCode == HTTP_200_OK) {
            navigator.pop();
          } else {
            showDialog(
              context: context,
              builder: (_) => const RequestFailedDialog(),
              barrierDismissible: false,
            );
          }
        },
        child: const Text('Sign Up as Organiser'),
      ),
    );

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sign Up as Organiser'),
        ),
        body: ListView(
          children: [
            usernameForm,
            passwordForm,
            const SizedBox(height: 50.0),
            Center(child: signUpButton),
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (_) => const ExitDialog(
              title: 'Are you sure that you want to exit?',
              text: 'You haven\'t created your account.'),
        )) ??
        false;
  }
}
