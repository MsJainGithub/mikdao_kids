import 'package:flutter/cupertino.dart';
import 'package:mikado_kids/providers/profileProvider.dart';
import 'package:mikado_kids/providers/userProvider.dart';
import 'package:provider/provider.dart';
import '../config/appConfig.dart';
import '../modals/feeDetailModal.dart';
import '../modals/installMentModal.dart';
import '../modals/sessionModal.dart';
import '../services/apiServices.dart';

class FeeProvider extends ChangeNotifier{
  SessionModal? session;
  String currentSession = "";
  String currentSessionId = "";

  Future <void> getSession(BuildContext context)async{
    session = null;
    currentSession = "";
    notifyListeners();
    ApiServices().getData(getsession, context: context).then((value) {
      if(value!=null){
        session = sessionModalFromJson(value.body);
        if(session!=null){
          currentSession = session!.data!.firstWhere((element) => element.id == session!.currentSession.toString()).schoolYear.toString();
          currentSessionId = session!.currentSession.toString();

        }
        notifyListeners();
      }
    });
  }
  FeeDetailModal? feeDetail;
  getFeeDetail(BuildContext context){
    feeDetail = null;
    notifyListeners();
    UserProvider up = Provider.of<UserProvider>(context, listen: false);
    ApiServices()
        .postData(
        uri: getfeedata,
        data: {
          "id": up.userId.toString(),
          "session_id": session!.currentSession.toString()
        },
        context: context).then((value) {
      if(value!=null){
        feeDetail = feeDetailModalFromJson(value.body);
        notifyListeners();
      }
    });

  }

  DataInstalment? instalmentDetail;
  bool noInstalmentData = false;

  getInstalmentDetail(BuildContext context){
    instalmentDetail = null;
    noInstalmentData = false;
    notifyListeners();
    UserProvider up = Provider.of<UserProvider>(context, listen: false);
    ProfileProvider pp = Provider.of<ProfileProvider>(context, listen: false);
    ApiServices()
        .postData(
        uri: getInstalmentDetailUrl,
        data: {
          "login_id": up.userId.toString(),
          "session_id": session!.currentSession.toString(),
          if(pp.dataUser?.class_id !=null)
          "class_id":pp.dataUser?.class_id,
        },
        context: context).then((value) {
      if(value!=null){
        instalmentDetail = installmentModalFromJson(value.body).data;
        if(instalmentDetail==null){
          noInstalmentData = true;
        }
        notifyListeners();
      }else{
        noInstalmentData = true;
        notifyListeners();
      }
    });

  }





}