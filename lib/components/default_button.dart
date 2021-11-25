import 'package:flutter/material.dart';

import '../size_config.dart';

class DefaultButton extends StatelessWidget {

  final String text;
  final Color color;
  final Function()? press;
  final double width;
  const DefaultButton({Key? key, required this.text, required this.press, required this.color, required this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: getPropScreenHeight(50),
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(color),
        ),
        onPressed: press,
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyText2,
        ),
      ),
    );
  }
}