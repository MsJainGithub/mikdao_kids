import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:downloadsfolder/downloadsfolder.dart';
import 'package:share_plus/share_plus.dart';

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

    if (Get.arguments != null) {
      pdfUrl = Get.arguments['url'] ?? Get.arguments[0];
      pdfTitle = Get.arguments['title'] ?? 'Document';
    }

    _loadPdfFromUrl();
  }

  // ---------------------------------------------------------------------------
  // LOAD PDF
  // ---------------------------------------------------------------------------

  Future<void> _loadPdfFromUrl() async {
    if (pdfUrl == null) {
      if (mounted) {
        setState(() {
          _isLoadingPdf = false;
        });
      }
      return;
    }

    try {
      if (mounted) {
        setState(() {
          _isLoadingPdf = true;
        });
      }

      final tempDir = await getTemporaryDirectory();

      final fileName = pdfTitle?.replaceAll(' ', '_') ?? 'temp_document';

      final filePath =
          '${tempDir.path}/${fileName}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final dio = Dio();

      await dio.download(
        pdfUrl!,
        filePath,
      );

      if (!mounted) return;

      setState(() {
        _localPdfPath = filePath;
        _isLoadingPdf = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingPdf = false;
      });

      showToastE(
        message: "Failed to load PDF: ${e.toString()}",
      );
    }
  }

  // ---------------------------------------------------------------------------
  // DOWNLOAD
  // ---------------------------------------------------------------------------

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
            showToastE(
              message: "Storage permission denied",
            );
            return;
          }
        }
      }

      if (mounted) {
        setState(() {
          _isDownloading = true;
          _downloadProgress = 0.0;
        });
      }

      final tempDir = await getTemporaryDirectory();

      final fileName = pdfTitle?.replaceAll(' ', '_') ?? 'document';

      final tempFilePath = '${tempDir.path}/$fileName.pdf';

      final dio = Dio();

      await dio.download(
        pdfUrl!,
        tempFilePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && mounted) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      final copied = await copyFileIntoDownloadFolder(
        tempFilePath,
        '$fileName.pdf',
      );

      if (!mounted) return;

      setState(() {
        _isDownloading = false;
      });

      if (copied == true) {
        showToastE(
          message: "PDF downloaded successfully",
        );
      } else {
        showToastE(
          message: "Failed to save to Downloads",
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isDownloading = false;
      });

      showToastE(
        message: "Download failed: ${e.toString()}",
      );
    }
  }

  // ---------------------------------------------------------------------------
  // ANDROID SDK
  // ---------------------------------------------------------------------------

  Future<int?> _getAndroidSdkInt() async {
    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;

      return androidInfo.version.sdkInt;
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // SHARE
  // ---------------------------------------------------------------------------

  Future<void> _sharePdf() async {
    if (pdfUrl == null) {
      showToastE(message: "PDF URL not found");
      return;
    }

    try {
      showToastE(
        message: "Preparing to share...",
      );

      final tempDir = await getTemporaryDirectory();

      final fileName = pdfTitle?.replaceAll(' ', '_') ?? 'document';

      final filePath = '${tempDir.path}/$fileName.pdf';

      final dio = Dio();

      await dio.download(
        pdfUrl!,
        filePath,
      );

      await Share.shareXFiles(
        [XFile(filePath)],
        text: pdfTitle ?? 'Check out this PDF',
      );
    } catch (e) {
      showToastE(
        message: "Share failed: ${e.toString()}",
      );
    }
  }

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
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

                InkWell(
                  onTap: () {
                    Get.back();
                  },

                  borderRadius: BorderRadius.circular(20.r),

                  child: SizedBox(
                    width: 30.w,
                    height: 55.h,

                    child: Center(
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 22.sp,
                      ),
                    ),
                  ),
                ),

                // ==================================================
                // TITLE
                // ==================================================

                Expanded(
                  child: Center(
                    child: Text(
                      pdfTitle ?? 'PDF Viewer',

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
                ),

                // ==================================================
                // DOWNLOAD + SHARE
                // ==================================================

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // DOWNLOAD
                    SizedBox(
                      width: 30.w,
                      height: 55.h,

                      child: IconButton(
                        padding: EdgeInsets.zero,

                        onPressed:
                        _isDownloading ? null : _downloadPdf,

                        icon: Icon(
                          Icons.download_rounded,
                          color: Colors.white,
                          size: 23.sp,
                        ),
                      ),
                    ),

                    SizedBox(width: 2.w),

                    // SHARE
                    SizedBox(
                      width: 30.w,
                      height: 55.h,

                      child: IconButton(
                        padding: EdgeInsets.zero,

                        onPressed: _sharePdf,

                        icon: Icon(
                          Icons.share_rounded,
                          color: Colors.white,
                          size: 22.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PDF VIEWER
  // ---------------------------------------------------------------------------

  Widget _buildPdfViewer() {
    return Stack(
      children: [
        // ---------------------------------------------------------------------
        // PDF
        // ---------------------------------------------------------------------

        if (_localPdfPath != null && !_isLoadingPdf)
          Positioned.fill(
            child: PDFView(
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
                if (!mounted) return;

                setState(() {
                  _totalPages = pages ?? 0;
                  _currentPage = 1;
                });
              },

              onError: (error) {
                showToastE(
                  message: "Error loading PDF: $error",
                );
              },

              onPageError: (page, error) {
                showToastE(
                  message: "Error on page $page: $error",
                );
              },

              onViewCreated: (
                  PDFViewController controller,
                  ) {
                _pdfViewController = controller;
              },

              onPageChanged: (int? page, int? total) {
                if (!mounted) return;

                setState(() {
                  _currentPage = (page ?? 0) + 1;
                  _totalPages = total ?? 0;
                });
              },
            ),
          ),

        // ---------------------------------------------------------------------
        // PDF LOADING
        // ---------------------------------------------------------------------

        if (_isLoadingPdf)
          Positioned.fill(
            child: Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor:
                      AlwaysStoppedAnimation<Color>(
                        maincolor,
                      ),
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
          ),

        // ---------------------------------------------------------------------
        // DOWNLOAD OVERLAY
        // ---------------------------------------------------------------------

        if (_isDownloading)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 40.w,
                  ),
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        value: _downloadProgress,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(
                          maincolor,
                        ),
                        strokeWidth: 5,
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
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // NO PDF
  // ---------------------------------------------------------------------------

  Widget _buildNoPdf() {
    return Center(
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
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      body: SafeArea(
        child: Column(
        children: [
          // -------------------------------------------------------------------
          // HEADER
          // -------------------------------------------------------------------

          _buildHeader(),

          // -------------------------------------------------------------------
          // PDF AREA
          // -------------------------------------------------------------------

          Expanded(
            child: pdfUrl == null
                ? _buildNoPdf()
                : _buildPdfViewer(),
          ),

          // -------------------------------------------------------------------
          // BOTTOM SAFE AREA
          // -------------------------------------------------------------------
          //
          // This prevents the PDF/content from going behind
          // Android gesture/navigation area.
          //

          if (MediaQuery.of(context).padding.bottom > 0)
            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            ),
        ],
      ),),
    );
  }

  // ---------------------------------------------------------------------------
  // DISPOSE
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    if (_localPdfPath != null) {
      try {
        File(_localPdfPath!).delete();
      } catch (_) {}
    }

    super.dispose();
  }
}
