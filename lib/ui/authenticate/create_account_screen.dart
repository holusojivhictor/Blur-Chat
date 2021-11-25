import 'package:blur_chat/components/default_button.dart';
import 'package:blur_chat/data/methods.dart';
import 'package:blur_chat/ui/authenticate/authenticate.dart';
import 'package:blur_chat/ui/authenticate/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../size_config.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({Key? key}) : super(key: key);

  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
                    'Create an account to continue',
                    style: Theme.of(context).textTheme.headline4,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: getPropScreenHeight(30)),
                  field("Name", Icons.person, _name),
                  SizedBox(height: getPropScreenHeight(20)),
                  field("Email", Icons.account_box, _email),
                  SizedBox(height: getPropScreenHeight(20)),
                  field("Password", Icons.lock, _password),
                  SizedBox(height: getPropScreenHeight(30)),
                  customButton(size),
                  SizedBox(height: getPropScreenHeight(30)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                        },
                        child: Text(
                          'Log in >',
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

  Widget customButton(Size size) {
    return DefaultButton(
      width: SizeConfig.screenWidth! * 0.9,
      color: const Color(0xFF00B661),
      text: 'Create account',
      press: () {
        if (_name.text.isNotEmpty &&
            _email.text.isNotEmpty &&
            _password.text.isNotEmpty) {
          setState(() {
            isLoading = true;
          });

          createAccount(_name.text, _email.text, _password.text)
              .then((user) {
            if (user != null) {
              setState(() {
                isLoading = false;
              });
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const Authenticate()), (route) => false);
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

  Widget field(
      String hintText, IconData icon, TextEditingController controller) {
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
