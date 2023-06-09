import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../components/already_have_an_account_acheck.dart';
import '../../../constants.dart';
import '../../../messages.dart';
import '../../Login/login_screen.dart';

class SignUpForm extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignUpForm> {
  final bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  String errorMessage = '';

  Future<void> _signUp() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    final email = _emailController.text;
    final password = _passwordController.text;
    final username = _usernameController.text;
    try {
      await supabase.auth.signUp(
          email: email, password: password, data: {'username': username});
      _showSuccessNotification(); // Show success notification
      Navigator.of(context)
          .pushAndRemoveUntil(LoginScreen.route(), (route) => false);
    } on AuthException catch (error) {
      //  print(error.message);
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      // print(unexpectedErrorMessage);
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
  }

  void _showSuccessNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Signup successful!'), // Customize the message as needed
        backgroundColor: Colors.green, // Customize the color as needed
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
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
            controller: _emailController,
            onSaved: (email) {},
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Email Required';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: "Your email",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.email),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              cursorColor: kPrimaryColor,
              controller: _usernameController,
              onSaved: (username) {},
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Required';
                }
                final isValid = RegExp(r'^[A-Za-z0-9_]{3,24}$').hasMatch(val);
                if (!isValid) {
                  return '3-24 long with alphanumeric or underscore';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: "Your name",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.person),
                ),
              ),
            ),
          ),
          TextFormField(
            textInputAction: TextInputAction.done,
            obscureText: true,
            controller: _passwordController,
            cursorColor: kPrimaryColor,
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Required';
              }
              if (val.length < 6) {
                return '6 characters minimum';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: "Your password",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.password),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              textInputAction: TextInputAction.done,
              obscureText: true,
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Required';
                }
                if (val.length < 6) {
                  return '6 characters minimum';
                }
                if (_passwordController.text != val) {
                  return 'The passwords do not match';
                }
                return null;
              },
              controller: _passwordConfirmationController,
              cursorColor: kPrimaryColor,
              decoration: InputDecoration(
                hintText: "Confirm password",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.password),
                ),
              ),
            ),
          ),
          SizedBox(height: defaultPadding / 2),
          ElevatedButton(
            onPressed: _isLoading ? null : _signUp,
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
