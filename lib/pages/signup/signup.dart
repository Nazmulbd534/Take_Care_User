import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:takecare_user/pages/sign_in_page.dart';
import 'package:takecare_user/public_variables/all_colors.dart';

import '../../controllers/language_controller.dart';
import '../../public_variables/size_config.dart';
import '../../widgets/AnimatedToggleButton.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool english = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColor.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(
                      height: 20.0,
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: GetBuilder<LanguageController>(
                            builder: (languageController) {
                          return Positioned(
                            right: dynamicSize(0.05),
                            top: dynamicSize(0.04),
                            child: AnimatedToggleButton(
                              values: const ['English', 'বাংলা'],
                              toggleValue: languageController.isEnglish.value,
                              width: dynamicSize(.4),
                              height: dynamicSize(0.08),
                              fontSize: dynamicSize(0.035),
                              onToggleCallback: (v) async {
                                setState(() => english = !english);
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Card(
                      elevation: 3.0,
                      shadowColor: AllColor.themeColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Container(
                          margin: EdgeInsets.all(5),
                          child: Image.asset("assets/images/icon.png")),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    RichText(
                      text: TextSpan(
                          text: "Sign up or ",
                          style: TextStyle(
                              fontFamily: "Muli", color: Colors.grey[700]),
                          children: [
                            TextSpan(
                                text: "Login",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Muli",
                                    decoration: TextDecoration.underline,
                                    color: Colors.blue))
                          ]),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "You must login to place an order.",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: 250,
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignInPage()));
                          },
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color?>(
                                      AllColor.themeColor),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(
                                          color: AllColor.themeColor)))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(Icons.phone),
                              Text("Sign up with Phone Number")
                            ],
                          )),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Or",
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: 250,
                      margin: EdgeInsets.only(bottom: 10),
                      child: ElevatedButton(
                          onPressed: () {},
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color?>(
                                      Color(0xffCBC9C9)),
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                  EdgeInsets.all(0)),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(
                                          color: Color(0xffCBC9C9))))),
                          child: Row(
                            children: [
                              Image.asset(
                                "assets/images/login_google_icon.png",
                                height: 38,
                                width: 38,
                              ),
                              SizedBox(
                                width: 30,
                              ),
                              Text("Continue with Google")
                            ],
                          )),
                    ),
                    Container(
                      width: 250,
                      margin: EdgeInsets.only(bottom: 10),
                      child: ElevatedButton(
                          onPressed: () {},
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color?>(
                                      Color(0xffCBC9C9)),
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                  EdgeInsets.all(0)),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(
                                          color: Color(0xffCBC9C9))))),
                          child: Row(
                            children: [
                              Image.asset(
                                "assets/images/login_facebook_icon.png",
                                height: 38,
                                width: 38,
                              ),
                              SizedBox(
                                width: 30,
                              ),
                              Text("Continue with Facebook")
                            ],
                          )),
                    ),
                    Container(
                      width: 250,
                      margin: EdgeInsets.only(bottom: 10),
                      child: ElevatedButton(
                          onPressed: () {},
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color?>(
                                      Color(0xffCBC9C9)),
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                  EdgeInsets.all(0)),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(
                                          color: Color(0xffCBC9C9))))),
                          child: Row(
                            children: [
                              Image.asset(
                                "assets/images/login_google_icon.png",
                                height: 38,
                                width: 38,
                              ),
                              SizedBox(
                                width: 30,
                              ),
                              Text("Continue with apple")
                            ],
                          )),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    RichText(
                      text: TextSpan(
                          text: "By sign up or Login I agree to the all ",
                          style: TextStyle(color: Colors.grey),
                          children: [
                            TextSpan(
                                text: "terms & conditions",
                                style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: AllColor.themeColor))
                          ]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
