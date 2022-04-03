import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:takecare_user/controllers/DataContollers.dart';
import 'package:takecare_user/pages/On%20Demand/categories_page.dart';
import 'package:takecare_user/pages/On%20Demand/popular_page.dart';
import 'package:takecare_user/pages/On%20Demand/caregiver_profile_page.dart';
import 'package:takecare_user/pages/On%20Demand/submitted_review_page.dart';
import 'package:takecare_user/pages/On%20Demand/write_review_page.dart';
import 'package:takecare_user/pages/home_page.dart';
import 'package:takecare_user/widgets/check_box.dart';
import 'package:intl/intl.dart';

import '../../controllers/language_controller.dart';
import '../../public_variables/all_colors.dart';
import '../../public_variables/notifications.dart';
import '../../public_variables/size_config.dart';
import '../../ui/common.dart';
import 'feedback_page.dart';
import 'map_page.dart';

class OnDemandPage extends StatefulWidget {
  const OnDemandPage({Key? key}) : super(key: key);

  @override
  _OnDemandPageState createState() => _OnDemandPageState();
}

var addedservice = false;
var showBottom = false;
var addedlist = false;

class _OnDemandPageState extends State<OnDemandPage> {
  Icon cusIcon = Icon(Icons.search, color: Colors.black);
  Widget cusSearchbar = Text(
    "On Demand",
    style: TextStyle(color: Colors.black, fontSize: dynamicSize(0.03)),
  );

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LanguageController>(builder: (lc) {
      return Scaffold(
        bottomNavigationBar: showBottom
            ? Container(
                height: dynamicSize(0.2),
                color: AllColor.button_color,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        color: Colors.red,
                        child: Column(
                          children: [
                            Container(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 8.0, top: 5),
                                child: Text(
                                  "On Demand",
                                  style: TextStyle(
                                      fontSize: dynamicSize(0.035),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            addedlist
                                ? Container(
                                    alignment: Alignment.topLeft,
                                    child: InkWell(
                                      onTap: () {
                                        BottomSheetAddedListDialog(context);
                                      },
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0, top: 5),
                                            child: Text(
                                              DataControllers
                                                  .to
                                                  .getAddCardResponse
                                                  .value
                                                  .data!
                                                  .length
                                                  .toString(),
                                              style: TextStyle(
                                                  fontSize: dynamicSize(0.04),
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5),
                                            child: Text(
                                              " Service Added",
                                              style: TextStyle(
                                                  fontSize: dynamicSize(0.04),
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: Icon(
                                              Icons.keyboard_arrow_up,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, top: 5),
                                      child: Text(
                                        "Attendant for Hospital Visit",
                                        style: TextStyle(
                                            fontSize: dynamicSize(0.04),
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ),
                                  )
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  /* title: Text(
                                    "Booking Information",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: dynamicSize(0.03),
                                        color: Colors.red),
                                  ),*/
                                  actions: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        width: dynamicSize(1),
                                        alignment: Alignment.topLeft,
                                        // height: dynamicSize(0.003),

                                        child: Column(
                                          children: [
                                            Container(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                "Booking Information",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            SizedBox(
                                              height: dynamicSize(0.08),
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  child: Text(
                                                    "Service For Whom ",
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    print("hdjbfdh");
                                                  },
                                                  child: Container(
                                                      child: Text(
                                                    "Edit",
                                                    style: TextStyle(
                                                        color: Colors.red,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: dynamicSize(0.05),
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Name ",
                                                ),
                                                SizedBox(
                                                  width: dynamicSize(.3),
                                                ),
                                                Text(
                                                  ": Rana Talukdar",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: dynamicSize(0.03),
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Age ",
                                                ),
                                                SizedBox(
                                                  width: dynamicSize(.335),
                                                ),
                                                Text(
                                                  ": 87 years",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: dynamicSize(0.03),
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Contact Number",
                                                ),
                                                SizedBox(
                                                  width: dynamicSize(.13),
                                                ),
                                                Text(
                                                  ": 01758351395",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              });
                        },
                        child: Container(
                          color: AllColor.button_color,
                          alignment: Alignment.center,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Text(
                                  "Continue",
                                  style: TextStyle(
                                      fontSize: dynamicSize(0.04),
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(
                                width: dynamicSize(0.02),
                              ),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Container(height: .01),
        appBar: AppBar(
          leading: InkWell(
            child: Icon(
              Icons.arrow_back,
              color: Colors.red,
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                if (cusIcon.icon == Icons.search) {
                  print("working");
                  setState(() {
                    cusIcon =
                        Icon(Icons.cancel, color: AllColor.cancel_icon_color);
                    cusSearchbar = SizedBox(
                      height: dynamicSize(0.09),
                      child: TextField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AllColor.search_field_color,
                          hintText: "Search",
                          prefixIcon: Icon(Icons.search),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(30.0)),
                            borderSide:
                                BorderSide(color: Colors.white, width: 2),
                          ),
                        ),
                        style: TextStyle(
                            color: Colors.black, fontSize: dynamicSize(0.04)),
                      ),
                    );
                  });
                } else {
                  print("working2");
                  setState(() {
                    cusIcon = Icon(Icons.search, color: Colors.black);
                    cusSearchbar = Text(
                      "On Demand",
                      style: TextStyle(
                          color: Colors.black, fontSize: dynamicSize(0.03)),
                    );
                  });
                }
              },
              icon: cusIcon,
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size(25, 25),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        showButtonListDialog(context);
                      },
                      child: Container(
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 8.0, right: 4, top: 4, bottom: 4),
                              child: Icon(Icons.filter_alt_outlined),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 4.0, right: 4, top: 4, bottom: 4),
                              child: Text('Categories'),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 4.0, right: 8, top: 4, bottom: 4),
                              child: Icon(Icons.arrow_drop_down),
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                          color: AllColor.shado_color,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: dynamicSize(0.03),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MapePage()),
                        );
                      },
                      child: Container(
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 4, top: 4, bottom: 4),
                              child: Icon(Icons.verified_outlined),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 4.0, right: 10, top: 4, bottom: 4),
                              child: Text('Popualar'),
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                          color: AllColor.shado_color,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: dynamicSize(0.03),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FeedBackPage()),
                        );
                      },
                      child: Container(
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 4, top: 4, bottom: 4),
                              child: Icon(Icons.shopping_cart_outlined),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 4.0, right: 10, top: 4, bottom: 4),
                              child: Text('Token Before'),
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                          color: AllColor.shado_color,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          title: cusSearchbar,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(8),
          children: List.generate(
            DataControllers.to.shortServiceResponse.value.data!.length,
            (index) => Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 2.0,
                      spreadRadius: 0.0,
                      offset:
                          Offset(2.0, 2.0), // shadow direction: bottom right
                    )
                  ],
                ),
                child: Row(
                  children: [
                    CachedNetworkImage(
                      width: 120,
                      imageUrl:
                          "${DataControllers.to.shortServiceResponse.value.data![index].imagePath /* == null ?   "https://cdn.vectorstock.com/i/1000x1000/21/73/old-people-in-hospital-vector-34042173.webp": DataControllers.to.shortServiceResponse.value.data![index]!.imagePath */}",
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) =>
                              CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Image.asset(
                        "assets/images/image.png",
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 5),
                          child: Text(
                            "${DataControllers.to.shortServiceResponse.value.data![index].serviceName /*! == null  ? "Guest" : DataControllers.to.shortServiceResponse.value.data![index]!.serviceName*/}",
                            style: TextStyle(
                                fontSize: dynamicSize(0.04),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          height: dynamicSize(0.02),
                        ),
                        TextButton(
                          onPressed: () {
                            showButtonDialog(context, index);
                          },
                          child: Text(
                            "Details",
                            style: TextStyle(
                                fontSize: dynamicSize(0.035),
                                color: Colors.purple),
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    InkWell(
                      onTap: () {
                        print("object");
                        // Navigator.pop(context);
                        addCard(index);
                      },
                      child:

                          //  DataControllers.to.shortServiceResponse.value.data![index].status == "Done" ?

                          /* Image.asset(
                        "assets/images/done_image.png",
                      ) :*/
                          Image.asset(
                        "assets/images/add.png",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  void showButtonDialog(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            height: dynamicSize(0.84),
            child: Column(
              children: [
                Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.cancel,
                          color: Colors.white,
                          size: 35,
                        ))),
                Container(
                  height: dynamicSize(0.7),
                  decoration: BoxDecoration(
                    color: AllColor.button_color,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(15.0),
                      topLeft: Radius.circular(15.0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 5),
                            child: Image.asset(
                              "assets/images/image.png",
                              height: 100,
                              width: 100,
                            ),
                          ),
                          Spacer(),
                          Column(
                            children: [
                              InkWell(
                                onTap: () async {
                                  Navigator.pop(context);


                                  addCard(index);

                                  /*  if(DataControllers.to.addServiceResponse.value.success!)
                                    {
                                      DataControllers.to.shortServiceResponse.value.data![index].status = "Done";
                                    }*/

                                  //updatedUserService();

                                  /*  setState(() {
                                    showBottom = true;
                                 //   DataControllers.to.shortServiceResponse;
                                    addedlist = true;
                                  });*/
                                },
                                child: Image.asset(
                                  "assets/images/added_now_button.png",
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 5),
                        child: Text(
                          DataControllers.to.shortServiceResponse.value
                              .data![index].serviceName!,
                          style: TextStyle(
                              fontSize: dynamicSize(0.05),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 5),
                        child: Text(
                          DataControllers.to.shortServiceResponse.value
                              .data![index].description!,
                          style: TextStyle(
                            fontSize: dynamicSize(0.03),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  void BottomSheetAddedListDialog(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bcs) {
          return Container(
            height: dynamicSize(0.9),
            child: Column(
              children: [
                Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_drop_down_circle_outlined,
                          color: Colors.white,
                          size: 35,
                        ))),
                Container(
                  color: AllColor.button_color,
                  height: dynamicSize(0.55),
                  child: ListView(
                    padding: const EdgeInsets.all(8),
                    children: new List.generate(
                      DataControllers.to.getAddCardResponse.value.data!.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 2.0,
                                spreadRadius: 0.0,
                                offset: Offset(
                                    2.0, 2.0), // shadow direction: bottom right
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                "assets/images/image.png",
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8.0, left: 5),
                                    child: Text(
                                      "${DataControllers.to.getAddCardResponse.value.data![index].bookingDate == null ? "Service Name" : DataControllers.to.getAddCardResponse.value.data![index].bookingDate}",
                                      style: TextStyle(
                                          fontSize: dynamicSize(0.04),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(
                                    height: dynamicSize(0.02),
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: Text(
                                      "",
                                      style: TextStyle(
                                          fontSize: dynamicSize(0.035),
                                          color: Colors.purple),
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Container(
                                height: 40,
                                width: 40,
                                child: InkWell(
                                  onTap: () {
                                    deleteAddCardData(index);
                                  },
                                  child: Image.asset(
                                    "assets/images/demand_service_cross_button.png",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  void showButtonListDialog(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child:

/*Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Select Category",style: TextStyle(fontSize: dynamicSize(0.08),fontWeight: FontWeight.bold),),
                      Text("Deselect All",style: TextStyle(fontSize: dynamicSize(0.05),color: Colors.purple),),
                    ],
                  ),*/

                  ListView(
                children: List.generate(
                  DataControllers.to.getCategoriesResponse.value.data!.length,
                  (index) => Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${DataControllers.to.getCategoriesResponse.value.data![index].categoryName}",
                        style: TextStyle(fontSize: dynamicSize(0.05)),
                      ),
                      CheckBox(),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    showBottom = false;
    getAddCardData();
    /* if(DataControllers.to.userServiceResponse.value.data!.isNotEmpty)
      {
        showBottom = false;
      }*/
  }

  void getAddCardData() async {
    await DataControllers.to.getCard(
        DataControllers.to.userLoginResponse.value.data!.user!.id.toString());

    if (DataControllers.to.getAddCardResponse.value.data!.length > 0) {
      setState(() {
        DataControllers.to.getAddCardResponse;
        showBottom = true;
        addedlist = true;
      });
    } else {
      showBottom = false;
      addedlist = false;
    }
  }

  void deleteAddCardData(int index) async {
    await DataControllers.to.deleteCard(
        DataControllers.to.userLoginResponse.value.data!.user!.id.toString(),
        DataControllers.to.getAddCardResponse.value.data![index].id.toString());
    showToast(DataControllers.to.errorResponse.value.message!);

    if (DataControllers.to.errorResponse.value.success!) {
      getAddCardData();
    }
  }

  void addCard(int index) async{

    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);

    await DataControllers.to.addCard(
        DataControllers.to.userLoginResponse.value
            .data!.user!.id
            .toString(),
        DataControllers.to.shortServiceResponse
            .value.data![index].id
            .toString(),
        formattedDate);

    showToast(
        DataControllers
            .to.addCardResponse.value.message!,
        AllColor.blue);
    Navigator.pop(context);

    if (DataControllers
        .to.addCardResponse.value.success!) {
      Common.storeSharedPreferences.setString("service", "short");

      getAddCardData();
    }
  }
}
