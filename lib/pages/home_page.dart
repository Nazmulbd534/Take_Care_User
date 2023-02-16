import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:takecare_user/api_service/ApiService.dart';
import 'package:takecare_user/controllers/DataContollers.dart';
import 'package:takecare_user/controllers/language_controller.dart';
import 'package:takecare_user/model/provider/provider_data.dart';
import 'package:takecare_user/pages/On%20Demand/on_demand_page.dart';
import 'package:takecare_user/pages/long_time_services/long_time_service_page.dart';
import 'package:takecare_user/pages/menu/help.dart';
import 'package:takecare_user/pages/menu/setting/setting.dart';
import 'package:takecare_user/pages/profile.dart';
import 'package:takecare_user/pages/sign_in_page.dart';
import 'package:takecare_user/public_variables/all_colors.dart';
import 'package:takecare_user/public_variables/notifications.dart';
import 'package:takecare_user/public_variables/size_config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:takecare_user/public_variables/variables.dart';
import 'package:takecare_user/ui/common.dart';
import 'package:takecare_user/widgets/loading_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/CategoriesResponse.dart';
import 'On Demand/accepted_page.dart';
import 'loved_ones_page.dart';
import 'order_history/order_history_page.dart';
import 'package:package_info_plus/package_info_plus.dart' show PackageInfo;
import 'package:firebase_remote_config/firebase_remote_config.dart'
    show FirebaseRemoteConfig, RemoteConfigSettings;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

