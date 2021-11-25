import 'dart:async';

import 'package:blur_chat/ui/authenticate/authenticate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserDao extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  void initializeApp() async {
    Timer(const Duration(milliseconds: 2000), () {
      _initialized = true;
      notifyListeners();
    });
  }

}

Future<User?> createAccount(String name, String email, String password) async {
  FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  try {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);

    // ignore: avoid_print
    print("Account created successfully");

    userCredential.user!.updateDisplayName(name);

    await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
      "name": name,
      "email": email,
      "status": "Unavailable",
      "uid": _auth.currentUser!.uid,
    });

    return userCredential.user;
  } catch(e) {
    // ignore: avoid_print
    print(e);
    return null;
  }
}

Future<User?> logIn(String email, String password) async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  try {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);

    // ignore: avoid_print
    print("Login Successful");

    _firestore.collection('users').doc(_auth.currentUser!.uid).get().then((value) => userCredential.user!.updateDisplayName(value['name']));

    return userCredential.user;
  } catch (e) {
    // ignore: avoid_print
    print(e);
    return null;
  }
}

Future logOut(BuildContext context) async {
  FirebaseAuth _auth = FirebaseAuth.instance;

  try {
    await _auth.signOut().then((value) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const Authenticate()));
    });
  } catch (e) {
    // ignore: avoid_print
    print("error");
  }
}