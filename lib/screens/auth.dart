import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/values/images.dart';

final _firebaseAuth = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final formKey = GlobalKey<FormState>();
  bool isLogin = true;
  String enteredEmail = '';
  String enteredPassword = '';

  Future<void> submit() async {
    final valid = formKey.currentState!.validate();
    if (!valid) return;
    formKey.currentState!.save();
    try {
      if (isLogin) {
        final UserCredential userCredential =
            await _firebaseAuth.signInWithEmailAndPassword(
                email: enteredEmail, password: enteredPassword);
        log(enteredEmail);
        log(enteredPassword);
        log(userCredential.toString());
      } else {
        final UserCredential userCredential =
            await _firebaseAuth.createUserWithEmailAndPassword(
          email: enteredEmail,
          password: enteredPassword,
        );
        log(enteredEmail);
        log(enteredPassword);
        log(userCredential.toString());
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? "Authentication Failed"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                child: Image.asset(JannImages.chatImage, height: 130),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          emailField(),
                          passwordField(),
                          const SizedBox(height: 12),
                          submitBtn(context),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                isLogin = !isLogin;
                              });
                            },
                            child: Text(
                              isLogin
                                  ? "Create an account."
                                  : "Already have an account.",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ElevatedButton submitBtn(BuildContext context) {
    return ElevatedButton(
      onPressed: submit,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Text(isLogin ? "LOGIN" : "SIGNUP"),
    );
  }

  TextFormField passwordField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Password'),
      obscureText: true,
      validator: (value) {
        if (value == null || value.trim().length < 6) {
          return "Password Must Be At Least 6 Character.";
        }
        return null;
      },
      onSaved: (value) => enteredPassword = value!,
    );
  }

  TextFormField emailField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Email Address'),
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      textCapitalization: TextCapitalization.none,
      validator: (value) {
        if (value == null || value.trim().isEmpty || !value.contains('@')) {
          return "Please Enter a Valid Email Address.";
        }
        return null;
      },
      onSaved: (value) => enteredEmail = value!,
    );
  }
}
