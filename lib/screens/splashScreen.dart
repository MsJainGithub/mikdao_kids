import 'package:app_version_update/app_version_update.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'package:mikado_kids/screens/updateScreen.dart';
import 'package:mikado_kids/widgets/developeByWidget.dart';
import 'package:mikado_kids/providers/userProvider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> _afterSplash() async {
    final UserProvider up =
    Provider.of<UserProvider>(context, listen: false);

    await Future.delayed(
      const Duration(seconds: 4),
    );

    if (up.isLogin == true) {
      Get.offAllNamed('/homeScreen');
    } else {
      Get.offAllNamed('/loginScreen');
    }
  }

  @override
  void initState() {
    super.initState();
    _verifyVersion();
  }

  Future<void> _verifyVersion() async {
    try {
      await AppVersionUpdate.checkForUpdates(
        playStoreId: 'com.mikado_kids',
        country: 'in',
      ).then((data) async {
        if (data.canUpdate!) {
          await AppVersionUpdate.showPageUpdate(
            appVersionResult: data,
            context: context,
            mandatory: true,
            page: UpdateScreen(
              appVersionResult: data,
            ),
          );
        } else {
          _afterSplash();
        }
      });
    } catch (e) {
      _afterSplash();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,

      body: SizedBox(
        height: size.height,
        width: size.width,

        child: Stack(
          children: [
            // ==================================================
            // LOGO
            // ==================================================

            Center(
              child: Image.asset(
                "assets/loginlogo.png",
                height: 100,
              ),
            ),

            // ==================================================
            // DEVELOPED BY
            // ==================================================

            Positioned(
              left: 0,
              right: 0,
              bottom: 20,

              child: SafeArea(
                top: false,
                left: false,
                right: false,

                child: const DevelopByWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
