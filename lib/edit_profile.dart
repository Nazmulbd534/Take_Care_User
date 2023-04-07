import 'package:flutter/material.dart';
import 'package:takecare_user/public_variables/all_colors.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AllColor.themeColor,
        elevation: 0,
        title: Text("Update Profile"),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(10),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AllColor.themeColor,
            minimumSize: Size(100, 50),
          ),
          child: Text("Save"),
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
                  padding: EdgeInsets.all(25),
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Nazmul Hasan Sohan",
                          contentPadding: EdgeInsets.all(12),
                          isDense: true,
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: AllColor.themeColor),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Age",
                          contentPadding: EdgeInsets.all(12),
                          isDense: true,
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: AllColor.themeColor),
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
  }
}
