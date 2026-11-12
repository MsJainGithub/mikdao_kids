import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';


import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:provider/provider.dart';

import 'package:retry/retry.dart';


import '../config/appConfig.dart';
import '../providers/userProvider.dart';
import '../widgets/toast.dart';





class ApiServices {
  Future<http.Response?> getData(String uri,{String? tocken,required BuildContext context}) async {
    print(uri);
    try {
      http.Response response = await http.get(
          Uri.parse(uri),
          headers: {
            "Authorization": "Bearer "+"${tocken??""}",
          }
      );
      print(response.body);
      if (response.statusCode == 200&&json.decode(response.body)["status"]==1) {
        return response;
      } else if(response.statusCode == 202){
        Provider.of<UserProvider>(context,listen: false).clearUserData();
      }else{
        showToastE(message: json.decode(response.body)["message"]);
        return null;
      }
    } catch (e) {

      print("Error in getData ${uri} ${e.toString()}");

    }
  }


  Future<http.Response?> postData({required String uri, dynamic data,required BuildContext context,id,bool showToast = true}) async {
    print(uri);
    print(data);
    if(id==null)
      EasyLoading.show();
    try {
      http.Response response = await http.post(
        Uri.parse(uri),
        body: (data),
      );
      print(response.statusCode);
      log(response.body);
      if (response.statusCode == 200&&json.decode(response.body)["status"]==1) {
        EasyLoading.dismiss();
        return response;
      }else if(response.statusCode==202){
        Provider.of<UserProvider>(context,listen: false).clearUserData();
        EasyLoading.dismiss();
        return null;
      } else{
        if(showToast)
        showToastE(message: json.decode(response.body)["message"]);
        EasyLoading.dismiss();
        return null;
      }
    } catch (e) {
      EasyLoading.dismiss();
      print("Error in postData ${uri} ${e.toString()}");
      return null;
    }
  }








}



