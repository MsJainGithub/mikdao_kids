import 'package:flutter/cupertino.dart';
import 'package:mikado_kids/modals/notificationModal.dart';
import 'package:mikado_kids/providers/feeProvider.dart';
import 'package:mikado_kids/providers/profileProvider.dart';
import 'package:mikado_kids/providers/userProvider.dart';
import 'package:provider/provider.dart';

import '../config/appConfig.dart';
import '../services/apiServices.dart';

class NotificationProvider extends ChangeNotifier{
  List<DatumNotificaltion>  notificationList=[];
  bool noNotification = false;


  getNotification(BuildContext context){
    notificationList.clear();
    noNotification = false;
    notifyListeners();
    UserProvider up = Provider.of<UserProvider>(context, listen: false);
    ProfileProvider pp = Provider.of<ProfileProvider>(context, listen: false);
    FeeProvider fp = Provider.of<FeeProvider>(context, listen: false);
    ApiServices()
        .postData(
        uri: notificationUrl,
        data: {
          "login_id": up.userId.toString(),
          "session_id": fp.currentSessionId.toString(),
          "class_id":pp.dataUser?.class_id,
        },
        context: context).then((value) {
      if(value!=null){
        notificationList.addAll(notificationModalFromJson(value.body).data??[]);
        noNotification = notificationList.isEmpty;
        notifyListeners();
      }else{
        noNotification = true;
        notifyListeners();
      }
    });

  }


}