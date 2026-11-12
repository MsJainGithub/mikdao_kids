import 'dart:convert';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:provider/provider.dart';
import 'package:mikado_kids/providers/profileProvider.dart';
import 'package:mikado_kids/providers/userProvider.dart';
import 'package:mikado_kids/widgets/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/appConfig.dart';
import '../config/themeConfig.dart';
import '../generated/assets.dart';
import '../services/imagepicker.dart';
import '../widgets/CustomizeDatePicker.dart';
import '../widgets/dataWidget.dart';
import 'feeInstallmentScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  void initState() {
    getProfileData();
    super.initState();
  }

  getProfileData(){
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().getProfileData(context);
      context.read<ProfileProvider>().getPartBData(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final ProfileProvider pp = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Profile Header
          SliverAppBar(
            expandedHeight: 280.h,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: maincolor,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildProfileHeader(pp, size),
            ),
            actions: [
              Container(
                margin: EdgeInsets.only(right: 8.w),
                child: IconButton(
                  onPressed: () {
                    Get.toNamed('/passwordResetScreen', arguments: [0]);
                  },
                  icon: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.key_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 16.w),
                child: IconButton(
                  onPressed: () {
                    pp.showLogoutPopout();
                  },
                  icon: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.logout_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              child: Column(
                children: [
                  // Student Information Card
                  _buildStudentInfoCard(pp),

                  Gap(20.h),


                  // Academic Services Section
                  _buildAcademicServicesSection(),

                  Gap(20.h),

                  // Footer
                  _buildFooter(),

                  Gap(30.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(ProfileProvider pp, Size size) {
    return Container(
      width: size.width,

      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Gap(40.h),
            // Profile Avatar with Status Indicator
            Image.asset(
              "assets/loginlogo.jpeg",
              fit: BoxFit.cover,
            ),


            Gap(16.h),

            // Student Name with Welcome Text
            Column(
              children: [
                Text(
                  "Welcome Back!",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Gap(4.h),
                Text(
                  "${pp.dataUser?.fname ?? "Student"} ${pp.dataUser?.lname ?? ""}".trim().toUpperCase(),
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),

            Gap(12.h),

            // Class Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25.r),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                  Gap(8.w),
                  Text(
                    "Class ${pp.dataUser?.dataClass ?? ""} - Section ${pp.dataUser?.section ?? ""}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentInfoCard(ProfileProvider pp) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: maincolor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: maincolor,
                  size: 20.sp,
                ),
              ),
              Gap(12.w),
              Text(
                "Student Details",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),

          Gap(20.h),

          _buildDetailRow(
            icon: Icons.badge_rounded,
            label: "Admission Number",
            value: pp.dataUser?.admNo ?? "N/A",
            iconColor: Colors.blue,
          ),

          Gap(16.h),

          _buildDetailRow(
            icon: Icons.class_rounded,
            label: "Class",
            value: pp.dataUser?.dataClass ?? "N/A",
            iconColor: Colors.green,
          ),

          Gap(16.h),

          _buildDetailRow(
            icon: Icons.groups_rounded,
            label: "Section",
            value: pp.dataUser?.section ?? "N/A",
            iconColor: Colors.orange,
          ),
        ],
      ),
    );
  }



  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24.sp,
            ),
          ),
          Gap(8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          Gap(4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicServicesSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 16.h),
            child: Text(
              "Academic Services",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),

          GridView.count(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 0.8,
            children: [
              _buildServiceCard(
                title: "Part A",
                subtitle: "Assignments & Projects",
                icon: Icons.assignment_turned_in_rounded,
                color: const Color(0xFF6366F1),
                onTap: () {
                  // Navigate to Part A
                },
              ),
              _buildServiceCard(
                title: "Part B",
                subtitle: "Practical Work",
                icon: Icons.science_rounded,
                color: const Color(0xFF10B981),
                onTap: () {
                  // Navigate to Part B
                },
              ),
              _buildServiceCard(
                title: "Fee Payment",
                subtitle: "Installments & Bills",
                icon: Icons.payment_rounded,
                color: const Color(0xFFF59E0B),
                onTap: () {
                  Get.to(() => FeeInstallmentScreen());
                },
              ),
              _buildServiceCard(
                title: "Syllabus",
                subtitle: "Course Content",
                icon: Icons.menu_book_rounded,
                color: const Color(0xFF8B5CF6),
                onTap: () {
                  // Navigate to Syllabus
                },
              ),
              _buildServiceCard(
                title: "Timetable",
                subtitle: "Class Schedule",
                icon: Icons.schedule_rounded,
                color: const Color(0xFFEF4444),
                onTap: () {
                  // Navigate to Timetable
                },
              ),
              _buildServiceCard(
                title: "Results",
                subtitle: "Exam Reports",
                icon: Icons.grade_rounded,
                color: const Color(0xFF06B6D4),
                onTap: () {
                  // Navigate to Results
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    icon,
                    size: 32.sp,
                    color: color,
                  ),
                ),

                Gap(12.h),

                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),

                Gap(4.h),

                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 16.sp,
          ),
        ),
        Gap(16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Gap(2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.code_rounded,
            color: Colors.grey[500],
            size: 16.sp,
          ),
          Gap(8.w),
          GestureDetector(
            onTap: () {
              launchUrl(Uri.parse("https://dacnis.in/"));
            },
            child: Text(
              "Developed By Dacnis Tech Solution",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}