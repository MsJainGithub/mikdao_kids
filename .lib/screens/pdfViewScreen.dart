import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:downloadsfolder/downloadsfolder.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../config/themeConfig.dart';
import '../widgets/toast.dart';

class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({Key? key}) : super(key: key);

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? pdfUrl;
  String? pdfTitle;
  bool _isDownloading = false;
  bool _isLoadingPdf = true;
  double _downloadProgress = 0.0;
  String? _localPdfPath;
  int _currentPage = 0;
  int _totalPages = 0;
  PDFViewController? _pdfViewController;

  @override
  void initState() {
    super.initState();
    // Get PDF URL and title from arguments
    if (Get.arguments != null) {
      pdfUrl = Get.arguments['url'] ?? Get.arguments[0];
      pdfTitle = Get.arguments['title'] ?? 'Document';
    }
    _loadPdfFromUrl();
  }

  Future<void> _loadPdfFromUrl() async {
    if (pdfUrl == null) {
      setState(() {
        _isLoadingPdf = false;
      });
      return;
    }

    try {
      setState(() {
        _isLoadingPdf = true;
      });

      // Download PDF to temporary directory for viewing
      Directory tempDir = await getTemporaryDirectory();
      String fileName = pdfTitle?.replaceAll(' ', '_') ?? 'temp_document';
      String filePath = '${tempDir.path}/${fileName}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      Dio dio = Dio();
      await dio.download(pdfUrl!, filePath);

      setState(() {
        _localPdfPath = filePath;
        _isLoadingPdf = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPdf = false;
      });
      showToastE(message: "Failed to load PDF: ${e.toString()}");
    }
  }

  Future<void> _downloadPdf() async {
    if (pdfUrl == null) {
      showToastE(message: "PDF URL not found");
      return;
    }

    try {
      if (Platform.isAndroid) {
        final sdkInt = await _getAndroidSdkInt();
        if (sdkInt != null && sdkInt <= 28) {
          final status = await Permission.storage.request();
          if (!status.isGranted) {
            showToastE(message: "Storage permission denied");
            return;
          }
        }
      }

      setState(() {
        _isDownloading = true;
        _downloadProgress = 0.0;
      });

      final tempDir = await getTemporaryDirectory();
      final fileName = pdfTitle?.replaceAll(' ', '_') ?? 'document';
      final tempFilePath = '${tempDir.path}/$fileName.pdf';

      final dio = Dio();
      await dio.download(
        pdfUrl!,
        tempFilePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      final copied = await copyFileIntoDownloadFolder(tempFilePath, '$fileName.pdf');

      setState(() {
        _isDownloading = false;
      });

      if (copied == true) {
        showToastE(message: "PDF downloaded successfully");
      } else {
        showToastE(message: "Failed to save to Downloads");
      }
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });
      showToastE(message: "Download failed: ${e.toString()}");
    }
  }

  Future<int?> _getAndroidSdkInt() async {
    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt;
    } catch (_) {
      return null;
    }
  }

  Future<void> _sharePdf() async {
    if (pdfUrl == null) {
      showToastE(message: "PDF URL not found");
      return;
    }

    try {
      showToastE(message: "Preparing to share...");

      // Download to temporary directory
      Directory tempDir = await getTemporaryDirectory();
      String fileName = pdfTitle?.replaceAll(' ', '_') ?? 'document';
      String filePath = '${tempDir.path}/$fileName.pdf';

      Dio dio = Dio();
      await dio.download(pdfUrl!, filePath);

      // Share the file
      await Share.shareXFiles(
        [XFile(filePath)],
        text: pdfTitle ?? 'Check out this PDF',
      );
    } catch (e) {
      showToastE(message: "Share failed: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: maincolor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pdfTitle ?? 'PDF Viewer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_totalPages > 0)
              Text(
                'Page $_currentPage of $_totalPages',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11.sp,
                ),
              ),
          ],
        ),
        actions: [
          // Download button
          IconButton(
            icon: Icon(
              Icons.download,
              color: Colors.white,
              size: 24.sp,
            ),
            onPressed: _isDownloading ? null : _downloadPdf,
          ),
          // Share button
          IconButton(
            icon: Icon(
              Icons.share,
              color: Colors.white,
              size: 24.sp,
            ),
            onPressed: _sharePdf,
          ),
        ],
      ),
      body: pdfUrl == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80.sp,
              color: Colors.grey,
            ),
            Gap(16.h),
            Text(
              'No PDF URL provided',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      )
          : Stack(
        children: [
          // PDF Viewer
          if (_localPdfPath != null && !_isLoadingPdf)
            PDFView(
              filePath: _localPdfPath!,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageFling: true,
              pageSnap: true,
              defaultPage: 0,
              fitPolicy: FitPolicy.BOTH,
              preventLinkNavigation: false,
              onRender: (pages) {
                setState(() {
                  _totalPages = pages ?? 0;
                  _currentPage = 1;
                });
              },
              onError: (error) {
                showToastE(message: "Error loading PDF: $error");
              },
              onPageError: (page, error) {
                showToastE(message: "Error on page $page: $error");
              },
              onViewCreated: (PDFViewController controller) {
                _pdfViewController = controller;
              },
              onPageChanged: (int? page, int? total) {
                setState(() {
                  _currentPage = (page ?? 0) + 1;
                  _totalPages = total ?? 0;
                });
              },
            ),

          // Loading indicator for PDF
          if (_isLoadingPdf)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(maincolor),
                    ),
                    Gap(16.h),
                    Text(
                      'Loading PDF...',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Download progress indicator
          if (_isDownloading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        value: _downloadProgress,
                        valueColor: AlwaysStoppedAnimation<Color>(maincolor),
                        strokeWidth: 6,
                      ),
                      Gap(16.h),
                      Text(
                        'Downloading...',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Gap(8.h),
                      Text(
                        '${(_downloadProgress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),

      // Bottom action buttons
      // bottomNavigationBar: pdfUrl != null
      //     ? Container(
      //   padding: EdgeInsets.all(16.w),
      //   decoration: BoxDecoration(
      //     color: Colors.white,
      //     boxShadow: [
      //       BoxShadow(
      //         color: Colors.black12,
      //         blurRadius: 4,
      //         offset: Offset(0, -2),
      //       ),
      //     ],
      //   ),
      //   child: Row(
      //     children: [
      //       // Download button
      //       Expanded(
      //         child: ElevatedButton.icon(
      //           onPressed: _isDownloading ? null : _downloadPdf,
      //           icon: Icon(Icons.download, color: Colors.white),
      //           label: Text(
      //             'Download',
      //             style: TextStyle(
      //               fontSize: 14.sp,
      //               fontWeight: FontWeight.bold,
      //               color: Colors.white,
      //             ),
      //           ),
      //           style: ElevatedButton.styleFrom(
      //             backgroundColor: maincolor,
      //             padding: EdgeInsets.symmetric(vertical: 12.h),
      //             shape: RoundedRectangleBorder(
      //               borderRadius: BorderRadius.circular(8.r),
      //             ),
      //             disabledBackgroundColor: maincolor.withOpacity(0.5),
      //           ),
      //         ),
      //       ),
      //
      //       Gap(12.w),
      //
      //       // Share button
      //       Expanded(
      //         child: ElevatedButton.icon(
      //           onPressed: _sharePdf,
      //           icon: Icon(Icons.share, color: maincolor),
      //           label: Text(
      //             'Share',
      //             style: TextStyle(
      //               fontSize: 14.sp,
      //               fontWeight: FontWeight.bold,
      //               color: maincolor,
      //             ),
      //           ),
      //           style: ElevatedButton.styleFrom(
      //             backgroundColor: Colors.white,
      //             padding: EdgeInsets.symmetric(vertical: 12.h),
      //             shape: RoundedRectangleBorder(
      //               borderRadius: BorderRadius.circular(8.r),
      //               side: BorderSide(color: maincolor, width: 2),
      //             ),
      //           ),
      //         ),
      //       ),
      //     ],
      //   ),
      // )
      //     : null,
    );
  }

  @override
  void dispose() {
    // Clean up temporary file if needed
    if (_localPdfPath != null) {
      try {
        File(_localPdfPath!).delete();
      } catch (e) {
        // Ignore cleanup errors
      }
    }
    super.dispose();
  }
}
