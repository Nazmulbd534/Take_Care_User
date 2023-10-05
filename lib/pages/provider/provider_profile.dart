import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';

class ProviderProfile extends StatefulWidget {
  final Map<String, dynamic> profile;
  const ProviderProfile({super.key, required this.profile});

  @override
  State<ProviderProfile> createState() => _ProviderProfileState();
}

class _ProviderProfileState extends State<ProviderProfile> {
  @override
  void initState() {
    super.initState();

    widget.profile["speciality"] =
        jsonDecode(widget.profile["speciality"].toString());
    log(widget.profile.toString(), name: "jsonObjectTest");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Provider profile"),
      ),
    );
  }
}
