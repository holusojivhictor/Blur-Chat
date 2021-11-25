import 'package:blur_chat/data/methods.dart';
import 'package:blur_chat/theme.dart';
import 'package:blur_chat/ui/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const BlurChat());
}

class BlurChat extends StatelessWidget {
  const BlurChat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserDao()),
      ],
      child: MaterialApp(
        title: 'Blur Chat',
        debugShowCheckedModeBanner: false,
        theme: BlurChatTheme.light(),
        darkTheme: BlurChatTheme.dark(),
        home: const Onboarding(),
      ),
    );
  }
}
