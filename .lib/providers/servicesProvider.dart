import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mikado_kids/providers/profileProvider.dart';
import 'package:provider/provider.dart';

import '../services/apiServices.dart';
import '../widgets/toast.dart';
import 'feeProvider.dart';

class ServicesProvider extends ChangeNotifier{

  String? pdfUrl;

  Future <void> getData(BuildContext context,url,title)async{
    final classId = Provider.of<ProfileProvider>(context,listen: false).dataUser?.class_id;
    final currentSessionId = Provider.of<FeeProvider>(context,listen: false).currentSessionId;
    final currentSession = Provider.of<FeeProvider>(context,listen: false).currentSession;
    pdfUrl = null;
    notifyListeners();
    ApiServices().postData(uri:url, context: context,data: {
      "session_id": currentSessionId,
      "class_id": classId??"",
    }).then((value) {
      if(value!=null){
        pdfUrl = json.decode(value.body)["data"]["doc_file"];
        if(pdfUrl!=null){
          Get.toNamed('/pdfViewerScreen', arguments: {
            "url": pdfUrl,
            "title":"${title}-${currentSession}"
          });
        }else{
          showToastE(message:json.decode(value.body)["message"] );
        }

        notifyListeners();
      }
    });
  }

}