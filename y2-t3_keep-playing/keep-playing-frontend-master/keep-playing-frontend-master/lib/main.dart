import 'package:flutter/material.dart';

import 'app_coach/login_page.dart';
import 'app_organiser/login_page.dart';
import 'constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Keep Playing',
      theme: ThemeData(
        primarySwatch: APP_COLOR,
      ),
      home: const EnterPage(title: 'Log In Page'),
    );
  }
}

class EnterPage extends StatefulWidget {
  const EnterPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<EnterPage> createState() => _EnterPageState();
}

class _EnterPageState extends State<EnterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _EnterAsOrganiserButton(),
            SizedBox(height: 50),
            _EnterAsCoachButton(),
          ],
        ),
      ),
    );
  }
}

class _EnterAsCoachButton extends StatelessWidget {
  const _EnterAsCoachButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.0,
      width: 300.0,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(fontSize: 25),
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CoachLoginPage(),
            ),
          );
        },
        child: const Text('Enter as coach'),
      ),
    );
  }
}

class _EnterAsOrganiserButton extends StatelessWidget {
  const _EnterAsOrganiserButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.0,
      width: 300.0,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(fontSize: 25),
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const OrganiserLoginPage(),
            ),
          );
        },
        child: const Text('Enter as organiser'),
      ),
    );
  }
}
