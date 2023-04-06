import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:takecare_user/controllers/DataContollers.dart';
import 'package:takecare_user/pages/home_page.dart';
import 'package:takecare_user/public_variables/all_colors.dart';
import 'package:takecare_user/public_variables/notifications.dart';
import 'package:takecare_user/public_variables/size_config.dart';
import 'package:takecare_user/public_variables/variables.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool name = false;
  bool email = false;
  bool password = false;
  bool mobile_number = false;
  bool age = false;
  var initialProfile = true;

  late FocusNode Name;
  late FocusNode Email;
  late FocusNode Password;
  late FocusNode Mobile_Number;
  late FocusNode Age;

  @override
  void initState() {
    Name = FocusNode();
    Email = FocusNode();
    Password = FocusNode();
    Mobile_Number = FocusNode();
    Age = FocusNode();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColor.white_light,
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.of(context)
                .pushReplacement(MaterialPageRoute(builder: (_) => HomePage()));
          },
          child: Icon(
            Icons.arrow_back,
          ),
        ),
        backgroundColor: AllColor.themeColor,
        elevation: 0,
        title: Text("My Profile"),
        actions: [],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 15.0,
            ),
            Stack(
              children: [
                Container(
                  height: 140.0,
                  width: 140.0,
                  decoration: BoxDecoration(
                    //color: Colors.amber,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: CachedNetworkImage(
                      fit: BoxFit.fitHeight,
                      imageUrl:
                          '${DataControllers.to.userLoginResponse.value.data!.user!.profilePhoto}',
                      /*  placeholder: (context, url) =>
                                    CircularProgressIndicator(),*/
                      errorWidget: (context, url, error) => Image.asset(
                        'assets/images/avatar.png',
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 25,
                  child: Container(
                    height: 25.0,
                    width: 25.0,
                    decoration: BoxDecoration(
                      color: AllColor.themeColor,
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        _getImage();
                      },
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 12.0,
                      ),
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: InkWell(
                    onTap: () {
                      setState(() {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return StatefulBuilder(
                                  builder: (context, setState) {
                                return Container(
                                  child: AlertDialog(
                                    actions: [
                                      Column(
                                        children: [
                                          SizedBox(
                                            height: dynamicSize(0.04),
                                          ),
                                          InkWell(
                                            onTap: () => _getImage(),
                                            child: Container(
                                              alignment: Alignment.center,
                                              height: dynamicSize(0.15),
                                              width: dynamicSize(0.15),
                                              child: initialProfile
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  30)),
                                                      child: CachedNetworkImage(
                                                        height: 100,
                                                        width: 100,
                                                        fit: BoxFit.cover,
                                                        imageUrl:
                                                            '${DataControllers.to.userLoginResponse.value.data!.user!.profilePhoto}',
                                                        /*  placeholder: (context, url) =>
                                              CircularProgressIndicator(),*/
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Image.asset(
                                                                'assets/images/baby.png'),
                                                      ),
                                                    )
                                                  : ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  dynamicSize(
                                                                      0.2))),
                                                      child: Image.file(
                                                          Variables.imageFile,
                                                          height:
                                                              dynamicSize(0.2),
                                                          width:
                                                              dynamicSize(0.2),
                                                          fit: BoxFit.cover)),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              color: Colors.white,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          "Name",
                                                          style: TextStyle(
                                                              fontSize:
                                                                  dynamicSize(
                                                                      0.05)),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: TextField(
                                                        // controller: et_gallery,
                                                        enabled: name,
                                                        focusNode: Name,
                                                        cursorHeight:
                                                            dynamicSize(0.06),
                                                        decoration: InputDecoration(
                                                            border: InputBorder
                                                                .none,
                                                            hintText:
                                                                DataControllers
                                                                    .to
                                                                    .userLoginResponse
                                                                    .value
                                                                    .data!
                                                                    .user!
                                                                    .fullName,
                                                            hintStyle: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              color: Colors.white,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          "Email",
                                                          style: TextStyle(
                                                              fontSize:
                                                                  dynamicSize(
                                                                      0.05)),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: TextField(
                                                        // controller: et_gallery,
                                                        enabled: name,
                                                        focusNode: FocusNode(),
                                                        cursorHeight:
                                                            dynamicSize(0.06),
                                                        decoration: InputDecoration(
                                                            border: InputBorder
                                                                .none,
                                                            hintText:
                                                                DataControllers
                                                                    .to
                                                                    .userLoginResponse
                                                                    .value
                                                                    .data!
                                                                    .user!
                                                                    .email,
                                                            hintStyle: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: AllColor.white,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8)),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      "Gender",
                                                      style: TextStyle(
                                                          fontSize: dynamicSize(
                                                              0.05)),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0,
                                                            right: 8,
                                                            bottom: 10,
                                                            top: 15),
                                                    child: Row(
                                                      children: Variables
                                                          .genderList
                                                          .map((item) =>
                                                              Expanded(
                                                                  child:
                                                                      InkWell(
                                                                onTap: () => setState(() =>
                                                                    DataControllers
                                                                        .to
                                                                        .gender
                                                                        .value = item),
                                                                child:
                                                                    Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  margin: EdgeInsets.only(
                                                                      right: item == 'Male' ||
                                                                              item ==
                                                                                  'Female'
                                                                          ? dynamicSize(
                                                                              .02)
                                                                          : 0.0),
                                                                  decoration: BoxDecoration(
                                                                      border: Border.all(
                                                                          color: AllColor
                                                                              .blue),
                                                                      color: item ==
                                                                              DataControllers
                                                                                  .to.gender.value
                                                                          ? AllColor
                                                                              .blue
                                                                          : Colors
                                                                              .white,
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(dynamicSize(.01)))),
                                                                  padding: EdgeInsets.symmetric(
                                                                      vertical:
                                                                          dynamicSize(
                                                                              .025),
                                                                      horizontal:
                                                                          dynamicSize(
                                                                              0.04)),
                                                                  child: Text(
                                                                    item,
                                                                    maxLines: 1,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            dynamicSize(
                                                                                0.04),
                                                                        color: item ==
                                                                                DataControllers.to.gender.value
                                                                            ? Colors.white
                                                                            : AllColor.textColor),
                                                                  ),
                                                                ),
                                                              )))
                                                          .toList(),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Flexible(
                                                flex: 1,
                                                child: SizedBox(
                                                  height: dynamicSize(0.10),
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: Container(
                                                    child: MaterialButton(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  10.0),
                                                        ),
                                                      ),
                                                      onPressed: () async {
                                                        Navigator.pop(context);

                                                        /* Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Dashboard()),
                );*/
                                                      },
                                                      //color: AllColor.button_color,
                                                      textColor: Colors.black,
                                                      child: Text(
                                                        "NO",
                                                        style: TextStyle(
                                                            fontSize: 18),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                height: dynamicSize(0.1),
                                                width: dynamicSize(0.003),
                                                color: Colors.grey,
                                              ),
                                              Flexible(
                                                flex: 1,
                                                child: SizedBox(
                                                  height: dynamicSize(0.10),
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: Container(
                                                    child: MaterialButton(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          bottomRight:
                                                              Radius.circular(
                                                                  10.0),
                                                        ),
                                                      ),
                                                      onPressed: () {},
                                                      //color: AllColor.button_color,
                                                      textColor: Colors.black,
                                                      child: Text(
                                                        "Edit",
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            color: Colors
                                                                .lightBlue),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              });
                            });
                        name = true;
                        Name = FocusNode();
                        Name.requestFocus();
                      });
                    },
                    child: Text(
                      "Edit",
                      style: TextStyle(
                          fontSize: dynamicSize(0.05),
                          color: AllColor.themeColor),
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 3.0,
                child: SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 5.0,
                      left: 15.0,
                      top: 10.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Name",
                              style: TextStyle(fontSize: dynamicSize(0.05)),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          DataControllers
                              .to.userLoginResponse.value.data!.user!.fullName!,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),

                        const SizedBox(
                          height: 30.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Email",
                                  style: TextStyle(fontSize: dynamicSize(0.05)),
                                ),
                              ],
                            ),
                            DataControllers.to.userLoginResponse.value.data!
                                        .user!.email ==
                                    null
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0,
                                        bottom: 8,
                                        right: 10,
                                        top: 10),
                                    child: Container(
                                      width: dynamicSize(0.33),
                                      decoration: const BoxDecoration(
                                        color: AllColor.shado_color,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(12.0),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: const [
                                          Padding(
                                            padding: EdgeInsets.only(left: 8.0),
                                            child: Icon(
                                              Icons.cancel_outlined,
                                              color: Colors.red,
                                            ),
                                          ),
                                          Text(
                                            "Not Verified",
                                            style: TextStyle(color: Colors.red),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0,
                                        bottom: 8,
                                        right: 10,
                                        top: 10),
                                    child: Container(
                                      width: dynamicSize(0.27),
                                      decoration: const BoxDecoration(
                                        color: AllColor.shado_color,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(12.0),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: const [
                                          Padding(
                                            padding: EdgeInsets.only(left: 8.0),
                                            child: Icon(
                                              Icons.done,
                                              color: Colors.green,
                                            ),
                                          ),
                                          Text(
                                            "Verified",
                                            style:
                                                TextStyle(color: Colors.green),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          DataControllers.to.userLoginResponse.value.data!.user!
                                  .email ??
                              "No email provided",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(
                          height: 30.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Mobile Number",
                                  style: TextStyle(fontSize: dynamicSize(0.05)),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 8.0, bottom: 8, right: 10, top: 10),
                              child: Container(
                                width: dynamicSize(0.27),
                                decoration: const BoxDecoration(
                                  color: AllColor.shado_color,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12.0),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: const [
                                    Padding(
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: Icon(
                                        Icons.done,
                                        color: Colors.green,
                                      ),
                                    ),
                                    Text(
                                      "Verified",
                                      style: TextStyle(color: Colors.green),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          "+88${DataControllers.to.userLoginResponse.value.data!.user!.phone}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(
                          height: 30.0,
                        ),
                        Text(
                          "Gender",
                          style: TextStyle(fontSize: dynamicSize(0.05)),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          DataControllers
                              .to.userLoginResponse.value.data!.user!.gender,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(
                          height: 30.0,
                        ),
                        Text(
                          "Age",
                          style: TextStyle(fontSize: dynamicSize(0.05)),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: Text(
                        //     "18",
                        //     style: TextStyle(fontSize: dynamicSize(0.05)),
                        //   ),
                        // ),
                        const SizedBox(
                          height: 10.0,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Card(
                elevation: 3.0,
                child: Container(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Password",
                              style: TextStyle(fontSize: dynamicSize(0.05)),
                            ),
                            TextButton(onPressed: () {}, child: Text("Change"))
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "*********",
                          style: TextStyle(
                              fontSize: dynamicSize(0.05), color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
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
