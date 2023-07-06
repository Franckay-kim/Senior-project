import 'package:MeChat/constants.dart';
import 'package:MeChat/screens/Login/login_screen.dart';
import 'package:MeChat/screens/welcome/welcome_screen.dart';
import 'package:flutter/material.dart';

/// Page to redirect users to the appropriate page depending on the initial auth state
class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    // await for for the widget to mount
    await Future.delayed(Duration.zero);

    final session = supabase.auth.currentSession;
    if (session == null) {
      Navigator.of(context)
          .pushAndRemoveUntil(LoginScreen.route(), (route) => false);
    } else {
      Navigator.of(context)
          .pushAndRemoveUntil(WelcomeScreen.route(), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: preloader);
  }
}
