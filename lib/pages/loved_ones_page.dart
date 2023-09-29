// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:takecare_user/controller/data_controller.dart';
import 'package:takecare_user/controllers/DataContollers.dart';
import 'package:takecare_user/controllers/language_controller.dart';
import 'package:takecare_user/model/LovedOnesResponse.dart';
import 'package:takecare_user/model/SaveAddressResponse.dart';
import 'package:takecare_user/model/loved_one/loved_one_model.dart';
import 'package:takecare_user/pages/On%20Demand/map_page.dart';
import 'package:takecare_user/pages/On%20Demand/on_demand_page.dart';
import 'package:takecare_user/pages/On%20Demand/order_information_page.dart';
import 'package:takecare_user/pages/On%20Demand/schedule_order_page.dart';
import 'package:takecare_user/pages/long_time_services/order_confirm_page.dart';
import 'package:takecare_user/public_variables/variables.dart';

import '../public_variables/all_colors.dart';
import '../public_variables/size_config.dart';
import 'home_page.dart';
import 'long_time_services/map_picker_page.dart';
import 'loved_form_page.dart';

class LovedOnesPage extends StatefulWidget {
  String? activity;
  String? serviceTime;
  String? serviceAddress;
  LovedOnesPage(
      {Key? key, this.activity, this.serviceTime, this.serviceAddress})
      : super(key: key);

  @override
  _LovedOnesPageState createState() => _LovedOnesPageState();
}

class _LovedOnesPageState extends State<LovedOnesPage> {
  //bool editFather = false;

  //late FocusNode name;

  LovedOnesResponse lovedOneResponse = new LovedOnesResponse();

  int length = 0;

  // GeocodingResult? resultGeo;

