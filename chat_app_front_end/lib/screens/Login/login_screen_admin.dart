import 'package:MeChat/screens/Login/components/admin_page_login.dart';
import 'package:flutter/material.dart';
import 'package:MeChat/responsive.dart';

import '../../components/background.dart';
import 'components/login_screen_top_image.dart';

class AdminLoginScreen extends StatelessWidget {
  final bool login = false;
  AdminLoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Background(
      child: SingleChildScrollView(
        child: Responsive(
          mobile: MobileLoginScreen(),
          desktop: Row(
            children: [
              Expanded(
                child: LoginScreenTopImage(),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 450,
                      child: AdminLoginForm(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Route<Object?> route() {
    return MaterialPageRoute(builder: (context) => AdminLoginScreen());
  }
}

class MobileLoginScreen extends StatelessWidget {
  MobileLoginScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        LoginScreenTopImage(),
        Row(
          children: [
            Spacer(),
            Expanded(
              flex: 8,
              child: AdminLoginForm(),
            ),
            Spacer(),
          ],
        ),
      ],
    );
  }
}
