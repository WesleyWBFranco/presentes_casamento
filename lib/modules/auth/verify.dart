import 'package:flutter/material.dart';
import 'package:presentes_casamento/modules/auth/screens/login_screen.dart';
import 'package:presentes_casamento/modules/auth/screens/register_screen.dart';

class Verify extends StatefulWidget {
  const Verify({super.key});

  @override
  State<Verify> createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {
  bool showLoginPage = true;

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return RegisterScreen(onTap: togglePages);
    } else {
      return LoginScreen(onTap: togglePages);
    }
  }
}
