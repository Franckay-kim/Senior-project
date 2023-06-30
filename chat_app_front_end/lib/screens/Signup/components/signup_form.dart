import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../components/already_have_an_account_acheck.dart';
import '../../../constants.dart';
import '../../../services/api_service.dart';
import '../../Login/login_screen.dart';

class SignUpForm extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignUpForm> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmationController =
      TextEditingController();

  String errorMessage = '';

  Future<void> handleSignup(String email, String name, String password,
      String password_confirmation) async {
    final email = emailController.text;
    final name = nameController.text;
    final password = passwordController.text;
    final password_confirmation = passwordConfirmationController.text;

    final response =
        await ApiService.signup(email, password, name, password_confirmation);

    if (response.statusCode == 200) {
      // Signup successful
      // Navigate to the login screen or any other screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    } else {
      // Signup failed
      setState(() {
        errorMessage = jsonDecode(response.body)['message'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          SizedBox(height: defaultPadding / 2),
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
            controller: emailController,
            onSaved: (email) {},
            decoration: InputDecoration(
              hintText: "Your email",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
            ),
          ),
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            controller: nameController,
            onSaved: (name) {},
            decoration: InputDecoration(
              hintText: "Your name",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              textInputAction: TextInputAction.done,
              obscureText: true,
              controller: passwordController,
              cursorColor: kPrimaryColor,
              decoration: InputDecoration(
                hintText: "Your password",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              textInputAction: TextInputAction.done,
              obscureText: true,
              controller: passwordConfirmationController,
              cursorColor: kPrimaryColor,
              decoration: InputDecoration(
                hintText: "Confirm password",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock),
                ),
              ),
            ),
          ),
          SizedBox(height: defaultPadding / 2),
          ElevatedButton(
            onPressed: () {
              // Call the signup function here
              handleSignup(emailController.text, passwordController.text,
                  nameController.text, passwordConfirmationController.text);
            },
            child: Text("Sign Up".toUpperCase()),
          ),
          SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            login: false,
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return LoginScreen();
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
