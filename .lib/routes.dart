import 'package:get/get.dart';
import 'package:mikado_kids/screens/notificationScreen.dart';
import 'package:mikado_kids/screens/passwordResetScreen.dart';
import 'package:mikado_kids/screens/pdfViewScreen.dart';
import 'package:mikado_kids/screens/splashScreen.dart';
import 'package:mikado_kids/screens/feeReceiptScreen.dart';
import 'package:mikado_kids/screens/feedetailScreen.dart';
import 'package:mikado_kids/screens/feesScreen.dart';
import 'package:mikado_kids/screens/homescreen.dart';
import 'package:mikado_kids/screens/loginScreen.dart';
import 'package:mikado_kids/screens/partAScreen.dart';
import 'package:mikado_kids/screens/partBScreen.dart';

final routes = [
  GetPage(
    name: '/splashScreen',
    page: () => SplashScreen(),
  ),
  GetPage(
    name: '/feesPage',
    page: () => FeesScreen(),
  ),
  GetPage(
    name: '/feesDetailPage',
    page: () => FeeDetailPage(),
  ),
  GetPage(
    name: '/feeReceiptPage',
    page: () => FeeReceitScreen(),
  ),
  GetPage(
    name: '/loginScreen',
    page: () => LoginScreen(),
  ),
  GetPage(
    name: '/homeScreen',
    page: () => HomeScreen(),
  ),
  GetPage(
    name: '/passwordResetScreen',
    page: () => PasswordResetScreen(),
  ),
  GetPage(
    name: '/notificationScreen',
    page: () => NotificationScreen(),
  ),

  GetPage(
    name: '/partAScreen',
    page: () => PartAScreen(isEditable: false),
  ),
  GetPage(
    name: '/partBScreen',
    page: () => PartBScreen(isEditable: false),
  ),
  GetPage(
    name: '/pdfViewerScreen',
    page: () => PdfViewerScreen(),
  ),
];