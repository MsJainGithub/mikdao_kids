import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';

showToastE({message}){
  Fluttertoast.showToast(msg: message,gravity: ToastGravity.CENTER);
}