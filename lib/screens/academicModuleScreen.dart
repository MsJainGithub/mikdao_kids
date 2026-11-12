import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../config/themeConfig.dart';
import '../providers/servicesProvider.dart';
import '../widgets/app_header.dart';

class AcademicModuleScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? apiUrl;
  final String? description;
  final List<String>? points;

  const AcademicModuleScreen({
    super.key,
    required this.title,
    required this.icon,
    this.apiUrl,
    this.description,
    this.points,
  });

  Future<void> _refreshData(BuildContext context) async {
    final service = context.read<ServicesProvider>();

    // Refresh only when this module has an API
    if (apiUrl != null) {
      await service.getData(
        context,
        apiUrl!,
        title,
      );
    } else {
      // Small delay so RefreshIndicator can complete
      await Future.delayed(
        const Duration(milliseconds: 500),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ServicesProvider>();

    final isApi = apiUrl != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            // ==========================================================
            // HEADER
            // ==========================================================

            AppHeader(title: title),

            // ==========================================================
            // CONTENT
            // ==========================================================

            Expanded(
              child: RefreshIndicator(
                color: maincolor,
                backgroundColor: Colors.white,
                strokeWidth: 3,
                onRefresh: () => _refreshData(context),

                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),

                  padding: EdgeInsets.fromLTRB(
                    18.w,
                    24.h,
                    18.w,
                    35.h,
                  ),

                  child: Column(
                    children: [
                      // ==================================================
                      // ICON
                      // ==================================================

                      Container(
                        width: 92.w,
                        height: 92.w,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFB50000),
                              Color(0xFFFF3B3B),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(28.r),
                          boxShadow: [
                            BoxShadow(
                              color: maincolor.withOpacity(.25),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 44.sp,
                        ),
                      ),

                      SizedBox(height: 22.h),

                      // ==================================================
                      // TITLE
                      // ==================================================

                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF171717),
                        ),
                      ),

                      SizedBox(height: 8.h),

                      // ==================================================
                      // DESCRIPTION
                      // ==================================================

                      Text(
                        description ??
                            'School information will appear here when it is published.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13.sp,
                          height: 1.5,
                        ),
                      ),

                      // ==================================================
                      // POINTS
                      // ==================================================

                      if (points != null && points!.isNotEmpty) ...[
                        SizedBox(height: 22.h),

                        _card(
                          context,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 18.w,
                              vertical: 16.h,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: points!
                                  .asMap()
                                  .entries
                                  .map(
                                    (entry) {
                                  final index = entry.key;
                                  final e = entry.value;

                                  return Padding(
                                    padding: EdgeInsets.only(
                                      top: index == 0 ? 0 : 8.h,
                                      bottom: index == points!.length - 1 ? 0 : 8.h,
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Bullet
                                        Container(
                                          margin: EdgeInsets.only(
                                            top: 7.h,
                                          ),
                                          width: 8.w,
                                          height: 8.w,
                                          decoration: const BoxDecoration(
                                            color: maincolor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),

                                        SizedBox(width: 13.w),

                                        // Point text
                                        Expanded(
                                          child: Text(
                                            e,
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              color: const Color(0xFF3D3D3D),
                                              height: 1.5,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
                                  .toList(),
                            ),
                          ),
                        ),
                      ],

                      // ==================================================
                      // API BUTTON
                      // ==================================================

                      if (isApi) ...[
                        SizedBox(height: 24.h),

                        SizedBox(
                          width: double.infinity,
                          height: 52.h,
                          child: ElevatedButton.icon(
                            onPressed: service.pdfUrl == null
                                ? () => context
                                .read<ServicesProvider>()
                                .getData(
                              context,
                              apiUrl!,
                              title,
                            )
                                : () => Get.toNamed(
                              '/pdfViewerScreen',
                              arguments: {
                                'url': service.pdfUrl,
                                'title': title,
                              },
                            ),
                            icon: Icon(
                              Icons.open_in_new_rounded,
                              size: 19.sp,
                            ),
                            label: Text(
                              'Open $title',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: maincolor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(16.r),
                              ),
                            ),
                          ),
                        ),
                      ],

                      // ==================================================
                      // NO API / NO POINTS
                      // ==================================================

                      if (!isApi &&
                          (points == null || points!.isEmpty)) ...[
                        SizedBox(height: 24.h),

                        _card(
                          context,
                          child: Padding(
                            padding: EdgeInsets.all(22.w),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color:
                                    maincolor.withOpacity(.08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.info_outline_rounded,
                                    color: maincolor,
                                    size: 24.sp,
                                  ),
                                ),

                                SizedBox(width: 14.w),

                                Expanded(
                                  child: Text(
                                    'This section is ready for school data. Once the corresponding content is published by the school, it can be shown here without changing the app design.',
                                    style: TextStyle(
                                      fontSize: 12.5.sp,
                                      color: Colors.grey.shade700,
                                      height: 1.45,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // Extra bottom space
                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(
      BuildContext context, {
        required Widget child,
      }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: const Color(0xFFEDEDED),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
