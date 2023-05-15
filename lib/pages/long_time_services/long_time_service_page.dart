// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:intl/intl.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:takecare_user/api_service/ApiService.dart';
import 'package:takecare_user/controllers/DataContollers.dart';
import 'package:takecare_user/controllers/language_controller.dart';
import 'package:takecare_user/model/AllServiceResponse.dart';
import 'package:takecare_user/model/CategoriesResponse.dart';
import 'package:takecare_user/model/LovedOnesResponse.dart';
import 'package:takecare_user/pages/On%20Demand/map_page.dart';
import 'package:takecare_user/pages/On%20Demand/order_information_page.dart';
import 'package:takecare_user/pages/home_page.dart';
import 'package:takecare_user/pages/long_time_services/map_picker_page.dart';
import 'package:takecare_user/pages/long_time_services/order_confirm_page.dart';
import 'package:takecare_user/pages/long_time_services/service_request_form_page.dart';
import 'package:takecare_user/pages/loved_form_page.dart';
import 'package:takecare_user/pages/loved_ones_page.dart';
import 'package:takecare_user/public_variables/all_colors.dart';
import 'package:takecare_user/public_variables/notifications.dart';
import 'package:takecare_user/public_variables/size_config.dart';
import 'package:takecare_user/public_variables/variables.dart';
import 'package:takecare_user/ui/common.dart';

class LongTimeServicesPage extends StatefulWidget {
  final String selectedType;
  const LongTimeServicesPage({Key? key, required this.selectedType})
      : super(key: key);

  @override
  _LongTimeServicesPageState createState() => _LongTimeServicesPageState();
}

bool addedservice = false;
bool showBottom = false;
bool addedlist = false;
bool selectMyself = true;
late List<bool> _isChecked;
bool searchValue = false;
List<String> result = [];
List<AllServiceData> searchData = [];
bool scheduleSelected = false;

class _LongTimeServicesPageState extends State<LongTimeServicesPage> {
  Icon cusIcon = Icon(Icons.search, color: Colors.black);
  Widget cusSearchbar = GetBuilder<LanguageController>(
    builder: (language) {
      return Text(
        language.longTimeService.string,
        style: TextStyle(color: Colors.black, fontSize: dynamicSize(0.04)),
      );
    },
  );
  int selectedColor = 0;
  List<AllServiceData> _searchResult = [];
  TextEditingController searchController = TextEditingController();
  List<CategoriesData> dataResponse = [];
  bool focus = false;

  @override
  void initState() {
    log(widget.selectedType.toString());
    super.initState();
    setState(() {
      _isChecked = List<bool>.filled(
          DataControllers.to.getLongCategoriesResponse.value.data!.length,
          false);
    });
    showBottom = false;
    result = [];
    result.add(widget.selectedType);
    getAddCardData();
    try {
      _filterValue();
    } catch (e) {}

    if (widget.selectedType.isEmpty) {
      setState(() {
        searchValue = false;
      });
    } else {
      setState(() {
        result.add(widget.selectedType);
        _filterValue();
      });
      for (int i = 0;
          i < DataControllers.to.getLongCategoriesResponse.value.data!.length;
          i++) {
        if (DataControllers
                .to.getLongCategoriesResponse.value.data![i].categoryName ==
            widget.selectedType) {
          setState(() {
            _isChecked[i] = true;
          });
        }
      }
    }
  }

