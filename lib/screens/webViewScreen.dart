import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../config/themeConfig.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({Key? key}) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;

  bool _isLoading = true;

  String url = '';
  String title = 'Web Page';

  @override
  void initState() {
    super.initState();

    url = Get.arguments?['url'] ?? '';
    title = Get.arguments?['title'] ?? 'Web Page';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
      child :Column(
        children: [
          // ==========================================================
          // HEADER
          // ==========================================================

          Container(
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
                bottomLeft: Radius.circular(45),
                bottomRight: Radius.circular(45),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16.w,
                  12.h,
                  16.w,
                  20.h,
                ),
                child: SizedBox(
                  height: 55.h,
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Get.back(),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 22.sp,
                        ),
                      ),

                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(
                        width: 22.w,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ==========================================================
          // LOADING
          // ==========================================================

          if (_isLoading)
            LinearProgressIndicator(
              color: maincolor,
              backgroundColor: Colors.transparent,
              minHeight: 2.h,
            ),

          // ==========================================================
          // WEBVIEW
          // ==========================================================

          Expanded(
            child: WebViewWidget(
              controller: _controller,
            ),
          ),
        ],
      ),
      )
    );
  }
}
