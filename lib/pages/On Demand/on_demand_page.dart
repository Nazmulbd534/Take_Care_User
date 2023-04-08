import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:takecare_user/controllers/DataContollers.dart';
import 'package:takecare_user/controllers/language_controller.dart';
import 'package:takecare_user/model/AllServiceResponse.dart';
import 'package:takecare_user/model/CategoriesResponse.dart';
import 'package:takecare_user/model/LovedOnesResponse.dart';
import 'package:takecare_user/pages/On%20Demand/schedule_order_page.dart';
import 'package:takecare_user/pages/home_page.dart';
import 'package:intl/intl.dart';
import 'package:takecare_user/pages/loved_form_page.dart';
import 'package:takecare_user/pages/loved_ones_page.dart';
import 'package:takecare_user/public_variables/all_colors.dart';
import 'package:takecare_user/public_variables/notifications.dart';
import 'package:takecare_user/public_variables/size_config.dart';
import 'package:takecare_user/public_variables/variables.dart';
import 'package:takecare_user/ui/common.dart';
import 'package:toggle_switch/toggle_switch.dart';
import '../../api_service/ApiService.dart';
import '../long_time_services/service_request_form_page.dart';
import 'feedback_page.dart';
import 'map_page.dart';
import 'package:blurrycontainer/blurrycontainer.dart';

class OnDemandPage extends StatefulWidget {
  List<String> selectedCategory;

  OnDemandPage({Key? key, required this.selectedCategory}) : super(key: key);

  @override
  _OnDemandPageState createState() => _OnDemandPageState();
}

class _OnDemandPageState extends State<OnDemandPage> {
  Icon cusIcon = const Icon(Icons.search, color: Colors.black);
  Widget cusSearchbar = Text(
    "Book for right now or later",
    style: TextStyle(
        fontFamily: 'Muli',
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontSize: 15),
  );

  bool focus = false;

  int selectedColor = 0;
  List<AllServiceData> _searchResult = [];
  TextEditingController searchController = TextEditingController();

  late GeocodingResult resultGeo;

