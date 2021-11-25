import 'package:flutter/material.dart';

const double kPadding = 10.0;
const Color kPrimary = Color(0xFF1E2360);
const Color kSecondary = Colors.grey;
const Color kTextDark = Colors.black;
const Color kTextLight = Colors.white;
const kAnimationDuration = Duration(milliseconds: 200);

OutlineInputBorder outlineInputBorder() {
  return const OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey),
    borderRadius: BorderRadius.all(Radius.circular(25)),
  );
}