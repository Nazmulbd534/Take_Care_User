import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

import '../../api_service/ApiService.dart';
import '../../controllers/DataContollers.dart';
import '../../public_variables/all_colors.dart';
import '../../public_variables/size_config.dart';
import '../../public_variables/variables.dart';
import '../On Demand/schedule_order_page.dart';

class OrderConfirmPage extends StatefulWidget {
  final GeocodingResult result;
  final String orderType;
  const OrderConfirmPage({
    super.key,
    required this.result,
    required this.orderType,
  });

  @override
  State<OrderConfirmPage> createState() => _OrderConfirmPageState();
}

class _OrderConfirmPageState extends State<OrderConfirmPage> {
  @override
  void initState() {
    super.initState();

    log(widget.result.formattedAddress.toString());
  }

  final TextEditingController notesController = TextEditingController();
  final TextEditingController extraAddressTextController =
      TextEditingController();

  List<List<DateTime>?> pickedTimes = List.generate(100, (i) => []);
  String dropdownvalue = 'Starting From';
  String timeDropdownValue = "Daily 6 Hrs.";

  // List of items in our dropdown menu
  var firstItems = [
    'Starting From',
    'Ending At',
  ];

  var timeItems = [
    "Daily 6 Hrs.",
    "Daily 8 Hrs.",
    "Daily 10 Hrs.",
    "Daily 12 Hrs.",
    "24 Hrs Stay.",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Container(
        color: Colors.grey[200]!.withOpacity(0.8),
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
            ),
            onPressed: () {
              log("clicked");
            },
            child: const Text("Confirm this Order"),
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
            const SizedBox(
              height: 10,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Select start date & duration",
                  style: TextStyle(
                    fontFamily: "Muli",
                    fontWeight: FontWeight.w600,
                    fontSize: 18.0,
                    color: AllColor.boldTextColor,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 5.0,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 20.0,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AllColor.dropDownColor,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.only(
                    left: 5.0,
                    right: 5.0,
                  ),
                  child: DropdownButton(
                    // Initial Value
                    value: dropdownvalue,
                    dropdownColor: AllColor.dropDownColor,
                    // Down Ar  row Icon
                    style: const TextStyle(color: Colors.white),
                    underline: SizedBox.shrink(),
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),

                    // Array list of items
                    items: firstItems.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(items),
                      );
                    }).toList(),
                    // After selecting the desired option,it will
                    // change button value to selected value
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownvalue = newValue!;
                      });
                    },
                  ),
                ),
                Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: AllColor.dropDownColor,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.only(
                    left: 5.0,
                    right: 5.0,
                  ),
                  child: DropdownButton(
                    // Initial Value
                    value: timeDropdownValue,
                    dropdownColor: AllColor.dropDownColor,
                    // Down Ar  row Icon
                    style: const TextStyle(color: Colors.white),
                    underline: SizedBox.shrink(),
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),

                    // Array list of items
                    items: timeItems.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(items),
                      );
                    }).toList(),
                    // After selecting the desired option,it will
                    // change button value to selected value
                    onChanged: (String? newValue) {
                      setState(() {
                        timeDropdownValue = newValue!;
                      });
                    },
                  ),
                ),
                const SizedBox(
                  width: 20.0,
                )
              ],
            ),
            Column(
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
                            late GeocodingResult resultGeo;
                            resultGeo = (await Navigator.push(
                              context,
                              MaterialPageRoute<GeocodingResult>(
                                builder: (cx) {
                                  return MapLocationPicker(
                                      location: Location(
                                        lat: Variables.currentPostion.latitude,
                                        lng: Variables.currentPostion.longitude,
                                      ),
                                      apiKey:
                                          "AIzaSyB5x56y_2IlWhARk8ivDevq-srAkHYr9HY",
                                      canPopOnNextButtonTaped: true,
                                      onNext: (GeocodingResult? result) {
                                        if (result != null) {
                                          setState(() {
                                            resultGeo = result;
                                            // var  address = result.formattedAddress ?? "";
                                            Navigator.pop(cx, resultGeo);
                                          });
                                          // Navigator.push(context, MaterialPageRoute(builder: (context) => MapPage()),);
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
                                  builder: (cp) => OrderConfirmPage(
                                      result: resultGeo,
                                      orderType: "Long Term"),
                                ),
                              );
                            }
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
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Container(
                    child: TextField(
                      controller: extraAddressTextController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Additional Address"),
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
                Row(
                  children: [
                    const SizedBox(
                      width: 15.0,
                    ),
                    Text(
                      "Baba",
                      style: TextStyle(
                        color: AllColor.boldTextColor,
                        fontSize: dynamicSize(0.05),
                        fontWeight: FontWeight.w600,
                      ),
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
                personDataRow("Name", "Wasiul Alam"),
                personDataRow("Age", "22 Years"),
                personDataRow("Gender", "Male"),
                personDataRow("Contact Number", "017xxxxxxxxxx"),
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
