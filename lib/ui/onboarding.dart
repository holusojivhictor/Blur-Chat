import 'package:blur_chat/data/app_state.dart';
import 'package:flutter/material.dart';

import '../size_config.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({Key? key}) : super(key: key);

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SizeConfig().init(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(height: getPropScreenHeight(20)),
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 200,
                  width: SizeConfig.screenWidth,
                  child: Image.asset(
                    "assets/images/onboarding_double.png",
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Text(
                      "Welcome to Blur Chat",
                      style: Theme.of(context).textTheme.headline1,
                    ),
                    SizedBox(height: getPropScreenHeight(10)),
                    Text(
                      "Chat anonymously with users across the globe.",
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    SizedBox(height: SizeConfig.screenHeight! * 0.1),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const AppState()),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Skip',
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                          Icon(Icons.chevron_right, color: Theme.of(context).indicatorColor),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}