  @override
  void initState() {
    getFavAddressList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LanguageController>(
      builder: (language) {
        return Scaffold(
          backgroundColor: AllColor.shado_color,
          appBar: AppBar(
            leading: InkWell(
              onTap: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => HomePage()));
              },
              child: const Icon(
                Icons.arrow_back,
                color: AllColor.themeColor,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              language.lovedOnes.string,
              style: const TextStyle(
                  fontFamily: 'Muli',
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
          ),
          body: ListView.builder(
              itemCount: length,
              itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () async {
                        print(widget.activity);
                        if (widget.activity ==
                            Variables.onDemandServiceActivity) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => OnDemandPage(
                                    selectedCategory: [''],
                                  )));
                        } else if (widget.activity ==
                                Variables.longTimeServiceActivity ||
                            widget.activity ==
                                Variables.orderInformationActivity) {
                          // TODO
                          // Navigator.of(context).pushReplacement(
                          //   MaterialPageRoute(
                          //     builder: (_) => OrderInformationPage(
                          //       activity: Variables.lovedOnesActivity,
                          //       serviceHolderInfo:
                          //           lovedOneResponse.data![index],
                          //       serviceAddress: "test",
                          //       serviceTime: "test1",
                          //     ),
                          //   ),
                          // );
                        } else if (widget.activity == "SelectAndGotoMap") {
                          await DataControllers.to.getProviderList(
                              "1",
                              "1",
                              Variables.currentPostion.longitude.toString(),
                              Variables.currentPostion.latitude.toString());
                          List<GeocodingResult?> results = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CustomMapPicker()));
                          if (results[0] != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (cp) => MapPage(
                                        result: results[0]!,
                                        lovedOnesId:
                                            lovedOneResponse.data![index].id,
                                      )),
                            );
                          }
                        } else if (widget.activity == "ScheduleActivity") {
                          await DataControllers.to.getProviderList(
                              "1",
                              "1",
                              Variables.currentPostion.longitude.toString(),
                              Variables.currentPostion.latitude.toString());
                          List<GeocodingResult?> results = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CustomMapPicker()));
                          if (results[0] != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (cp) => ScheduledOrderPage(
                                  result: results[0]!,
                                  orderType: "Scheduled",
                                  lovedOne: LovedOneModel(
                                      name: lovedOneResponse.data![index].name!,
                                      mobileNumber: lovedOneResponse
                                          .data![index].contactNo!
                                          .toString(),
                                      age: lovedOneResponse.data![index].age
                                          .toString(),
                                      gender:
                                          lovedOneResponse.data![index].gender!,
                                      relation: lovedOneResponse
                                          .data![index].relationship!),
                                ),
                              ),
                            );
                          }
                        } else if (widget.activity == "LongTermSchedule") {
                          await DataControllers.to.getProviderList(
                              "1",
                              "1",
                              Variables.currentPostion.longitude.toString(),
                              Variables.currentPostion.latitude.toString());
                          List<GeocodingResult?> results = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CustomMapPicker()));
                          if (results[0] != null) {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (cp) => OrderConfirmPage(
                            //         result: resultGeo!, orderType: "Long Term"),
                            //   ),
                            // );
                          }
                        }
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, right: 8, top: 10, bottom: 20),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${lovedOneResponse.data![index].relationship}',
                                    style: TextStyle(
                                        fontFamily: 'Muli',
                                        fontWeight: FontWeight.w600,
                                        fontSize: dynamicSize(0.05)),
                                  ),
                                  TextButton(
                                      onPressed: () {
                                        setState(() {
                                          Navigator.of(context).pushReplacement(
                                              MaterialPageRoute(
                                                  builder: (_) => LovedFormPage(
                                                        edit: true,
                                                        editValue:
                                                            lovedOneResponse
                                                                .data![index],
                                                        activity:
                                                            widget.activity,
                                                      )));
                                        });
                                      },
                                      child: (widget.activity ==
                                              Variables.homeActivity)
                                          ? Text(
                                              language.edit.string,
                                              style: TextStyle(
                                                  fontFamily: 'Muli',
                                                  fontWeight: FontWeight.w600,
                                                  color: AllColor.themeColor,
                                                  fontSize: dynamicSize(0.05)),
                                            )
                                          : Container())
                                ],
                              ),
                              Container(
                                height: 30,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 40),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              language.name.string,
                                              style: TextStyle(
                                                  fontFamily: 'Muli',
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: dynamicSize(0.04)),
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
                                        flex: 3,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 3.0),
                                          child: Text(
                                            '${lovedOneResponse.data![index].name}',
                                            style: TextStyle(
                                              fontSize: dynamicSize(0.04),
                                              fontFamily: 'Muli',
                                              fontWeight: FontWeight.w700,
                                            ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              language.age.string,
                                              style: TextStyle(
                                                  fontFamily: 'Muli',
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: dynamicSize(0.04)),
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
                                        flex: 3,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 3.0),
                                          child: Text(
                                            '${lovedOneResponse.data![index].age} Year(s)',
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              language.mobileNumber.string,
                                              style: TextStyle(
                                                fontSize: dynamicSize(0.04),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(": ",
                                                style: TextStyle(
                                                    fontSize: dynamicSize(0.05),
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 3.0),
                                          child: Text(
                                            '${lovedOneResponse.data![index].contactNo}',
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
                        ),
                      ),
                    ),
                  )),
          bottomNavigationBar: BottomAppBar(
            elevation: 0,
            //color: AllColor.themeColor,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 8.0, right: 8, bottom: 8, top: 20),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (_) => LovedFormPage(
                            activity: widget.activity,
                          )));
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AllColor.themeColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  alignment: Alignment.center,
                  height: dynamicSize(0.15),
                  child: Text(
                    language.addNew.string,
                    style: TextStyle(
                        fontSize: dynamicSize(0.05), color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void getFavAddressList() async {
    lovedOneResponse = await DataControllers.to.getFavAddress();

    if (lovedOneResponse.success!) {
      setState(() {
        length = lovedOneResponse.data!.length;
        //   addressResponse;
      });
    }
  }
}
