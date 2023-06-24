import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:takecare_user/model/loved_one/loved_one_model.dart';
import 'package:takecare_user/public_variables/all_colors.dart';

import '../../api_service/ApiService.dart';
import '../../controllers/DataContollers.dart';
import '../../public_variables/size_config.dart';
import '../../public_variables/variables.dart';
import '../long_time_services/map_picker_page.dart';

class ScheduledOrderPage extends StatefulWidget {
  final GeocodingResult result;
  final String orderType;
  final LovedOneModel lovedOne;
  // ignore: prefer_const_constructors_in_immutables
  ScheduledOrderPage(
      {super.key,
      required this.result,
      required this.orderType,
      required this.lovedOne});

  @override
  State<ScheduledOrderPage> createState() => _ScheduledOrderPageState();
}

class _ScheduledOrderPageState extends State<ScheduledOrderPage> {
  @override
  void initState() {
    super.initState();

    log(widget.result.formattedAddress.toString());
  }

  final TextEditingController notesController = TextEditingController();
  final TextEditingController extraAddressTextController =
      TextEditingController();

  List<List<DateTime>?> pickedTimes = List.generate(100, (i) => []);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Container(
        color: Colors.grey[100]!.withOpacity(0.9),
        height: dynamicSize(0.2),
        child: Center(
          child: ElevatedButton(
            style: ButtonStyle(
                fixedSize: MaterialStateProperty.all<Size>(
                  Size(
                    dynamicSize(0.8),
                    dynamicSize(0.17),
                  ),
                ),
                backgroundColor:
                    MaterialStateProperty.all<Color>(AllColor.themeColor)),
            onPressed: () {
              log("clicked");
            },
            child: const Text(
              "Confirm this Order",
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text("Order Information"),
        backgroundColor: AllColor.themeColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: [
                Container(
                  // height: dynamicSize(0.55),
                  child: ListView(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(8),
                    children: List.generate(
                      DataControllers
                          .to.getAddCardShortServiceResponse.value.data!.length,
                      (index) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(10),
                                      bottomRight: Radius.circular(10)),
                                  child: CachedNetworkImage(
                                    fit: BoxFit.fill,
                                    width: 100,
                                    height: 100,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 8.0, left: 10, right: 10),
                                        child: Text(
                                          "${DataControllers.to.getAddCardShortServiceResponse.value.data![index].service!.serviceName == null ? "Service Name" : DataControllers.to.getAddCardShortServiceResponse.value.data![index].service!.serviceName}",
                                          style: TextStyle(
                                            fontSize: dynamicSize(0.04),
                                            fontFamily: "Muli",
                                            fontWeight: FontWeight.w700,
                                            color: AllColor.boldTextColor,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5),
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            widget.orderType,
                                            style: const TextStyle(
                                              fontFamily: "Muli",
                                              color: AllColor.boldTextColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 5, top: 10),
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: InkWell(
                                            onTap: () async {
                                              DateTime? dateTime =
                                                  await showOmniDateTimePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime.now(),
                                                lastDate: DateTime.now().add(
                                                  const Duration(days: 3652),
                                                ),
                                                is24HourMode: false,
                                                isShowSeconds: false,
                                                minutesInterval: 1,
                                                secondsInterval: 1,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(16)),
                                                constraints:
                                                    const BoxConstraints(
                                                  maxWidth: 350,
                                                  maxHeight: 650,
                                                ),
                                                transitionBuilder: (context,
                                                    anim1, anim2, child) {
                                                  return FadeTransition(
                                                    opacity: anim1.drive(
                                                      Tween(
                                                        begin: 0,
                                                        end: 1,
                                                      ),
                                                    ),
                                                    child: child,
                                                  );
                                                },
                                                transitionDuration:
                                                    const Duration(
                                                        milliseconds: 200),
                                                barrierDismissible: true,
                                                selectableDayPredicate:
                                                    (dateTime) {
                                                  // Disable 25th Feb 2023
                                                  if (dateTime ==
                                                      DateTime(2023, 2, 25)) {
                                                    return false;
                                                  } else {
                                                    return true;
                                                  }
                                                },
                                              );

                                              if (dateTime != null) {
                                                setState(() {
                                                  pickedTimes[index]!
                                                      .add(dateTime);
                                                });
                                              }

                                              log(pickedTimes.toString());
                                            },
                                            child: const Text(
                                              "+ Add one or more Date and Time",
                                              style: TextStyle(
                                                fontFamily: "Muli",
                                                color: AllColor.blue_light,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: pickedTimes[index]!.length,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index1) {
                                          String formattedDate = DateFormat(
                                                  'dd - MMM – h:mm a')
                                              .format(
                                                  pickedTimes[index]![index1]);
                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              // const Spacer(),
                                              Text(
                                                formattedDate,
                                                style: const TextStyle(
                                                  fontFamily: "Muli",
                                                  color: AllColor.boldTextColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              //  const Spacer(),
                                              IconButton(
                                                onPressed: () async {
                                                  DateTime? dateTime =
                                                      await showOmniDateTimePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime.now(),
                                                    lastDate:
                                                        DateTime.now().add(
                                                      const Duration(
                                                          days: 3652),
                                                    ),
                                                    is24HourMode: false,
                                                    isShowSeconds: false,
                                                    minutesInterval: 1,
                                                    secondsInterval: 1,
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                16)),
                                                    constraints:
                                                        const BoxConstraints(
                                                      maxWidth: 350,
                                                      maxHeight: 650,
                                                    ),
                                                    transitionBuilder: (context,
                                                        anim1, anim2, child) {
                                                      return FadeTransition(
                                                        opacity: anim1.drive(
                                                          Tween(
                                                            begin: 0,
                                                            end: 1,
                                                          ),
                                                        ),
                                                        child: child,
                                                      );
                                                    },
                                                    transitionDuration:
                                                        const Duration(
                                                            milliseconds: 200),
                                                    barrierDismissible: true,
                                                    selectableDayPredicate:
                                                        (dateTime) {
                                                      // Disable 25th Feb 2023
                                                      if (dateTime ==
                                                          DateTime(
                                                              2023, 2, 25)) {
                                                        return false;
                                                      } else {
                                                        return true;
                                                      }
                                                    },
                                                  );
                                                  if (dateTime != null) {
                                                    setState(() {
                                                      pickedTimes[index]![
                                                          index1] = dateTime;
                                                    });
                                                  }
                                                },
                                                icon: const Icon(
                                                  Icons.edit,
                                                  size: 16.0,
                                                  color: AllColor.boldTextColor,
                                                ),
                                              ),

                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    pickedTimes.remove(
                                                        pickedTimes[index]);
                                                  });
                                                },
                                                icon: const Icon(
                                                  Icons.delete,
                                                  size: 16.0,
                                                  color: AllColor.boldTextColor,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Card(
                    elevation: 3,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                const Text(
                                  "Visiting Address",
                                  style: TextStyle(
                                    fontFamily: "Muli",
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () async {
                                    // late GeocodingResult resultGeo;
                                    // List<GeocodingResult?> results =
                                    //     await Navigator.push(
                                    //         context,
                                    //         MaterialPageRoute(
                                    //             builder: (context) =>
                                    //                 CustomMapPicker()));
                                    // if (results[0] != null) {
                                    //   // ignore: use_build_context_synchronously
                                    //   Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //       builder: (cp) => ScheduledOrderPage(
                                    //         result: results[0]!,
                                    //         orderType: "Schedule",
                                    //         lovedOne: widget.lovedOne,
                                    //       ),
                                    //     ),
                                    //   );
                                    // }
                                  },
                                  child: const Text(
                                    "Edit",
                                    style: TextStyle(),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10.0,
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, top: 5),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_pin,
                                  color: AllColor.colorGreen,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Flexible(
                                  child: Text(
                                    widget.result.formattedAddress!,
                                    style: const TextStyle(
                                      fontFamily: "Muli",
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Container(
                            child: TextField(
                              controller: extraAddressTextController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: "Additional Address",
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10.0,
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                const Padding(
                  padding: EdgeInsets.only(
                    left: 15.0,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Booking Information",
                      style: TextStyle(
                        fontFamily: "Muli",
                        color: AllColor.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Card(
                    elevation: 3.0,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const SizedBox(
                              width: 15.0,
                            ),
                            Text(
                              widget.lovedOne.relation,
                              style: TextStyle(
                                  color: AllColor.boldTextColor,
                                  fontSize: dynamicSize(0.05),
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Muli"),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {},
                              child: Text("Edit"),
                            ),
                            const SizedBox(
                              width: 10.0,
                            )
                          ],
                        ),
                        personDataRow("Name", widget.lovedOne.name),
                        personDataRow("Age", widget.lovedOne.age),
                        personDataRow("Gender", widget.lovedOne.gender),
                        personDataRow(
                            "Contact Number", widget.lovedOne.mobileNumber),
                        const SizedBox(
                          height: 5.0,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Padding(
                  padding: EdgeInsets.only(
                    left: 15.0,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Additional Note",
                      style: TextStyle(
                        fontFamily: "Muli",
                        color: AllColor.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Container(
                  width: dynamicSize(0.98),
                  height: dynamicSize(0.3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AllColor.textFieldColor,
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10, left: 10),
                    child: TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "(ex. Bring a syringe of 5ml..……..)",
                        hintStyle: TextStyle(
                          fontFamily: "Muli",
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: dynamicSize(0.26),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget personDataRow(String colName, String value) {
    return Container(
      height: 30,
      child: Padding(
        padding: const EdgeInsets.only(left: 40),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "$colName ",
                    style: TextStyle(
                        fontFamily: 'Muli',
                        fontWeight: FontWeight.w600,
                        fontSize: dynamicSize(0.04)),
                  ),
                  Text(
                    ":  ",
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
                padding: const EdgeInsets.only(top: 3.0),
                child: Text(
                  value,
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
    );
  }
}
