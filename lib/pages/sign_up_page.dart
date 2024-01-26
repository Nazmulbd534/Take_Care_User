import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:takecare_user/controllers/language_controller.dart';
import 'package:takecare_user/pages/sign_in_page.dart';
import 'package:takecare_user/public_variables/variables.dart';
import 'package:takecare_user/widgets/AnimatedToggleButton.dart';
import 'package:takecare_user/widgets/loading_widget.dart';

import '../controllers/DataContollers.dart';
import '../public_variables/all_colors.dart';
import '../public_variables/notifications.dart';
import '../public_variables/size_config.dart';
import '../widgets/check_box.dart';
import '../widgets/text_field_tile.dart';
import 'otp_verification_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  var isLoading = false;
  var initialProfile = true;
  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to go Login'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => SignInPage()));
                },
                child: new Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Variables.categoryCheckBoxValue = false;
    Variables.base64Image = "";
  }

  @override
  void dispose() {
    print('dispose sign up');
    DataControllers.to.name.value.text = "";
    DataControllers.to.gender.value = "";
    DataControllers.to.phoneNumber.value.text = "";
    DataControllers.to.password.value.text = "";
    // DataControllers.to.name.refresh();
    // DataControllers.to.gender.refresh();
    // DataControllers.to.phoneNumber.refresh();
    // DataControllers.to.password.refresh();
    super.dispose();
  }

  bool english = true;
  // late PickResult selectedPlace;
  bool language = true;

  @override
  Widget build(BuildContext size) {
    double totalWidth = MediaQuery.of(context).size.width;
    double totalHeight = MediaQuery.of(context).size.height;
    return Scaffold(body: GetBuilder<LanguageController>(
      builder: (language) {
        return SingleChildScrollView(
          child: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  right: 0,
                  // top: totalHeight * 0.03,
                  child: SizedBox(
                    height: totalHeight * 0.2,
                    width: totalWidth * 0.8,
                    child: FittedBox(
                        fit: BoxFit.fill,
                        child:
                            Image.asset('assets/images/clip_path_shape.png')),
                  ),
                ),
                Positioned(
                  top: 50.0,
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
                    SizedBox(height: totalHeight * 0.2),
                    Center(
                      child: Container(
                        width: totalWidth * 0.9,
                        padding: const EdgeInsets.only(top: 40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              offset: const Offset(0, 5),
                              color: Colors.grey.shade400,
                              blurRadius: 10,
                            )
                          ],
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          children: [
                            Center(
                              child: InkWell(
                                onTap: () => _getImage(),
                                child: Container(
                                  alignment: Alignment.center,
                                  height: totalHeight * 0.09,
                                  width: totalWidth * 0.2,
                                  decoration: const BoxDecoration(
                                      color: AllColor.white,
                                      shape: BoxShape.circle),
                                  child: initialProfile
                                      ? Stack(
                                          children: [
                                            Icon(
                                              Icons.account_circle_rounded,
                                              color: AllColor.blue,
                                              size: dynamicSize(0.2),
                                            ),
                                          ],
                                        )
                                      : ClipRRect(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(
                                              dynamicSize(0.2),
                                            ),
                                          ),
                                          child: Image.file(Variables.imageFile,
                                              height: dynamicSize(0.2),
                                              width: dynamicSize(0.2),
                                              fit: BoxFit.cover)),
                                ),
                              ),
                            ),
                            SizedBox(height: dynamicSize(.06)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: dynamicSize(0.12),
                                      child: TextField(
                                        controller:
                                            DataControllers.to.name.value,
                                        decoration: InputDecoration(
                                            enabledBorder:
                                                const OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: AllColor.blue,
                                              ),
                                            ),
                                            labelText: language.name.string,
                                            border: OutlineInputBorder(),
                                            hintStyle: TextStyle(
                                                fontFamily: 'Muli',
                                                fontWeight: FontWeight.w600,
                                                fontSize: dynamicSize(0.04))),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: totalHeight * 0.02,
                            ),

                            ///Gender
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30),
                              child: language.isEnglish.isTrue
                                  ? Row(
                                      children: Variables.genderList
                                          .map((item) => Expanded(
                                                  child: InkWell(
                                                onTap: () => setState(() =>
                                                    DataControllers.to.gender
                                                        .value = item),
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  margin: EdgeInsets.only(
                                                      right: item == 'Male' ||
                                                              item == 'Female'
                                                          ? size.width * .02
                                                          : 0.0),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: AllColor.blue),
                                                      color: item ==
                                                              DataControllers.to
                                                                  .gender.value
                                                          ? AllColor.blue
                                                          : Colors.white,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  size.width *
                                                                      .01))),
                                                  padding: EdgeInsets.symmetric(
                                                      vertical:
                                                          size.width * .025,
                                                      horizontal:
                                                          size.width * .04),
                                                  child: Text(
                                                    item,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        fontFamily: 'Muli',
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize:
                                                            size.width * .04,
                                                        color: item ==
                                                                DataControllers
                                                                    .to
                                                                    .gender
                                                                    .value
                                                            ? Colors.white
                                                            : AllColor
                                                                .textColor),
                                                  ),
                                                ),
                                              )))
                                          .toList(),
                                    )
                                  : Row(
                                      children: Variables.genderListBangla
                                          .map((item) => Expanded(
                                                  child: InkWell(
                                                onTap: () => setState(() =>
                                                    DataControllers.to.gender
                                                        .value = item),
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  margin: EdgeInsets.only(
                                                      right: item == 'পুরুষ' ||
                                                              item == 'নারী'
                                                          ? size.width * .02
                                                          : 0.0),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: AllColor.blue),
                                                      color: item ==
                                                              DataControllers.to
                                                                  .gender.value
                                                          ? AllColor.blue
                                                          : Colors.white,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  size.width *
                                                                      .01))),
                                                  padding: EdgeInsets.symmetric(
                                                      vertical:
                                                          size.width * .025,
                                                      horizontal:
                                                          size.width * .04),
                                                  child: Text(
                                                    item,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        fontFamily: 'Muli',
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize:
                                                            size.width * .04,
                                                        color: item ==
                                                                DataControllers
                                                                    .to
                                                                    .gender
                                                                    .value
                                                            ? Colors.white
                                                            : AllColor
                                                                .textColor),
                                                  ),
                                                ),
                                              )))
                                          .toList(),
                                    ),
                            ),
                            SizedBox(
                              height: totalHeight * 0.02,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30),
                              child: Container(
                                height: dynamicSize(0.14),
                                child: BorderTextField(
                                  labelText: language.age.string,
                                  controller: DataControllers.to.age.value,
                                  textInputType: TextInputType.number,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: totalHeight * 0.02,
                            ),

                            /// Number
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      height: dynamicSize(0.12),
                                      child: TextField(
                                        textAlign: TextAlign.center,
                                        enabled: false,
                                        decoration: InputDecoration(
                                            disabledBorder:
                                                const OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: AllColor.blue,
                                              ),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.only(
                                                    bottom: 0.0),
                                            border: const OutlineInputBorder(
                                                borderSide: BorderSide(
                                              color: AllColor.blue,
                                            )),
                                            hintText: '+88',
                                            hintStyle: TextStyle(
                                                fontFamily: 'Muli',
                                                fontWeight: FontWeight.w600,
                                                fontSize: dynamicSize(0.05))),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 7,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Container(
                                        height: dynamicSize(0.12),
                                        child: TextField(
                                          style: const TextStyle(
                                            fontFamily: 'Muli',
                                            fontWeight: FontWeight.w600,
                                          ),
                                          keyboardType: TextInputType.phone,
                                          controller: DataControllers
                                              .to.phoneNumber.value,
                                          decoration: InputDecoration(
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: AllColor.blue,
                                                ),
                                              ),
                                              border:
                                                  const OutlineInputBorder(),
                                              labelText:
                                                  language.mobileNumber.string,
                                              hintText: '01XXXXXXXXX',
                                              hintStyle: const TextStyle(
                                                fontFamily: 'Muli',
                                                fontWeight: FontWeight.w600,
                                              )),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: totalHeight * 0.03,
                            ),

                            ///Password
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30),
                              child: Container(
                                height: dynamicSize(0.14),
                                child: BorderTextField(
                                  labelText: language.password.string,
                                  controller: DataControllers.to.password.value,
                                  obscure: true,
                                ),
                              ),
                            ),

                            SizedBox(
                              height: totalHeight * 0.02,
                            ),

                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CheckBox(),
                                  Expanded(
                                    child: RichText(
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      text: TextSpan(
                                        text: language.termsPrefix.string + " ",
                                        style: TextStyle(
                                            fontFamily: 'Muli',
                                            fontWeight: FontWeight.w600,
                                            fontSize: dynamicSize(0.035),
                                            color: Colors.black),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: language.terms.string,
                                            recognizer: TapGestureRecognizer()
                                              ..onTap =
                                                  () => print('Tap Here onTap'),
                                            style: const TextStyle(
                                                fontFamily: 'Muli',
                                                fontWeight: FontWeight.w600,
                                                color: AllColor.pink_button,
                                                decoration:
                                                    TextDecoration.underline),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: dynamicSize(0.02),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: totalHeight * 0.02,
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: dynamicSize(0.04)),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              AllColor.themeColor,
                            ),
                          ),
                          onPressed: () async {
                            if (DataControllers
                                    .to.phoneNumber.value.text.isNotEmpty &&
                                DataControllers
                                    .to.password.value.text.isNotEmpty &&
                                DataControllers.to.gender.value.isNotEmpty &&
                                DataControllers.to.name.value.text.isNotEmpty &&
                                DataControllers.to.age.value.text.isNotEmpty &&
                                (Variables.base64Image.isNotEmpty &&
                                    Variables.base64Image != "") &&
                                Variables.categoryCheckBoxValue) {
                              if (DataControllers
                                      .to.password.value.text.length >
                                  5) {
                                setState(() => isLoading = true);
                                final signature =
                                    await SmsAutoFill().getAppSignature;

                                await DataControllers.to.postRegister(
                                    DataControllers.to.name.value.text,
                                    DataControllers.to.phoneNumber.value.text,
                                    DataControllers.to.password.value.text,
                                    DataControllers.to.gender.value,
                                    "4",
                                    Variables.base64Image,
                                    signature);

                                if (DataControllers.to.regsiter.value.success ==
                                    true) {
                                  Get.to(OtpVerificationPage());
                                } else {
                                  showToast(DataControllers
                                      .to.regsiter.value.message!);
                                }

                                setState(() => isLoading = false);
                              } else {
                                snackBar(
                                    context, 'Minimum Password 6 character');
                              }
                            } else {
                              snackBar(context, 'Fil up the filed!!');
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(13.0),
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontFamily: 'Muli',
                                    fontWeight: FontWeight.w600,
                                    fontSize: dynamicSize(0.045),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                GetBuilder<LanguageController>(
                  builder: (languageController) {
                    return Positioned(
                      top: totalHeight * 0.180,
                      left: totalWidth * 0.16,
                      child: AnimatedToggleButton(
                        values: [
                          (languageController.sigIn.value),
                          (languageController.signUp.value)
                        ],
                        toggleValue: false,
                        width: totalWidth * 0.7,
                        height: dynamicSize(0.12),
                        fontSize: dynamicSize(0.045),
                        onToggleCallback: (v) async {
                          Get.to(SignInPage());
                          // if (signIn) {
                          //   Get.to(SignUpPage());
                          //   setState(() {
                          //     signIn = true;
                          //   });
                          // } else {
                          //   setState(() {
                          //     signIn = true;
                          //   });
                          // }

                          // /*  setState(() => );*/

                          //Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    ));
  }

  void _getImage() async {
    final ImagePicker _picker = ImagePicker();
    var image = await _picker.pickImage(source: ImageSource.gallery);
    // var choosedimage = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => Variables.imageFile = File(image.path));

      List<int> imageBytes = Variables.imageFile.readAsBytesSync();
      Variables.base64Image = base64Encode(imageBytes);
      //Variables.base64Image = Base64Encoder().convert(Variables.imageFile.readAsBytesSync());//base64Encode(Variables.imageFile.readAsBytesSync());
      // Variables.base64Image = base64Encode(Variables.imageFile.readAsBytesSync());
      print("image : " + Variables.base64Image);

      setState(() {
        initialProfile = false;
      });

      // String fileName = _image!.path.split("/").last;
      //print('Image File Name: $fileName');
      //showLoadingDialog(context);
      /*    await userProvider
          .profileImageUpdate(base64Image, fileName)
          .then((value) {
        if (value) {
          showToast('Success');
          Navigator.pop(context);
        } else {
          showToast('Failed!');
          Navigator.pop(context);
        }
      });*/
    } else {
      showToast('Image not selected');
    }
  }
}
