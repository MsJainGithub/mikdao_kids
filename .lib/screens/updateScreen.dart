
import 'package:app_version_update/data/models/app_version_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/themeConfig.dart';
import '../services/apiServices.dart';

class UpdateScreen extends StatefulWidget {
  final AppVersionResult? appVersionResult;
  const UpdateScreen({Key? key, this.appVersionResult}) : super(key: key);


  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  @override
  Widget build(BuildContext context) {
    return  WillPopScope(
      onWillPop: ()async{
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Image.asset("assets/update.gif"),
              const Text(
                'A new version is available!',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 16.0,
              ),
              const Text(
                'Please update your application?',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 20.h,
              ),
              Flexible(
                child: MaterialButton(
                  minWidth: 140.0,
                  onPressed: () async => await launchUrl(
                      Uri.parse(widget.appVersionResult!.storeUrl!),
                      mode: LaunchMode.externalApplication),
                  color: maincolor,
                  child: const Text(
                    'Update',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
