import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:takecare_user/controller/data_controller.dart';
import 'package:takecare_user/controllers/DataContollers.dart';
import 'package:takecare_user/model/AddCardResponse.dart';
import 'package:takecare_user/model/AllServiceResponse.dart';
import 'package:takecare_user/model/AvailableProviderResponse.dart';
import 'package:takecare_user/model/CategoriesResponse.dart';
import 'package:takecare_user/model/Erorr.dart';
import 'package:takecare_user/model/Expertise.dart';
import 'package:takecare_user/model/LovedOnesResponse.dart';
import 'package:takecare_user/model/RegisterResponse.dart';
import 'package:takecare_user/model/ResendOTPResponse.dart';
import 'package:takecare_user/model/SaveAddressResponse.dart';
import 'package:takecare_user/model/SliderResponse.dart';
import 'package:takecare_user/model/UserLoginResponse.dart';
import 'package:takecare_user/model/UserServiceResponse.dart';
import 'package:takecare_user/model/app_response.dart';
import 'package:takecare_user/model/provider/provider_data.dart';
import 'package:takecare_user/model/provider/provider_response.dart';
import 'package:takecare_user/public_variables/notifications.dart';
import 'package:takecare_user/public_variables/variables.dart';

class ApiService {
  static var client = http.Client();
  static var BaseURL = 'https://api.takecare.ltd/api/v1/';
  static var MainURL = 'https://api.takecare.ltd/';

  /**
   *    get Request
   */

