import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:mikado_kids/config/appConfig.dart';
import 'package:mikado_kids/config/themeConfig.dart';
import 'package:mikado_kids/generated/assets.dart';
import 'package:mikado_kids/providers/userProvider.dart';
import 'package:mikado_kids/services/apiServices.dart';
import 'package:mikado_kids/widgets/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/developeByWidget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  TextEditingController _emailClt = TextEditingController();
  TextEditingController _passClt = TextEditingController();
  bool showpassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailClt.dispose();
    _passClt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final UserProvider up = context.watch<UserProvider>();

    return Scaffold(
      bottomSheet: DevelopByWidget(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Color(0xFFF5F7FA),
              Color(0xFFE8EEF2),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Section
                      Hero(
                        tag: 'logo',
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 15,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.r),
                            child: Image.asset(
                              "assets/loginlogo.png",
                              height: 60.h,
                              width: 160.w,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      Gap(25.h),

                      // Login Card
                      Container(
                        width: size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 30,
                              offset: Offset(0, 15),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Text(
                              "Welcome Back",
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Gap(6.h),
                            Text(
                              "Please login to continue to your account",
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey.shade600,
                                height: 1.4,
                              ),
                            ),
                            Gap(24.h),

                            // Username Field
                            _buildInputLabel("Username"),
                            Gap(6.h),
                            _buildTextField(
                              controller: _emailClt,
                              hintText: "Enter your username",
                              prefixIcon: Icons.person_outline_rounded,
                            ),
                            Gap(16.h),

                            // Password Field
                            _buildInputLabel("Password"),
                            Gap(6.h),
                            _buildTextField(
                              controller: _passClt,
                              hintText: "Enter your password",
                              prefixIcon: Icons.lock_outline_rounded,
                              isPassword: true,
                              obscureText: showpassword,
                              onTogglePassword: () {
                                setState(() {
                                  showpassword = !showpassword;
                                });
                              },
                            ),
                            Gap(24.h),

                            // Login Button
                            _buildLoginButton(size, up),
                          ],
                        ),
                      ),
                      Gap(80.h), // Space for bottom sheet
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onTogglePassword,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Color(0xFFE5E9EC),
          width: 1.5,
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? obscureText : false,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: Colors.grey.shade500,
            size: 20.sp,
          ),
          suffixIcon: isPassword
              ? GestureDetector(
            onTap: onTogglePassword,
            child: Icon(
              obscureText
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.grey.shade500,
              size: 20.sp,
            ),
          )
              : null,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 14.h,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildLoginButton(Size size, UserProvider up) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          PackageInfo packageInfo = await PackageInfo.fromPlatform();
          print(packageInfo.version.toString());

          if (_emailClt.text.isEmpty) {
            showToastE(message: "Please enter username");
          } else if (_passClt.text.isEmpty) {
            showToastE(message: "Please enter password");
          } else {
            EasyLoading.show();
            ApiServices()
                .postData(
                uri: login,
                data: loginBody(
                  email: _emailClt.text,
                  password: _passClt.text,
                  version: packageInfo.version.toString(),
                ),
                context: context)
                .then((value) {
              if (value != null) {
                showToastE(message: json.decode(value.body)["message"]);
                up.setUserData(json.decode(value.body)["data"]["user_id"]);
                up.setSignIn();
                Get.offAllNamed("/homeScreen");
              }
            });
          }
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Ink(
          height: 54.h,
          width: size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            gradient: LinearGradient(
              colors: [
                redMainColor,
                redMainColor.withOpacity(0.85),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: redMainColor.withOpacity(0.3),
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              "Login",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}