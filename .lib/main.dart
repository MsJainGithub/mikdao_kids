import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:mikado_kids/providers/feeProvider.dart';
import 'package:mikado_kids/providers/notificationProvider.dart';
import 'package:mikado_kids/providers/servicesProvider.dart';
import 'package:provider/provider.dart';
import 'package:mikado_kids/config/themeConfig.dart';
import 'package:mikado_kids/providers/profileProvider.dart';
import 'package:mikado_kids/providers/userProvider.dart';
import 'package:mikado_kids/routes.dart';
import 'package:mikado_kids/screens/homescreen.dart';
import 'package:mikado_kids/screens/splashScreen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return  MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(create: (context) => UserProvider()),
        ChangeNotifierProvider<FeeProvider>(create: (context) => FeeProvider()),
        ChangeNotifierProvider<NotificationProvider>(create: (context) => NotificationProvider()),
        ChangeNotifierProvider<ServicesProvider>(create: (context) => ServicesProvider()),
        ChangeNotifierProvider<ProfileProvider>(create: (context) => ProfileProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child){
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            builder: (context, widget) {
              // Fix text scale factor
              Widget easyLoadingWidget = EasyLoading.init()(context, widget);
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: 1.0, // Force text scale factor to 1.0
                ),
                child: easyLoadingWidget,
              );
            },
            theme: ThemeData(
                bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.white),
                scaffoldBackgroundColor: Colors.white,
                useMaterial3: false,
                fontFamily: "Poppins",
                appBarTheme: AppBarTheme(
                    backgroundColor: maincolor,
                    elevation: 0
                )
            ),
            getPages: routes,
            initialRoute: '/splashScreen',
          );
        },
      ),
    );
  }
}