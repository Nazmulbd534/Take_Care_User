import 'package:flutter/material.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:takecare_user/model/AvailableProviderResponse.dart';
import 'package:takecare_user/model/provider/provider_data.dart';
import 'package:takecare_user/pages/On%20Demand/map_page.dart';
import 'package:takecare_user/public_variables/variables.dart';

import '../../controllers/DataContollers.dart';
import '../../public_variables/all_colors.dart';
import '../../public_variables/size_config.dart';
import '../long_time_services/map_picker_page.dart';

class CancelPage extends StatelessWidget {
  final  Map<String, dynamic>? details;
  const CancelPage({Key? key, required this.details}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          //backgroundColor: AllColor.themeColor,
          body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: dynamicSize(0.6),
            ),
            Row(
              // crossAxisAlignment:CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Sorry!",
                  style: TextStyle(
                      color: AllColor.themeColor,
                      fontSize: dynamicSize(0.06),
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
            SizedBox(
              height: dynamicSize(0.1),
            ),
           CircleAvatar(
                    radius: 50,
                    backgroundColor: AllColor.white,
                    backgroundImage: NetworkImage(details!["data"]["service_request"][0]["provider"]["profile_photo"])

                  ),
                  SizedBox(
                    height: dynamicSize(0.07),
                  ),
                  Text(
                    details!["data"]["service_request"][0]["provider"]["full_name"],
                    style: TextStyle(
                        fontFamily: 'Muli',
                        fontWeight: FontWeight.w600,
                        fontSize: dynamicSize(0.06),
                        color: AllColor.themeColor),
                  ),
                  Text(
                    "Didn't accept the request.",
                    style: TextStyle(
                        fontFamily: 'Muli',
                        fontWeight: FontWeight.w600,
                        fontSize: dynamicSize(0.05),
                        color: AllColor.themeColor),
                  ),
            SizedBox(
              height: dynamicSize(0.6),
            ),
            Text(
              "Choose Another",
              style: TextStyle(
                  fontSize: dynamicSize(0.06),
                  color: Colors.green,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: dynamicSize(0.04),
            ),
            TextButton(
              onPressed: () async {
                GeocodingResult? result;

               List<GeocodingResult?> results =
                                            await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        CustomMapPicker()));

                                        await DataControllers.to
                                            .getProviderList(
                                                "1",
                                                "1",
                                                results.first!.geometry.location
                                                    .lng
                                                    .toString(),
                                                results.first!.geometry.location
                                                    .lat
                                                    .toString());
                                        if (result != null) {
                                          // ignore: use_build_context_synchronously
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (cp) => MapPage(
                                                result: results.first!,
                                              ),
                                            ),
                                          );
                                        }
              },
              child: Text(
                "Request again",
                style:
                    TextStyle(fontSize: dynamicSize(0.05), color: Colors.blue),
              ),
            )
          ],
        ),
      )),
    );
  }
}
