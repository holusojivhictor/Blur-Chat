import 'package:blur_chat/components/default_button.dart';
import 'package:blur_chat/ui/authenticate/login_screen.dart';
import 'package:flutter/material.dart';

import '../../size_config.dart';
import 'create_account_screen.dart';

class Authenticate extends StatelessWidget {
  const Authenticate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: SizedBox(
                  child: Center(
                    child: Text(
                      'Blur Chat',
                      style: Theme.of(context).textTheme.headline1,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    DefaultButton(
                      width: SizeConfig.screenWidth! * 0.9,
                      color: const Color(0xFF00B661),
                      text: 'Log in',
                      press: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                    ),
                    SizedBox(height: getPropScreenHeight(30)),
                    DefaultButton(
                      width: SizeConfig.screenWidth! * 0.9,
                      color: const Color(0xFF00B661).withOpacity(0.7),
                      text: 'Sign up',
                      press: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const CreateAccountScreen()),
                        );
                      },
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
}