  var addedservice = false;
  var showBottom = false;
  var addedlist = false;
  var searchValue = false;
  List<String> result = [];
  List<AllServiceData> searchData = [];
  bool selectMyself = true;
  @override
  void initState() {
    super.initState();
    log(widget.selectedCategory.toString(), name: "selectedCategory");
    if (widget.selectedCategory[0] != "") {
      for (int i = 0; i < widget.selectedCategory.length; i++) {
        setState(() {
          result.add(widget.selectedCategory[i]);
        });

        _filterValue();
      }
      // for (int i = 0;
      //     i < DataControllers.to.getCategoriesResponse.value.data!.length;
      //     i++) {
      //   if (DataControllers
      //           .to.getCategoriesResponse.value.data![i].categoryName ==
      //       widget.selectedCategory[i]) {
      //     setState(() {
      //       _isChecked[i] = true;
      //     });
      //   }
      // }
    } else {
      log("here");
      getAllService();
    }
    showBottom = false;
    getAddCardData();
    setState(() {
      searchData;
    });
    _getUserLocation();
    loadOrderHistory();
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
                        icon: const Icon(
                          Icons.cancel,
                          color: Colors.white,
                          size: 35,
                        ))),
                ServiceButtonWidget(
                  index: index,
                  addCard: addCard,
                ),
              ],
            ),
          );
        });
  }

  // TODO :: here

  void BottomSheetAddedListDialog(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bcs) {
          return Container(
            color: Colors.transparent,
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
                  color: AllColor.card_bg,
                  height: dynamicSize(0.55),
                  child: ListView(
                    padding: const EdgeInsets.all(8),
                    children: List.generate(
                      DataControllers
                          .to.getAddCardShortServiceResponse.value.data!.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors.white,
                            boxShadow: const [
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
                              Card(
                                margin: const EdgeInsets.only(
                                    left: 0, top: 10, bottom: 10),
                                semanticContainer: true,
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(15),
                                      topRight: Radius.circular(15)),
                                ),
                                elevation: 10,
                                child: CachedNetworkImage(
                                  fit: BoxFit.fill,
                                  width: 120,
                                  height: 110,
                                  imageUrl:
                                      "${ApiService.MainURL}${DataControllers.to.getAddCardShortServiceResponse.value.data![index].service!.imagePath /* == null ?   "https://cdn.vectorstock.com/i/1000x1000/21/73/old-people-in-hospital-vector-34042173.webp": DataControllers.to.shortServiceResponse.value.data![index]!.imagePath */}",
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                    "assets/images/image.png",
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8.0, left: 5, right: 10),
                                      child: Text(
                                        "${DataControllers.to.getAddCardShortServiceResponse.value.data![index].service!.serviceName == null ? "Service Name" : DataControllers.to.getAddCardShortServiceResponse.value.data![index].service!.serviceName}",
                                        style: TextStyle(
                                            fontSize: dynamicSize(0.04),
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 40,
                                width: 40,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
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
    List<CategoriesData> dataResponse = [];

    // DataControllers.to.getCategoriesResponse.value.data!.forEach((element) => _setData(element)).toList();
    DataControllers.to.getCategoriesResponse.value.data!.forEach((element) {
      if (element.serviceType == "short") {
        dataResponse.add(element);
      }
    });

    // dataResponse.add( DataControllers.to.getCategoriesResponse.value.data!.map((e) => e.serviceType == "short").toList());

    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return StatefulBuilder(builder: (context, setSt) {
            return Container(
              color: Colors.white,
              /*margin: EdgeInsets.only(left: 10,right: 10),*/
              height: dynamicSize(2),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Select Category",
                          style: TextStyle(
                              fontSize: dynamicSize(0.07),
                              fontWeight: FontWeight.bold),
                        ),
                        // InkWell(
                        //     // onTap: () {
                        //     //   setSt(() {
                        //     //     _isChecked = List<bool>.filled(
                        //     //         DataControllers.to.getCategoriesResponse
                        //     //             .value.data!.length,
                        //     //         false);
                        //     //   });

                        //     //   searchData = [];
                        //     //   result = [];
                        //     //   searchValue = false;
                        //     //   setState(() {});
                        //     //   //Navigator.pop(context);
                        //     // },
                        //     child: widget.selectedCategory.contains(true)
                        //         ? Text("Deselect All",
                        //             style: TextStyle(
                        //                 fontSize: dynamicSize(0.05),
                        //                 color: Colors.purple))
                        //         : Container()),
                      ],
                    ),
                    Flexible(
                      child: Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ListView(
                            children: List.generate(
                                dataResponse.length,
                                (index) => CheckboxListTile(
                                      title: Text(
                                          dataResponse[index].categoryName!),
                                      value: widget.selectedCategory.contains(
                                          dataResponse[index].categoryName!),
                                      onChanged: (val) {
                                        if (val!) {
                                          result.add(dataResponse[index]
                                              .categoryName!);
                                        } else {
                                          String? value = result
                                              .firstWhereOrNull((element) =>
                                                  element ==
                                                  dataResponse[index]
                                                      .categoryName!);
                                          result.remove(value);
                                        }
                                        // setSt(() {
                                        //   _isChecked[index] = val;
                                        // });
                                        setSt(() {
                                          if (val) {
                                            widget.selectedCategory.add(
                                                dataResponse[index]
                                                    .categoryName!);
                                          } else {
                                            widget.selectedCategory.remove(
                                                dataResponse[index]
                                                    .categoryName!);
                                          }
                                        });

                                        setState(() {});
                                      },
                                    )),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: dynamicSize(0.08)),
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          _filterValue();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text('Show Listing',
                                  style:
                                      TextStyle(fontSize: dynamicSize(0.045))),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          });
        }).whenComplete(() {
      log("done");
      setState(() {
        _filterValue();
      });
    });
  }

  void getAddCardData() async {
    await DataControllers.to.getCard('short');
    await DataControllers.to.getAllShortService("short");
    setState(() {
      searchData;
    });
    if (DataControllers.to.getAddCardShortServiceResponse.value.data == null) {
      setState(() {
        showBottom = false;
        addedlist = false;
        DataControllers.to.getAddCardShortServiceResponse;
      });
    } else if (DataControllers
            .to.getAddCardShortServiceResponse.value.data!.length >
        0) {
      setState(() {
        DataControllers.to.getAddCardShortServiceResponse;
        showBottom = true;
        addedlist = true;
      });
    } else {
      setState(() {
        DataControllers.to.getAddCardShortServiceResponse;
        showBottom = false;
        addedlist = false;
      });
    }

    setState(() {
      DataControllers.to.shortServiceResponse;
      searchData;
      _filterValue();
    });
  }

  void deleteAddCardData(int index) async {
    await DataControllers.to.deleteCard(
        DataControllers.to.userLoginResponse.value.data!.user!.id.toString(),
        DataControllers.to.getAddCardShortServiceResponse.value.data![index].id
            .toString());
    showToast(DataControllers.to.addCardResponse.value.message!);

    if (DataControllers.to.addCardResponse.value.success!) {
      getAddCardData();
    }
  }

  void addCard(int index) async {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);

    log(searchData[index].id.toString(), name: "YUGRFEKF");

    await DataControllers.to
        .addCard(searchData[index].id.toString(), formattedDate);

    if (DataControllers.to.addCardResponse.value.success!) {
      Common.storeSharedPreferences.setString("service", "short");
      getAddCardData();
    } else {
      showToast(
          DataControllers.to.addCardResponse.value.message!, AllColor.blue);
    }
  }

  void getAllService() async {
    await DataControllers.to.getAllShortService("short");
    _filterValue();
  }

  void _filterValue() {
    searchData = [];
    searchValue = false;

    if (result.isEmpty) {
      DataControllers.to.shortServiceResponse.value.data!.data!
          .forEach((value) {
        value.serviceCats!.forEach((categories) {
          searchData.add(value);
          searchValue = true;
        });
      });
    }

    result.forEach((element) {
      DataControllers.to.shortServiceResponse.value.data!.data!
          .forEach((value) {
        value.serviceCats!.forEach((categories) {
          if (element == categories.serviceCategory!.categoryName) {
            searchData.add(value);
            searchValue = true;
          }
        });
      });
    });

    setState(() {
      searchValue;
    });
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      //  _searchResult.addAll(DataControllers.to.shortServiceResponse.value.data!.data!);
      setState(() {});
      return;
    }

    DataControllers.to.shortServiceResponse.value.data!.data!
        .forEach((userDetail) {
      if (userDetail.serviceName!.toLowerCase().contains(text.toLowerCase())) {
        _searchResult.add(userDetail);
        //print(userDetail.serviceName!);
        // print(userDetail.added_in_my_service!);
      }
    });

    setState(() {});
  }

  void _getUserLocation() async {
    print('_getUserLocation');
    LocationPermission permission;
    permission = await Geolocator.requestPermission();

    var position = await GeolocatorPlatform.instance.getCurrentPosition();

    setState(() {
      Variables.currentPostion = LatLng(position.latitude, position.longitude);

      print(
          'lat : ${Variables.currentPostion.latitude} \nlong ${Variables.currentPostion.longitude}');

      double locationDistance = Geolocator.distanceBetween(
              position.latitude, position.longitude, 23.742743, 90.418278) /
          1000;
      print('distance : ${locationDistance}');
    });
  }

  Future<bool> _onWillPop() async {
    setState(() {
      result = [];
      _filterValue();
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
    return true;
  }

  int selectedToogleIndex = 0;

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          children: List.generate(
            _searchResult.length,
            (index) => Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      /* borderRadius: BorderRadius.circular(8.0),*/
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                              left: 0, top: 10, bottom: 10),
                          child: Card(
                            margin: const EdgeInsets.only(left: 0),
                            semanticContainer: true,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(15),
                                  topRight: Radius.circular(15)),
                            ),
                            elevation: 10,
                            child: CachedNetworkImage(
                              fit: BoxFit.fill,
                              width: 120,
                              height: 110,
                              imageUrl:
                                  "${ApiService.MainURL}${_searchResult[index].imagePath}",
                              errorWidget: (context, url, error) => Image.asset(
                                "assets/images/image.png",
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    "${_searchResult[index].serviceName}",
                                    style: TextStyle(
                                        fontSize: dynamicSize(0.04),
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(
                                  height: dynamicSize(0.12),
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
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 20.0,
                    right: 0.0,
                    child: InkWell(
                        onTap: () {
                          addCard(index);
                        },
                        child: Container(
                          height: dynamicSize(0.10),
                          width: dynamicSize(0.12),
                          child: Card(
                            color: AllColor.pink_button,
                            margin: EdgeInsets.only(left: 0, right: 0),
                            semanticContainer: true,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(15),
                                  topLeft: Radius.circular(15)),
                            ),
                            elevation: 6,
                            child: Icon(
                              (_searchResult[index].addedInMyCart == null)
                                  ? Icons.add
                                  : Icons.done,
                              color: Colors.white,
                            ),
                          ),
                        )),
                  )
                ],
              ),
            ),
          ),
        );
      case 1:
        return ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          children: List.generate(
            searchValue
                ? searchData.length
                : DataControllers
                    .to.shortServiceResponse.value.data!.data!.length,
            (index) => Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      /* borderRadius: BorderRadius.circular(8.0),*/
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                              left: 0, top: 10, bottom: 10),
                          child: Card(
                            margin: const EdgeInsets.only(left: 0),
                            semanticContainer: true,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(15),
                                  topRight: Radius.circular(15)),
                            ),
                            elevation: 10,
                            child: CachedNetworkImage(
                              fit: BoxFit.fill,
                              width: 120,
                              height: 110,
                              imageUrl:
                                  "${ApiService.MainURL}${(searchValue != true) ? DataControllers.to.shortServiceResponse.value.data!.data![index].imagePath : searchData[index].imagePath /* == null ?   "https://cdn.vectorstock.com/i/1000x1000/21/73/old-people-in-hospital-vector-34042173.webp": DataControllers.to.shortServiceResponse.value.data![index]!.imagePath */}",
                              errorWidget: (context, url, error) => Image.asset(
                                "assets/images/image.png",
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    "${(searchValue != true) ? DataControllers.to.shortServiceResponse.value.data!.data![index].serviceName : searchData[index].serviceName}",
                                    style: TextStyle(
                                        fontSize: dynamicSize(0.04),
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 10, top: 5),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Estimated Price ${(searchValue != true) ? DataControllers.to.shortServiceResponse.value.data!.data![index].price : searchData[index].price}/-",
                                        style: TextStyle(
                                          fontSize: dynamicSize(0.04),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Tooltip(
                                        message:
                                            "It's an estimated price, it's not the final. Price various upon service provider's demand",
                                        showDuration: Duration(seconds: 5),
                                        triggerMode: TooltipTriggerMode.tap,
                                        child: Text("ⓘ"),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: dynamicSize(0.12),
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
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 20.0,
                    right: 0.0,
                    child: InkWell(
                        onTap: () {
                          addCard(index);
                        },
                        child: Container(
                          height: dynamicSize(0.10),
                          width: dynamicSize(0.12),
                          child: Card(
                            color: AllColor.pink_button,
                            margin: EdgeInsets.only(left: 0, right: 0),
                            semanticContainer: true,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(15),
                                  topLeft: Radius.circular(15)),
                            ),
                            elevation: 6,
                            child: Icon(
                              (searchValue != true)
                                  ? ((DataControllers
                                              .to
                                              .shortServiceResponse
                                              .value
                                              .data!
                                              .data![index]
                                              .addedInMyCart ==
                                          null)
                                      ? Icons.add
                                      : Icons.done)
                                  : ((searchData[index].addedInMyCart == null)
                                      ? Icons.add
                                      : Icons.done),
                              color: Colors.white,
                            ),
                          ),
                        )),
                  )
                ],
              ),
            ),
          ),
        );
      case 2:
        return ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          children: List.generate(
            searchValue
                ? searchData.length
                : DataControllers
                    .to.shortServiceResponse.value.data!.data!.length
                    .clamp(0, 3),
            (index) => Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      /* borderRadius: BorderRadius.circular(8.0),*/
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                              left: 0, top: 10, bottom: 10),
                          child: Card(
                            margin: const EdgeInsets.only(left: 0),
                            semanticContainer: true,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(15),
                                  topRight: Radius.circular(15)),
                            ),
                            elevation: 10,
                            child: CachedNetworkImage(
                              fit: BoxFit.fill,
                              width: 120,
                              height: 110,
                              imageUrl:
                                  "${ApiService.MainURL}${(searchValue != true) ? DataControllers.to.shortServiceResponse.value.data!.data![index].imagePath : searchData[index].imagePath /* == null ?   "https://cdn.vectorstock.com/i/1000x1000/21/73/old-people-in-hospital-vector-34042173.webp": DataControllers.to.shortServiceResponse.value.data![index]!.imagePath */}",
                              errorWidget: (context, url, error) => Image.asset(
                                "assets/images/image.png",
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    "${(searchValue != true) ? DataControllers.to.shortServiceResponse.value.data!.data![index].serviceName : searchData[index].serviceName}",
                                    style: TextStyle(
                                        fontSize: dynamicSize(0.04),
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(
                                  height: dynamicSize(0.12),
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
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 20.0,
                    right: 0.0,
                    child: InkWell(
                        onTap: () {
                          addCard(index);
                        },
                        child: Container(
                          height: dynamicSize(0.10),
                          width: dynamicSize(0.12),
                          child: Card(
                            color: AllColor.pink_button,
                            margin: EdgeInsets.only(left: 0, right: 0),
                            semanticContainer: true,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(15),
                                  topLeft: Radius.circular(15)),
                            ),
                            elevation: 6,
                            child: Icon(
                              (searchValue != true)
                                  ? ((DataControllers
                                              .to
                                              .shortServiceResponse
                                              .value
                                              .data!
                                              .data![index]
                                              .addedInMyCart ==
                                          null)
                                      ? Icons.add
                                      : Icons.done)
                                  : ((searchData[index].addedInMyCart == null)
                                      ? Icons.add
                                      : Icons.done),
                              color: Colors.white,
                            ),
                          ),
                        )),
                  )
                ],
              ),
            ),
          ),
        );
    }

    return SizedBox();
  }

  void loadOrderHistory() async {
    var data = await ApiService.getOrderHistory();
    log(data.toString(), name: "loadOrderHistory");
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LanguageController>(builder: (lc) {
      return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          bottomNavigationBar: showBottom
              ? BlurryContainer(
                  blur: 30,
                  // color: Colors.white.withOpacity(0.15)
                  elevation: 0,
                  color: Colors.transparent.withOpacity(0.001),
                  padding: const EdgeInsets.all(12),
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  child: Container(
                    height: dynamicSize(0.18),
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AllColor.themeColor,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5.0),
                                  bottomLeft: Radius.circular(5.0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, top: 5),
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
                                                      .getAddCardShortServiceResponse
                                                      .value
                                                      .data!
                                                      .length
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize:
                                                          dynamicSize(0.04),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5),
                                                child: Text(
                                                  " Service Added",
                                                  style: TextStyle(
                                                      fontSize:
                                                          dynamicSize(0.04),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white),
                                                ),
                                              ),
                                              const Padding(
                                                padding:
                                                    EdgeInsets.only(left: 8.0),
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
                            onTap: () async {
                              // TODO : move these logic accordingly

                              serviceReceiverSheetOnDemand(context);
                              // await DataControllers.to.getProviderList(
                              //     "1",
                              //     "1",
                              //     Variables.currentPostion.longitude.toString(),
                              //     Variables.currentPostion.latitude.toString());
                              // resultGeo = (await Navigator.push(
                              //   context,
                              //   MaterialPageRoute<GeocodingResult>(
                              //     builder: (cx) {
                              //       return MapLocationPicker(
                              //           topCardColor: Colors.white70,
                              //           bottomCardColor: Colors.pinkAccent,
                              //           origin: Location(
                              //               lat: Variables
                              //                   .currentPostion.latitude,
                              //               lng: Variables
                              //                   .currentPostion.longitude),
                              //           desiredAccuracy: LocationAccuracy.high,
                              //           location: Location(
                              //               lat: Variables
                              //                   .currentPostion.latitude,
                              //               lng: Variables
                              //                   .currentPostion.longitude),
                              //           apiKey:
                              //               "AIzaSyB5x56y_2IlWhARk8ivDevq-srAkHYr9HY",
                              //           canPopOnNextButtonTaped: true,
                              //           onNext: (GeocodingResult? result) {
                              //             if (result != null) {
                              //               setState(() {
                              //                 resultGeo = result;
                              //                 Navigator.pop(cx, resultGeo);
                              //               });
                              //             } else {
                              //               resultGeo = result!;
                              //             }
                              //           });
                              //     },
                              //   ),
                              // ))!;
                              // if (resultGeo != null) {
                              //   Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (cp) => MapPage(
                              //               result: resultGeo,
                              //             )),
                              //   );
                              // }
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: AllColor.button_color,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(5.0),
                                    bottomRight: Radius.circular(5.0)),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
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
                                  const Icon(
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
                  ),
                )
              : Container(height: .01),
          appBar: AppBar(
            leading: InkWell(
              child: const Icon(
                Icons.arrow_back,
                color: Colors.red,
              ),
              onTap: () {
                setState(() {
                  result = [];
                  _filterValue();
                });
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
            ),
            actions: <Widget>[
              IconButton(
                onPressed: () {
                  setState(() {
                    cusIcon;
                    focus = true;
                  });
                  if (cusIcon.icon == Icons.search) {
                    setState(() {
                      cusIcon =
                          Icon(Icons.cancel, color: AllColor.cancel_icon_color);
                      cusSearchbar = Card(
                        color: AllColor.search_field_color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        child: SizedBox(
                          width: dynamicSize(20),
                          height: dynamicSize(0.09),
                          child: TextField(
                            autofocus: focus,
                            controller: searchController,
                            onChanged: (text) => onSearchTextChanged(text),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              fillColor: AllColor.search_field_color,
                              hintText: lc.search.value,
                              prefixIcon: Icon(Icons.search),
                            ),
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: dynamicSize(0.04)),
                          ),
                        ),
                      );
                    });
                  } else {
                    setState(() {
                      onSearchTextChanged('');
                      searchController.text = '';
                      cusIcon = Icon(Icons.search, color: Colors.black);
                      cusSearchbar = Text(
                        LanguageController.lc.onDemandServiceSetup.value,
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
              preferredSize: const Size(25, 35),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 10),
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            selectedColor = 1;
                          });
                          showButtonListDialog(context);
                        },
                        child: Container(
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 8.0, right: 4, top: 4, bottom: 4),
                                child: Icon(Icons.filter_alt_outlined,
                                    color: (selectedColor == 1)
                                        ? Colors.white
                                        : Colors.black),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 4.0, right: 4, top: 4, bottom: 4),
                                child: Text(
                                  'Categories',
                                  style: TextStyle(
                                      color: (selectedColor == 1)
                                          ? Colors.white
                                          : Colors.black),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 4.0, right: 8, top: 4, bottom: 4),
                                child: Icon(
                                  Icons.arrow_drop_down,
                                  color: (selectedColor == 1)
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                          decoration: BoxDecoration(
                            color: (selectedColor == 1)
                                ? Colors.pinkAccent
                                : AllColor.shado_color,
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: dynamicSize(0.03),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            selectedColor = 5;
                            searchValue = false;
                          });
                        },
                        child: Container(
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 10.0, right: 4, top: 4, bottom: 4),
                                child: Icon(Icons.list_alt,
                                    color: (selectedColor == 5)
                                        ? Colors.white
                                        : Colors.black),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 4.0, right: 10, top: 4, bottom: 4),
                                child: Text('All',
                                    style: TextStyle(
                                        color: (selectedColor == 5)
                                            ? Colors.white
                                            : Colors.black)),
                              ),
                            ],
                          ),
                          decoration: BoxDecoration(
                            color: (selectedColor == 5)
                                ? Colors.pinkAccent
                                : AllColor.shado_color,
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: dynamicSize(0.03),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            selectedColor = 2;
                          });
                          /*     Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const FeedBackPage()),
                          );*/
                        },
                        child: Container(
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 10.0, right: 4, top: 4, bottom: 4),
                                child: Icon(Icons.shopping_cart_outlined,
                                    color: (selectedColor == 2)
                                        ? Colors.white
                                        : Colors.black),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 4.0, right: 10, top: 4, bottom: 4),
                                child: Text('Taken Before',
                                    style: TextStyle(
                                        color: (selectedColor == 2)
                                            ? Colors.white
                                            : Colors.black)),
                              ),
                            ],
                          ),
                          decoration: BoxDecoration(
                            color: (selectedColor == 2)
                                ? Colors.pinkAccent
                                : AllColor.shado_color,
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: dynamicSize(0.03),
                      ),
                      InkWell(
                        onTap: () {},
                        child: Container(
                          child: Row(
                            children: const [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 10.0, right: 4, top: 4, bottom: 4),
                                child: Icon(Icons.verified_outlined),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 4.0, right: 10, top: 4, bottom: 4),
                                child: Text('Popular Service'),
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
          body: (_searchResult.isNotEmpty || searchController.text.isNotEmpty)
              ? _buildBody(0)
              : (selectedColor == 2)
                  ? _buildBody(2)
                  : _buildBody(1),
        ),
      );
    });
  }

  void serviceReceiverSheetOnDemand(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Container(
                decoration: const BoxDecoration(
                  color: AllColor.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15.0),
                    topLeft: Radius.circular(15.0),
                  ),
                ),
                height: dynamicSize(0.97),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Colors.black38,
                          size: 25,
                        ),
                      ),
                    ),
                    const Center(
                      child: Text(
                        "Book For",
                        style: TextStyle(
                            color: AllColor.boldTextColor,
                            fontFamily: "Muli",
                            fontWeight: FontWeight.w600,
                            fontSize: 18.0),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Center(
                      child: ToggleSwitch(
                        minWidth: 90.0,
                        cornerRadius: 20.0,
                        activeBgColors: [
                          [AllColor.pink_button],
                          [AllColor.pink_button]
                        ],
                        activeFgColor: Colors.white,
                        inactiveBgColor: Colors.grey,
                        inactiveFgColor: Colors.white,
                        initialLabelIndex: selectedToogleIndex,
                        totalSwitches: 2,
                        labels: ['Now', 'Later'],
                        radiusStyle: true,
                        onToggle: (index) {
                          selectedToogleIndex = index!;
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10, right: 10, top: 15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectMyself = true;
                                    });
                                  },
                                  child: Container(
                                    height: dynamicSize(0.3),
                                    child: Card(
                                      color: selectMyself
                                          ? AllColor.blue_light
                                          : AllColor.white_light,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 15,
                                                bottom: 10,
                                                left: 10,
                                                right: 10),
                                            child: Text(
                                              'Myself',
                                              style: TextStyle(
                                                  fontSize: dynamicSize(0.05),
                                                  fontWeight: FontWeight.bold,
                                                  color: selectMyself
                                                      ? AllColor.white
                                                      : Colors.black),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 10, left: 10, right: 10),
                                            child: Text(
                                              'Book Service for you',
                                              style: TextStyle(
                                                  fontSize: dynamicSize(0.04),
                                                  fontWeight: FontWeight.bold,
                                                  color: selectMyself
                                                      ? AllColor.white
                                                      : Colors.black38),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: dynamicSize(0.35),
                                margin: EdgeInsets.all(10),
                                alignment: Alignment.center,
                                child: Text(
                                  'Or',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: dynamicSize(0.06),
                                    fontWeight: FontWeight.bold,
                                    color: AllColor.black,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectMyself = false;
                                    });
                                  },
                                  child: Container(
                                    height: dynamicSize(0.3),
                                    child: Card(
                                      color: selectMyself
                                          ? AllColor.white_light
                                          : AllColor.blue_light,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 15,
                                                bottom: 10,
                                                left: 10,
                                                right: 10),
                                            child: Text(
                                              'Loved Ones',
                                              style: TextStyle(
                                                  fontSize: dynamicSize(0.05),
                                                  fontWeight: FontWeight.bold,
                                                  color: selectMyself
                                                      ? Colors.black
                                                      : AllColor.white),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 10, left: 10, right: 10),
                                            child: Text(
                                              'Book Service for Your loved One\'s',
                                              style: TextStyle(
                                                  fontSize: dynamicSize(0.04),
                                                  fontWeight: FontWeight.bold,
                                                  color: selectMyself
                                                      ? Colors.black38
                                                      : AllColor.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () async {
                              if (selectMyself) {
                                if (selectedToogleIndex == 1) {
                                  log("Scheduled for later  myself");
                                  await DataControllers.to.getProviderList(
                                      "1",
                                      "1",
                                      Variables.currentPostion.longitude
                                          .toString(),
                                      Variables.currentPostion.latitude
                                          .toString());
                                  // ignore: use_build_context_synchronously
                                  resultGeo = (await Navigator.push(
                                    context,
                                    MaterialPageRoute<GeocodingResult>(
                                      builder: (cx) {
                                        return MapLocationPicker(
                                            topCardColor: Colors.white70,
                                            bottomCardColor: Colors.pinkAccent,
                                            currentLatLng:
                                                Variables.currentPostion,
                                            desiredAccuracy:
                                                LocationAccuracy.high,
                                            apiKey:
                                                "AIzaSyB5x56y_2IlWhARk8ivDevq-srAkHYr9HY",
                                            canPopOnNextButtonTaped: true,
                                            onNext: (GeocodingResult? result) {
                                              if (result != null) {
                                                setState(() {
                                                  resultGeo = result;
                                                  Navigator.pop(cx, resultGeo);
                                                });
                                              } else {
                                                resultGeo = result!;
                                              }
                                            });
                                      },
                                    ),
                                  ))!;
                                  if (resultGeo != null) {
                                    // ignore: use_build_context_synchronously
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (cp) => ScheduledOrderPage(
                                          result: resultGeo,
                                          orderType: "Schedule",
                                        ),
                                      ),
                                    );
                                  }
                                } else {
                                  await DataControllers.to.getProviderList(
                                      "1",
                                      "1",
                                      Variables.currentPostion.longitude
                                          .toString(),
                                      Variables.currentPostion.latitude
                                          .toString());
                                  // ignore: use_build_context_synchronously
                                  resultGeo = (await Navigator.push(
                                    context,
                                    MaterialPageRoute<GeocodingResult>(
                                      builder: (cx) {
                                        return MapLocationPicker(
                                            topCardColor: Colors.white70,
                                            bottomCardColor: Colors.pinkAccent,
                                            currentLatLng:
                                                Variables.currentPostion,
                                            desiredAccuracy:
                                                LocationAccuracy.high,
                                            apiKey:
                                                "AIzaSyB5x56y_2IlWhARk8ivDevq-srAkHYr9HY",
                                            canPopOnNextButtonTaped: true,
                                            onNext: (GeocodingResult? result) {
                                              if (result != null) {
                                                setState(() {
                                                  resultGeo = result;
                                                  Navigator.pop(cx, resultGeo);
                                                });
                                              } else {
                                                resultGeo = result!;
                                              }
                                            });
                                      },
                                    ),
                                  ))!;
                                  if (resultGeo != null) {
                                    // ignore: use_build_context_synchronously
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (cp) => MapPage(
                                          result: resultGeo,
                                        ),
                                      ),
                                    );
                                  }
                                }
                              } else {
                                if (selectedToogleIndex == 1) {
                                  log("Schedulef for later");
                                  LovedOnesResponse lovedOnes =
                                      await ApiService.getFavAddress();
                                  if (!lovedOnes.success!) {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (_) => LovedFormPage(
                                          activity: Variables
                                              .orderInformationActivity,
                                        ),
                                      ),
                                    );
                                  } else {
                                    log("not empty");
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (_) => LovedOnesPage(
                                            activity: "ScheduleActivity"),
                                      ),
                                    );
                                  }
                                } else {
                                  LovedOnesResponse lovedOnes =
                                      await ApiService.getFavAddress();
                                  if (!lovedOnes.success!) {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (_) => LovedFormPage(
                                          activity: Variables
                                              .orderInformationActivity,
                                        ),
                                      ),
                                    );
                                  } else {
                                    log("not empty");
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (_) => LovedOnesPage(
                                            activity: "SelectAndGotoMap"),
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            child: Container(
                              height: dynamicSize(0.1),
                              width: dynamicSize(0.35),
                              decoration: BoxDecoration(
                                color: AllColor.greyButton,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Continue',
                                    style: TextStyle(
                                      fontSize: dynamicSize(0.04),
                                      color: AllColor.blue_light,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Icon(Icons.arrow_right_alt,
                                      color: AllColor.blue_light)
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }
}

class ServiceButtonWidget extends StatefulWidget {
  int index;
  Function addCard;
  ServiceButtonWidget({required this.index, required this.addCard, super.key});

  @override
  State<ServiceButtonWidget> createState() => _ServiceButtonWidgetState();
}

class _ServiceButtonWidgetState extends State<ServiceButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: dynamicSize(0.7),
      decoration: const BoxDecoration(
        color: Colors.white,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 20),
                child: CachedNetworkImage(
                  width: 120,
                  height: 110,
                  imageUrl:
                      "${ApiService.MainURL}${DataControllers.to.shortServiceResponse.value.data!.data![widget.index].imagePath /* == null ?   "https://cdn.vectorstock.com/i/1000x1000/21/73/old-people-in-hospital-vector-34042173.webp": DataControllers.to.shortServiceResponse.value.data![index]!.imagePath */}",
                  errorWidget: (context, url, error) => Image.asset(
                    "assets/images/image.png",
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 30),
                      child: Text(
                        DataControllers.to.shortServiceResponse.value.data!
                            .data![widget.index].serviceName!,
                        style: TextStyle(
                            fontSize: dynamicSize(0.05),
                            fontFamily: 'Muli',
                            fontWeight: FontWeight.w700,
                            color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () async {
                  Navigator.pop(context);
                  widget.addCard(widget.index);
                },
                child: Container(
                  height: dynamicSize(0.09),
                  margin: EdgeInsets.only(top: 66),
                  child: Card(
                    color: AllColor.pink_button,
                    margin: EdgeInsets.only(left: 0, right: 0),
                    semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          topLeft: Radius.circular(15)),
                    ),
                    elevation: 6,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 2.0,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            (DataControllers.to.shortServiceResponse.value.data!
                                        .data![widget.index].addedInMyCart ==
                                    null)
                                ? Icons.add
                                : Icons.done,
                            color: Colors.white,
                          ),
                          Text(
                            (DataControllers.to.shortServiceResponse.value.data!
                                        .data![widget.index].addedInMyCart ==
                                    null)
                                ? "Order Now "
                                : " added ",
                            style: TextStyle(
                                fontFamily: 'Muli',
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          )
                        ],
                      ),
                    ),

                    /*CachedNetworkImage(
                            fit: BoxFit.fill,
                            width: 120,
                            imageUrl:
                            "https://takecare.ltd/${DataControllers.to.shortServiceResponse.value.data!.data![index].imagePath */ /* == null ?   "https://cdn.vectorstock.com/i/1000x1000/21/73/old-people-in-hospital-vector-34042173.webp": DataControllers.to.shortServiceResponse.value.data![index]!.imagePath */ /*}",
                            progressIndicatorBuilder:
                            (context, url, downloadProgress) =>
                            CircularProgressIndicator(),
                            errorWidget: (context, url, error) => Image.asset(
                          "assets/images/image.png",
                            ),
                          ),*/
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 15),
            child: SingleChildScrollView(
              child: Text(
                DataControllers.to.shortServiceResponse.value.data!
                    .data![widget.index].description!,
                style: TextStyle(
                    fontFamily: 'Muli',
                    fontWeight: FontWeight.w600,
                    fontSize: dynamicSize(0.04),
                    color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
