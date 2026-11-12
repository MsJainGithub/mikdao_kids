import 'dart:convert';

import 'package:flutter/cupertino.dart';

import 'package:get/get.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/appConfig.dart';
import '../screens/updateScreen.dart';
import '../services/apiServices.dart';

class UserProvider extends ChangeNotifier{

  UserProvider(){
    getUserData();
    getSignIn();
  }


  String userId = "";
  bool isLogin = false;


  setUserData(id)async{
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString("userId", id);
    userId = id;
    notifyListeners();
  }

  getUserData()async{
    final SharedPreferences sp = await SharedPreferences.getInstance();
    userId = sp.getString("userId")??"";
    notifyListeners();
  }

  setSignIn()async{
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool("isLogin", true);
    isLogin = true;
    notifyListeners();
  }

  getSignIn()async{
    final SharedPreferences sp = await SharedPreferences.getInstance();
    isLogin = sp.getBool("isLogin")??false;
    notifyListeners();
  }

  clearUserData()async{
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.clear();
    isLogin = false;
    userId = "";
    notifyListeners();
    Get.offAllNamed("/loginScreen");
  }
  //
  // Future checkVersion(BuildContext context)async{
  //   final _checker = AppVersionChecker();
  //   await ApiServices().postData(uri: deviceverfication, context: context,id: 1).then((response) {
  //     if(response!=null){
  //       _checker.checkUpdate().then((value) {
  //         if(json.decode(response.body)["data"]["version"].toString()!=value.currentVersion.toString()){
  //           Get.offAll(()=>UpdateScreen(url: json.decode(response.body)["data"]["apkpath"].toString(),));
  //         }else{
  //           isLogin==true?
  //           Get.offAllNamed('/profilePage'):
  //           Get.offAllNamed('/loginScreen');
  //         }
  //       });
  //     }
  //   });
  // }

}