import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/themeConfig.dart';
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
    context.read<NotificationProvider>().getNotification(context);
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: maincolor,
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: notificationProvider.noNotification
          ? _buildEmptyState()
          : ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: notificationProvider.notificationList.length,
        itemBuilder: (context, index) {
          final notification = notificationProvider.notificationList[index];
          return _buildNotificationCard(notification);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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

        ],
      ),
    );
  }

  Widget _buildNotificationCard(DatumNotificaltion notification) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
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
          if(notification.docFile != null && notification.docFile!.isNotEmpty)
          ElevatedButton(onPressed: (){
            print(notification.docFile);
            launchUrl(Uri.parse(notification.docFile.toString()),mode: LaunchMode.externalApplication);
          }, child: Text(
            "More Detail"
          ),style: ElevatedButton.styleFrom(backgroundColor: maincolor),)
        ],
      ),
    );
  }
}