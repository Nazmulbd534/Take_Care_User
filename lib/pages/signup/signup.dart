import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:takecare_user/controllers/DataContollers.dart';
import 'package:takecare_user/pages/home_page.dart';
import 'package:takecare_user/pages/sign_in_page.dart';
import 'package:takecare_user/pages/sign_up_page.dart';
import 'package:takecare_user/public_variables/all_colors.dart';
import 'package:takecare_user/public_variables/notifications.dart';
import 'package:takecare_user/public_variables/variables.dart';
import 'package:takecare_user/ui/common.dart';
import 'package:takecare_user/widgets/loading_widget.dart';

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

  bool isLoading = false;

  onProgressBar(bool progress) {
    setState(() {
      isLoading = progress;
    });
  }

  void sharePreferences(BuildContext context) async {
    await Common.init();

    try {
      // storeSharedPreferences = await SharedPreferences.getInstance();

      var userId = Common.storeSharedPreferences.getString("userid");
      var pass = Common.storeSharedPreferences.getString("pass");

      print("user Id : " + userId!);
      print("Pass : " + pass!);

      if (userId != "" && userId != null && pass != "" && pass != null) {
        loginClass(userId, pass);
      }
    } catch (e) {}
  }

  void loginClass(String user, String pass) async {
    onProgressBar(true);

    try {
      await DataControllers.to.postLogin(user, pass);
    } catch (e) {
      onProgressBar(false);
      //  isLoading = false;
    }
    if (DataControllers.to.userLoginResponse.value.success == true) {
      // isLoading = false;
      // Get.offAll(HomePage());

      bearerToken = "Bearer " +
          DataControllers.to.userLoginResponse.value.data!.token.toString();

      await DataControllers.to.getSlider();
      await DataControllers.to.getAllCategories();
      Common.storeSharedPreferences.setString('userid', user);
      Common.storeSharedPreferences.setString('pass', pass);
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => HomePage()));
      onProgressBar(false);
    } else {
      onProgressBar(false);
      showToast(DataControllers.to.userLoginResponse.value.message.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    sharePreferences(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColor.white,
      body: GetBuilder<LanguageController>(
        builder: (language) {
          return SafeArea(
            child: SingleChildScrollView(
              child: isLoading
                  ? LoadingWidget()
                  : Container(
                      child: Stack(
                        children: [
                          Positioned(
                            top: 40.0,
                            left: 25.0,
                            child: GetBuilder<LanguageController>(
                                builder: (languageController) {
                              return AnimatedToggleButton(
                                values: const ['English', 'বাংলা'],
                                toggleValue: languageController.isEnglish.value,
                                width: dynamicSize(.4),
                                height: dynamicSize(0.08),
                                fontSize: dynamicSize(0.035),
                                onToggleCallback: (v) async {
                                  setState(() => english = !english);
                                },
                              );
                            }),
                          ),
                          Column(
                            children: [
                              SizedBox(
                                height: 110,
                              ),
                              Card(
                                elevation: 3.0,
                                shadowColor: AllColor.themeColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Container(
                                    height: 130.0,
                                    width: 150.0,
                                    margin: EdgeInsets.all(5),
                                    child:
                                        Image.asset("assets/images/icon.png")),
                              ),
                              SizedBox(
                                height: 25,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    language.signInOrSignup.string,
                                    style: TextStyle(
                                      fontFamily: "Muli",
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5.0,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const SignInPage(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      language.login.string,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "Muli",
                                          decoration: TextDecoration.underline,
                                          color: Colors.blue),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                language.loginNeeded.string,
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                width: 250,
                                child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SignUpPage(),
                                        ),
                                      );
                                    },
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color?>(
                                                AllColor.themeColor),
                                        shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18.0),
                                                side: BorderSide(
                                                    color:
                                                        AllColor.themeColor)))),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Icon(Icons.phone),
                                        Text(language.mobileSignup.string)
                                      ],
                                    )),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                language.or.string,
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
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text(language.comingSoon.string),
                                        ),
                                      );
                                    },
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color?>(
                                                Color(0xffCBC9C9)),
                                        padding: MaterialStateProperty.all<
                                            EdgeInsets>(EdgeInsets.all(0)),
                                        shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18.0),
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
                                        Text(language.google.string)
                                      ],
                                    )),
                              ),
                              Container(
                                width: 250,
                                margin: EdgeInsets.only(bottom: 10),
                                child: ElevatedButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text(language.comingSoon.string),
                                        ),
                                      );
                                    },
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color?>(
                                                Color(0xffCBC9C9)),
                                        padding: MaterialStateProperty.all<
                                            EdgeInsets>(EdgeInsets.all(0)),
                                        shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18.0),
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
                                        Text(language.facebook.string)
                                      ],
                                    )),
                              ),
                              Container(
                                width: 250,
                                margin: EdgeInsets.only(bottom: 10),
                                child: ElevatedButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text(language.comingSoon.string),
                                        ),
                                      );
                                    },
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color?>(
                                                Color(0xffCBC9C9)),
                                        padding: MaterialStateProperty.all<
                                            EdgeInsets>(EdgeInsets.all(0)),
                                        shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18.0),
                                                side: BorderSide(
                                                    color: Color(0xffCBC9C9))))),
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                          width: 2.0,
                                        ),
                                        Image.asset(
                                          "assets/images/login_apple_icon.png",
                                          height: 30,
                                          width: 30,
                                        ),
                                        SizedBox(
                                          width: 30,
                                        ),
                                        Text(language.apple.string)
                                      ],
                                    )),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              RichText(
                                text: TextSpan(
                                    text: language.termsPrefix.string + " ",
                                    style: TextStyle(color: Colors.grey),
                                    children: [
                                      TextSpan(
                                          text: language.terms.string,
                                          style: TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                              color: AllColor.themeColor))
                                    ]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
