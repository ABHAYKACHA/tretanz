import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:tretanz_task/app_statics/assets_path.dart';
import 'package:tretanz_task/controllers/user_controller.dart';

import '../app_statics/app_const.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginviewState();
}

class _LoginviewState extends State<LoginView> {

  UserController userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AssetsPath.loginBackground),
            fit: BoxFit.cover, // Optional: Adjusts how the image fits in the box
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            const Spacer(),

            SignInButton(
              Buttons.google,
              elevation: 10,
              shape: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10)),
              text: "Sign up with Google",
              clipBehavior: Clip.hardEdge,
              onPressed: () async {
                await userController.signInWithGoogle();
              },
            ),

            const SizedBox(height: 15,),
          ],
        ),
      ),
    );
  }
}