  static Future<ExpertiseResponse?> fetchExpertiseResponse() async {
    var response = await client
        .get(Uri.parse(BaseURL + 'specialities'), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': bearerToken,
    });
    print("Api Response : ${response.body}");
    if (response.statusCode == 200) {
      print("Api Response : ${response.body}");
      var jsonString = response.body;
      return expertiseResponseFromJson(jsonString);
    } else {
      return null;
    }
  }

  static Future<AllServiceResponse?> fetchServiceResponse() async {
    var response = await client
        .get(Uri.parse(BaseURL + 'service/all'), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': bearerToken,
    });
    if (response.statusCode == 200) {
      log("Api Response : ${response.body}");
      var jsonString = response.body;
      return allServiceResponseFromJson(jsonString);
    } else {
      return null;
    }
  }

  static Future<AllServiceResponse?> fetchAllLongShortServiceResponse(
      String type) async {
    var response = await client.post(
      Uri.parse(BaseURL + 'service/allbytype'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': bearerToken,
      },
      body: jsonEncode(<String, String>{
        'service_type': type,
      }),
    );
    print("Api Response  : ${response.body}");

    if (response.statusCode == 200) {
      var jsonString = response.body;
      return allServiceResponseFromJson(jsonString);
    } else {
      if (type == 'long') {
        DataControllers.to.longServiceResponse.value.success =
            json.decode(response.body)["success"];
        DataControllers.to.longServiceResponse.value.message =
            json.decode(response.body)["message"];
        return allServiceResponseFromJson(response.body);
      } else {
        DataControllers.to.shortServiceResponse.value.success =
            json.decode(response.body)["success"];
        DataControllers.to.shortServiceResponse.value.message =
            json.decode(response.body)["message"];
        return allServiceResponseFromJson(response.body);
      }
    }
  }

  static Future<CategoriesResponse?> fetchAllCategoriesResponse() async {
    var response = await client.get(Uri.parse(BaseURL + 'service/categories'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': bearerToken,
        });
    if (response.statusCode == 200) {
      print("Api Response service categories : ${response.body}");
      var jsonString = response.body;
      return categoriesResponseFromJson(jsonString);
    } else {
      return null;
    }
  }

  /**
   *    Post Request
   */

  static Future<RegisterResponse> postRegister(
      String first_name,
      String phone_no,
      String password,
      String gender,
      String role,
      String image,
      String signature) async {
    final response = await http.post(
      Uri.parse(BaseURL + 'register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'full_name': first_name,
        'phone': phone_no,
        'password': password,
        'gender': gender,
        'role': role,
        'profile_photo': image,
        'signature_otp': signature,
      }),
    );
    print(response.body);
    if (response.statusCode == 200) {
      // If the server did return a 200 CREATED response,
      // then parse the JSON.
      return registerResponseFromJson(response.body);
    } else {
      Fluttertoast.showToast(
          msg: "Registration failed !!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return registerResponseFromJson(response.body);
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to create.');
    }

    return registerResponseFromJson(response.body);
  }

  static Future<UserLoginResponse> postLogin(
      String phoneNumber, String pass) async {
    ///Get Device token for push notification
    final String fcmToken = await DataController.dc.generateUserToken();
    // print("fcmToken : "+fcmToken);
    var response;
    try {
      response = await http.post(
        Uri.parse(BaseURL + 'login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'phone': phoneNumber,
          'password': pass,
          'role_id': "4",
          'token': fcmToken
        }),
      );
    } catch (e) {
      print('errro');
      print(e.toString());
    }

    print(response.body);
    if (response.statusCode == 200) {
      // If the server did return a 200 CREATED response,
      // then parse the JSON.
      await FirebaseFirestore.instance
          .collection('users')
          .doc(phoneNumber)
          .set({
        'phone': phoneNumber,
        'token': fcmToken,
        'date_time': DateTime.now().millisecondsSinceEpoch.toString()
      }, SetOptions(merge: true));

      DataControllers.to.userLoginResponse.value.success =
          json.decode(response.body)["success"];
      DataControllers.to.userLoginResponse.value.message =
          json.decode(response.body)["message"];

      return userLoginResponseFromJson(response.body);
    } else {
      // showToast("Please enter your valid user and password!!");
      //throw Exception('Failed to login');
      DataControllers.to.userLoginResponse.value.success =
          json.decode(response.body)["success"];
      DataControllers.to.userLoginResponse.value.message =
          json.decode(response.body)["message"];
      return DataControllers.to.userLoginResponse.value;
    }
  }

  static Future<UserLoginResponse> postVerifyOTP(
      String phone_number, String otp) async {
    final response = await http.post(
      Uri.parse(BaseURL + 'register/verify-otp'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'phone': phone_number,
        'otp': otp,
      }),
    );

    print(response.body);
    if (response.statusCode == 200) {
      // If the server did return a 200 CREATED response,
      // then parse the JSON.

      DataControllers.to.userLoginResponse.value.success =
          json.decode(response.body)["success"];
      DataControllers.to.userLoginResponse.value.message =
          json.decode(response.body)["message"];

      return DataControllers.to.userLoginResponse.value;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      DataControllers.to.userLoginResponse.value.success =
          json.decode(response.body)["success"];
      DataControllers.to.userLoginResponse.value.message =
          json.decode(response.body)["message"];

      return DataControllers.to.userLoginResponse.value;
      showToast("Please enter your valid user and password!!");
      throw Exception('Failed to login');
    }
  }

  static Future<ResendOTPResponse> postResendOTP(String phone_no) async {
    final response = await http.post(
      Uri.parse(BaseURL + 'register/resend-otp'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'phone': phone_no,
      }),
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 CREATED response,
      // then parse the JSON.
      return jsonDecode(response.body);
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      Fluttertoast.showToast(
          msg: "Please enter your valid user and password!!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      throw Exception('Failed to login');
    }
  }

  /// Card Service

  static Future<AddCardResponse?> fetchCard(String type) async {
    var response = await client.get(
      Uri.parse(BaseURL + 'user/cart/list?type=${type}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': bearerToken,
      },

      // body: jsonEncode(<String, String>{
      //   'user_id': user_id,
      // }),
    );
    if (response.statusCode == 200) {
      print("Api Response : ${response.body}");
      var jsonString = response.body;
      return addCardResponseFromJson(jsonString);
    } else {
      if (type == 'short') {
        DataControllers.to.getAddCardShortServiceResponse.value.success =
            json.decode(response.body)["success"];
        DataControllers.to.getAddCardShortServiceResponse.value.message =
            json.decode(response.body)["message"];
        return DataControllers.to.getAddCardShortServiceResponse.value;
      } else {
        DataControllers.to.getAddCardLongServiceResponse.value.success =
            json.decode(response.body)["success"];
        DataControllers.to.getAddCardLongServiceResponse.value.message =
            json.decode(response.body)["message"];
        return DataControllers.to.getAddCardLongServiceResponse.value;
      }
    }
  }

  static Future<ErrorResponse?> deleteCard(String user_id, String id) async {
    var response = await client.post(
      Uri.parse(BaseURL + 'user/cart/delete-cart'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': bearerToken,
      },
      body: jsonEncode(<String, String>{
        'id': id,
        'user_id': user_id,
      }),
    );
    if (response.statusCode == 200) {
      print("Api Response  delete card : ${response.body}");
      var jsonString = response.body;
      return errorResponseFromJson(jsonString);
    } else {
      DataControllers.to.addCardResponse.value.success =
          json.decode(response.body)["success"];
      DataControllers.to.addCardResponse.value.message =
          json.decode(response.body)["message"];
      return DataControllers.to.addCardResponse.value;
    }
  }

  static Future<ErrorResponse?> deleteAllCard(String user_id) async {
    var response = await client.post(
      Uri.parse(BaseURL + 'user/cart/empty-cart'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': bearerToken,
      },
      body: jsonEncode(<String, String>{
        'user_id': user_id,
      }),
    );
    if (response.statusCode == 200) {
      print("Api Response : ${response.body}");
      var jsonString = response.body;
      return errorResponseFromJson(jsonString);
    } else {
      DataControllers.to.addCardResponse.value.success =
          json.decode(response.body)["success"];
      DataControllers.to.addCardResponse.value.message =
          json.decode(response.body)["message"];
      //showToast("Please enter your valid user and password!!",Colors.red);
      //  return errorResponseFromJson(response.body);
      return DataControllers.to.addCardResponse.value;
    }
  }

  static Future<ErrorResponse?> addCard(BuildContext context, String service_id,
      String booking_date, String categoryId, String userID) async {
    var response = await client.post(
      Uri.parse(BaseURL + 'user/cart/add-service-to-cart'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': bearerToken,
      },
      body: jsonEncode(<String, String>{
        'id': service_id,
        'booking_date': booking_date,
        'category_id': categoryId,
      }),
    );

    if (response.statusCode == 200) {
      print("Api Response : ${response.body}");
      var jsonString = response.body;
      return errorResponseFromJson(jsonString);
    } else {
      DataControllers.to.addCardResponse.value.success =
          json.decode(response.body)["success"];
      DataControllers.to.addCardResponse.value.message =
          json.decode(response.body)["message"];

      if (json.decode(response.body)["success"] == false) {
        await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text(
                    "You can't add to cart from multiple categiory at once. If you continue your previous cart will be cleared."),
                actions: [
                  TextButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                    child: Text("Continue"),
                    onPressed: () async {
                      await deleteAllCard(userID);
                      await addCard(context, service_id, booking_date,
                          categoryId, userID);
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            });
      }
      //return errorResponseFromJson(response.body);
      //return DataControllers.to.addCardResponse.value;
    }
  }

  static Future<AppResponse?> newRequest(
      {String coupon_code = '',
      ProviderData? providerData,
      GeocodingResult? result}) async {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(now);
    log("this is called", name: "test");
    var jsonData = <String, String>{
      // "coupon_code": coupon_code,
      "booking_date": formatted,
      "provider_id": providerData!.id.toString(),
      "latitude": result!.geometry.location.lat.toString(),
      "longitude": result.geometry.location.lng.toString(),
      //   "foundSchedule": "a",
    };

    log(jsonData.toString() + "\n token = " + bearerToken,
        name: "new-request payload");
    var response = await client.post(
      Uri.parse(BaseURL + 'user/request/new-request'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': bearerToken,
      },
      body: jsonEncode(jsonData),
    );
    log("Api Response : ${response.body}", name: "newRequest");
    // List<String> stringList = (jsonDecode(response.body) as List<dynamic>).cast<String>();

    if (response.statusCode == 200) {
      //  var jsonString = response.body;

      return AppResponse.fromJson(jsonDecode(response.body));
    } else {
      DataControllers.to.appResponse.value.success =
          json.decode(response.body)["success"];
      DataControllers.to.appResponse.value.message =
          json.decode(response.body)["message"];
      return AppResponse.fromJson(jsonDecode(response.body));
    }
  }

  /// Order
  static Future<String?> placeOrder(
      {required String request_number,
      String coupon_code = '',
      String order_note = '',
      required String provider_id,
      GeocodingResult? result}) async {
    log("place order called");
    Map<String, String> jsonData = <String, String>{
      'user_id':
          DataControllers.to.userLoginResponse.value.data!.user!.id.toString(),
      "request_number": request_number,
      "coupon_code": coupon_code,
      "order_note": order_note,
      "booking_date": DateTime.now().millisecondsSinceEpoch.toString(),
      "booking_address": result!.formattedAddress!,
      "provider_id": provider_id,
      "latitude": result.geometry.location.lat.toString(),
      "longitude": result.geometry.location.lng.toString()
    };

    log(jsonData.toString(), name: "jsonTest");
    var jsonDataFormate = jsonEncode(jsonData);

    var response = await client.post(
      Uri.parse(BaseURL + 'user/order/place-order'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': bearerToken,
      },
      body: jsonDataFormate,
    );
    log("Api Response : ${response.body}", name: "user reconfirm place order");
    if (response.statusCode == 200) {
      //  var jsonString = response.body;
      log("Success here", name: "user reconfirm place order");
      var data = jsonDecode(response.body);
      log(data["data"]["invoice_number"], name: "final var test");
      return data["data"]["invoice_number"];
    } else {
      DataControllers.to.appResponse.value.success =
          json.decode(response.body)["success"];
      DataControllers.to.appResponse.value.message =
          json.decode(response.body)["message"];
      return "invoice not found";
    }
  }

  static Future<Map<String, dynamic>> fetchOrderInformation(
      String invoiceId) async {
    var response = await client.post(
      Uri.parse(BaseURL + 'user/order/single-order'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': bearerToken,
      },
      body: jsonEncode(<String, String>{
        'invoice_number': invoiceId,
      }),
    );

    log(response.body, name: "fetchOrderInformation");
    return jsonDecode(response.body);
  }

  static Future<ErrorResponse?> providerOrder(String id) async {
    var response = await client.post(
      Uri.parse(BaseURL + 'user/order/provider-orders'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': bearerToken,
      },
      body: jsonEncode(<String, String>{
        'provider_id': id,
      }),
    );
    if (response.statusCode == 200) {
      print("Api Response : ${response.body}");
      var jsonString = response.body;
      return errorResponseFromJson(jsonString);
    } else {
      DataControllers.to.userServiceResponse.value.success =
          json.decode(response.body)["success"];
      DataControllers.to.userServiceResponse.value.message =
          json.decode(response.body)["message"];
      return null;
    }
  }

  static Future<ErrorResponse?> seekerOrder() async {
    var response = await client.post(
      Uri.parse(BaseURL + 'user/order/seeker-orders'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': bearerToken,
      },
      body: jsonEncode(<String, String>{
        "seeker_id":
            DataControllers.to.userLoginResponse.value.data!.user!.id.toString()
      }),
    );
    if (response.statusCode == 200) {
      print("Api Response : ${response.body}");
      var jsonString = response.body;
      return errorResponseFromJson(jsonString);
    } else {
      DataControllers.to.userServiceResponse.value.success =
          json.decode(response.body)["success"];
      DataControllers.to.userServiceResponse.value.message =
          json.decode(response.body)["message"];
      return null;
    }
  }

  static Future<AppResponse?> getOrderServiceItem(String invoice_number) async {
    var response = await client.post(
      Uri.parse(BaseURL + 'user/order/get-order-service-items'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': bearerToken,
      },
      body: jsonEncode(<String, String>{"invoice_number": invoice_number}),
    );
    if (response.statusCode == 200) {
      print("Api Response : ${response.body}");
      // var jsonString = response.body;
      return AppResponse.fromJson(jsonDecode(response.body));
    } else {
      DataControllers.to.userServiceResponse.value.success =
          json.decode(response.body)["success"];
      DataControllers.to.userServiceResponse.value.message =
          json.decode(response.body)["message"];
      return AppResponse.fromJson(jsonDecode(response.body));
    }
  }

  static Future<ErrorResponse?> getOrderHistory() async {
    var response = await client.post(
      Uri.parse(BaseURL + 'user/order/get-order-status-history'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': bearerToken,
      },
      body: jsonEncode(<String, String>{
        "get-order-service-items":
            DataControllers.to.userLoginResponse.value.data!.user!.id.toString()
      }),
    );

    log("Api Response : ${response.statusCode.toString()}",
        name: "getOrderHistory");

    if (response.statusCode == 200) {
      log("Api Response : ${response.body}", name: "getOrderHistory");
      var jsonString = response.body;
      return errorResponseFromJson(jsonString);
    } else {
      DataControllers.to.userServiceResponse.value.success =
          json.decode(response.body)["success"];
      DataControllers.to.userServiceResponse.value.message =
          json.decode(response.body)["message"];
      return null;
    }
  }

  static Future<Map<String, dynamic>> getRequestItems(
      String requestNumber) async {
    var response = await client.post(
      Uri.parse(BaseURL + "user/request/get-request-items"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': bearerToken,
      },
      body: jsonEncode(<String, String>{
        "request_number": requestNumber,
      }),
    );

    log("Api Response : ${response.statusCode.toString()}",
        name: "getRequestItems");

    return jsonDecode(response.body);
  }

  static Future<ErrorResponse?> getSingleOrderHistory() async {
    var response = await client.post(
      Uri.parse(BaseURL + 'user/order/get-order-histories'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': bearerToken,
      },
      body: jsonEncode(<String, String>{
        "get-order-service-items":
            DataControllers.to.userLoginResponse.value.data!.user!.id.toString()
      }),
    );
    if (response.statusCode == 200) {
      print("Api Response : ${response.body}");
      var jsonString = response.body;
      return errorResponseFromJson(jsonString);
    } else {
      DataControllers.to.userServiceResponse.value.success =
          json.decode(response.body)["success"];
      DataControllers.to.userServiceResponse.value.message =
          json.decode(response.body)["message"];
      return null;
    }
  }

  static Future<ErrorResponse?> providerConfirmOrder() async {
    var response = await client.post(
      Uri.parse(BaseURL + 'user/order/confirm-order'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': bearerToken,
      },
      body: jsonEncode(<String, String>{
        "id":
            DataControllers.to.userLoginResponse.value.data!.user!.id.toString()
      }),
    );
    if (response.statusCode == 200) {
      print("Api Response : ${response.body}");
      var jsonString = response.body;
      return errorResponseFromJson(jsonString);
    } else {
      DataControllers.to.userServiceResponse.value.success =
          json.decode(response.body)["success"];
      DataControllers.to.userServiceResponse.value.message =
          json.decode(response.body)["message"];
      return null;
    }
  }

  static Future<void> changeOrderStatus(int orderid, int status) async {
    var response = await client.post(
      Uri.parse(BaseURL + 'user/order/change-order-status'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': bearerToken,
      },
      body: jsonEncode(<String, dynamic>{"id": orderid, "status": status}),
    );
    return;
  }

  static Future<ErrorResponse?> changeOrderStatusbySeeker() async {
    var response = await client.post(
      Uri.parse(BaseURL + 'user/order/change-order-status'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': bearerToken,
      },
      body: jsonEncode(<String, String>{
        "id": DataControllers.to.userLoginResponse.value.data!.user!.id
            .toString(),
        "status": "7"
      }),
    );
    if (response.statusCode == 200) {
      print("Api Response : ${response.body}");
      var jsonString = response.body;
      return errorResponseFromJson(jsonString);
    } else {
      DataControllers.to.userServiceResponse.value.success =
          json.decode(response.body)["success"];
      DataControllers.to.userServiceResponse.value.message =
          json.decode(response.body)["message"];
      return null;
    }
  }

  /// Service

  static Future<UserServiceResponse?> postUserServiceResponse(
      String user_id) async {
    var response = await client.post(
      Uri.parse(BaseURL + 'user/service/all'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': bearerToken,
      },
      body: jsonEncode(<String, String>{
        'user_id': user_id,
      }),
    );
    if (response.statusCode == 200) {
      var jsonString = response.body;
      return userServiceResponseFromJson(jsonString);
    } else {
      DataControllers.to.userServiceResponse.value.success =
          json.decode(response.body)["success"];
      DataControllers.to.userServiceResponse.value.message =
          json.decode(response.body)["message"];
      return DataControllers.to.userServiceResponse.value;
    }
  }

  static Future<ErrorResponse> addService(
      String user_id, String service_id) async {
    final response = await http.post(
      Uri.parse(BaseURL + 'user/service/add'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': bearerToken,
      },
      body: jsonEncode(<String, String>{
        'user_id': user_id,
        'service_id': service_id,
        'service_price': "200",
      }),
    );

    print(response.body);

    if (response.statusCode == 200) {
      return errorResponseFromJson(response.body);
    } else {
      DataControllers.to.addServiceResponse.value.success =
          json.decode(response.body)["success"];
      DataControllers.to.addServiceResponse.value.message =
          json.decode(response.body)["message"];
      return DataControllers.to.addServiceResponse.value;
    }
  }

  ///  Update or Edit
  static Future<ErrorResponse> editService(
      String user_id, String service_id) async {
    final response = await http.post(
      Uri.parse(BaseURL + 'user/service/edit'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': bearerToken,
      },
      body: jsonEncode(<String, String>{
        'user_id': user_id,
        'service_id': service_id,
        'service_price': "200",
      }),
    );

    print(response.body);

    if (response.statusCode == 200) {
      return errorResponseFromJson(response.body);
    } else {
      DataControllers.to.addServiceResponse.value.success =
          json.decode(response.body)["success"];
      DataControllers.to.addServiceResponse.value.message =
          json.decode(response.body)["message"];
      return DataControllers.to.addServiceResponse.value;
    }
  }

  /// Delete Section
  static Future<ErrorResponse> deleteService(String user_id, String id) async {
    final response = await http.post(
      Uri.parse(BaseURL + 'user/service/delete'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': bearerToken,
      },
      body: jsonEncode(<String, String>{
        'user_id': user_id,
        'id': id,
      }),
    );

    print(response.body);

    if (response.statusCode == 200) {
      return errorResponseFromJson(response.body);
    } else {
      DataControllers.to.addServiceResponse.value.success =
          json.decode(response.body)["success"];
      DataControllers.to.addServiceResponse.value.message =
          json.decode(response.body)["message"];
      //showToast("Please enter your valid user and password!!",Colors.red);
      //  return errorResponseFromJson(response.body);
      return DataControllers.to.addServiceResponse.value;
      throw Exception('add service');
    }
  }

  /// Service

  static Future<AvailableProviderResponseNew?> getAvailableProviderList(
      String status,
      String available,
      String longitude,
      String lattitude) async {
    var response = await client.get(
      Uri.parse(BaseURL +
          'user/providers-by-status?status=${status}&available=${available}&longitude=${longitude}&latitude=${lattitude}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': bearerToken,
      }, /*,
      body: jsonEncode(<String, String>{
        'status': status,
        'available': available,
      }),*/
    );
    log(response.request!.url.toString());
    log("token = \n $bearerToken \n status = $status \n available = $available \n latitude = $lattitude \n longitude = $longitude\n",
        name: "payload");
    print("Api Response -> Available Provider List : ${response.body}");

    if (response.statusCode == 200) {
      var jsonString = response.body;
      Map<String, dynamic> userMap = jsonDecode(jsonString);

      return AvailableProviderResponseNew.fromJson(userMap);
    } else {
      DataControllers.to.getAvailableProviderList.value.success =
          json.decode(response.body)["success"];
      DataControllers.to.getAvailableProviderList.value.message =
          json.decode(response.body)["message"];
      //showToast("Please enter your valid user and password!!",Colors.red);
      //  return errorResponseFromJson(response.body);
      return DataControllers.to.getAvailableProviderList.value;
    }
  }

  ///   Forget Password

  static Future<ErrorResponse?> forgetPassMobileValidation(
      String number, String signature) async {
    var response = await client.post(
      Uri.parse(BaseURL + 'forgot-password'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'phone': number,
        'signature_otp': signature,
      }),
    );

    print("Api Response : ${response.body}");

    if (response.statusCode == 200) {
      print("Api Response : ${response.body}");
      var jsonString = response.body;
      return errorResponseFromJson(jsonString);
    } else {
      DataControllers.to.forgetPassMobileOtpResponse.value.success =
          json.decode(response.body)["success"];
      DataControllers.to.forgetPassMobileOtpResponse.value.message =
          json.decode(response.body)["message"];
      //showToast("Please enter your valid user and password!!",Colors.red);
      //  return errorResponseFromJson(response.body);
      return DataControllers.to.forgetPassMobileOtpResponse.value;
    }
  }

  static Future<ErrorResponse?> forgetPassConfirm(
      String number, String otp, String newPass) async {
    var response = await client.post(
      Uri.parse(BaseURL + 'change-password-by-otp'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'phone': number,
        'otp': otp,
        'new_password': newPass,
      }),
    );

    print("Api Response : ${response}");

    if (response.statusCode == 200) {
      print("Api Response : ${response.body}");
      var jsonString = response.body;
      return errorResponseFromJson(jsonString);
    } else {
      DataControllers.to.forgetPassConfirm.value.success =
          json.decode(response.body)["success"];
      DataControllers.to.forgetPassConfirm.value.message =
          json.decode(response.body)["message"];
      //showToast("Please enter your valid user and password!!",Colors.red);
      //  return errorResponseFromJson(response.body);
      return DataControllers.to.forgetPassConfirm.value;
    }
  }

  static Future<ErrorResponse?> addFavAddress(String name, String age,
      String contact_no, String relationship, String gender) async {
    var response = await client.post(
      Uri.parse(BaseURL + 'user/loved-ones/add'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': bearerToken,
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'age': age,
        'contact_no': contact_no,
        'relationship': relationship,
        'gender': gender
      }),
    );

    print("Api Response  data : ${response}");

    if (response.statusCode == 200) {
      print("Api Response  data : ${response.body}");
      var jsonString = response.body;
      return errorResponseFromJson(jsonString);
    } else {
      DataControllers.to.forgetPassConfirm.value.success =
          json.decode(response.body)["success"];
      DataControllers.to.forgetPassConfirm.value.message =
          json.decode(response.body)["message"];
      //showToast("Please enter your valid user and password!!",Colors.red);
      //  return errorResponseFromJson(response.body);
      return DataControllers.to.forgetPassConfirm.value;
    }
  }

  static Future<ErrorResponse?> editFavAddress(String id, String name,
      String age, String contact_no, String gender, String relationship) async {
    var response = await client.post(
      Uri.parse(BaseURL + 'user/loved-ones/edit'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': bearerToken,
      },
      body: jsonEncode(<String, String>{
        'id': id,
        'name': name,
        'age': age,
        'contact_no': contact_no,
        'gender': gender,
        'relationship': relationship,
      }),
    );

    print("Api Response : ${response}");

    if (response.statusCode == 200) {
      print("Api Response : ${response.body}");
      var jsonString = response.body;
      return errorResponseFromJson(jsonString);
    } else {
      DataControllers.to.forgetPassConfirm.value.success =
          json.decode(response.body)["success"];
      DataControllers.to.forgetPassConfirm.value.message =
          json.decode(response.body)["message"];
      //showToast("Please enter your valid user and password!!",Colors.red);
      //  return errorResponseFromJson(response.body);
      return DataControllers.to.forgetPassConfirm.value;
    }
  }

  static getFavAddress() async {
    var response = await client.get(Uri.parse(BaseURL + 'user/loved-ones/all'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': bearerToken,
        });

    print("Api Response  fav-address : ${response.body}");

    if (response.statusCode == 200) {
      var jsonString = response.body;
      return lovedOnesResponseFromJson(jsonString);
    } else {
      DataControllers.to.getFavAddressResponse.value.success =
          json.decode(response.body)["success"];
      DataControllers.to.getFavAddressResponse.value.message =
          json.decode(response.body)["message"];
      return DataControllers.to.getFavAddressResponse.value;
    }
  }

  /// Delete Section
  static Future<ErrorResponse> deleteFavAddress(String id) async {
    final response = await http.post(
      Uri.parse(BaseURL + 'user/saved-address/delete'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': bearerToken,
      },
      body: jsonEncode(<String, String>{
        'id': id,
      }),
    );

    if (response.statusCode == 200) {
      return errorResponseFromJson(response.body);
    } else {
      DataControllers.to.addServiceResponse.value.success =
          json.decode(response.body)["success"];
      DataControllers.to.addServiceResponse.value.message =
          json.decode(response.body)["message"];
      return DataControllers.to.addServiceResponse.value;
    }
  }

  static Future<SliderResponse?> fetchSliderResponse() async {
    var response = await client
        .get(Uri.parse(BaseURL + 'app-sliders'), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': bearerToken,
    });
    if (response.statusCode == 200) {
      print("Api Response categories : ${response.body}");
      var jsonString = response.body;
      return sliderResponseFromJson(jsonString);
    } else {
      DataControllers.to.sliderResponse.value.success =
          json.decode(response.body)["success"];
      DataControllers.to.sliderResponse.value.message =
          json.decode(response.body)["message"];

      return DataControllers.to.sliderResponse.value;
    }
  }

  static Future<ErrorResponse?> editSaveAddress(
      String id,
      String phone,
      String beneficiary_name,
      String district,
      String city,
      String postcode,
      String lon,
      String lat) async {
    var response = await client.post(
      Uri.parse(BaseURL + 'user/saved-address/edit'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': bearerToken,
      },
      body: jsonEncode(<String, String>{
        'id': id,
        'phone': phone,
        'beneficiary_name': beneficiary_name,
        'district': district,
        'city': city,
        'postcode': postcode,
        'lon': lon,
        'lat': lat,
      }),
    );

    print("Api Response : ${response}");

    if (response.statusCode == 200) {
      print("Api Response : ${response.body}");
      var jsonString = response.body;
      return errorResponseFromJson(jsonString);
    } else {
      DataControllers.to.forgetPassConfirm.value.success =
          json.decode(response.body)["success"];
      DataControllers.to.forgetPassConfirm.value.message =
          json.decode(response.body)["message"];
      return DataControllers.to.forgetPassConfirm.value;
    }
  }

  static getSaveAddress() async {
    var response = await client.post(
        Uri.parse(BaseURL + 'user/saved-address/all'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': bearerToken,
        });

    print("Api Response  saved-address : ${response.body}");

    if (response.statusCode == 200) {
      // print("Api Response : ${response.body}");
      var jsonString = response.body;
      return saveAddressResponseFromJson(jsonString);
    } else {
      DataControllers.to.getFavAddressResponse.value.success =
          json.decode(response.body)["success"];
      DataControllers.to.getFavAddressResponse.value.message =
          json.decode(response.body)["message"];
      return DataControllers.to.getFavAddressResponse.value;
    }
  }

  /// Delete Section
  static Future<ErrorResponse> deleteSaveAddress(String id) async {
    final response = await http.post(
      Uri.parse(BaseURL + 'user/saved-address/delete'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': bearerToken,
      },
      body: jsonEncode(<String, String>{
        'id': id,
      }),
    );

    if (response.statusCode == 200) {
      return errorResponseFromJson(response.body);
    } else {
      DataControllers.to.addServiceResponse.value.success =
          json.decode(response.body)["success"];
      DataControllers.to.addServiceResponse.value.message =
          json.decode(response.body)["message"];
      //showToast("Please enter your valid user and password!!",Colors.red);
      //  return errorResponseFromJson(response.body);
      return DataControllers.to.addServiceResponse.value;
      throw Exception('add service');
    }
  }

  /// checkout-discount
  static Future<AppResponse> checkoutDiscount(
      String coupon, String amount) async {
    final response = await http.post(
      Uri.parse(BaseURL + 'discount/checkout-discount'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': bearerToken,
      },
      body:
          jsonEncode(<String, String>{'coupon_code': coupon, 'amount': amount}),
    );

    print("Api Response -->> Coupon : ${response.body}");

    if (response.statusCode == 200) {
      return AppResponse.fromJson(jsonDecode(response.body));
    } else {
      DataControllers.to.couponPrize.value.success =
          json.decode(response.body)["success"];
      DataControllers.to.couponPrize.value.message =
          json.decode(response.body)["message"];
      return AppResponse.fromJson(jsonDecode(response.body));
    }
  }


  static Future<Map<String, dynamic>> fetchRequestInformation(
      String request_number) async {
    var response = await client.post(
      Uri.parse(BaseURL + 'user/request/get-request-items'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': bearerToken,
      },
      body: jsonEncode(<String, String>{
        'request_number': request_number,
      }),
    );

    log(response.body, name: "fetchOrderInformation");
    return jsonDecode(response.body);
  }
}
