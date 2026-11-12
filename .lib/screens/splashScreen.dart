import 'package:app_version_update/app_version_update.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:mikado_kids/screens/updateScreen.dart';
import 'package:mikado_kids/widgets/developeByWidget.dart';
import 'package:provider/provider.dart';
import 'package:mikado_kids/generated/assets.dart';
import 'package:mikado_kids/providers/userProvider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/themeConfig.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {



  _afterSplash() async {
    UserProvider up = Provider.of<UserProvider>(context,listen: false);
    await Future.delayed(Duration(seconds: 3));
    if (up.isLogin == true) {
      Get.offAllNamed('/homeScreen');
    } else {
      Get.offAllNamed('/loginScreen');
    }
  }
  @override
  void initState() {
    _verifyVersion();
    super.initState();
  }
  _verifyVersion()async{
    try{
      await AppVersionUpdate.checkForUpdates(
          playStoreId: 'com.mikado_kids',
          country: 'in').then((data) async {
        if (data.canUpdate!) {
          await AppVersionUpdate.showPageUpdate(
              appVersionResult: data,
              context: context,
              mandatory: true,
              page: UpdateScreen(appVersionResult: data,)

          );
        } else {
          _afterSplash();

        }
      });

    }catch (e){
      _afterSplash();
    }
  }
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      bottomSheet:DevelopByWidget(),
      body: Container(
        height: size.height,
        width: size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Image.asset("assets/loginlogo.png",height: 100,),

          ],
        ),
      ),
    );
  }
}
