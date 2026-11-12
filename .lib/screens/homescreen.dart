
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mikado_kids/config/appConfig.dart';
import 'package:mikado_kids/providers/feeProvider.dart';
import 'package:mikado_kids/screens/feeInstallmentScreen.dart';
import 'package:mikado_kids/screens/passwordResetScreen.dart';
import 'package:mikado_kids/widgets/developeByWidget.dart';
import 'package:provider/provider.dart';
import 'package:mikado_kids/providers/profileProvider.dart';
import 'package:mikado_kids/screens/notificationScreen.dart';

import 'package:mikado_kids/screens/studentDetailScreen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/themeConfig.dart';
import '../generated/assets.dart';
import '../providers/servicesProvider.dart';
import '../providers/userProvider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const HomeTab(),
    const NotificationScreen(),
    const PasswordResetScreen(type: 0,),
  ];

  @override
  void initState() {
    getSessionData();
    super.initState();
  }

  getSessionData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().getProfileData(context);
      context.read<FeeProvider>().getSession(context);

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          selectedItemColor: maincolor,
          unselectedItemColor: Colors.grey.shade600,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 11.sp,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 10.sp,
            color:  Colors.grey.shade600,
          ),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          iconSize: 22.sp,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_rounded),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.lock_rounded),
              label: 'Password',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final ProfileProvider pp = context.watch<ProfileProvider>();
    final UserProvider up = context.watch<UserProvider>();

    return CustomScrollView(
      slivers: [
        // Simple App Bar
        SliverAppBar(
          expandedHeight: 60.h,
          floating: false,
          pinned: true,
          elevation: 0,
          backgroundColor: maincolor,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Dashboard",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text("User ID :- ${pp.dataUser?.admNo ?? ""}",style: TextStyle(
                fontSize: 15.sp
              ),),
            ],
          ),
          actions: [

            IconButton(
              onPressed: () {
                pp.showLogoutPopout();
              },
              icon: Icon(
                Icons.logout_rounded,
                color: Colors.white,
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
                _buildStudentInfoCard(pp, context),

                Gap(5.h),

                // Academic Services Section
                _buildAcademicServicesSection(context),


                // Footer
                DevelopByWidget(),

                Gap(30.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentInfoCard(ProfileProvider pp, BuildContext context) {
    final UserProvider up = context.watch<UserProvider>();
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25.r,
                backgroundColor: maincolor.withOpacity(0.1),
                child: Text(
                  pp.dataUser?.fname?.substring(0, 1) ?? "S",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: maincolor,
                  ),
                ),
              ),
              Gap(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${pp.dataUser?.fname ?? "Student"} ${pp.dataUser?.lname ?? ""}".trim().toUpperCase(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Gap(2.h),
                    Text(
                      "Enroll No: ${pp.dataUser?.admNo ?? "N/A"}",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gap(8.h),
          Divider(),
          Gap(8.h),
          _buildInfoRow("Grade", "${pp.dataUser?.dataClass ?? "N/A"} (${pp.dataUser?.section ?? "N/A"})"),
          Gap(6.h),
          // _buildInfoRow("Roll Number", pp.dataUser?.admNo ?? "N/A"),
          // Gap(6.h),
          // _buildInfoRow("Date of Birth", pp.dataUser?.dob ?? "N/A"),
          // Gap(6.h),
          // _buildInfoRow("Gender", pp.dataUser?.gender ?? "N/A"),
          // Gap(6.h),
          // _buildInfoRow("Contact", pp.dataUser?.fmo ?? "N/A"),
          // Gap(6.h),
          // _buildInfoRow("Email", pp.dataUser?.address ?? "N/A"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAcademicServicesSection(BuildContext context) {
    final sp = context.read<ServicesProvider>();
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   "Academic Services",
          //   style: TextStyle(
          //     fontSize: 16.sp,
          //     fontWeight: FontWeight.bold,
          //     color: Colors.black87,
          //   ),
          // ),
          // Gap(10),
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 8.h,
            crossAxisSpacing: 8.w,
            childAspectRatio: 0.9,
            padding: EdgeInsets.zero,
            children: [
              _buildServiceItem("Profile", Assets.assetsFamilymember, () => Get.to(() => const StudentDetailScreen())),
              _buildServiceItem("Fee Payment", "assets/fees.png", () => Get.to(()=>FeeInstallmentScreen())),
              _buildServiceItem("Monthly Planner", "assets/timetable.png", () {
                sp.getData(context, getMonthlyPlanner, "Monthly Planner");
              }),
              _buildServiceItem("Calendar", Assets.assetsCalendar, () {
                sp.getData(context, getCalender, "Calendar");
              }),
              _buildServiceItem("Marksheet", "assets/result.png", () {}),
              _buildServiceItem("Syllabus", "assets/syllabus.png", () {
                sp.getData(context, getSyllabus, "Syllabus");
              }),
             // _buildServiceItem("Results", "assets/performation.png", () {}),
              _buildServiceItem("Exam\nTimeTable", "assets/timetable.png", () {
                sp.getData(context, getTimeTable, "Exam TimeTable");
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(String title, String iconPath, VoidCallback onTap) {
    return Builder(
      builder: (BuildContext context) {
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.r),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  iconPath,
                  height: 28.h,
                  width: 28.w,
                ),
                Gap(4.h),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }








}
