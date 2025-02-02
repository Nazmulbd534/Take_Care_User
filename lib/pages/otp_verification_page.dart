import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:takecare_user/controllers/DataContollers.dart';
import 'package:takecare_user/pages/sign_in_page.dart';
import 'package:takecare_user/public_variables/all_colors.dart';
import 'package:takecare_user/public_variables/notifications.dart';
import 'package:takecare_user/public_variables/size_config.dart';
import 'package:takecare_user/public_variables/variables.dart';
import 'package:takecare_user/ui/common.dart';
import 'package:takecare_user/widgets/loading_widget.dart';
import 'home_page.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({Key? key}) : super(key: key);

  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {

  late String completedPin = '';


  late Timer _timer;
  int _start = 180;



  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  bool isLoading = false;

  onProgressBar(bool progress) {
    setState(() {
      isLoading = progress;
    });
  }

  void loginClass(String user, String pass) async {
    onProgressBar(true);

    print('user ${user} pass ${pass}');
    try {
      await DataControllers.to.postLogin(user, pass);
    } catch (e) {
      onProgressBar(false);
      //  isLoading = false;
    }
    if (DataControllers.to.userLoginResponse.value.success == true)
    {

      bearerToken = "Bearer " +
          DataControllers.to.userLoginResponse.value.data!.token.toString();


      await DataControllers.to.getSlider();
      await DataControllers.to.getAllCategories();
      Common.storeSharedPreferences.setString('userid', user);
      Common.storeSharedPreferences.setString('pass', pass);

      Get.offAll(HomePage());
      onProgressBar(false);
    }else
    {
      onProgressBar(false);
      showToast(DataControllers.to.userLoginResponse.value.message!);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.devices_other,color: Colors.black38,size: dynamicSize(0.25),),
                Padding(
                  padding: const EdgeInsets.only( top: 20,bottom: 5),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Enter 6 digit code that ',
                      style: TextStyle(
                        fontFamily: 'Muli',
                        fontWeight: FontWeight.w600,
                        fontSize: dynamicSize(0.06),
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Wrap(
crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'sent you in',
                      style: TextStyle(
                        fontFamily: 'Muli',
                        fontWeight: FontWeight.w600,
                        fontSize: dynamicSize(0.06),
                        color: Colors.black,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        DataControllers.to.phoneNumber.value.text,
                        style: TextStyle(
                            color: Colors.red,
                            fontFamily: 'Muli',
                            fontWeight: FontWeight.w700,
                            fontSize: 20),

                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child:Container(
                    // padding: const EdgeInsets.only(left:40),
                    margin: EdgeInsets.only(left: MediaQuery.of(context).size.width/3),

                    child: MaterialButton(
                        onPressed: () {},
                        child: Text(
                          "",
                          style: TextStyle(
                              color: Colors.blue,
                              fontFamily: 'Muli',
                              fontWeight: FontWeight.w700,
                              fontSize: dynamicSize(0.07)),
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 10),
                  child: PinFieldAutoFill(
                    autoFocus: true,
                    decoration: UnderlineDecoration(
                      lineHeight: 0,
                      bgColorBuilder: FixedColorBuilder(Colors.green.withOpacity(0.3)) ,
                      textStyle: TextStyle(
                          fontFamily: 'Muli',
                          fontWeight: FontWeight.w600,
                          fontSize: 20, color: Colors.black),
                      colorBuilder: FixedColorBuilder(Colors.green.withOpacity(0.3)),
                    ),
                    onCodeSubmitted: (code) {},
                    onCodeChanged: (code) async{
                      completedPin = code.toString();
                      if(completedPin.length == 6)
                        {


                          await DataControllers.to.postVerifyOTP(DataControllers.to.phoneNumber.value.text,completedPin);

                          if(DataControllers.to.userLoginResponse.value.success == true)
                          {

                            loginClass(DataControllers.to.phoneNumber.value.text.toString(),
                                DataControllers.to.password.value.text.toString());
                          }else
                            {
                              snackBar(context, DataControllers.to.userLoginResponse.value.message!);
                            }

                        }
                    },
                  ),
                ),
                Timers( callback: (){
                  Navigator.pop(context);
                },),
              ],
            ),
          ),
        ),
        isLoading ? const LoadingWidget() : Container()
      ],
    );
  }
}


class Timers extends StatefulWidget {
  final VoidCallback callback;
  Timers({Key? key, required this.callback}) : super(key: key);

  @override
  State<Timers> createState() => _TimerState();
}

class _TimerState extends State<Timers> {


  late Timer _timer;
  int _start = 120;





  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }


  void startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) => _update());
  }

  _update() {
    if (_start == 0) {
      setState(() {_timer.cancel();widget.callback();});
    } else {
      setState(() => _start--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child:  Padding(
        padding: const EdgeInsets.only(left: 30.0, top: 20),
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(
            '${_start} sec.',
            style: TextStyle(
              fontSize: dynamicSize(0.06),
              color: AllColor.button_color,
            ),
          ),
        ),
      ),
    );
  }
}