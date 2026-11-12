import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mikado_kids/providers/profileProvider.dart';
import 'package:mikado_kids/screens/profileScreen.dart';
import 'package:mikado_kids/widgets/toast.dart';
import 'package:provider/provider.dart';

import '../config/themeConfig.dart';
import '../widgets/dataWidget.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key, this.type});
  final int? type;

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  bool _isObscureOldPassword = true;
  bool _isObscureNewPassword = true;
  bool _isObscureConfirmPassword = true;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: maincolor,
        title: Text(
          "Change Password",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Security icon
                Center(
                  child: Container(
                    width: 100.w,
                    height: 100.h,
                    decoration: BoxDecoration(
                      color: maincolor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.security,
                      size: 50.sp,
                      color: maincolor,
                    ),
                  ),
                ),

                Gap(24.h),

                // Title and description
                Center(
                  child: Text(
                    'Change Your Password',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),



                Gap(32.h),

                // Old password field (conditional)
                if (widget.type!=null && widget.type!=1) ...[
                  Text(
                    'Old Password',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),

                  Gap(8.h),

                  TextFormField(
                    controller: provider.oldpasswordClt,
                    obscureText: _isObscureOldPassword,
                    decoration: InputDecoration(
                      hintText: 'Enter your old password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: maincolor),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscureOldPassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscureOldPassword = !_isObscureOldPassword;
                          });
                        },
                      ),
                    ),
                  ),

                  Gap(20.h),
                ],

                // New password field
                Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),

                Gap(8.h),

                TextFormField(
                  controller: provider.newpasswordClt,
                  obscureText: _isObscureNewPassword,
                  decoration: InputDecoration(
                    hintText: 'Enter your new password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: maincolor),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscureNewPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscureNewPassword = !_isObscureNewPassword;
                        });
                      },
                    ),
                  ),
                ),

                Gap(20.h),

                // Confirm password field
                Text(
                  'Confirm Password',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),

                Gap(8.h),

                TextFormField(
                  controller: provider.conformpasswordClt,
                  obscureText: _isObscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'Confirm your new password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: maincolor),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscureConfirmPassword = !_isObscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),

                Gap(32.h),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () {
                      if (provider.newpasswordClt.text.isEmpty) {
                        showToastE(message: "Please enter password");
                      } else if (provider.conformpasswordClt.text.isEmpty) {
                        showToastE(message: "Please enter conform password");
                      } else if (provider.conformpasswordClt.text != provider.newpasswordClt.text) {
                        showToastE(message: "Please enter correct password");
                      } else if (widget.type!=null && widget.type!=1 && provider.oldpasswordClt.text.isEmpty) {
                        showToastE(message: "Please enter old password");
                      } else {
                        provider.changePassword(
                            context,
                            provider.newpasswordClt.text,
                            widget.type!=null && widget.type!=1 ? provider.oldpasswordClt.text : null
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: maincolor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Change Password',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}