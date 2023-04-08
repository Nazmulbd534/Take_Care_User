import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: Stack(
              children: [
                Transform.rotate(
                  angle: pi * 90 / 2,
                  child: Image.asset('assets/images/image_below.png'),
                ),
                Column(
                  children: [
                    const SizedBox(
                      height: 40.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20.0,
                      ),
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
