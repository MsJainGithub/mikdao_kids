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
import 'package:mikado_kids/providers/userProvider.dart';
import 'package:mikado_kids/services/apiServices.dart';
import 'package:mikado_kids/widgets/toast.dart';

import '../widgets/developeByWidget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailClt = TextEditingController();
  final TextEditingController _passClt = TextEditingController();

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

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

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

    // ==========================================================
    // CHECK KEYBOARD
    // ==========================================================

    final bool keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: Colors.white,

      // ========================================================
      // IMPORTANT:
      // Scaffold keyboard resize enabled
      // ========================================================

      resizeToAvoidBottomInset: true,

      body: Stack(
        children: [
          // ======================================================
          // BACKGROUND + LOGIN CONTENT
          // ======================================================

          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      24.w,
                      keyboardOpen ? 10.h : 20.h,
                      24.w,
                      keyboardOpen ? 30.h : 100.h,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight -
                            (keyboardOpen ? 10.h : 20.h),
                      ),
                      child: Center(
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // ==================================================
                                // LOGO
                                // ==================================================

                                Hero(
                                  tag: 'logo',
                                  child: Container(
                                    padding: EdgeInsets.all(12.w),

                                    // decoration: BoxDecoration(
                                    //   color: Colors.white,
                                    //
                                    //   borderRadius:
                                    //   BorderRadius.circular(
                                    //       16.r),
                                    //
                                    //   boxShadow: [
                                    //     BoxShadow(
                                    //       color: Colors.black
                                    //           .withOpacity(.05),
                                    //       blurRadius: 15,
                                    //       offset:
                                    //       const Offset(0, 8),
                                    //     ),
                                    //   ],
                                    // ),

                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10.r),
                                      child: Image.asset(
                                        "assets/loginlogo.png",
                                        height: 90.h,
                                        width: 270.w,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),

                                Gap(
                                  keyboardOpen ? 15.h : 25.h,
                                ),

                                // ==================================================
                                // LOGIN CARD
                                // ==================================================

                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(.08),
                                        blurRadius: 30,
                                        offset: const Offset(0, 15),
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.all(20.w),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // ==========================================
                                      // HEADER
                                      // ==========================================

                                      Text(
                                        "Welcome Back",
                                        style: TextStyle(
                                          fontSize: 22.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                          letterSpacing: -.5,
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

                                      Gap(
                                        keyboardOpen ? 16.h : 24.h,
                                      ),

                                      // ==========================================
                                      // USERNAME
                                      // ==========================================

                                      _buildInputLabel(
                                        "Username",
                                      ),

                                      Gap(6.h),

                                      _buildTextField(
                                        controller: _emailClt,
                                        hintText: "Enter your username",
                                        prefixIcon:
                                            Icons.person_outline_rounded,
                                      ),

                                      Gap(16.h),

                                      // ==========================================
                                      // PASSWORD
                                      // ==========================================

                                      _buildInputLabel(
                                        "Password",
                                      ),

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

                                      // ==========================================
                                      // LOGIN BUTTON
                                      // ==========================================

                                      _buildLoginButton(
                                        size,
                                        up,
                                      ),
                                    ],
                                  ),
                                ),

                                // ==================================================
                                // BOTTOM SPACE
                                // ==================================================

                                SizedBox(
                                  height: keyboardOpen ? 20.h : 80.h,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ======================================================
          // DEVELOPED BY
          //
          // Keyboard open:
          // HIDE IT
          //
          // Keyboard closed:
          // SHOW IT
          // ======================================================

          if (!keyboardOpen)
            Positioned(
              left: 0,
              right: 0,
              bottom: 15,
              child: SafeArea(
                top: false,
                left: false,
                right: false,
                child: const DevelopByWidget(),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // INPUT LABEL
  // ============================================================

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
        letterSpacing: .2,
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

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
        color: const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFE5E9EC),
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

  // ============================================================
  // LOGIN BUTTON
  // ============================================================

  Widget _buildLoginButton(
    Size size,
    UserProvider up,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final PackageInfo packageInfo = await PackageInfo.fromPlatform();

          print(packageInfo.version);

          if (_emailClt.text.isEmpty) {
            showToastE(
              message: "Please enter username",
            );
          } else if (_passClt.text.isEmpty) {
            showToastE(
              message: "Please enter password",
            );
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
              context: context,
            )
                .then((value) {
              if (value != null) {
                showToastE(
                  message: json.decode(value.body)["message"],
                );

                up.setUserData(
                  json.decode(value.body)["data"]["user_id"],
                );

                up.setSignIn();

                Get.offAllNamed(
                  "/homeScreen",
                );
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
                redMainColor.withOpacity(.85),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: redMainColor.withOpacity(.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
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
                letterSpacing: .5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
