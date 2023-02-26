import 'package:flutter/material.dart';
import 'package:takecare_user/public_variables/all_colors.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: size.width,
      alignment: Alignment.center,
      color: Colors.white,
      child: const CircularProgressIndicator(color: AllColor.themeColor),
    );
  }
}
