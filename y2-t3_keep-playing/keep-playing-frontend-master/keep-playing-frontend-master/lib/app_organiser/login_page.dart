import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:keep_playing_frontend/api_manager/api.dart';
import 'package:keep_playing_frontend/constants.dart';
import 'package:keep_playing_frontend/models/user.dart';
import 'package:keep_playing_frontend/stored_data.dart';
import 'package:keep_playing_frontend/widgets/buttons.dart';
import 'package:keep_playing_frontend/widgets/images.dart';
import 'package:keep_playing_frontend/widgets/loading_widgets.dart';
import 'package:keep_playing_frontend/widgets/log_in.dart';

import 'home_page.dart';
import 'sign_up.dart';

class OrganiserLoginPage extends StatefulWidget {
  const OrganiserLoginPage({Key? key}) : super(key: key);

  @override
  State<OrganiserLoginPage> createState() => _OrganiserLoginPageState();
}

class _OrganiserLoginPageState extends State<OrganiserLoginPage> {
  TextStyle style = const TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  String _username = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    final Widget appLogo = APP_LOGO;

    final Widget usernameField = TextFormField(
      obscureText: false,
      style: style,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "Username",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32.0),
        ),
      ),
      onChanged: (text) {
        _username = text;
      },
    );

    final Widget passwordField = TextFormField(
      obscureText: true,
      style: style,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "Password",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32.0),
        ),
      ),
      onChanged: (text) {
        _password = text;
      },
    );

    Future<void> onLoginPressed() async {
      showLoadingDialog(context);

      UserLogin userLogin = UserLogin(username: _username, password: _password);

      final NavigatorState navigator = Navigator.of(context);

      Response response = await API.user.login(userLogin: userLogin);
      if (response.statusCode == HTTP_200_OK) {
        /* Save the token to shared preferences. */
        final body = jsonDecode(response.body);
        await StoredData.setLoginToken(body['token']);
        await StoredData.setCurrentUser();

        User currentUser = StoredData.getCurrentUser();
        if (currentUser.isOrganiserUser()) {
          navigator.pop();
          navigator.push(
            MaterialPageRoute(
              builder: (_) => const OrganiserHomePage(),
            ),
          );
        } else {
          navigator.pop();
          showDialog(
            context: context,
            builder: (_) => const InvalidCredentialsDialog(
                loginStatus: LoginStatus.NOT_ORGANISER_CREDENTIALS),
            barrierDismissible: false,
          );
        }
      } else {
        navigator.pop();
        showDialog(
          context: context,
          builder: (_) => const InvalidCredentialsDialog(
              loginStatus: LoginStatus.INVALID_CREDENTIALS),
          barrierDismissible: false,
        );
      }
    }

    final Widget loginButton = Container(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0),
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: APP_COLOR,
          textStyle: const TextStyle(fontSize: BUTTON_FONT_SIZE),
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32.0),
          ),
        ),
        onPressed: onLoginPressed,
        child: Text(
          "Log In as Organiser",
          textAlign: TextAlign.center,
          style: style.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    final Widget signUpAsOrganiserButton = Container(
      padding: const EdgeInsets.fromLTRB(0, BUTTON_PADDING, 0, 0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: SIGN_UP_BUTTON_COLOR,
          textStyle: const TextStyle(fontSize: BUTTON_FONT_SIZE),
        ),
        onPressed: () async {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const OrganiserSignUpPage(),
            ),
          );
        },
        child: const Text('Sign Up as Organiser'),
      ),
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                appLogo,
                usernameField,
                const SizedBox(height: 25.0),
                passwordField,
                const SizedBox(height: 35.0),
                loginButton,
                const SizedBox(height: 50.0),
                signUpAsOrganiserButton,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
