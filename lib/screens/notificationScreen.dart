import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/themeConfig.dart';
import '../widgets/app_header.dart';
import '../modals/notificationModal.dart';
import '../providers/notificationProvider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshNotifications();
    });
  }

  Future<void> _refreshNotifications() async {
    await context.read<NotificationProvider>().getNotification(context);
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider =
    context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          const AppHeader(title: 'Notifications'),

          Expanded(
            child: RefreshIndicator(
              color: maincolor,
              backgroundColor: Colors.white,
              strokeWidth: 2.5,
              onRefresh: _refreshNotifications,

              child: notificationProvider.noNotification
                  ? _buildEmptyState()
                  : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.fromLTRB(
                  16.w,
                  18.h,
                  16.w,
                  28.h,
                ),
                itemCount:
                notificationProvider.notificationList.length,
                itemBuilder: (context, index) {
                  final notification =
                  notificationProvider.notificationList[index];

                  return _buildNotificationCard(notification);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  size: 80.sp,
                  color: Colors.grey,
                ),
                Gap(16.h),
                Text(
                  'No Notifications',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                Gap(6.h),
                Text(
                  'Pull down to refresh',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(
      DatumNotificaltion notification) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
        childrenPadding: EdgeInsets.fromLTRB(
          16.w,
          0,
          16.w,
          16.h,
        ),
        shape: const Border(),
        collapsedShape: const Border(),

        title: Text(
          notification.title ?? "",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),

        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: Colors.grey[600],
        ),

        iconColor: Colors.grey[600],
        collapsedIconColor: Colors.grey[600],

        children: [
          Divider(height: 1.h),

          Gap(12.h),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              notification.description ?? "",
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),

          Gap(12.h),

          if (notification.docFile != null &&
              notification.docFile!.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final url = notification.docFile!;

                  final uri = Uri.tryParse(url);

                  if (uri == null) {
                    return;
                  }

                  await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );
                },
                icon: Icon(
                  Icons.open_in_new_rounded,
                  size: 17.sp,
                ),
                label: const Text("More Detail"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: maincolor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 11.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