  void _filterValue() {
    searchData = [];
    searchValue = false;

    result.forEach((element) {
      DataControllers.to.longServiceResponse.value.data!.data!.forEach((value) {
        value.serviceCats!.forEach((categories) {
          bool _search = false;
          if (element == categories.serviceCategory!.categoryName) {
            searchData.forEach((searchingValue) {
              if (categories.serviceCategory!.categoryName == searchingValue) {
                _search = true;
              }
            });

            if (!_search) {
              searchData.add(value);
              searchValue = true;
            }
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

    DataControllers.to.longServiceResponse.value.data!.data!
        .forEach((userDetail) {
      if (userDetail.serviceName!.toLowerCase().contains(text.toLowerCase())) {
        _searchResult.add(userDetail);
        //print(userDetail.serviceName!);
        // print(userDetail.added_in_my_service!);
      }
    });

    setState(() {});
  }

  void showButtonDialog(BuildContext context, AllServiceData service) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return GetBuilder<LanguageController>(builder: (lang) {
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
                  Container(
                    height: dynamicSize(0.7),
                    decoration: const BoxDecoration(
                      color: AllColor.white,
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
                              padding:
                                  const EdgeInsets.only(left: 10.0, top: 20),
                              child: CachedNetworkImage(
                                width: 120,
                                height: 110,
                                imageUrl:
                                    "${ApiService.MainURL}${service.imagePath /* == null ?   "https://cdn.vectorstock.com/i/1000x1000/21/73/old-people-in-hospital-vector-34042173.webp": DataControllers.to.shortServiceResponse.value.data![index]!.imagePath */}",
                                errorWidget: (context, url, error) =>
                                    Image.asset(
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
                                    padding: const EdgeInsets.only(
                                        left: 8.0, top: 30),
                                    child: Text(
                                      service.serviceName!,
                                      style: TextStyle(
                                          fontSize: dynamicSize(0.05),
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                Navigator.pop(context);
                                addCard(service);
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
                                          (service.addedInMyCart == null)
                                              ? Icons.add
                                              : Icons.done,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          (service.addedInMyCart == null)
                                              ? lang.orderNow.string
                                              : lang.added.string,
                                          style: const TextStyle(
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
                              service.description!,
                              style: TextStyle(
                                  fontSize: dynamicSize(0.04),
                                  color: Colors.grey),
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
        });
  }

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
                    children: new List.generate(
                      DataControllers
                          .to.getAddCardLongServiceResponse.value.data!.length,
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
                              Card(
                                margin: EdgeInsets.only(
                                    left: 0, top: 10, bottom: 10),
                                semanticContainer: true,
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                shape: RoundedRectangleBorder(
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
                                      "${ApiService.MainURL}${DataControllers.to.getAddCardLongServiceResponse.value.data![index].service!.imagePath /* == null ?   "https://cdn.vectorstock.com/i/1000x1000/21/73/old-people-in-hospital-vector-34042173.webp": DataControllers.to.shortServiceResponse.value.data![index]!.imagePath */}",
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
                                        "${DataControllers.to.getAddCardLongServiceResponse.value.data![index].service!.serviceName == null ? "Service Name" : DataControllers.to.getAddCardLongServiceResponse.value.data![index].service!.serviceName}",
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
    dataResponse = [];
    result = [];
    // DataControllers.to.getCategoriesResponse.value.data!.forEach((element) => _setData(element)).toList();
    DataControllers.to.getLongCategoriesResponse.value.data!.forEach((element) {
      if (element.serviceType == "long") {
        dataResponse.add(element);
      }
    });

    // dataResponse.add( DataControllers.to.getCategoriesResponse.value.data!.map((e) => e.serviceType == "short").toList());

    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return StatefulBuilder(builder: (context, setSt) {
            return GetBuilder<LanguageController>(builder: (lang) {
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
                            lang.selcat.string,
                            style: TextStyle(
                                fontSize: dynamicSize(0.07),
                                fontWeight: FontWeight.bold),
                          ),
                          InkWell(
                              onTap: () {
                                setSt(() {
                                  _isChecked = List<bool>.filled(
                                      DataControllers
                                          .to
                                          .getLongCategoriesResponse
                                          .value
                                          .data!
                                          .length,
                                      false);
                                });
                                setState(() {
                                  searchData = [];
                                  result = [];
                                  _searchResult = [];
                                  searchValue = false;
                                });
                                //Navigator.pop(context);
                              },
                              child: _isChecked.contains(true)
                                  ? Text("Deselect All",
                                      style: TextStyle(
                                          fontSize: dynamicSize(0.05),
                                          color: Colors.purple))
                                  : Container()),
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
                                        value: _isChecked[index],
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
                                          setSt(() {
                                            _isChecked[index] = val;
                                          });
                                          setState(() {});
                                        },
                                      )),
                            ),
                          ),
                        ),
                      ),
                      _isChecked.contains(true)
                          ? Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: dynamicSize(0.08)),
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
                                      child: Text(lang.showList.string,
                                          style: TextStyle(
                                              fontSize: dynamicSize(0.045))),
                                    )
                                  ],
                                ),
                              ))
                          : Container(),
                    ],
                  ),
                ),
              );
            });
          });
        });
  }

  void getAddCardData() async {
    await DataControllers.to.getCard('long');
    //await DataControllers.to.getAllLongService("long");

    if (DataControllers.to.getAddCardLongServiceResponse.value.success!) {
      setState(() {
        //DataControllers.to.longServiceResponse;
        DataControllers.to.getAddCardLongServiceResponse;
        _filterValue();
        showBottom = true;
        addedlist = true;
      });
    } else {
      setState(() {
        showBottom = false;
        addedlist = false;
      });
    }
  }

  void deleteAddCardData(int index) async {
    await DataControllers.to.deleteCard(
        DataControllers.to.userLoginResponse.value.data!.user!.id.toString(),
        DataControllers.to.getAddCardLongServiceResponse.value.data![index].id
            .toString());
    showToast(DataControllers.to.addCardResponse.value.message!);

    if (DataControllers.to.addCardResponse.value.success!) {
      getAddCardData();
    }
  }

  void addCard(AllServiceData addedService) async {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);

    await DataControllers.to.addCard(
      context,
      addedService.id.toString(),
      formattedDate,
      addedService.serviceCategoryId.toString(),
      DataControllers.to.userLoginResponse.value.data!.user!.id.toString(),
    );

    if (DataControllers.to.addCardResponse.value.success!) {
      Common.storeSharedPreferences.setString("service", "long");
      getAddCardData();
    } else {
      showToast(
          DataControllers.to.addCardResponse.value.message!, AllColor.blue);
    }
  }

  void serviceReceiverSheet(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return StatefulBuilder(
            builder: (context, setState) {
              return GetBuilder<LanguageController>(builder: (lang) {
                return Container(
                  decoration: const BoxDecoration(
                    color: AllColor.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(15.0),
                      topLeft: Radius.circular(15.0),
                    ),
                  ),
                  height: dynamicSize(0.9),
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
                      Center(
                        child: Text(
                          lang.bookfor.string,
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
                      Padding(
                        padding:
                            EdgeInsets.only(left: 10, right: 10, top: 15.0),
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
                                                lang.myself.string,
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
                                                lang.srvcforu.string,
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
                                    lang.or.string,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: dynamicSize(0.05),
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
                                                lang.lovedOnes.string,
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
                                                lang.bookedloved.string,
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
                                  log("here");
                                  List<GeocodingResult?> results =
                                      await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CustomMapPicker()));

                                  await DataControllers.to.getProviderList(
                                    "1",
                                    "1",
                                    results.first!.geometry.location.lng
                                        .toString(),
                                    results.first!.geometry.location.lat
                                        .toString(),
                                  );

                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (cp) => OrderConfirmPage(
                                  //         result: results.first,
                                  //         orderType: "Long Term",
                                  //   ),
                                  // );

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (cp) => OrderConfirmPage(
                                                result: results.first!,
                                                orderType: "Long Term",
                                              )));
                                } else {
                                  LovedOnesResponse lovedOnes =
                                      await ApiService.getFavAddress();
                                  if (!lovedOnes.success!) {
                                    Navigator.of(context)
                                        .pushReplacement(MaterialPageRoute(
                                            builder: (_) => LovedFormPage(
                                                  activity: Variables
                                                      .orderInformationActivity,
                                                )));
                                  } else {
                                    log("not empty");
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (_) => LovedOnesPage(
                                            activity: "LongTermSchedule"),
                                      ),
                                    );
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
                                      lang.continueString.string,
                                      style: TextStyle(
                                        fontSize: dynamicSize(0.04),
                                        color: AllColor.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Icon(Icons.arrow_right_alt,
                                        color: AllColor.white)
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
              });
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LanguageController>(builder: (lc) {
      return Scaffold(
        bottomNavigationBar: showBottom
            ? BlurryContainer(
                blur: 30,
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
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8.0, top: 5),
                                  child: Text(
                                    lc.longTimeService.string,
                                    style: TextStyle(
                                        fontSize: dynamicSize(0.035),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              addedlist
                                  ? Container(
                                      alignment: Alignment.centerLeft,
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
                                                    .getAddCardLongServiceResponse
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
                                                " " + lc.serviceAdded.string,
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
                                      alignment: Alignment.centerLeft,
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
                            serviceReceiverSheet(context);
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
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    lc.continueString.string,
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
                              color: Colors.black, fontSize: dynamicSize(0.04)),
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
                      LanguageController.lc.longTimeServiceSetup.value,
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
            preferredSize: Size(25, 35),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
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
                              padding: const EdgeInsets.only(
                                  left: 8.0, right: 4, top: 4, bottom: 4),
                              child: Icon(Icons.filter_alt_outlined,
                                  color: (selectedColor == 1)
                                      ? Colors.white
                                      : Colors.black),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 4.0, right: 4, top: 4, bottom: 4),
                              child: Text(
                                lc.categories.string,
                                style: TextStyle(
                                    color: (selectedColor == 1)
                                        ? Colors.white
                                        : Colors.black),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 4.0, right: 8, top: 4, bottom: 4),
                              child: Icon(Icons.arrow_drop_down,
                                  color: (selectedColor == 1)
                                      ? Colors.white
                                      : Colors.black),
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
                        /*     Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>  MapePage()),
                        );*/
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
                              child: Text(lc.pop.string),
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
                        /*     Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>FeedBackPage()),
                        );*/
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
                              child: Text(lc.takenbefore.string),
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
        body: _searchResult.length != 0 || searchController.text.isNotEmpty
            ? ListView(
                padding: const EdgeInsets.all(8),
                children: List.generate(
                  _searchResult.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Stack(
                      children: [
                        Container(
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
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                      "assets/images/image.png",
                                    ),
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
                                          top: 8.0, left: 10),
                                      child: Text(
                                        "${_searchResult[index].serviceName /*! == null  ? "Guest" : DataControllers.to.shortServiceResponse.value.data![index]!.serviceName*/}",
                                        style: TextStyle(
                                            fontSize: dynamicSize(0.04),
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(
                                      height: dynamicSize(0.07),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        showButtonDialog(
                                            context, _searchResult[index]);
                                      },
                                      child: Text(
                                        lc.details.string,
                                        style: TextStyle(
                                            fontSize: dynamicSize(0.035),
                                            color: Colors.purple),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 25.0,
                          right: 0.0,
                          child: InkWell(
                              onTap: () {
                                addCard(_searchResult[index]);
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
                                    (searchData[index].addedInMyCart == null)
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
              )
            : ListView(
                padding: const EdgeInsets.all(8),
                children: List.generate(
                  searchValue
                      ? searchData.length
                      : DataControllers
                          .to.longServiceResponse.value.data!.data!.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Stack(
                      children: [
                        Container(
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
                                        "${ApiService.MainURL}${(searchValue != true) ? DataControllers.to.longServiceResponse.value.data!.data![index].imagePath : searchData[index].imagePath}",
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                      "assets/images/image.png",
                                    ),
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
                                          top: 8.0, left: 10),
                                      child: Text(
                                        "${(searchValue != true) ? DataControllers.to.longServiceResponse.value.data!.data![index].serviceName : searchData[index].serviceName /*! == null  ? "Guest" : DataControllers.to.shortServiceResponse.value.data![index]!.serviceName*/}",
                                        style: TextStyle(
                                            fontSize: dynamicSize(0.04),
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(
                                      height: dynamicSize(0.07),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        showButtonDialog(
                                            context,
                                            (searchValue != true)
                                                ? DataControllers
                                                    .to
                                                    .longServiceResponse
                                                    .value
                                                    .data!
                                                    .data![index]
                                                : searchData[index]);
                                      },
                                      child: Text(
                                        lc.details.string,
                                        style: TextStyle(
                                            fontSize: dynamicSize(0.035),
                                            color: Colors.purple),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 25.0,
                          right: 0.0,
                          child: InkWell(
                              onTap: () {
                                addCard((searchValue != true)
                                    ? DataControllers.to.longServiceResponse
                                        .value.data!.data![index]
                                    : searchData[index]);
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
                                    (searchValue
                                            ? (searchData[index]
                                                    .addedInMyCart ==
                                                null)
                                            : (DataControllers
                                                    .to
                                                    .longServiceResponse
                                                    .value
                                                    .data!
                                                    .data![index]
                                                    .addedInMyCart ==
                                                null))
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
              ),
      );
    });
  }
}