var isLoading = false;

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  String currentVersion = '';
  String enforcedVersion = '';
  String storeVersion = '';
  @override
  void initState() {
    super.initState();
    getAllService();
  }

  static Future<String> get _enforcedVersion async {
    final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
    remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ),
    );
    await remoteConfig.fetch();
    await remoteConfig.activate();
    return remoteConfig.getString("enforced_version"); // 'enforced_version'
  }

  static Future<String> get _storeVersion async {
    final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
    remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ),
    );
    await remoteConfig.fetch();
    await remoteConfig.activate();
    return remoteConfig.getString("store_version"); // 'enforced_version'
  }

  onProgressBar(bool progress) {
    setState(() => isLoading = progress);
  }

  void getAllService() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      currentVersion = packageInfo.version;
    });

    String enforced = await _enforcedVersion;
    String store = await _storeVersion;
    setState(() {
      enforcedVersion = enforced;
      storeVersion = store;
    });

    if (int.parse(enforcedVersion.numericOnly()) >
        int.parse(currentVersion.numericOnly())) {
      _showForceUpdateAlert(context);
    } else if (int.parse(currentVersion.numericOnly()) <
        int.parse(storeVersion.numericOnly())) {
      _showUpdateAlert(context);
    }
    log("Current version === $currentVersion \n\n\n store version == $storeVersion\n");
    // double a = double.parse(enforcedVersion);

    // int enforcedInt = int.parse(enforcedVersion.numericOnly());
    // int storeInt = int.parse(storeVersion.numericOnly());

    // log("test = $enforcedInt", name: "RMCONGIF");
    DataControllers.to.getCategoriesResponse.value.data!.forEach((element) {
      if (element.serviceType == "short") {
        dataResponse.add(element);
      }
    });
    onProgressBar(true);
    try {
      await DataControllers.to.getAllCategories();
    } catch (e) {}

    try {
      await DataControllers.to.getProviderList("1", "1", "", "");
    } catch (e) {}
    onProgressBar(false);
    checkEngaged();
    //  await DataControllers.to.postUserServiceResponse(DataControllers.to.userLoginResponse.value.data!.user!.id.toString());
  }

  CarouselController buttonCarouselController = CarouselController();
  int _current = 0;
  List<CategoriesData> dataResponse = [];

  // DataControllers.to.getCategoriesResponse.value.data!.forEach((element) => _setData(element)).toList();

  Future<void> checkEngaged() async {
    await DataControllers.to.getSlider();

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('request')
        .where('sender_id',
            isEqualTo: DataControllers
                .to.userLoginResponse.value.data!.user!.phone
                .toString())
        .where('status', isEqualTo: Variables.orderStatusData[1].statusCode)
        .get();
    final List<QueryDocumentSnapshot> requests = snapshot.docs;

    if (requests.isEmpty) {
    } else {
      if (requests.first.get('engage_end_time') != null &&
          DateTime.fromMillisecondsSinceEpoch(
                      requests.first.get('engage_end_time'))
                  .difference(DateTime.now())
                  .inMinutes >
              2) {
        await FirebaseFirestore.instance
            .collection('request')
            .doc(requests.first.get('id'))
            .update({
          'status': Variables.orderStatusData[2].statusCode,
        });
      } else {
        ProviderData providerData = DataControllers
            .to.getAvailableProviderList.value.data!.provider_data!
            .firstWhere((element) =>
                element.phone == requests.first.get('receiver_id'));
        Get.to(() => AcceptedPage(
              reqDocId: requests.first.get('id'),
              receiverId: requests.first.get('receiver_id'),
              requestList: snapshot.docs.first,
              providerData: providerData,
            ));
      }
    }
  }

  void _showUpdateAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Update Available !",
          style: TextStyle(fontFamily: "Muli"),
        ),
        content: const Text(
            "A new version of TakeCare is available to download. Please download it to get the latest version.",
            style: TextStyle(fontFamily: "Muli")),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Okay"),
          )
        ],
      ),
    );
  }

  void _showForceUpdateAlert(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Urgent Update Available !",
          style: TextStyle(fontFamily: "Muli"),
        ),
        content: const Text(
            "A new version of TakeCare is available to download. This version has breaking changes and it is mandatory to download this version. Please upgrade to keep using TakeCare.",
            style: TextStyle(fontFamily: "Muli")),
        actions: [
          TextButton(
            onPressed: () {
              if (Platform.isAndroid || Platform.isIOS) {
                final appId = Platform.isAndroid
                    ? 'com.spontit.takecareuser'
                    : 'YOUR_IOS_APP_ID';
                final url = Uri.parse(
                  Platform.isAndroid
                      ? "market://details?id=$appId"
                      : "https://apps.apple.com/app/id$appId",
                );
                launchUrl(
                  url,
                  mode: LaunchMode.externalApplication,
                );
              }
            },
            child: const Text("Upgrade"),
          )
        ],
      ),
    );
  }

  bool showServiceCheckBox = false;
  List<String> selectedCategory = [];

  bool _getIsSelected(String categoryName) {
    if (!showServiceCheckBox) return false;
    if (selectedCategory.contains(categoryName)) return true;
    return false;
  }

  void _addOrRemoveSelectedCategory(String categoryName) {
    if (!selectedCategory.contains(categoryName)) {
      selectedCategory.add(categoryName);
    } else {
      selectedCategory.remove(categoryName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: GetBuilder<LanguageController>(builder: (lc) {
        return Stack(
          children: [
            Scaffold(
              key: _scaffoldKey,
              // appBar: AppBar(title: Text('Goog Morning'),),
              bottomNavigationBar: showServiceCheckBox
                  ? Container(
                      height: 70,
                      padding: EdgeInsets.all(10),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AllColor.blue_light,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => OnDemandPage(
                                selectedCategory: selectedCategory,
                              ),
                            ),
                          );
                        },
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: const [
                              Text("Continue"),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(Icons.arrow_forward)
                            ]),
                      ))
                  : null,
              body: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(18.0),
                            bottomRight: Radius.circular(18.0),
                          ),
                          color: AllColor.themeColor,
                        ),
                        height: size.height * 0.22,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Image.asset("assets/images/baby.png"),
                            ClipRRect(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(15),
                              ),
                              child: CachedNetworkImage(
                                height: 55,
                                width: 55,
                                fit: BoxFit.cover,
                                imageUrl:
                                    '${DataControllers.to.userLoginResponse.value.data!.user!.profilePhoto}',
                                errorWidget: (context, url, error) =>
                                    Image.asset('assets/images/baby.png'),
                              ),
                            ),
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      margin: const EdgeInsets.only(
                                          left: 10, top: 25),
                                      child: Text(
                                        messageDisplay(lc),
                                        style: TextStyle(
                                            fontSize: dynamicSize(0.04),
                                            color: Colors.white,
                                            fontFamily: 'Muli'),
                                      )),
                                  Container(
                                    margin: const EdgeInsets.only(
                                        left: 10, bottom: 10, top: 0),
                                    child: Text(
                                      (DataControllers
                                              .to
                                              .userLoginResponse
                                              .value
                                              .data!
                                              .user!
                                              .fullName!
                                              .isEmpty
                                          ? " "
                                          : DataControllers.to.userLoginResponse
                                              .value.data!.user!.fullName
                                              .toString()),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontFamily: "Muli",
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                _scaffoldKey.currentState!.openEndDrawer();
                              },
                              icon: const Icon(
                                Icons.menu,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: size.height * 0.14,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  flex: 4,
                                  child: CarouselSlider.builder(
                                    carouselController:
                                        buttonCarouselController,
                                    itemCount: DataControllers
                                        .to.sliderResponse.value.data!.length,
                                    itemBuilder: (BuildContext context,
                                            int itemIndex, int pageViewIndex) =>
                                        Container(
                                      //color: Colors.pinkAccent,
                                      height: dynamicSize(0.38),
                                      width: dynamicSize(0.96),
                                      // width: MediaQuery.of(context).size.width/2,
                                      decoration: BoxDecoration(
                                        // color: Colors.pinkAccent,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),

                                        image: DecorationImage(
                                          image: NetworkImage(
                                              "${ApiService.MainURL + DataControllers.to.sliderResponse.value.data![itemIndex].sliderImage!}"),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            alignment: Alignment.bottomLeft,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10, bottom: 10),
                                              child: Text(
                                                "${(DataControllers.to.sliderResponse.value.data![itemIndex].sliderTitle == null) ? "" : DataControllers.to.sliderResponse.value.data![itemIndex].sliderTitle}" /*DataControllers.to.getCategoriesResponse.value.data[].*/,
                                                style: TextStyle(
                                                    fontSize:
                                                        dynamicSize(0.075),
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.bottomLeft,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10.0, bottom: 15),
                                              child: Text(
                                                "${(DataControllers.to.sliderResponse.value.data![itemIndex].sliderDescription == null) ? '' : DataControllers.to.sliderResponse.value.data![itemIndex].sliderDescription}",
                                                style: TextStyle(
                                                  fontSize: dynamicSize(0.045),
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    options: CarouselOptions(
                                        autoPlay: true,
                                        enlargeCenterPage: false,
                                        viewportFraction: 1.0,
                                        aspectRatio: 2.8,
                                        initialPage: 0,
                                        onPageChanged: (index, reason) {
                                          setState(() {
                                            _current = index;
                                          });
                                        }),
                                  )),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: DataControllers
                                .to.sliderResponse.value.data!
                                .asMap()
                                .entries
                                .map((entry) {
                              return GestureDetector(
                                onTap: () => buttonCarouselController
                                    .animateToPage(entry.key),
                                child: Container(
                                  width: 10.0,
                                  height: 10.0,
                                  margin: EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 4.0),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: (Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? AllColor.blue_light
                                              : AllColor.blue)
                                          .withOpacity(_current == entry.key
                                              ? 0.9
                                              : 0.4)),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ],
                  ), //appbar design
                  Flexible(
                    child: Column(
                      children: [
                        SizedBox(height: dynamicSize(0)),
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: 15.0, top: 15.0),
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              lc.onDemandService.value,
                              style: TextStyle(
                                  fontSize: dynamicSize(0.056),
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Muli"),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: dynamicSize(0.02),
                        ),
                        // Row(
                        //   children: [
                        //     Expanded(
                        //       child: InkWell(

                        //         child: Stack(
                        //           children: [
                        //             ///Red Back
                        //             Container(
                        //               height: dynamicSize(0.5),
                        //               decoration: const BoxDecoration(
                        //                 color: Colors.pinkAccent,
                        //                 borderRadius: BorderRadius.all(
                        //                     Radius.circular(10)),
                        //               ),
                        //             ),

                        //             ///Top Image
                        //             Positioned(
                        //               right: -size.width * .015,
                        //               top: -size.width * .09,
                        //               child: Image.asset(
                        //                 'assets/images/right_now_top.png',
                        //                 height: size.width * .3,
                        //                 width: size.width * .18,
                        //               ),
                        //             ),
                        //             Positioned(
                        //               left: -size.width * .01,
                        //               top: size.width * .12,
                        //               child: Padding(
                        //                 padding: EdgeInsets.only(
                        //                     left: size.width * .04),
                        //                 child: Text(
                        //                   "Right Now",
                        //                   style: TextStyle(
                        //                       fontSize: size.width * .05,
                        //                       color: Colors.white,
                        //                       fontWeight: FontWeight.bold),
                        //                 ),
                        //               ),
                        //             ),

                        //             Positioned(
                        //               bottom: size.width * .04,
                        //               left: size.width * .03,
                        //               right: -5.0,
                        //               child: Text('Book Service for\nRight now',
                        //                   style: TextStyle(
                        //                       color: Colors.white,
                        //                       fontSize: size.width * .038,
                        //                       fontWeight: FontWeight.bold)),
                        //             ),
                        //             /*   Positioned(
                        //                 bottom: size.width * .008,
                        //                 right: -size.width * .02,
                        //                 child: ElevatedButton(
                        //                   onPressed: () {

                        //                       Navigator.of(context)
                        //                           .push(
                        //                               MaterialPageRoute(
                        //                                   builder: (_) =>
                        //                                       OnDemandPage()));
                        //                   },
                        //                   child: Icon(Icons.chevron_right,
                        //                       size: size.width * .06,
                        //                       color: Colors.white),
                        //                   style: ElevatedButton.styleFrom(
                        //                     shape: const CircleBorder(),
                        //                     padding:
                        //                         EdgeInsets.all(size.width * .005),
                        //                     primary: AllColor.colorArrow,
                        //                     onPrimary: Colors.black,
                        //                   ),
                        //                 ),
                        //               ),*/
                        //           ],
                        //         ),
                        //       ),
                        //     ),
                        //     SizedBox(width: dynamicSize(0.02)),
                        //     Expanded(
                        //       child: InkWell(

                        //         child: Stack(
                        //           children: [
                        //             ///Red Back
                        //             Container(
                        //               height: dynamicSize(0.5),
                        //               decoration: const BoxDecoration(
                        //                 color: AllColor
                        //                     .colorDashboardOnDemand_blue,
                        //                 borderRadius: BorderRadius.all(
                        //                     Radius.circular(10)),
                        //               ),
                        //             ),

                        //             ///Top Image
                        //             Positioned(
                        //               right: -size.width * .015,
                        //               top: -size.width * .09,
                        //               child: Image.asset(
                        //                 'assets/images/schedule_top.png',
                        //                 height: size.width * .3,
                        //                 width: size.width * .18,
                        //               ),
                        //             ),
                        //             Positioned(
                        //               left: -size.width * .01,
                        //               top: size.width * .12,
                        //               child: Padding(
                        //                 padding: EdgeInsets.only(
                        //                     left: size.width * .04),
                        //                 child: Text(
                        //                   "Schedule",
                        //                   style: TextStyle(
                        //                       fontSize: size.width * .05,
                        //                       color: Colors.white,
                        //                       fontWeight: FontWeight.bold),
                        //                 ),
                        //               ),
                        //             ),
                        //             Positioned(
                        //               bottom: size.width * .04,
                        //               left: size.width * .03,
                        //               right: -5.0,
                        //               child: Text('Book Service for\nLater',
                        //                   style: TextStyle(
                        //                       color: Colors.white,
                        //                       fontSize: size.width * .038,
                        //                       fontWeight: FontWeight.bold)),
                        //             ),
                        //             /* Positioned(
                        //                 bottom: size.width * .008,
                        //                 right: -size.width * .02,
                        //                 child: ElevatedButton(
                        //                   onPressed: () {},
                        //                   child: Icon(Icons.chevron_right,
                        //                       size: size.width * .06,
                        //                       color: Colors.white),
                        //                   style: ElevatedButton.styleFrom(
                        //                     shape: const CircleBorder(),
                        //                     padding:
                        //                         EdgeInsets.all(size.width * .005),
                        //                     primary: AllColor.colorArrow,
                        //                     onPrimary: Colors.black,
                        //                   ),
                        //                 ),
                        //               ),*/
                        //           ],
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),

                        // cut here
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 0.0,
                            left: 12.0,
                          ),
                          child: Container(
                            color: Colors.white,
                            height: size.height * 0.22,
                            child: ListView.builder(
                              itemCount: dataResponse.length + 1,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: ((context, index) {
                                if (index == 0) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    child: Column(
                                      children: [
                                        InkWell(
                                          onTap: () async {
                                            onProgressBar(true);
                                            await DataControllers.to
                                                .getAllShortService("short");
                                            onProgressBar(false);
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const OnDemandPage(
                                                  selectedCategory: [''],
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            height: size.height * 0.11,
                                            width: dynamicSize(0.27),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: Colors.white,
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Color.fromRGBO(
                                                      0, 173, 229, 0.20),
                                                  blurRadius: 2,
                                                  offset: Offset(
                                                      0, 3), // Shadow position
                                                ),
                                              ],
                                            ),
                                            child: SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: Image.asset(
                                                'assets/images/all_service_icon.png',
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: dynamicSize(0.02),
                                        ),
                                        const Text(
                                          "All Services",
                                          style: TextStyle(
                                            fontFamily: "Muli",
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 2,
                                        )
                                      ],
                                    ),
                                  );
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(right: 10.0),
                                  child: Column(
                                    children: [
                                      InkWell(
                                        onLongPress: () {
                                          setState(() {
                                            // if (!showServiceCheckBox) {
                                            //   _addOrRemoveSelectedCategory(
                                            //       dataResponse[index - 1]
                                            //           .categoryName!);
                                            // }
                                            _addOrRemoveSelectedCategory(
                                                dataResponse[index - 1]
                                                    .categoryName!);
                                            showServiceCheckBox =
                                                !showServiceCheckBox;
                                            if (!showServiceCheckBox) {
                                              selectedCategory.clear();
                                            }
                                          });
                                        },
                                        onTap: () async {
                                          if (showServiceCheckBox) {
                                            _addOrRemoveSelectedCategory(
                                                dataResponse[index - 1]
                                                    .categoryName!);
                                            if (selectedCategory.isEmpty) {
                                              setState(() {
                                                showServiceCheckBox = false;
                                              });
                                            }
                                          } else {
                                            if (selectedCategory.isEmpty) {
                                              setState(() {
                                                showServiceCheckBox = false;
                                              });
                                            }
                                            onProgressBar(true);
                                            await DataControllers.to
                                                .getAllShortService("short");
                                            onProgressBar(false);
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => OnDemandPage(
                                                  selectedCategory: [
                                                    dataResponse[index - 1]
                                                        .categoryName!
                                                  ],
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: _getIsSelected(
                                                    dataResponse[index - 1]
                                                        .categoryName!) ==
                                                true
                                            ? Stack(
                                                children: [
                                                  Container(
                                                    height: size.height * 0.11,
                                                    width: dynamicSize(0.27),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color: _getIsSelected(
                                                              dataResponse[
                                                                      index - 1]
                                                                  .categoryName!)
                                                          ? AllColor.pinkShadow
                                                          : Colors.white,
                                                      boxShadow: const [
                                                        BoxShadow(
                                                          color: Color.fromRGBO(
                                                              0,
                                                              173,
                                                              229,
                                                              0.16),
                                                          blurRadius: 2,
                                                          offset: Offset(0,
                                                              3), // Shadow position
                                                        ),
                                                      ],
                                                    ),
                                                    child: SizedBox(
                                                      height: 20,
                                                      width: 20,
                                                      child: Image.network(
                                                        ApiService.MainURL +
                                                            dataResponse[
                                                                    index - 1]
                                                                .serviceImage!,
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: size.height * 0.02,
                                                    right: size.width * 0.06,
                                                    child: const ClipOval(
                                                      child: Material(
                                                        color: Colors
                                                            .white, // Button color
                                                        child: InkWell(
                                                          // Splash color

                                                          child: SizedBox(
                                                            width: 56,
                                                            height: 56,
                                                            child: Icon(
                                                              Icons.check,
                                                              color:
                                                                  AllColor.blue,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              )
                                            : Container(
                                                height: size.height * 0.11,
                                                width: dynamicSize(0.27),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: _getIsSelected(
                                                          dataResponse[
                                                                  index - 1]
                                                              .categoryName!)
                                                      ? AllColor.pinkShadow
                                                      : Colors.white,
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Color.fromRGBO(
                                                          0, 173, 229, 0.16),
                                                      blurRadius: 2,
                                                      offset: Offset(0,
                                                          3), // Shadow position
                                                    ),
                                                  ],
                                                ),
                                                child: SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child: Image.network(
                                                    ApiService.MainURL +
                                                        dataResponse[index - 1]
                                                            .serviceImage!,
                                                  ),
                                                ),
                                              ),
                                      ),
                                      SizedBox(
                                        height: dynamicSize(0.02),
                                      ),
                                      Text(
                                        dataResponse[index - 1].categoryName!,
                                        style: const TextStyle(
                                          fontFamily: "Muli",
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 2,
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(5),
                                topRight: Radius.circular(5)),
                            color: Colors.white,
                          ),
                          height: size.height * 0.27,
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 2, bottom: 2),
                                child: Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      lc.longTimeService.value,
                                      style: TextStyle(
                                          fontSize: dynamicSize(0.059),
                                          fontWeight: FontWeight.w600,
                                          fontFamily: "Muli"),
                                    )),
                              ),
                              Container(
                                height: size.height * 0.22,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  // padding: EdgeInsets.zero,
                                  itemCount: DataControllers
                                          .to
                                          .getLongCategoriesResponse
                                          .value
                                          .data!
                                          .length +
                                      1,
                                  itemBuilder: (context, index) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6.0, vertical: 8.0),
                                    child: InkWell(
                                      onTap: () async {
                                        onProgressBar(true);
                                        await DataControllers.to
                                            .getAllLongService("long");
                                        onProgressBar(false);
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => LongTimeServicesPage(
                                                selectedType: (DataControllers
                                                            .to
                                                            .getLongCategoriesResponse
                                                            .value
                                                            .data!
                                                            .length >
                                                        index)
                                                    ? DataControllers
                                                        .to
                                                        .getLongCategoriesResponse
                                                        .value
                                                        .data![index]
                                                        .categoryName!
                                                        .toString()
                                                    : ""),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: size.width / 2.42,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Colors.white,
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 4,
                                              offset: Offset(
                                                  4, 4), // Shadow position
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: Colors.white,
                                              ),
                                              height: dynamicSize(0.27),
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: (DataControllers
                                                          .to
                                                          .getLongCategoriesResponse
                                                          .value
                                                          .data!
                                                          .length >
                                                      index)
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      child: CachedNetworkImage(
                                                        fit: BoxFit.fill,
                                                        imageUrl:
                                                            "${ApiService.MainURL + DataControllers.to.getLongCategoriesResponse.value.data![index].serviceImage! /* == null ?   "https://cdn.vectorstock.com/i/1000x1000/21/73/old-people-in-hospital-vector-34042173.webp": DataControllers.to.shortServiceResponse.value.data![index]!.imagePath */}",
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Image.asset(
                                                          "assets/images/pet.png",
                                                        ),
                                                      ),
                                                    )
                                                  : Container(
                                                      height: size.height * 0.1,
                                                      width: dynamicSize(0.12),
                                                      child: Card(
                                                        color: AllColor
                                                            .colorDashboardOnDemand_blue,
                                                        margin: const EdgeInsets
                                                                .only(
                                                            left: 0, right: 0),
                                                        semanticContainer: true,
                                                        clipBehavior: Clip
                                                            .antiAliasWithSaveLayer,
                                                        shape:
                                                            const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .only(),
                                                        ),
                                                        elevation: 6,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(15),
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pushReplacement(
                                                                MaterialPageRoute(
                                                                  builder: (_) =>
                                                                      const LongTimeServicesPage(
                                                                          selectedType:
                                                                              ""),
                                                                ),
                                                              );
                                                            },
                                                            child: const Icon(
                                                              Icons
                                                                  .arrow_forward,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              shape:
                                                                  const CircleBorder(),
                                                              padding:
                                                                  EdgeInsets.all(
                                                                      size.width *
                                                                          .002),
                                                              primary: Colors
                                                                  .pinkAccent,
                                                              onPrimary:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                            ),
                                            Container(
                                                alignment: (DataControllers
                                                            .to
                                                            .getLongCategoriesResponse
                                                            .value
                                                            .data!
                                                            .length >
                                                        index)
                                                    ? Alignment.topLeft
                                                    : Alignment.center,
                                                margin: const EdgeInsets.only(
                                                    left: 4, top: 8),
                                                child: (DataControllers
                                                            .to
                                                            .getLongCategoriesResponse
                                                            .value
                                                            .data!
                                                            .length >
                                                        index)
                                                    ? Text(
                                                        DataControllers
                                                                .to
                                                                .getLongCategoriesResponse
                                                                .value
                                                                .data![index]
                                                                .categoryName!
                                                                .isNotEmpty
                                                            ? DataControllers
                                                                .to
                                                                .getLongCategoriesResponse
                                                                .value
                                                                .data![index]
                                                                .categoryName!
                                                            : "",
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                            fontSize:
                                                                dynamicSize(
                                                                    0.045),
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )
                                                    : Text(
                                                        lc.seeAll.value,
                                                        style: TextStyle(
                                                            fontSize:
                                                                dynamicSize(
                                                                    0.045),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: AllColor
                                                                .pink_button),
                                                      )),
                                            Expanded(
                                              child: Container(
                                                alignment: Alignment.topLeft,
                                                margin: const EdgeInsets.only(
                                                    left: 4, bottom: 5, top: 2),
                                                child: (DataControllers
                                                            .to
                                                            .getLongCategoriesResponse
                                                            .value
                                                            .data!
                                                            .length >
                                                        index)
                                                    ? Text(
                                                        "Starts from ${DataControllers.to.getLongCategoriesResponse.value.data![index].startPrice!.isNaN ? "0.00" : DataControllers.to.getLongCategoriesResponse.value.data![index].startPrice!} Tk",
                                                        style: TextStyle(
                                                            fontSize:
                                                                dynamicSize(
                                                                    0.035)),
                                                      )
                                                    : Text(''),
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
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              endDrawer: _drawer(),
            ),
            isLoading ? const LoadingWidget() : Container()
          ],
        );
      }),
    );
  }

  Widget _drawer() => Drawer(
        child: SafeArea(
          child: GetBuilder<LanguageController>(builder: (lc) {
            return Scaffold(
              backgroundColor: AllColor.themeColor,
              appBar: AppBar(
//leadingWidth: 0,
                  leading: Text(""),
                  backgroundColor: AllColor.themeColor,
                  elevation: 0,
                  bottom: PreferredSize(
                    preferredSize: Size(70, 100),
                    child: Container(
                      // height: dynamicSize(0.5),
                      color: AllColor.themeColor,
                      child: Column(
                        children: [
                          SizedBox(
                            height: dynamicSize(0.02),
                          ),
                          Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30)),
                                    child: CachedNetworkImage(
                                      height: 55,
                                      width: 55,
                                      fit: BoxFit.cover,
                                      imageUrl:
                                          '${DataControllers.to.userLoginResponse.value.data!.user!.profilePhoto}',
                                      /*  placeholder: (context, url) =>
                                            CircularProgressIndicator(),*/
                                      errorWidget: (context, url, error) =>
                                          Image.asset('assets/images/baby.png'),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      '${DataControllers.to.userLoginResponse.value.data!.user!.fullName}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: dynamicSize(0.06),
                                          color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.all(dynamicSize(.04)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                        onTap: () => Navigator.pop(context),
                                        child: Icon(Icons.arrow_forward,
                                            color: Colors.white)),
                                  ],
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: dynamicSize(0.08),
                          ),
                          SizedBox(
                            height: dynamicSize(0.02),
                          ),
                        ],
                      ),
                    ),
                  )),
              bottomNavigationBar: BottomAppBar(
                child: InkWell(
                  onTap: () {
                    logOutMethod(context);
                  },
                  child: Container(
                    color: AllColor.themeColor,
                    height: dynamicSize(0.15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 20.0,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.logout, color: Colors.white),
                              TextButton(
                                onPressed: () {
                                  logOutMethod(context);
                                },
                                child: Text(
                                  lc.logOut.value,
                                  style: TextStyle(
                                      fontSize: dynamicSize(0.04),
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              body: Container(
                color: Colors.white,
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                  child: Column(children: [
                    Wrap(
                      direction: Axis.vertical,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20, top: 30),
                          child: InkWell(
                            onTap: () {
                              goToOtherHistory();
                            },
                            child: Container(
                              width: dynamicSize(1),
                              child: Row(
                                children: [
                                  Image.asset(
                                    "assets/images/service_history.png",
                                    fit: BoxFit.fill,
                                    height: 25,
                                  ),
                                  Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: TextButton(
                                        onPressed: () {
                                          goToOtherHistory();
                                        },
                                        child: Text(
                                          lc.orderHistory.value,
                                          style: TextStyle(
                                              fontSize: dynamicSize(0.035),
                                              color: Colors.black),
                                        ),
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, top: 15),
                          child: InkWell(
                            onTap: () {
                              goToProfile();
                            },
                            child: Container(
                              width: dynamicSize(1),
                              child: Row(
                                children: [
                                  Image.asset(
                                    "assets/images/profile_setup.png",
                                    fit: BoxFit.fill,
                                    height: 20,
                                    color: Colors.black,
                                  ),
                                  Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: TextButton(
                                        onPressed: () {
                                          goToProfile();
                                        },
                                        child: Text(
                                          lc.profile.value,
                                          style: TextStyle(
                                              fontSize: dynamicSize(0.035),
                                              color: Colors.black),
                                        ),
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15, left: 20),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => LovedOnesPage(
                                        activity: Variables.homeActivity,
                                      )));
                            },
                            child: Container(
                              width: dynamicSize(1),
                              child: Row(
                                children: [
                                  Image.asset(
                                    "assets/images/earning.png",
                                    height: 25,
                                    fit: BoxFit.fill,
                                  ),
                                  Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (_) => LovedOnesPage(
                                                      activity: Variables
                                                          .homeActivity)));
                                        },
                                        child: Text(
                                          lc.lovedOnes.value,
                                          style: TextStyle(
                                              fontSize: dynamicSize(0.035),
                                              color: Colors.black),
                                        ),
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                        /* Padding(
                            padding: const EdgeInsets.only(top: 15, left: 20),
                            child: InkWell(
                              onTap: (){
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            AddressesPage()));
                              },
                              child: Container(
                                  width: dynamicSize(1),
                                  child: Row(
                                    children: [
                                      Icon(Icons.location_on),
                                      Padding(
                                          padding: const EdgeInsets.only(left: 10.0),
                                          child: TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pushReplacement(
                                                  MaterialPageRoute(
                                                      builder: (_) =>
                                                          AddressesPage()));
                                            },
                                            child: Text(
                                              "Addresses",
                                              style: TextStyle(
                                                  fontSize: dynamicSize(0.035),
                                                  color: Colors.black),
                                            ),
                                          )),
                                    ],
                                  )),
                            ),
                          ),*/
                        /* Padding(
                            padding: const EdgeInsets.only(top: 15, left: 20),
                            child: InkWell(
                              onTap: (){
                                Navigator.of(context)
                                    .push(
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            CouponsHomePage()));
                              },
                              child: Container(
                                  width: dynamicSize(1),
                                  child: Row(
                                    children: [
                                      Icon(Icons.loyalty),
                                      Padding(
                                          padding: const EdgeInsets.only(left: 10.0),
                                          child: TextButton(
                                            onPressed: () {
                                               Navigator.of(context)
                                              .push(
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      CouponsHomePage()));
                                            },
                                            child: Text(
                                               lc.coupons.value,
                                              style: TextStyle(
                                                  fontSize: dynamicSize(0.035),
                                                  color: Colors.black),
                                            ),
                                          )),
                                    ],
                                  )),
                            ),
                          ),*/
                        Padding(
                          padding: const EdgeInsets.only(top: 15, left: 20),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => HelpPage()));
                            },
                            child: Container(
                                width: dynamicSize(1),
                                child: Row(
                                  children: [
                                    Icon(Icons.help_outline),
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10.0),
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        HelpPage()));
                                          },
                                          child: Text(
                                            lc.helpCenter.value,
                                            style: TextStyle(
                                                fontSize: dynamicSize(0.035),
                                                color: Colors.black),
                                          ),
                                        )),
                                  ],
                                )),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 15, left: 20, bottom: 30),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => SettingsPage()));
                            },
                            child: Container(
                                width: dynamicSize(1),
                                child: Row(
                                  children: [
                                    Icon(Icons.settings),
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10.0),
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        SettingsPage()));
                                          },
                                          child: Text(
                                            lc.setting.value,
                                            style: TextStyle(
                                                fontSize: dynamicSize(0.035),
                                                color: Colors.black),
                                          ),
                                        )),
                                  ],
                                )),
                          ),
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
            );
          }),
        ),
      );

  showAlertForAddCardDeleted(var title, var message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
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
                          title,
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        message,
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Are you want to delete Add Card Value ??",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: dynamicSize(0.08),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                                child: Text(
                              "No",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            )),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              deleteAllCardData();
                            },
                            child: Container(
                                child: Text(
                              "Yes",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            )),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: dynamicSize(0.05),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        });
  }

  void deleteAllCardData() async {
    onProgressBar(true);
    await DataControllers.to.deleteAllCard(
        DataControllers.to.userLoginResponse.value.data!.user!.id.toString());
    onProgressBar(false);
    showToast(DataControllers.to.addCardResponse.value.message!);
    if (DataControllers.to.addCardResponse.value.success!) {
      Common.storeSharedPreferences.setString("service", "");
      getAllService();
    }
  }

  late String message = "";

  String messageDisplay(LanguageController lc) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('kk').format(now);

    int check = int.parse(formattedDate);
    if (check > 4 && check < 12) {
      message = lc.goodMorning.value;
    } else if (check >= 12 && check < 15) {
      message = lc.goodNoon.value;
    } else if (check >= 15 && check <= 17) {
      message = lc.goodAfterNoon.value;
    } else if (check >= 17 && check <= 19) {
      message = lc.goodEv.value;
    } else {
      message = lc.goodNight.value;
    }
    return message;
  }

  void goToProfile() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => Profile()));
  }

  void goToOtherHistory() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => OrderHistoryPage()));
  }
}

void logOutMethod(BuildContext context) {
  Common.storeSharedPreferences.setString("userid", "");
  Common.storeSharedPreferences.setString("pass", "");

  Navigator.of(context)
      .pushReplacement(MaterialPageRoute(builder: (_) => SignInPage()));
}
