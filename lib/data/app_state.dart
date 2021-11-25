import 'package:blur_chat/data/methods.dart';
import 'package:blur_chat/ui/authenticate/authenticate.dart';
import 'package:blur_chat/ui/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppState extends StatelessWidget {
  const AppState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDao>(
      builder: (context, userDao, child) {
        if (userDao.isLoggedIn()) {
          return const HomeScreen();
        } else {
          return const Authenticate();
        }
      },
    );
  }
}
