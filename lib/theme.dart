import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

import 'constants.dart';

TextTheme textTheme(BuildContext context) {
  return GoogleFonts.latoTextTheme(Theme.of(context).textTheme);
}

class BlurChatTheme {
  static TextTheme lightTextTheme = TextTheme(
    bodyText1: GoogleFonts.lato(
      fontSize: 14.0,
      fontWeight:FontWeight.w700,
      color: kTextDark,
    ),
    bodyText2: GoogleFonts.lato(
      fontSize: 14.0,
      fontWeight:FontWeight.normal,
      color: kTextDark,
    ),
    headline1: GoogleFonts.lato(
      fontSize: 26.0,
      fontWeight:FontWeight.bold,
      color: kTextDark,
    ),
    headline2: GoogleFonts.lato(
      fontSize: 18.0,
      fontWeight:FontWeight.w700,
      color: kTextDark,
    ),
    headline3: GoogleFonts.lato(
      fontSize: 14.0,
      fontWeight:FontWeight.w600,
      color: kTextDark,
    ),
    headline4: GoogleFonts.lato(
      fontSize: 16.0,
      fontWeight:FontWeight.w500,
      color: kTextDark,
    ),
    headline6: GoogleFonts.lato(
      fontSize: 20.0,
      fontWeight:FontWeight.normal,
      color: kTextDark,
    ),
  );

  static TextTheme darkTextTheme = TextTheme(
    bodyText1: GoogleFonts.lato(
      fontSize: 14.0,
      fontWeight:FontWeight.w700,
      color: kTextLight,
    ),
    bodyText2: GoogleFonts.lato(
      fontSize: 14.0,
      fontWeight:FontWeight.normal,
      color: kTextLight,
    ),
    headline1: GoogleFonts.lato(
      fontSize: 26.0,
      fontWeight:FontWeight.bold,
      color: kTextLight,
    ),
    headline2: GoogleFonts.lato(
      fontSize: 18.0,
      fontWeight:FontWeight.w700,
      color: kTextLight,
    ),
    headline3: GoogleFonts.lato(
      fontSize: 14.0,
      fontWeight:FontWeight.w600,
      color: kTextLight,
    ),
    headline4: GoogleFonts.lato(
      fontSize: 16.0,
      fontWeight:FontWeight.w500,
      color: kTextLight,
    ),
    headline6: GoogleFonts.lato(
      fontSize: 20.0,
      fontWeight:FontWeight.normal,
      color: kTextLight,
    ),
  );

  static ThemeData light() {
    return ThemeData(
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(const Color(0xFF00B661)),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
      dividerColor: const Color(0xFFF9F9F9),
      bottomAppBarColor: const Color(0xFFF1F1F1),
      canvasColor: Colors.grey[50],
      cardColor: Colors.white,
      shadowColor: const Color(0xFFC3EDDA),
      indicatorColor: Colors.black,
      textSelectionTheme: const TextSelectionThemeData(cursorColor: Colors.black),
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF1F1F1),
      appBarTheme: AppBarTheme(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        titleTextStyle: lightTextTheme.headline2,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      textTheme: lightTextTheme,
      primaryColor: const Color(0xFF00B661),
      colorScheme: const ColorScheme.light(primary: Colors.grey).copyWith(secondary: const Color(0xFFC5EFE6)),
    );
  }
  static ThemeData dark() {
    return ThemeData(
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
      dividerColor: const Color(0xFF373A3F),
      bottomAppBarColor: const Color(0xFF272C2F),
      canvasColor: Colors.black54,
      cardColor: Colors.grey.shade900,
      shadowColor: const Color(0xFF192C31),
      indicatorColor: Colors.white,
      textSelectionTheme: const TextSelectionThemeData(cursorColor: Colors.white),
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF1A1B2F),
      appBarTheme: AppBarTheme(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        backgroundColor: Colors.black45,
        titleTextStyle: darkTextTheme.headline2,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
      ),
      textTheme: darkTextTheme,
      primaryColor: const Color(0xFF00B661),
      colorScheme: const ColorScheme.dark(primary: Colors.grey).copyWith(secondary: const Color(0xFFC5EFE6)),
    );
  }
}