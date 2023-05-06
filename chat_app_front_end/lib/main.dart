import 'package:chat_app_front_end/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/screens/welcome/welcome_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Auth',
      theme: ThemeData(
        primaryColor: kPrimarycolor,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: welcomeScreen(),
    )
  }
}