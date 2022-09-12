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
import 'package:takecare_user/public_variables/size_config.dart';
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





  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;


    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            Icon(Icons.devices_other,color: Colors.black38,size: dynamicSize(0.25),),

            Padding(
              padding: const EdgeInsets.only(left: 60.0, top: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Enter 6 digit code that ',
                  style: TextStyle(
                    fontSize: dynamicSize(0.07),
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 60.0, top: 5),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'sent you in',
                      style: TextStyle(
                        fontSize: dynamicSize(0.07),
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                FlatButton(
                    onPressed: () {},
                    child: Text(
                      DataControllers.to.phoneNumber.value.text,
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 23),

                    )
                ),
              ],
            ),
            Align(
              alignment: Alignment.topCenter,
              child:Container(
                // padding: const EdgeInsets.only(left:40),
                margin: EdgeInsets.only(left: MediaQuery.of(context).size.width/3),

                child: FlatButton(
                    onPressed: () {},
                    child: Text(
                      "",
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: dynamicSize(0.07)),
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 10),
              child: PinFieldAutoFill(

                decoration: UnderlineDecoration(

                  lineHeight: 0,
                  bgColorBuilder: FixedColorBuilder(Colors.green.withOpacity(0.3)) ,
                  textStyle: TextStyle(fontSize: 20, color: Colors.black),
                  colorBuilder: FixedColorBuilder(Colors.green.withOpacity(0.3)),
                ),
                onCodeSubmitted: (code) {},
                onCodeChanged: (code) async{
                  completedPin = code.toString();
                  if(completedPin.length == 6)
                    {
                      await DataControllers.to.postVerifyOTP(DataControllers.to.phoneNumber.value.text,completedPin);

                      Fluttertoast.showToast(
                          msg: DataControllers.to.userLoginResponse.value.message!,
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                          fontSize: 16.0
                      );
                      if(DataControllers.to.userLoginResponse.value.success == true)
                      {
                        Get.offAll(SignInPage());

                      }

                    }
                },
              ),
            ),
            Timers( callback: (){
              //Navigator.pop(context);
            },),
         /*   Spacer(),
            SizedBox(
              height: dynamicSize(0.15),
              width: MediaQuery.of(context).size.width,
              child: Container(
                //margin: EdgeInsets.only(bottom: 5),
                padding: const EdgeInsets.only(left: 5, right: 5, bottom:10),
                child: RaisedButton(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onPressed: () async{

                    if(completedPin.isNotEmpty && completedPin.length > 5)
                    {

                      await DataControllers.to.postVerifyOTP(DataControllers.to.phoneNumber.value.text,completedPin);

                      Fluttertoast.showToast(
                          msg: DataControllers.to.userLoginResponse.value.message!,
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                          fontSize: 16.0
                      );
                      if(DataControllers.to.userLoginResponse.value.success == true)
                      {
                         Get.offAll(SignInPage());

                      }

                    }else
                    {
                      Fluttertoast.showToast(
                          msg: "Fil up the filed!!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0
                      );
                    }

                  },
                  //padding: EdgeInsets.all(10.0),
                  color: Colors.redAccent,
                  textColor: Colors.white,
                  child: Text(
                    "Verify",
                    style: TextStyle(fontSize: dynamicSize(0.07)),
                  ),
                ),
              ),
            ),*/
          ],
        ),
      ),
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
      setState(() {

        _timer.cancel();
        widget.callback();



      });
    } else {
      setState(() {
        _start--;
      });
    }
  }

}