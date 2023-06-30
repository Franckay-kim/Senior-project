// ignore_for_file: unused_import

import 'dart:convert';

import 'package:MeChat/screens/welcome/welcome_screen.dart';
import 'package:flutter/material.dart';

import '../../../components/already_have_an_account_acheck.dart';
import '../../../constants.dart';
import '../../../messages.dart';
import '../../../services/api_service.dart';
import '../../Signup/signup_screen.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginForm> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String errorMessage = '';

  Future<void> handleLogin(String email, String password) async {
    final email = emailController.text;
    final password = passwordController.text;

    final response = await ApiService.login(email, password);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Login successful
      final responseBody = jsonDecode(response.body);
      final token = responseBody['token'];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WelcomeScreen(token: token),
        ),
      );
    } else {
      // Login failed
      final responseBody = jsonDecode(response.body);
      setState(() {
        errorMessage = responseBody['message'];
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          SizedBox(height: 16.0),
          Text(
            errorMessage,
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            onSaved: (email) {},
            controller: emailController,
            decoration: InputDecoration(
              hintText: "Your email",
              prefixIcon: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              textInputAction: TextInputAction.done,
              obscureText: true,
              controller: passwordController,
              cursorColor: kPrimaryColor,
              decoration: InputDecoration(
                hintText: "Your password",
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          Hero(
            tag: "login_btn",
            child: ElevatedButton(
                           onPressed: () {
                // Call the login function here
                handleLogin(emailController.text, passwordController.text);
              },

              child: Text("Login".toUpperCase()),
            ),
          ),
          const SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return SignUpScreen();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
