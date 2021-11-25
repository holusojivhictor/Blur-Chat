import 'package:blur_chat/components/default_button.dart';
import 'package:blur_chat/data/methods.dart';
import 'package:blur_chat/size_config.dart';
import 'package:blur_chat/ui/authenticate/create_account_screen.dart';
import 'package:blur_chat/ui/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: SizeConfig.screenHeight! * 0.1),
                  Text(
                    'Blur Chat',
                    style: Theme.of(context).textTheme.headline1,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: SizeConfig.screenHeight! * 0.15),
                  Text(
                    'Sign in to Continue',
                    style: Theme.of(context).textTheme.headline4,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: getPropScreenHeight(30)),
                  field("Email", Icons.account_box, _email),
                  SizedBox(height: getPropScreenHeight(20)),
                  field("Password", Icons.lock, _password),
                  SizedBox(height: getPropScreenHeight(30)),
                  customButton(),
                  SizedBox(height: getPropScreenHeight(30)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateAccountScreen()));
                        },
                        child: Text(
                          'Sign up >',
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                              color: Color(0xFF00B661),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget customButton() {
    return DefaultButton(
      width: SizeConfig.screenWidth! * 0.9,
      color: const Color(0xFF00B661),
      text: 'Log in',
      press: () {
        if (_email.text.isNotEmpty && _password.text.isNotEmpty) {
          setState(() {
            isLoading = true;
          });

          logIn(_email.text, _password.text).then((user) {
            if (user != null) {
              setState(() {
                isLoading = false;
              });
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()));
            } else {
              setState(() {
                isLoading = false;
              });
            }
          });
        } else {
        }
      },
    );
  }

  Widget field(String hintText, IconData icon, TextEditingController controller) {
    return SizedBox(
      height: SizeConfig.screenHeight! * 0.08,
      width: SizeConfig.screenWidth! * 0.9,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18),
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            )),
      ),
    );
  }
}
