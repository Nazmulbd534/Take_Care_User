// ignore_for_file: sort_child_properties_last

import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:takecare_user/api_service/ApiService.dart';
import 'package:takecare_user/controller/data_controller.dart';
import 'package:takecare_user/controllers/DataContollers.dart';
import 'package:takecare_user/model/LovedOnesResponse.dart';
import 'package:takecare_user/model/provider/provider_data.dart';
import 'package:takecare_user/pages/On%20Demand/service_runing_map_page.dart';
import 'package:takecare_user/pages/loved_ones_page.dart';
import 'package:takecare_user/public_variables/all_colors.dart';
import 'package:takecare_user/public_variables/notifications.dart';
import 'package:takecare_user/public_variables/size_config.dart';
import 'package:takecare_user/public_variables/variables.dart';
import '../../public_variables/variables.dart';

class OrderInformationPage extends StatefulWidget {
  String? activity;
  String? serviceTime;
  String? serviceAddress;
  LovedOnes? serviceHolderInfo;
  final Map<String, dynamic>? details;

  OrderInformationPage(
      {Key? key,
      required this.requestNumber,
      required this.providerId,
      required this.details})
      : super(key: key);

  String requestNumber;
  String providerId;
  @override
  _OrderInformationPageState createState() => _OrderInformationPageState();
}

class _OrderInformationPageState extends State<OrderInformationPage> {
  bool orderList = false;
  bool editInformation = false;
  late FocusNode name;
  bool addCoupon = false;
  double discountAmount = 0;
  TextEditingController _couponController = TextEditingController();
  TextEditingController _orderNoteController = TextEditingController();

  @override
  void initState() {
    name = FocusNode();
    super.initState();
    countServices();
    loadData();
  }

  int total = 0;
  int price = 0;
  void countServices() {
    for (int i = 0;
        i <
            widget
                .details!["data"]["service_request"][0]["service_request_items"]
                .length;
        i++) {
      total++;
      price += int.parse(widget.details!["data"]["service_request"][0]
              ["service_request_items"][i]["service_price"]
          .toString());
    }
  }

  @override
  void dispose() {
    super.dispose();
    _couponController.dispose();
    _orderNoteController.dispose();
  }

  void loadData() async {
    Map<String, dynamic> data =
        await ApiService.getRequestItems(widget.requestNumber);
  }

