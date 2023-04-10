import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:takecare_user/controllers/language_controller.dart';
import 'package:takecare_user/public_variables/all_colors.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LanguageController>(
      builder: (language) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AllColor.themeColor,
            elevation: 0,
            title: Text(language.updateProfile.string),
          ),
          bottomNavigationBar: Container(
            padding: EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AllColor.themeColor,
                minimumSize: Size(100, 50),
              ),
              child: Text(language.save.string),
            ),
          ),
          body: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(5),
              child: Column(
                children: [
                  Card(
                    elevation: 2.0,
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        children: [
                          TextField(
                            decoration: InputDecoration(
                              hintText: language.nameHint.string,
                              contentPadding: const EdgeInsets.all(12),
                              isDense: true,
                              enabledBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: AllColor.themeColor),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextField(
                            decoration: InputDecoration(
                              hintText: language.age.string,
                              contentPadding: const EdgeInsets.all(12),
                              isDense: true,
                              enabledBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: AllColor.themeColor),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
