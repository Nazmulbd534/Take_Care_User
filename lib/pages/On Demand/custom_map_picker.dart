import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:takecare_user/controllers/DataContollers.dart';
import 'package:takecare_user/pages/long_time_services/order_confirm_page.dart';

import '../../public_variables/variables.dart';

class CustomMapPickerOnDemand extends StatelessWidget {
  const CustomMapPickerOnDemand({super.key});

  @override
  Widget build(BuildContext context) {
    return MapLocationPicker(
        topCardColor: Colors.white70,
        bottomCardColor: Colors.pinkAccent,
        currentLatLng: Variables.currentPostion,
        desiredAccuracy: LocationAccuracy.high,
        apiKey: "AIzaSyB5x56y_2IlWhARk8ivDevq-srAkHYr9HY",
        onNext: (GeocodingResult? result) async {});
  }
}
