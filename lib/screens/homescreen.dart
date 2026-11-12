import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../config/appConfig.dart';
import '../config/themeConfig.dart';
import '../providers/feeProvider.dart';
import '../providers/profileProvider.dart';
import '../providers/servicesProvider.dart';
import '../screens/academicModuleScreen.dart';
import '../screens/feeInstallmentScreen.dart';
import '../screens/notificationScreen.dart';
import '../screens/passwordResetScreen.dart';
import '../screens/studentDetailScreen.dart';
import '../widgets/developeByWidget.dart';
import 'classWorkScreen.dart';
import 'earlyDepartureScreen.dart';
import '../providers/feeProvider.dart';
import 'pdfViewScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    const HomeTab(),
    const NotificationScreen(),
    const PasswordResetScreen(type: 0),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<ProfileProvider>().getProfileData(context);
      context.read<FeeProvider>().getSession(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      extendBody: true,

      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      bottomNavigationBar: _FloatingBottomNavigation(
        currentIndex: _currentIndex,
        onChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

// ============================================================
// BOTTOM NAVIGATION
// ============================================================

class _BottomNavItem {
  final IconData icon;
  final String label;

  const _BottomNavItem({
    required this.icon,
    required this.label,
  });
}

class _FloatingBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const _FloatingBottomNavigation({
    required this.currentIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      _BottomNavItem(
        icon: Icons.home_rounded,
        label: 'Home',
      ),
      _BottomNavItem(
        icon: Icons.notifications_rounded,
        label: 'Alerts',
      ),
      _BottomNavItem(
        icon: Icons.lock_rounded,
        label: 'Password',
      ),
    ];

    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: 58.h,
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32.r),
                border: Border.all(
                  color: const Color(0xFFE7E7E7),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.16),
                    blurRadius: 22,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  items.length,
                      (index) {
                    final item = items[index];
                    final selected = currentIndex == index;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => onChanged(index),
                        borderRadius: BorderRadius.circular(27.r),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          padding: EdgeInsets.symmetric(
                            horizontal: selected ? 15.w : 13.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: selected
                                ? const LinearGradient(
                              colors: [
                                Color(0xFFB50000),
                                Color(0xFFFF3B3B),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                                : null,
                            borderRadius: BorderRadius.circular(27.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item.icon,
                                size: 20.sp,
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFF777777),
                              ),
                              if (selected) ...[
                                SizedBox(width: 6.w),
                                Text(
                                  item.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.5.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// HOME TAB
// ============================================================

class HomeTab extends StatelessWidget {
  const HomeTab({Key? key}) : super(key: key);

  Future<void> _refresh(BuildContext context) async {
    final profileProvider = context.read<ProfileProvider>();
    final feeProvider = context.read<FeeProvider>();

    profileProvider.getProfileData(context);
    feeProvider.getSession(context);

    await Future.delayed(
      const Duration(milliseconds: 600),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pp = context.watch<ProfileProvider>();
    final user = pp.dataUser;

    final fullName =
    '${user?.fname ?? 'Student'} ${user?.lname ?? ''}'.trim();

    return SafeArea(
      top: true,
      bottom: false,
      left: true,
      right: true,
      child: RefreshIndicator(
        color: maincolor,
        backgroundColor: Colors.white,
        notificationPredicate: (notification) {
          return notification.depth == 0;
        },
        onRefresh: () => _refresh(context),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // ==================================================
            // HEADER
            // ==================================================

            SliverToBoxAdapter(
              child: _DashboardHeader(
                name: fullName,
                userId: user?.admNo?.toString() ?? '',
                onLogout: pp.showLogoutPopout,
              ),
            ),

            // ==================================================
            // STUDENT CARD
            // ==================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16.w,
                  16.h,
                  16.w,
                  0,
                ),
                child: _StudentMiniCard(
                  pp: pp,
                ),
              ),
            ),

            // ==================================================
            // QUICK ACCESS
            // ==================================================

            _categoriesSection(),

            // ==================================================
            // DEVELOPED BY
            // ==================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 18.h,
                  bottom: 100.h,
                ),
                child: const DevelopByWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // QUICK ACCESS SECTION
  // ==========================================================

  SliverToBoxAdapter _categoriesSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          18.w,
          20.h,
          18.w,
          4.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // SECTION TITLE
            // ==================================================

            Row(
              children: [
                Container(
                  width: 34.w,
                  height: 34.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6048D5).withOpacity(.10),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.apps_rounded,
                    color: const Color(0xFF6048D5),
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 9.w),
                Text(
                  'Quick Access',
                  style: TextStyle(
                    color: const Color(0xFF202020),
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // ==================================================
            // 3 COLUMN GRID
            // ==================================================

            LayoutBuilder(
              builder: (context, constraints) {
                const double gap = 10;
                const int columns = 3;

                final double cardWidth =
                    (constraints.maxWidth -
                        (gap * (columns - 1))) /
                        columns;

                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: _modules.map((item) {
                    return SizedBox(
                      width: cardWidth,
                      height: 95.h,
                      child: _categoryCard(
                        context,
                        item,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // CATEGORY CARD
  // ==========================================================

  Widget _categoryCard(
      BuildContext context,
      _ModuleItem item,
      ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => item.action(context),
        borderRadius: BorderRadius.circular(18.r),

        child: Ink(
          decoration: BoxDecoration(
            // ==================================================
            // MAIN CARD - LIGHT COLORED
            // ==================================================

            gradient: LinearGradient(
              colors: item.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),

            borderRadius: BorderRadius.circular(18.r),

            boxShadow: [
              BoxShadow(
                color: item.gradient.first.withOpacity(.22),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),

          child: Stack(
            children: [
              // ==================================================
              // BACKGROUND DECORATION
              // ==================================================

              Positioned(
                right: -22.w,
                top: -22.h,
                child: Container(
                  width: 75.w,
                  height: 75.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.22),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              Positioned(
                left: -25.w,
                bottom: -28.h,
                child: Container(
                  width: 70.w,
                  height: 70.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.12),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // ==================================================
              // CARD CONTENT
              // ==================================================

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 3.w,
                  vertical: 4.h,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [
                    // ==================================================
                    // 3D PNG ICON
                    // ==================================================

                    Container(
                      width: 60.w,
                      height: 60.w,

                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.22),
                        borderRadius: BorderRadius.circular(15.r),

                        border: Border.all(
                          color: Colors.white.withOpacity(.28),
                          width: 1,
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.06),
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),

                      child: Padding(
                        padding: EdgeInsets.all(2.w),

                        child: Image.asset(
                          item.image,
                          fit: BoxFit.contain,

                          errorBuilder: (
                              context,
                              error,
                              stackTrace,
                              ) {
                            return Icon(
                              Icons.image_not_supported_rounded,
                              color: Colors.white,
                              size: 24.sp,
                            );
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: 8.h),

                    // ==================================================
                    // TITLE
                    // ==================================================

                    Expanded(
                      child: Center(
                        child: Text(
                          item.title,

                          textAlign: TextAlign.center,

                          softWrap: true,

                          maxLines: 3,

                          overflow: TextOverflow.ellipsis,

                          style: TextStyle(
                            color: const Color(0xFF252525),
                            fontSize: 10.5.sp,
                            height: 1.18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

// ============================================================
// HEADER
// ============================================================

class _DashboardHeader extends StatelessWidget {
  final String name;
  final String userId;
  final VoidCallback onLogout;

  const _DashboardHeader({
    required this.name,
    required this.userId,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFB50000),
            Color(0xFFE31A1A),
            Color(0xFFFF3B3B),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(38),
          bottomRight: Radius.circular(38),
        ),
      ),
      child: Padding(
        // padding: EdgeInsets.fromLTRB(
        //   18.w,
        //   15.h,
        //   16.w,
        //   22.h,
        // ),
        padding: const EdgeInsets.fromLTRB(
          16,
          12,
          16,
          20,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 52.w,
              height: 52.w,
              // decoration: BoxDecoration(
              //   color: Colors.white.withOpacity(.17),
              //   borderRadius: BorderRadius.circular(17.r),
              //   border: Border.all(
              //     color: Colors.white.withOpacity(.20),
              //   ),
              // ),
              child: Center(
                child: Image.asset(
                  'assets/mikado_icon.png',
                  width: 58.w,
                  height: 58.w,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            SizedBox(width: 11.w),

            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(.82),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: 2.h),

                  Text(
                    name.isEmpty ? 'Student' : name.toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17.sp,
                      height: 1.12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  if (userId.isNotEmpty) ...[
                    SizedBox(height: 3.h),
                    Text(
                      'Register No. $userId',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(.86),
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(width: 7.w),

            SizedBox(
              width: 42.w,
              height: 42.w,
              child: IconButton(
                onPressed: onLogout,
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(.16),
                  foregroundColor: Colors.white,
                ),
                icon: Icon(
                  Icons.logout_rounded,
                  size: 20.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// STUDENT CARD
// ============================================================

class _StudentMiniCard extends StatelessWidget {
  final ProfileProvider pp;

  const _StudentMiniCard({
    required this.pp,
  });

  @override
  Widget build(BuildContext context) {
    final u = pp.dataUser;

    // FeeProvider se current session lo
    final feeProvider = context.watch<FeeProvider>();

    final className =
    (u?.dataClass?.toString().trim().isNotEmpty ?? false)
        ? u!.dataClass.toString()
        : '—';

    final section =
    (u?.section?.toString().trim().isNotEmpty ?? false)
        ? u!.section.toString()
        : '—';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14.w,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19.r),
        border: Border.all(
          color: const Color(0xFFEAEAEA),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.045),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: maincolor.withOpacity(.09),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_rounded,
              color: maincolor,
              size: 25.sp,
            ),
          ),

          SizedBox(width: 11.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [

                Text(
                  'Grade : $className  •  $section',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF222222),
                  ),
                ),

                // CURRENT SESSION
                if (feeProvider.currentSession.isNotEmpty) ...[
                  SizedBox(height: 4.h),

                  Text(
                    'Session: ${feeProvider.currentSession}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(width: 8.w),

          Icon(
            Icons.verified_rounded,
            color: maincolor,
            size: 22.sp,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MODULE MODEL
// ============================================================

class _ModuleItem {
  final String title;
  final String image;
  final List<Color> gradient;
  final void Function(BuildContext) action;

  const _ModuleItem(
      this.title,
      this.image,
      this.gradient,
      this.action,
      );
}

// ============================================================
// MODULES
// ============================================================

final List<_ModuleItem> _modules = [
  // ==========================================================
  // PROFILE
  // ==========================================================

  _ModuleItem(
    'Profile',
    'assets/icons/profile.png',
    const [
      Color(0xFFFFE1E1),
      Color(0xFFFFBABA),
    ],
        (c) {
      Get.to(
            () => const StudentDetailScreen(),
      );
    },
  ),

  // ==========================================================
  // FEE PAYMENT
  // ==========================================================

  _ModuleItem(
    'Fee Payment',
    'assets/icons/fees.png',
    const [
      Color(0xFFE8E8E8),
      Color(0xFFD0D0D0),
    ],
        (c) {
      Get.to(
            () => const FeeInstallmentScreen(),
      );
    },
  ),

  // ==========================================================
  // STUDENT RULES
  // ==========================================================

  _ModuleItem(
    'Student Rules & Regulations',
    'assets/icons/policy.png',
    const [
      Color(0xFFE8DFFF),
      Color(0xFFD5C2FF),
    ],
        (c) {
      Get.to(
            () => const PdfViewerScreen(),
        arguments: {
          'url': 'https://portal.mikadoeducation.com/Students_parents_Guidelines.pdf',
          'title': 'Student Rules & Regulations',
        },
      );
    },
  ),

  // ==========================================================
  // MONTHLY PLANNER
  // ==========================================================

  _ModuleItem(
    'Monthly Planner',
    'assets/icons/planner.png',
    const [
      Color(0xFFD9F5F0),
      Color(0xFFB8E8DF),
    ],
        (c) {
      c.read<ServicesProvider>().getData(
        c,
        getMonthlyPlanner,
        'Monthly Planner',
      );
    },
  ),

  // ==========================================================
  // DAILY TIME TABLE
  // ==========================================================
  //
  // _ModuleItem(
  //   'Daily Time Table',
  //   'assets/icons/timetable.png',
  //   const [
  //     Color(0xFFDCEEFF),
  //     Color(0xFFBBD9FA),
  //   ],
  //       (c) {
  //     Get.to(
  //           () => const AcademicModuleScreen(
  //         title: 'Daily Time Table',
  //         icon: Icons.schedule_rounded,
  //         description:
  //         'Your day-wise class timetable will be displayed here when the school publishes it.',
  //       ),
  //     );
  //   },
  // ),

  // ==========================================================
// DAILY TIME TABLE
// ==========================================================

  // ==========================================================
// DAILY TIME TABLE
// ==========================================================

  _ModuleItem(
    'Daily Time Table',
    'assets/icons/timetable.png',
    const [
      Color(0xFFDCEEFF),
      Color(0xFFBBD9FA),
    ],
        (c) {
      c.read<ServicesProvider>().getData(
        c,
        getDailyTimeTable,
        'Daily Time Table',
      );
    },
  ),
  // ==========================================================
  // CLASS WORK
  // ==========================================================

  _ModuleItem(
    'Class Work',
    'assets/icons/academics.png',
    const [
      Color(0xFFEADFD9),
      Color(0xFFD7C5BB),
    ],
    //     (c) {
    //   Get.to(
    //         () => const AcademicModuleScreen(
    //       title: 'Class Work',
    //       icon: Icons.menu_book_rounded,
    //       description:
    //       'Class work and subject-wise learning material will be displayed here.',
    //     ),
    //   );
    // },
        (c) {
      Navigator.push(
        c,
        MaterialPageRoute(
          builder: (_) => const ClassWorkScreen(
            subjectListApi: getClassWorkSubjects,
            classWorkDetailsApi: getClassWorkDetails,
          ),
        ),
      );
    },
  ),

  // ==========================================================
  // EXAM TIME TABLE
  // ==========================================================

  _ModuleItem(
    'Exam Time Table',
    'assets/icons/exam.png',
    const [
      Color(0xFFE0E4FF),
      Color(0xFFC8CEFA),
    ],
        (c) {
      c.read<ServicesProvider>().getData(
        c,
        getTimeTable,
        'Exam Time Table',
      );
    },
  ),

  // ==========================================================
  // EXAM SYLLABUS
  // ==========================================================

  _ModuleItem(
    'Exam Syllabus',
    'assets/icons/pdf.png',
    const [
      Color(0xFFD8F5F7),
      Color(0xFFB8E8EC),
    ],
        (c) {
      c.read<ServicesProvider>().getData(
        c,
        getSyllabus,
        'Exam Syllabus',
      );
    },
  ),

  // ==========================================================
  // YEARLY CALENDAR
  // ==========================================================

  _ModuleItem(
    'Yearly Calendar',
    'assets/icons/category.png',
    const [
      Color(0xFFDDF3DE),
      Color(0xFFBFE5C1),
    ],
        (c) {
      c.read<ServicesProvider>().getData(
        c,
        getCalender,
        'Yearly Calendar',
      );
    },
  ),

  // ==========================================================
  // EARLY DEPARTURE
  // ==========================================================

  _ModuleItem(
    'Early Departure',
    'assets/icons/leave.png',
    const [
      Color(0xFFE5DCFA),
      Color(0xFFD0C0F0),
    ],
        (c) {
      Get.to(
            () => const EarlyDepartureScreen(),
      );
    },
  ),
  // ==========================================================
  // ATTENDANCE
  // ==========================================================

  // _ModuleItem(
  //   'Attendance',
  //   'assets/icons/attendance.png',
  //   const [
  //     Color(0xFFFFE8D2),
  //     Color(0xFFFFD0A0),
  //   ],
  //       (c) {
  //     Get.to(
  //           () => const AcademicModuleScreen(
  //         title: 'Attendance',
  //         icon: Icons.fact_check_outlined,
  //         description:
  //         'Attendance details will be shown here as soon as the school publishes the attendance record.',
  //       ),
  //     );
  //   },
  // ),

  // ==========================================================
  // PROGRESS REPORT
  // ==========================================================

  // _ModuleItem(
  //   'Progress Report Card',
  //   'assets/icons/pdf.png',
  //   const [
  //     Color(0xFFF9DCE8),
  //     Color(0xFFF2BBD0),
  //   ],
  //       (c) {
  //     Get.to(
  //           () => const AcademicModuleScreen(
  //         title: 'Progress Report Card',
  //         icon: Icons.trending_up_rounded,
  //         description:
  //         'Academic progress and subject-wise performance will be displayed here.',
  //       ),
  //     );
  //   },
  // ),

];

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:provider/provider.dart';
//
// import '../config/appConfig.dart';
// import '../config/themeConfig.dart';
// import '../providers/feeProvider.dart';
// import '../providers/profileProvider.dart';
// import '../providers/servicesProvider.dart';
// import '../screens/academicModuleScreen.dart';
// import '../screens/feeInstallmentScreen.dart';
// import '../screens/notificationScreen.dart';
// import '../screens/passwordResetScreen.dart';
// import '../screens/studentDetailScreen.dart';
// import '../widgets/developeByWidget.dart';
// import 'earlyDepartureScreen.dart';
// import '../providers/feeProvider.dart';
// import 'pdfViewScreen.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   int _currentIndex = 0;
//
//   late final List<Widget> _screens = [
//     const HomeTab(),
//     const NotificationScreen(),
//     const PasswordResetScreen(type: 0),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted) return;
//
//       context.read<ProfileProvider>().getProfileData(context);
//       context.read<FeeProvider>().getSession(context);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF6F7FB),
//       extendBody: true,
//
//       body: IndexedStack(
//         index: _currentIndex,
//         children: _screens,
//       ),
//
//       bottomNavigationBar: _FloatingBottomNavigation(
//         currentIndex: _currentIndex,
//         onChanged: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//       ),
//     );
//   }
// }
//
// // ============================================================
// // BOTTOM NAVIGATION
// // ============================================================
//
// class _BottomNavItem {
//   final IconData icon;
//   final String label;
//
//   const _BottomNavItem({
//     required this.icon,
//     required this.label,
//   });
// }
//
// class _FloatingBottomNavigation extends StatelessWidget {
//   final int currentIndex;
//   final ValueChanged<int> onChanged;
//
//   const _FloatingBottomNavigation({
//     required this.currentIndex,
//     required this.onChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     const items = [
//       _BottomNavItem(
//         icon: Icons.home_rounded,
//         label: 'Home',
//       ),
//       _BottomNavItem(
//         icon: Icons.notifications_rounded,
//         label: 'Alerts',
//       ),
//       _BottomNavItem(
//         icon: Icons.lock_rounded,
//         label: 'Password',
//       ),
//     ];
//
//     return SafeArea(
//       top: false,
//       left: false,
//       right: false,
//       child: Padding(
//         padding: EdgeInsets.only(bottom: 10.h),
//         child: Align(
//           alignment: Alignment.bottomCenter,
//           child: Material(
//             color: Colors.transparent,
//             child: Container(
//               height: 58.h,
//               padding: EdgeInsets.all(5.w),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(32.r),
//                 border: Border.all(
//                   color: const Color(0xFFE7E7E7),
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(.16),
//                     blurRadius: 22,
//                     offset: const Offset(0, 7),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: List.generate(
//                   items.length,
//                       (index) {
//                     final item = items[index];
//                     final selected = currentIndex == index;
//
//                     return Material(
//                       color: Colors.transparent,
//                       child: InkWell(
//                         onTap: () => onChanged(index),
//                         borderRadius: BorderRadius.circular(27.r),
//                         child: AnimatedContainer(
//                           duration: const Duration(milliseconds: 220),
//                           curve: Curves.easeOutCubic,
//                           padding: EdgeInsets.symmetric(
//                             horizontal: selected ? 15.w : 13.w,
//                             vertical: 10.h,
//                           ),
//                           decoration: BoxDecoration(
//                             gradient: selected
//                                 ? const LinearGradient(
//                               colors: [
//                                 Color(0xFFB50000),
//                                 Color(0xFFFF3B3B),
//                               ],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             )
//                                 : null,
//                             borderRadius: BorderRadius.circular(27.r),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 item.icon,
//                                 size: 20.sp,
//                                 color: selected
//                                     ? Colors.white
//                                     : const Color(0xFF777777),
//                               ),
//                               if (selected) ...[
//                                 SizedBox(width: 6.w),
//                                 Text(
//                                   item.label,
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 10.5.sp,
//                                     fontWeight: FontWeight.w800,
//                                   ),
//                                 ),
//                               ],
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ============================================================
// // HOME TAB
// // ============================================================
//
// class HomeTab extends StatelessWidget {
//   const HomeTab({Key? key}) : super(key: key);
//
//   Future<void> _refresh(BuildContext context) async {
//     final profileProvider = context.read<ProfileProvider>();
//     final feeProvider = context.read<FeeProvider>();
//
//     profileProvider.getProfileData(context);
//     feeProvider.getSession(context);
//
//     await Future.delayed(
//       const Duration(milliseconds: 600),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final pp = context.watch<ProfileProvider>();
//     final user = pp.dataUser;
//
//     final fullName =
//     '${user?.fname ?? 'Student'} ${user?.lname ?? ''}'.trim();
//
//     return SafeArea(
//       top: true,
//       bottom: false,
//       left: true,
//       right: true,
//       child: RefreshIndicator(
//         color: maincolor,
//         backgroundColor: Colors.white,
//         notificationPredicate: (notification) {
//           return notification.depth == 0;
//         },
//         onRefresh: () => _refresh(context),
//         child: CustomScrollView(
//           physics: const AlwaysScrollableScrollPhysics(
//             parent: BouncingScrollPhysics(),
//           ),
//           slivers: [
//             // ==================================================
//             // HEADER
//             // ==================================================
//
//             SliverToBoxAdapter(
//               child: _DashboardHeader(
//                 name: fullName,
//                 userId: user?.admNo?.toString() ?? '',
//                 onLogout: pp.showLogoutPopout,
//               ),
//             ),
//
//             // ==================================================
//             // STUDENT CARD
//             // ==================================================
//
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: EdgeInsets.fromLTRB(
//                   16.w,
//                   16.h,
//                   16.w,
//                   0,
//                 ),
//                 child: _StudentMiniCard(
//                   pp: pp,
//                 ),
//               ),
//             ),
//
//             // ==================================================
//             // QUICK ACCESS
//             // ==================================================
//
//             _categoriesSection(),
//
//             // ==================================================
//             // DEVELOPED BY
//             // ==================================================
//
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: EdgeInsets.only(
//                   top: 18.h,
//                   bottom: 100.h,
//                 ),
//                 child: const DevelopByWidget(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ==========================================================
//   // QUICK ACCESS SECTION
//   // ==========================================================
//
//   SliverToBoxAdapter _categoriesSection() {
//     return SliverToBoxAdapter(
//       child: Padding(
//         padding: EdgeInsets.fromLTRB(
//           18.w,
//           20.h,
//           18.w,
//           4.h,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ==================================================
//             // SECTION TITLE
//             // ==================================================
//
//             Row(
//               children: [
//                 Container(
//                   width: 34.w,
//                   height: 34.w,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF6048D5).withOpacity(.10),
//                     borderRadius: BorderRadius.circular(10.r),
//                   ),
//                   child: Icon(
//                     Icons.apps_rounded,
//                     color: const Color(0xFF6048D5),
//                     size: 20.sp,
//                   ),
//                 ),
//                 SizedBox(width: 9.w),
//                 Text(
//                   'Quick Access',
//                   style: TextStyle(
//                     color: const Color(0xFF202020),
//                     fontSize: 17.sp,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//               ],
//             ),
//
//             SizedBox(height: 12.h),
//
//             // ==================================================
//             // 3 COLUMN GRID
//             // ==================================================
//
//             LayoutBuilder(
//               builder: (context, constraints) {
//                 const double gap = 10;
//                 const int columns = 3;
//
//                 final double cardWidth =
//                     (constraints.maxWidth -
//                         (gap * (columns - 1))) /
//                         columns;
//
//                 return Wrap(
//                   spacing: gap,
//                   runSpacing: gap,
//                   children: _modules.map((item) {
//                     return SizedBox(
//                       width: cardWidth,
//                       height: 95.h,
//                       child: _categoryCard(
//                         context,
//                         item,
//                       ),
//                     );
//                   }).toList(),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ==========================================================
//   // CATEGORY CARD
//   // ==========================================================
//
//   Widget _categoryCard(
//       BuildContext context,
//       _ModuleItem item,
//       ) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: () => item.action(context),
//         borderRadius: BorderRadius.circular(18.r),
//
//         child: Ink(
//           decoration: BoxDecoration(
//             // ==================================================
//             // MAIN CARD - LIGHT COLORED
//             // ==================================================
//
//             gradient: LinearGradient(
//               colors: item.gradient,
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//
//             borderRadius: BorderRadius.circular(18.r),
//
//             boxShadow: [
//               BoxShadow(
//                 color: item.gradient.first.withOpacity(.22),
//                 blurRadius: 10,
//                 offset: const Offset(0, 5),
//               ),
//             ],
//           ),
//
//           child: Stack(
//             children: [
//               // ==================================================
//               // BACKGROUND DECORATION
//               // ==================================================
//
//               Positioned(
//                 right: -22.w,
//                 top: -22.h,
//                 child: Container(
//                   width: 75.w,
//                   height: 75.w,
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(.22),
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//               ),
//
//               Positioned(
//                 left: -25.w,
//                 bottom: -28.h,
//                 child: Container(
//                   width: 70.w,
//                   height: 70.w,
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(.12),
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//               ),
//
//               // ==================================================
//               // CARD CONTENT
//               // ==================================================
//
//               Padding(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: 3.w,
//                   vertical: 4.h,
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//
//                   children: [
//                     // ==================================================
//                     // 3D PNG ICON
//                     // ==================================================
//
//                     Container(
//                       width: 60.w,
//                       height: 60.w,
//
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(.22),
//                         borderRadius: BorderRadius.circular(15.r),
//
//                         border: Border.all(
//                           color: Colors.white.withOpacity(.28),
//                           width: 1,
//                         ),
//
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(.06),
//                             blurRadius: 7,
//                             offset: const Offset(0, 3),
//                           ),
//                         ],
//                       ),
//
//                       child: Padding(
//                         padding: EdgeInsets.all(2.w),
//
//                         child: Image.asset(
//                           item.image,
//                           fit: BoxFit.contain,
//
//                           errorBuilder: (
//                               context,
//                               error,
//                               stackTrace,
//                               ) {
//                             return Icon(
//                               Icons.image_not_supported_rounded,
//                               color: Colors.white,
//                               size: 24.sp,
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//
//                     SizedBox(height: 8.h),
//
//                     // ==================================================
//                     // TITLE
//                     // ==================================================
//
//                     Expanded(
//                       child: Center(
//                         child: Text(
//                           item.title,
//
//                           textAlign: TextAlign.center,
//
//                           softWrap: true,
//
//                           maxLines: 3,
//
//                           overflow: TextOverflow.ellipsis,
//
//                           style: TextStyle(
//                             color: const Color(0xFF252525),
//                             fontSize: 10.5.sp,
//                             height: 1.18,
//                             fontWeight: FontWeight.w800,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
// }
//
// // ============================================================
// // HEADER
// // ============================================================
//
// class _DashboardHeader extends StatelessWidget {
//   final String name;
//   final String userId;
//   final VoidCallback onLogout;
//
//   const _DashboardHeader({
//     required this.name,
//     required this.userId,
//     required this.onLogout,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Color(0xFFB50000),
//             Color(0xFFE31A1A),
//             Color(0xFFFF3B3B),
//           ],
//         ),
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(38),
//           bottomRight: Radius.circular(38),
//         ),
//       ),
//       child: Padding(
//         // padding: EdgeInsets.fromLTRB(
//         //   18.w,
//         //   15.h,
//         //   16.w,
//         //   22.h,
//         // ),
//         padding: const EdgeInsets.fromLTRB(
//           16,
//           12,
//           16,
//           20,
//         ),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Container(
//               width: 52.w,
//               height: 52.w,
//               // decoration: BoxDecoration(
//               //   color: Colors.white.withOpacity(.17),
//               //   borderRadius: BorderRadius.circular(17.r),
//               //   border: Border.all(
//               //     color: Colors.white.withOpacity(.20),
//               //   ),
//               // ),
//               child: Center(
//                 child: Image.asset(
//                   'assets/mikado_icon.png',
//                   width: 58.w,
//                   height: 58.w,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ),
//
//             SizedBox(width: 11.w),
//
//             Expanded(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Welcome back',
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(.82),
//                       fontSize: 11.sp,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//
//                   SizedBox(height: 2.h),
//
//                   Text(
//                     name.isEmpty ? 'Student' : name.toUpperCase(),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 17.sp,
//                       height: 1.12,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),
//
//                   if (userId.isNotEmpty) ...[
//                     SizedBox(height: 3.h),
//                     Text(
//                       'Register No. $userId',
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(.86),
//                         fontSize: 10.sp,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//
//             SizedBox(width: 7.w),
//
//             SizedBox(
//               width: 42.w,
//               height: 42.w,
//               child: IconButton(
//                 onPressed: onLogout,
//                 padding: EdgeInsets.zero,
//                 style: IconButton.styleFrom(
//                   backgroundColor: Colors.white.withOpacity(.16),
//                   foregroundColor: Colors.white,
//                 ),
//                 icon: Icon(
//                   Icons.logout_rounded,
//                   size: 20.sp,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ============================================================
// // STUDENT CARD
// // ============================================================
//
// class _StudentMiniCard extends StatelessWidget {
//   final ProfileProvider pp;
//
//   const _StudentMiniCard({
//     required this.pp,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final u = pp.dataUser;
//
//     // FeeProvider se current session lo
//     final feeProvider = context.watch<FeeProvider>();
//
//     final className =
//     (u?.dataClass?.toString().trim().isNotEmpty ?? false)
//         ? u!.dataClass.toString()
//         : '—';
//
//     final section =
//     (u?.section?.toString().trim().isNotEmpty ?? false)
//         ? u!.section.toString()
//         : '—';
//
//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: 14.w,
//         vertical: 12.h,
//       ),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(19.r),
//         border: Border.all(
//           color: const Color(0xFFEAEAEA),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(.045),
//             blurRadius: 16,
//             offset: const Offset(0, 7),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 46.w,
//             height: 46.w,
//             decoration: BoxDecoration(
//               color: maincolor.withOpacity(.09),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.person_rounded,
//               color: maincolor,
//               size: 25.sp,
//             ),
//           ),
//
//           SizedBox(width: 11.w),
//
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//
//                 Text(
//                   'Grade : $className  •  $section',
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     fontSize: 13.5.sp,
//                     height: 1.2,
//                     fontWeight: FontWeight.w800,
//                     color: const Color(0xFF222222),
//                   ),
//                 ),
//
//                 // CURRENT SESSION
//                 if (feeProvider.currentSession.isNotEmpty) ...[
//                   SizedBox(height: 4.h),
//
//                   Text(
//                     'Session: ${feeProvider.currentSession}',
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       color: Colors.grey.shade600,
//                       fontSize: 10.sp,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//
//           SizedBox(width: 8.w),
//
//           Icon(
//             Icons.verified_rounded,
//             color: maincolor,
//             size: 22.sp,
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ============================================================
// // MODULE MODEL
// // ============================================================
//
// class _ModuleItem {
//   final String title;
//   final String image;
//   final List<Color> gradient;
//   final void Function(BuildContext) action;
//
//   const _ModuleItem(
//       this.title,
//       this.image,
//       this.gradient,
//       this.action,
//       );
// }
//
// // ============================================================
// // MODULES
// // ============================================================
//
// final List<_ModuleItem> _modules = [
//   // ==========================================================
//   // PROFILE
//   // ==========================================================
//
//   _ModuleItem(
//     'Profile',
//     'assets/icons/profile.png',
//     const [
//       Color(0xFFFFE1E1),
//       Color(0xFFFFBABA),
//     ],
//         (c) {
//       Get.to(
//             () => const StudentDetailScreen(),
//       );
//     },
//   ),
//
//   // ==========================================================
//   // FEE PAYMENT
//   // ==========================================================
//
//   _ModuleItem(
//     'Fee Payment',
//     'assets/icons/fees.png',
//     const [
//       Color(0xFFE8E8E8),
//       Color(0xFFD0D0D0),
//     ],
//         (c) {
//       Get.to(
//             () => const FeeInstallmentScreen(),
//       );
//     },
//   ),
//
//   // ==========================================================
//   // STUDENT RULES
//   // ==========================================================
//
//   _ModuleItem(
//     'Student Rules & Regulations',
//     'assets/icons/policy.png',
//     const [
//       Color(0xFFE8DFFF),
//       Color(0xFFD5C2FF),
//     ],
//         (c) {
//       Get.to(
//             () => const PdfViewerScreen(),
//         arguments: {
//           'url': 'https://portal.mikadoeducation.com/Students_parents_Guidelines.pdf',
//           'title': 'Student Rules & Regulations',
//         },
//       );
//     },
//   ),
//
//   // ==========================================================
//   // MONTHLY PLANNER
//   // ==========================================================
//
//   _ModuleItem(
//     'Monthly Planner',
//     'assets/icons/planner.png',
//     const [
//       Color(0xFFD9F5F0),
//       Color(0xFFB8E8DF),
//     ],
//         (c) {
//       c.read<ServicesProvider>().getData(
//         c,
//         getMonthlyPlanner,
//         'Monthly Planner',
//       );
//     },
//   ),
//
//   // ==========================================================
//   // DAILY TIME TABLE
//   // ==========================================================
//
//   _ModuleItem(
//     'Daily Time Table',
//     'assets/icons/timetable.png',
//     const [
//       Color(0xFFDCEEFF),
//       Color(0xFFBBD9FA),
//     ],
//         (c) {
//       Get.to(
//             () => const AcademicModuleScreen(
//           title: 'Daily Time Table',
//           icon: Icons.schedule_rounded,
//           description:
//           'Your day-wise class timetable will be displayed here when the school publishes it.',
//         ),
//       );
//     },
//   ),
//
//   // ==========================================================
//   // CLASS WORK
//   // ==========================================================
//
//   _ModuleItem(
//     'Class Work',
//     'assets/icons/academics.png',
//     const [
//       Color(0xFFEADFD9),
//       Color(0xFFD7C5BB),
//     ],
//         (c) {
//       Get.to(
//             () => const AcademicModuleScreen(
//           title: 'Class Work',
//           icon: Icons.menu_book_rounded,
//           description:
//           'Class work and subject-wise learning material will be displayed here.',
//         ),
//       );
//     },
//   ),
//
//   // ==========================================================
//   // EXAM TIME TABLE
//   // ==========================================================
//
//   _ModuleItem(
//     'Exam Time Table',
//     'assets/icons/exam.png',
//     const [
//       Color(0xFFE0E4FF),
//       Color(0xFFC8CEFA),
//     ],
//         (c) {
//       c.read<ServicesProvider>().getData(
//         c,
//         getTimeTable,
//         'Exam Time Table',
//       );
//     },
//   ),
//
//   // ==========================================================
//   // EXAM SYLLABUS
//   // ==========================================================
//
//   _ModuleItem(
//     'Exam Syllabus',
//     'assets/icons/pdf.png',
//     const [
//       Color(0xFFD8F5F7),
//       Color(0xFFB8E8EC),
//     ],
//         (c) {
//       c.read<ServicesProvider>().getData(
//         c,
//         getSyllabus,
//         'Exam Syllabus',
//       );
//     },
//   ),
//
//   // ==========================================================
//   // YEARLY CALENDAR
//   // ==========================================================
//
//   _ModuleItem(
//     'Yearly Calendar',
//     'assets/icons/category.png',
//     const [
//       Color(0xFFDDF3DE),
//       Color(0xFFBFE5C1),
//     ],
//         (c) {
//       c.read<ServicesProvider>().getData(
//         c,
//         getCalender,
//         'Yearly Calendar',
//       );
//     },
//   ),
//
//   // ==========================================================
//   // EARLY DEPARTURE
//   // ==========================================================
//
//   _ModuleItem(
//     'Early Departure',
//     'assets/icons/leave.png',
//     const [
//       Color(0xFFE5DCFA),
//       Color(0xFFD0C0F0),
//     ],
//         (c) {
//       Get.to(
//             () => const EarlyDepartureScreen(),
//       );
//     },
//   ),
//   // ==========================================================
//   // ATTENDANCE
//   // ==========================================================
//
//   // _ModuleItem(
//   //   'Attendance',
//   //   'assets/icons/attendance.png',
//   //   const [
//   //     Color(0xFFFFE8D2),
//   //     Color(0xFFFFD0A0),
//   //   ],
//   //       (c) {
//   //     Get.to(
//   //           () => const AcademicModuleScreen(
//   //         title: 'Attendance',
//   //         icon: Icons.fact_check_outlined,
//   //         description:
//   //         'Attendance details will be shown here as soon as the school publishes the attendance record.',
//   //       ),
//   //     );
//   //   },
//   // ),
//
//   // ==========================================================
//   // PROGRESS REPORT
//   // ==========================================================
//
//   // _ModuleItem(
//   //   'Progress Report Card',
//   //   'assets/icons/pdf.png',
//   //   const [
//   //     Color(0xFFF9DCE8),
//   //     Color(0xFFF2BBD0),
//   //   ],
//   //       (c) {
//   //     Get.to(
//   //           () => const AcademicModuleScreen(
//   //         title: 'Progress Report Card',
//   //         icon: Icons.trending_up_rounded,
//   //         description:
//   //         'Academic progress and subject-wise performance will be displayed here.',
//   //       ),
//   //     );
//   //   },
//   // ),
//
// ];
