import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../core/values/images.dart';
import '../widgets/image_picker.dart';

final _firebaseAuth = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final formKey = GlobalKey<FormState>();
  bool isLogin = true;
  bool isLoading = false;
  String enteredUsername = '';
  String enteredEmail = '';
  String enteredPassword = '';
  File? pickedImageFile;

  Future<void> submit() async {
    setState(() {
      isLoading = true;
    });
    final valid = formKey.currentState!.validate();
    if (!valid || (!isLogin && pickedImageFile == null)) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    ;
    formKey.currentState!.save();
    try {
      log(enteredEmail);
      if (isLogin) {
        final UserCredential userCredential =
            await _firebaseAuth.signInWithEmailAndPassword(
          email: enteredEmail,
          password: enteredPassword,
        );
        log(userCredential.toString());
      } else {
        final UserCredential userCredential =
            await _firebaseAuth.createUserWithEmailAndPassword(
          email: enteredEmail,
          password: enteredPassword,
        );
        final storageRef = FirebaseStorage.instance
            .ref()
            .child("user_images")
            .child("${userCredential.user!.uid}.jpg");
        await storageRef.putFile(pickedImageFile!);
        final String imageUrl = await storageRef.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(
          {
            'username': enteredUsername,
            'email': enteredEmail,
            'image_url': imageUrl,
          },
        );
      }
    } on FirebaseAuthException catch (error) {
      snackMessage(error);
      setState(() {
        isLoading = false;
      });
    }
  }

  void snackMessage(FirebaseAuthException error) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.message ?? "Authentication Failed"),
      ),
    );
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
              formSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Card formSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isLogin)
                  AppImagePicker(
                    onImagePicked: (imageFile) {
                      pickedImageFile = imageFile;
                    },
                  ),
                if (!isLogin) usernameField(),
                emailField(),
                passwordField(),
                const SizedBox(height: 12),
                submitBtn(context),
                if (!isLoading) toggleBtn()
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextFormField usernameField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Username'),
      keyboardType: TextInputType.name,
      autocorrect: false,
      textCapitalization: TextCapitalization.none,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Please Enter a Valid User Name.";
        }
        return null;
      },
      onSaved: (value) => enteredUsername = value!,
    );
  }

  TextButton toggleBtn() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;
        });
      },
      child: Text(
        isLogin ? "Create an account." : "Already have an account.",
      ),
    );
  }

  Widget submitBtn(BuildContext context) {
    return isLoading
        ? const CircularProgressIndicator()
        : ElevatedButton(
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
