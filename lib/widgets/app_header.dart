import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../config/themeConfig.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;
  final bool showBack;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      // ======================================================
      // SAME HEADER DESIGN AS FEE HEADER
      // ======================================================

      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFB50000),
            Color(0xFFE31A1A),
            Color(0xFFFF3B3B),
          ],
          stops: [
            0.0,
            0.55,
            1.0,
          ],
        ),

        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(45),
          bottomRight: Radius.circular(45),
        ),
      ),

      child: SafeArea(
        bottom: false,

        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            20,
          ),
          child: SizedBox(
            height: 55,
            child: Row(
              children: [
                // ==================================================
                // BACK BUTTON
                // ==================================================

                if (showBack)
                  InkWell(
                    onTap: onBack ??
                            () => Navigator.of(context).maybePop(),

                    child: Padding(
                      padding: EdgeInsets.zero,

                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 22.sp,
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: 22.w,
                  ),

                // ==================================================
                // TITLE + SUBTITLE
                // ==================================================

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,

                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),

                      ),

                      // if (subtitle != null &&
                      //     subtitle!.trim().isNotEmpty)
                      //   Text(
                      //     subtitle!,
                      //
                      //     maxLines: 1,
                      //     overflow: TextOverflow.ellipsis,
                      //     textAlign: TextAlign.center,
                      //
                      //     style: TextStyle(
                      //       color: Colors.white,
                      //       fontWeight: FontWeight.bold,
                      //       fontSize: 12.sp,
                      //     ),
                      //   ),
                    ],
                  ),
                ),

                // ==================================================
                // RIGHT SIDE
                // Same width balance as old Fee Header
                // ==================================================

                SizedBox(
                  width: 22.w,
                  child: trailing ?? const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SECTION TITLE
// ============================================================

class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 30.h,
          decoration: BoxDecoration(
            color: maincolor,
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),

        SizedBox(width: 10.w),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF171717),
                ),
              ),

              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
