import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mikado_kids/screens/partAScreen.dart';
import 'package:mikado_kids/screens/partBScreen.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';

import '../config/themeConfig.dart';
import '../providers/profileProvider.dart';
import '../widgets/CustomizeDatePicker.dart';
import '../widgets/dataWidget.dart';

class StudentDetailScreen extends StatefulWidget {
  const StudentDetailScreen({Key? key}) : super(key: key);

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load profile data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ProfileProvider pp = Provider.of<ProfileProvider>(context, listen: false);
      pp.getProfileData(context);
      pp.getPartBData(context);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: maincolor,
        elevation: 0,
        title: Text(
          "Student Details",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          // if (_isEditing) ...[
          //   IconButton(
          //     icon: const Icon(Icons.close_rounded, color: Colors.white),
          //     tooltip: 'Cancel',
          //     onPressed: () {
          //       // Revert changes by reloading data and exit edit mode
          //       final pp = Provider.of<ProfileProvider>(context, listen: false);
          //       pp.getProfileData(context);
          //       pp.getPartBData(context);
          //       setState(() {
          //         _isEditing = false;
          //       });
          //     },
          //   ),
          //   IconButton(
          //     icon: const Icon(Icons.save_rounded, color: Colors.white),
          //     tooltip: 'Save',
          //     onPressed: () async {
          //       final pp = Provider.of<ProfileProvider>(context, listen: false);
          //       if (_tabController.index == 0) {
          //         pp.hangelSubmit(context);
          //       } else {
          //         pp.submitePartBData(context);
          //       }
          //       setState(() {
          //         _isEditing = false;
          //       });
          //     },
          //   ),
          // ] else ...[
          //   IconButton(
          //     icon: const Icon(Icons.edit_rounded, color: Colors.white),
          //     tooltip: 'Edit',
          //     onPressed: () {
          //       setState(() {
          //         _isEditing = true;
          //       });
          //     },
          //   ),
          // ]
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(70.h),
          child: Container(
            margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  colors: [maincolor, maincolor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: maincolor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Tab(
                  height: 48.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_ind_rounded, size: 20.sp),
                      SizedBox(width: 6.w),
                      const Text("Part A"),
                    ],
                  ),
                ),
                Tab(
                  height: 48.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fact_check_rounded, size: 20.sp),
                      SizedBox(width: 6.w),
                      const Text("Part B"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          PartAScreen(isEditable: _isEditing),
          PartBScreen(isEditable: _isEditing),
        ],
      ),
    );
  }
}