  bool cardVisible = false;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DataController>(builder: (dc) {
      return SafeArea(
        child: Scaffold(
          backgroundColor: AllColor.shado_color,
          appBar: AppBar(
            backgroundColor: AllColor.themeColor,
            title: const Text(
              "Order Information",
              style: TextStyle(
                  fontFamily: 'Muli',
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
            leading: InkWell(
              onTap: () {
                // Navigator.of(context).pushReplacement(
                //   MaterialPageRoute(builder: (_) => CaregiverProfile()));
              },
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: dynamicSize(0.03),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              child: ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(30)),
                                child: CachedNetworkImage(
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                  imageUrl: widget.details!["data"]
                                                  ["service_request"][0]
                                              ["provider"]["profile_photo"] ==
                                          null
                                      ? 'https://thumbs.dreamstime.com/b/man-profile-cartoon-smiling-round-icon-vector-illustration-graphic-design-135443422.jpg'
                                      : widget.details!["data"]
                                              ["service_request"][0]["provider"]
                                              ["profile_photo"]
                                          .toString(),
                                  placeholder: (context, url) =>
                                      Image.asset('assets/images/baby.png'),
                                  errorWidget: (context, url, error) =>
                                      Image.asset('assets/images/baby.png'),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -7.0,
                              child: Container(
                                  alignment: Alignment.center,
                                  height: dynamicSize(.05),
                                  width: dynamicSize(0.13),
                                  //color: Colors.red,
                                  decoration: BoxDecoration(
                                    color: AllColor.white_yeo,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    "${widget.details!["data"]["service_request"][0]["provider"]["latitude"] == null ? (0).toString() : (Geolocator.distanceBetween(double.parse(widget.details!["data"]["service_request"][0]["provider"]["latitude"]), double.parse(widget.details!["data"]["service_request"][0]["provider"]["longitude"]), Variables.currentPostion.latitude, Variables.currentPostion.longitude) / 1000).toStringAsFixed(1)} km",
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.green),
                                  )),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.details!["data"]["service_request"][0]
                                    ["provider"]["full_name"],
                                style: TextStyle(
                                    fontSize: dynamicSize(0.05),
                                    color: AllColor.themeColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Row(
                                  children: [
                                    /*●*/
                                    Text(widget.details!["data"]
                                            ["service_request"][0]["provider"]
                                        ["speciality"]["speciality_name"]),
                                    const Text(" • 9 Patient Served"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Services ($total)",
                              style: TextStyle(
                                  fontFamily: 'Muli',
                                  fontWeight: FontWeight.w600,
                                  fontSize: dynamicSize(0.05)),
                            ),
                            Expanded(
                              child: SizedBox(),
                            ),
                            Text(
                              "Total: $price/-",
                              style: TextStyle(
                                  fontFamily: 'Muli',
                                  fontWeight: FontWeight.w600,
                                  fontSize: dynamicSize(0.05)),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            IconButton(onPressed: (){
                              setState(() {
                                cardVisible = !cardVisible;
                              });
                            }, icon: cardVisible ? const Icon(Icons.arrow_drop_up) : const Icon(Icons.arrow_drop_down)  )
                          ],
                        ),
                        Visibility(
                          visible: cardVisible,
                          child: ListView.builder(
                            itemCount: widget
                                .details!["data"]["service_request"][0]
                                    ["service_request_items"]
                                .length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: const BoxDecoration(
                                  /* borderRadius: BorderRadius.circular(8.0),*/
                                  color: Colors.white,
                                
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
                                        elevation: 0,
                                        child: CachedNetworkImage(
                                          fit: BoxFit.fill,
                                          width: 80,
                                          height: 80,
                                          imageUrl:
                                              "${ApiService.BaseURL}${widget.details!["data"]["service_request"][0]["service_request_items"][index]["image_path"]}",
                                          errorWidget: (context, url, error) =>
                                              Image.asset(
                                            "assets/images/image.png",
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 10,
                                                top: 10,
                                              ),
                                              child: Text(
                                                "${widget.details!["data"]["service_request"][0]["service_request_items"][index]["service"]["service_name"]}",
                                                style: TextStyle(
                                                    fontSize: dynamicSize(0.04),
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            SizedBox(
                                              height: dynamicSize(0.01),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                // showButtonDialog(context, index);
                                              },
                                              child: Text(
                                                "Price - ${widget.details!["data"]["service_request"][0]["service_request_items"][index]["service"]["price"]} /-",
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
                              );
                            },
                          ),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.only(top: 8.0),
                        //   child: Row(
                        //     mainAxisAlignment:
                        //         MainAxisAlignment.spaceBetween,
                        //     children: [
                        //       Text(
                        //         ' Service Duration',
                        //         style: TextStyle(
                        //             fontFamily: 'Muli',
                        //             fontWeight: FontWeight.w600,
                        //             fontSize: dynamicSize(0.05)),
                        //       ),
                        //       Text(
                        //         '${Variables.serviceTime} Hrs',
                        //         style: TextStyle(
                        //             fontFamily: 'Muli',
                        //             fontWeight: FontWeight.w600,
                        //             fontSize: dynamicSize(0.05)),
                        //       ),
                        //     ],
                        //   ),
                        // )
                      ],
                    ),
                  ),
                  color: Colors.white,
                ),
                if (widget.activity == Variables.onDemandServiceActivity)
                  Visibility(
                    visible: orderList,
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 8),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Total Price",
                                  style: TextStyle(
                                      fontFamily: 'Muli',
                                      fontWeight: FontWeight.w600,
                                      fontSize: dynamicSize(0.05)),
                                ),
                                Text(
                                  //'${widget.providerData!.provider_service_total_price.toString()}/-',
                                  "total_price",
                                  style: TextStyle(
                                      fontFamily: 'Muli',
                                      fontWeight: FontWeight.w600,
                                      fontSize: dynamicSize(0.05)),
                                )
                              ],
                            ),
                            SizedBox(
                              height: dynamicSize(0.06),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Promo Applied",
                                  style: TextStyle(
                                      fontFamily: 'Muli',
                                      fontWeight: FontWeight.w600,
                                      fontSize: dynamicSize(0.05)),
                                ),
                                Text(
                                  //"- ${discountAmount != 0 ? widget.providerData!.provider_service_total_price! - discountAmount : 0.0}/-",
                                  "discount",
                                  style: TextStyle(
                                      fontFamily: 'Muli',
                                      fontWeight: FontWeight.w600,
                                      fontSize: dynamicSize(0.05)),
                                )
                              ],
                            ),
                            SizedBox(
                              height: dynamicSize(0.06),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Sub Total",
                                  style: TextStyle(
                                    fontSize: dynamicSize(0.05),
                                    fontFamily: 'Muli',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  //"${(discountAmount == 0 ? widget.providerData!.provider_service_total_price.toString() : discountAmount)}/-",
                                  "discount",
                                  style: TextStyle(
                                    fontSize: dynamicSize(0.05),
                                    fontFamily: 'Muli',
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      color: Colors.white,
                    ),
                  ),
                SizedBox(
                  height: dynamicSize(0.03),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20, top: 15, bottom: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Visiting Address",
                          style: TextStyle(
                              fontFamily: 'Muli',
                              fontWeight: FontWeight.w600,
                              fontSize: dynamicSize(0.05)),
                        ),
                        SizedBox(
                          height: dynamicSize(0.02),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: Colors.green,
                            ),
                            Expanded(
                              child: Text(selectedLoc!.formattedAddress!,
                                  style: TextStyle(
                                    fontSize: dynamicSize(0.05),
                                    fontFamily: 'Muli',
                                    fontWeight: FontWeight.w700,
                                  )),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  color: Colors.white,
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20, top: 15, bottom: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Booking For",
                          style: TextStyle(
                              fontFamily: 'Muli',
                              fontWeight: FontWeight.w600,
                              fontSize: dynamicSize(0.05)),
                        ),
                        SizedBox(
                          height: dynamicSize(0.02),
                        ),
                        Column(
                          children: [
                            Container(
                              height: 30,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 40.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Name",
                                            style: TextStyle(
                                              fontSize: dynamicSize(0.04),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(": ",
                                              style: TextStyle(
                                                  fontSize: dynamicSize(0.05),
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 3.0),
                                        child: Text(
                                        widget.details!["data"]["service_request"][0]["booking_for"] == null ?  '${widget.details!["data"]["service_request"][0]["seeker"]["full_name"]}' : "${widget.details!["data"]["service_request"][0]["loved_one"]["name"]}",
                                          style: TextStyle(
                                              fontSize: dynamicSize(0.04),
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: 30,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 40.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Gender",
                                            style: TextStyle(
                                              fontSize: dynamicSize(0.04),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(": ",
                                              style: TextStyle(
                                                  fontSize: dynamicSize(0.05),
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 3.0),
                                        child: Text(
                                                widget.details!["data"]["service_request"][0]["booking_for"] == null ?  '${widget.details!["data"]["service_request"][0]["seeker"]["gender"]}' : "${widget.details!["data"]["service_request"][0]["loved_one"]["gender"]}",
                                          style: TextStyle(
                                              fontSize: dynamicSize(0.04),
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: 30,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 40.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Mobile",
                                            style: TextStyle(
                                              fontSize: dynamicSize(0.04),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(": ",
                                              style: TextStyle(
                                                  fontSize: dynamicSize(0.05),
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 3.0),
                                        child: Text(
                                                widget.details!["data"]["service_request"][0]["booking_for"] == null ?  '${widget.details!["data"]["service_request"][0]["seeker"]["phone"]}' : "${widget.details!["data"]["service_request"][0]["loved_one"]["contact_no"]}",
                                          style: TextStyle(
                                              fontSize: dynamicSize(0.04),
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  color: Colors.white,
                ),
                if (widget.serviceHolderInfo != null)
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20, top: 15, bottom: 15),
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Service For -",
                          style: TextStyle(
                              fontSize: dynamicSize(0.05),
                              fontFamily: 'Muli',
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                if (widget.serviceHolderInfo != null)
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, right: 20, bottom: 5),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.serviceHolderInfo!.relationship ?? '',
                                style: TextStyle(
                                    fontFamily: 'Muli',
                                    fontWeight: FontWeight.w600,
                                    fontSize: dynamicSize(0.05),
                                    color: AllColor.black),
                              ),
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      Navigator.of(context)
                                          .pushReplacement(MaterialPageRoute(
                                              builder: (_) => LovedOnesPage(
                                                    activity: Variables
                                                        .orderInformationActivity,
                                                    serviceAddress:
                                                        widget.serviceAddress,
                                                    serviceTime:
                                                        Variables.serviceTime,
                                                  )));
                                    });
                                  },
                                  child: Text(
                                    "Change",
                                    style: TextStyle(
                                        fontFamily: 'Muli',
                                        fontWeight: FontWeight.w600,
                                        color: AllColor.themeColor,
                                        fontSize: dynamicSize(0.05)),
                                  ))
                            ],
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 30.0),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Name ",
                                            style: TextStyle(
                                                fontFamily: 'Muli',
                                                fontWeight: FontWeight.w600,
                                                fontSize: dynamicSize(0.05)),
                                          ),
                                          Text(
                                            ": ",
                                            style: TextStyle(
                                              fontSize: dynamicSize(0.05),
                                              fontFamily: 'Muli',
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 3.0),
                                        child: SizedBox(
                                            //height: dynamicSize(0.2),
                                            width: dynamicSize(.5),
                                            child: TextField(
                                              // controller: et_gallery,
                                              enabled: editInformation,
                                              focusNode: name,
                                              cursorHeight: dynamicSize(0.06),
                                              decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: widget
                                                      .serviceHolderInfo!.name,
                                                  hintStyle: TextStyle(
                                                    color: Colors.black,
                                                    fontFamily: 'Muli',
                                                    fontWeight: FontWeight.w700,
                                                  )),
                                            )),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Age ",
                                            style: TextStyle(
                                                fontFamily: 'Muli',
                                                fontWeight: FontWeight.w600,
                                                fontSize: dynamicSize(0.05)),
                                          ),
                                          Text(
                                            ": ",
                                            style: TextStyle(
                                              fontFamily: 'Muli',
                                              fontWeight: FontWeight.w700,
                                              fontSize: dynamicSize(0.05),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        "${widget.serviceHolderInfo!.age!} Year(s)",
                                        style: TextStyle(
                                            fontFamily: 'Muli',
                                            fontWeight: FontWeight.w700,
                                            fontSize: dynamicSize(0.05)),
                                      ),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Gender ",
                                              style: TextStyle(
                                                  fontFamily: 'Muli',
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: dynamicSize(0.05)),
                                            ),
                                            Text(
                                              ": ",
                                              style: TextStyle(
                                                fontSize: dynamicSize(0.05),
                                                fontFamily: 'Muli',
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          "${widget.serviceHolderInfo!.gender!}",
                                          style: TextStyle(
                                              fontFamily: 'Muli',
                                              fontWeight: FontWeight.w700,
                                              fontSize: dynamicSize(0.05)),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Contact Number",
                                              style: TextStyle(
                                                  fontSize: dynamicSize(0.05))),
                                          Text(": ",
                                              style: TextStyle(
                                                  fontSize: dynamicSize(0.05),
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: SizedBox(
                                          //height: dynamicSize(0.2),
                                          width: dynamicSize(.5),
                                          child: TextField(
                                            // controller: et_gallery,
                                            enabled: editInformation,

                                            cursorHeight: dynamicSize(0.06),
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: widget
                                                    .serviceHolderInfo!
                                                    .contactNo!,
                                                hintStyle: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          )),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    color: Colors.white,
                  ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20, top: 15, bottom: 15),
                    child: Column(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Additional Note",
                          style: TextStyle(
                              fontSize: dynamicSize(0.05),
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          height: dynamicSize(0.25),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                width: 1,
                                color: Colors.grey,
                              )),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 8),
                            child: TextField(
                              controller: _orderNoteController,
                              cursorHeight: dynamicSize(0.06),
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText:
                                      '(ex. Bring a syringe of 5ml..……..)',
                                  hintStyle:
                                      TextStyle(fontSize: dynamicSize(0.035))),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: dynamicSize(0.03),
                ),
                // Container(
                //   child: Padding(
                //     padding: const EdgeInsets.symmetric(
                //         horizontal: 20.0, vertical: 8),
                //     child: Column(
                //       children: [
                //         Row(
                //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //           children: [
                //             Text(
                //               "Promo Code",
                //               style: TextStyle(fontSize: dynamicSize(0.05)),
                //             ),
                //             Expanded(
                //               flex: 2,
                //               child: Container(
                //                 height: dynamicSize(0.18),
                //                 child: Padding(
                //                   padding: EdgeInsets.symmetric(
                //                       horizontal: 10.0, vertical: 10),
                //                   child: TextField(
                //                     controller: _couponController,
                //                     cursorHeight: dynamicSize(0.06),
                //                     decoration: InputDecoration(
                //                         border: OutlineInputBorder(),
                //                         labelText: 'Write your Promo code',
                //                         hintStyle: TextStyle(
                //                             fontSize: dynamicSize(0.035))),
                //                   ),
                //                 ),
                //               ),
                //             ),
                //           ],
                //         ),
                //         TextButton(
                //             onPressed: () async {
                //               // TODO
                //               // await DataControllers.to.checkoutDiscount(
                //               //     _couponController.text,
                //               //     widget.providerData!
                //               //         .provider_service_total_price
                //               //         .toString());
                //               // if (DataControllers
                //               //     .to.couponPrize.value.success!) {
                //               //   setState(() {
                //               //     discountAmount = DataControllers
                //               //         .to.couponPrize.value.data!.discount!
                //               //         .toDouble();
                //               //   });
                //               // }
                //             },
                //             child: Text(
                //               "+ Apply",
                //               style: TextStyle(
                //                   fontSize: dynamicSize(0.05),
                //                   color: Colors.blue),
                //             ))
                //       ],
                //     ),
                //   ),
                //   color: Colors.white,
                // ),
              ],
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            elevation: 0,
            //color: AllColor.themeColor,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 8.0, right: 8, bottom: 8, top: 15),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Placing your order"),
                          ),
                        );
                        log("tapped", name: "user_map");
                        dc.loading(true);

                        var data = await ApiService.placeOrder(
                            request_number: widget.requestNumber,
                            provider_id: widget.providerId,
                            result: selectedLoc,
                            coupon_code: "",
                            order_note: "");

                        log(data.toString(), name: "user_map_raw");
                        // await dc.confirmOrder(widget.reqDocId!,
                        //     widget.receiverId!, widget.providerData);

                        // ignore: use_build_context_synchronously
                        Future.delayed(Duration(seconds: 2)).then((value) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DestinationMapPage(
                                  invoiceId: data["invoice_number"],
                                  orderID: data["order_id"],
                                  details: widget.details),
                            ),
                          );
                        });
                        dc.loading(false);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AllColor.themeColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        alignment: Alignment.center,
                        height: dynamicSize(0.15),
                        child: Text(
                          "Confirm this order",
                          style: TextStyle(
                              fontSize: dynamicSize(0.05), color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
