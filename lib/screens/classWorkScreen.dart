
import 'dart:convert';
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../config/appConfig.dart';
import 'pdfViewScreen.dart';
import '../config/themeConfig.dart';
import '../providers/profileProvider.dart';
import '../providers/feeProvider.dart';
import '../services/apiServices.dart';
import '../widgets/app_header.dart';

// ============================================================
// SUBJECT MODEL
// ============================================================

class ClassWorkSubject {
  final String id;
  final String subjectId;
  final String subjectName;

  const ClassWorkSubject({
    required this.id,
    required this.subjectId,
    required this.subjectName,
  });

  factory ClassWorkSubject.fromJson(Map<String, dynamic> json) {
    return ClassWorkSubject(
      id: '${json['id'] ?? ''}',
      subjectId: '${json['subject_id'] ?? ''}',
      subjectName: '${json['subject_name'] ?? ''}',
    );
  }
}

// ============================================================
// SUBJECT LIST SCREEN
// ============================================================

class ClassWorkScreen extends StatefulWidget {
  final String subjectListApi;
  final String classWorkDetailsApi;

  const ClassWorkScreen({
    super.key,
    required this.subjectListApi,
    required this.classWorkDetailsApi,
  });

  @override
  State<ClassWorkScreen> createState() =>
      _ClassWorkScreenState();
}

class _ClassWorkScreenState extends State<ClassWorkScreen> {
  bool loading = false;
  bool openingSubject = false;

  String? selectedSubjectId;
  String? listError;

  List<ClassWorkSubject> subjects = [];

  String _sessionId = '';
  String _classId = '';
  String _secId = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadSubjects();
    });
  }

  // ============================================================
  // STUDENT DATA FROM PROFILE
  // ============================================================

  void _readStudentData() {
    final profileProvider = context.read<ProfileProvider>();
    final feeProvider = context.read<FeeProvider>();

    final student = profileProvider.dataUser;

    _sessionId =
        '${feeProvider.currentSessionId ?? ''}'.trim();

    _classId =
        '${student?.class_id ?? ''}'.trim();

    // IMPORTANT:
    // UserInfo API: "section_id": "11"
    // ClassWork API: "sec_id": "11"
    _secId =
        '${student?.section_id ?? ''}'.trim();

    debugPrint('========== CLASS WORK STUDENT DATA ==========');
    debugPrint('SESSION ID => $_sessionId');
    debugPrint('CLASS ID => $_classId');
    debugPrint('SECTION NAME => ${student?.section}');
    debugPrint('SECTION ID => $_secId');
  }

  // ============================================================
  // SUBJECT LIST API
  // ============================================================

  Future<void> _loadSubjects() async {
    if (loading) return;

    _readStudentData();

    setState(() {
      loading = true;
      listError = null;
    });

    try {
      if (_sessionId.isEmpty ||
          _classId.isEmpty ||
          widget.subjectListApi.trim().isEmpty) {
        throw Exception(
          'Missing session, class or subject API URL',
        );
      }

      final payload = {
        'session_id': _sessionId,
        'class_id': _classId,
      };

      debugPrint('========== SUBJECT LIST API ==========');
      debugPrint('URL => ${widget.subjectListApi}');
      debugPrint('PAYLOAD => $payload');

      final response = await ApiServices().postData(
        uri: widget.subjectListApi,
        context: context,
        data: payload,
      );

      if (response == null) {
        throw Exception('Subject API returned null');
      }

      debugPrint('HTTP STATUS => ${response.statusCode}');
      debugPrint('RESPONSE => ${response.body}');

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          'Subject API HTTP ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map) {
        throw Exception('Invalid subject response');
      }

      if ('${decoded['status']}' != '1') {
        if (!mounted) return;

        setState(() {
          subjects = [];
          listError = null;
        });
        return;
      }

      final rawSubjects = decoded['data'];

      if (rawSubjects is! List) {
        throw Exception('Subject data is not a list');
      }

      final uniqueSubjects = <String, ClassWorkSubject>{};

      for (final item in rawSubjects) {
        if (item is! Map) continue;

        final subject = ClassWorkSubject.fromJson(
          Map<String, dynamic>.from(item),
        );

        if (subject.subjectId.isEmpty) continue;

        uniqueSubjects.putIfAbsent(
          subject.subjectId,
              () => subject,
        );
      }

      if (!mounted) return;

      setState(() {
        subjects = uniqueSubjects.values.toList();
        listError = null;
      });

      debugPrint(
        'UNIQUE SUBJECT COUNT => ${subjects.length}',
      );
    } catch (e) {
      debugPrint('SUBJECT LIST ERROR => $e');

      if (!mounted) return;

      setState(() {
        listError = 'Unable to load subjects right now.';
      });
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  // ============================================================
  // DATA EMPTY CHECK
  // ============================================================

  bool _hasData(dynamic data) {
    if (data == null) return false;

    if (data is List) {
      return data.isNotEmpty;
    }

    if (data is Map) {
      return data.isNotEmpty;
    }

    if (data is String) {
      return data.trim().isNotEmpty;
    }

    return true;
  }

  // ============================================================
  // FRIENDLY MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.fixed,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  // ============================================================
  // CLASSWORK.PHP - CALL BEFORE NAVIGATION
  // ============================================================

  // Future<void> _openSubject(ClassWorkSubject subject) async {
  //   if (openingSubject) return;
  //
  //   _readStudentData();
  //
  //   if (_sessionId.isEmpty || _classId.isEmpty) {
  //     debugPrint('CLASS WORK => Session or Class ID missing');
  //     _showMessage('Class work is unavailable right now.');
  //     return;
  //   }
  //
  //   if (_secId.isEmpty) {
  //     debugPrint(
  //       'CLASS WORK => section_id missing from ProfileProvider',
  //     );
  //     _showMessage('Section information is unavailable.');
  //     return;
  //   }
  //
  //   if (widget.classWorkDetailsApi.trim().isEmpty) {
  //     debugPrint('CLASS WORK => Details API URL missing');
  //     _showMessage('Class work is unavailable right now.');
  //     return;
  //   }
  //
  //   final sessionId = _sessionId;
  //   final classId = _classId;
  //   final secId = _secId;
  //
  //   setState(() {
  //     openingSubject = true;
  //     selectedSubjectId = subject.subjectId;
  //   });
  //
  //   final payload = {
  //     'session_id': sessionId,
  //     'class_id': classId,
  //     'sec_id': secId,
  //     'subject_id': subject.subjectId,
  //   };
  //
  //   debugPrint('========== CLASSWORK.PHP REQUEST ==========');
  //   debugPrint('URL => ${widget.classWorkDetailsApi}');
  //   debugPrint('PAYLOAD => $payload');
  //
  //   dynamic classWorkData;
  //   bool hasData = false;
  //   bool requestFailed = false;
  //
  //   try {
  //     final response = await ApiServices().postData(
  //       uri: widget.classWorkDetailsApi,
  //       context: context,
  //       data: payload,
  //     );
  //
  //     if (response == null) {
  //       debugPrint('CLASSWORK.PHP => Null response');
  //       requestFailed = true;
  //     } else {
  //       debugPrint('HTTP STATUS => ${response.statusCode}');
  //       debugPrint('RESPONSE => ${response.body}');
  //
  //       if (response.statusCode < 200 ||
  //           response.statusCode >= 300) {
  //         requestFailed = true;
  //       } else {
  //         final decoded = jsonDecode(response.body);
  //
  //         if (decoded is Map) {
  //           debugPrint(
  //             'API STATUS => ${decoded['status']}',
  //           );
  //           debugPrint(
  //             'API MESSAGE => ${decoded['message']}',
  //           );
  //
  //           if ('${decoded['status']}' == '1') {
  //             classWorkData = decoded['data'];
  //             hasData = _hasData(classWorkData);
  //           }
  //         } else {
  //           requestFailed = true;
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint('CLASSWORK.PHP ERROR => $e');
  //     requestFailed = true;
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         openingSubject = false;
  //         selectedSubjectId = null;
  //       });
  //     }
  //   }
  //
  //   if (!mounted) return;
  //
  //   if (!hasData) {
  //     _showMessage(
  //       requestFailed
  //           ? 'Class work is unavailable right now.'
  //           : 'No class work available',
  //     );
  //     return;
  //   }
  //
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (_) => ClassWorkDetailsScreen(
  //         title: subject.subjectName,
  //         subjectId: subject.subjectId,
  //         sessionId: sessionId,
  //         classId: classId,
  //         secId: secId,
  //         detailsApi: widget.classWorkDetailsApi,
  //         initialData: classWorkData,
  //       ),
  //     ),
  //   );
  // }

  Future<void> _openSubject(ClassWorkSubject subject) async {
    if (openingSubject) return;

    _readStudentData();

    if (_sessionId.isEmpty ||
        _classId.isEmpty ||
        _secId.isEmpty ||
        widget.classWorkDetailsApi.trim().isEmpty) {
      _showMessage('Class work information is unavailable.');
      return;
    }

    setState(() {
      openingSubject = true;
      selectedSubjectId = subject.subjectId;
    });

    try {
      final payload = {
        'session_id': _sessionId,
        'class_id': _classId,
        'sec_id': _secId,
        'subject_id': subject.subjectId,
      };

      debugPrint('CLASSWORK API => ${widget.classWorkDetailsApi}');
      debugPrint('PAYLOAD => $payload');

      final response = await ApiServices().postData(
        uri: widget.classWorkDetailsApi,
        context: context,
        data: payload,
      );

      if (!mounted) return;

      if (response == null ||
          response.statusCode < 200 ||
          response.statusCode >= 300) {
        _showMessage('Unable to load class work.');
        return;
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map || '${decoded['status']}' != '1') {
        _showMessage('No class work available.');
        return;
      }

      final data = decoded['data'];

      if (data is! Map) {
        _showMessage('PDF information not found.');
        return;
      }

      final docFile = '${data['doc_file'] ?? ''}'.trim();
      final pdfTitle = '${data['name'] ?? subject.subjectName}'.trim();

      if (docFile.isEmpty || docFile == 'null') {
        _showMessage('PDF file not available.');
        return;
      }

      // Build the complete URL from the relative API path.
      final Uri baseUri = Uri.parse(widget.classWorkDetailsApi);
      // final Uri pdfUri = baseUri.resolve(docFile);
      // final Uri pdfUri = Uri.parse(basepdf).resolve(docFile);
      final Uri pdfUri = Uri.parse(
        '${basepdf}${docFile.replaceFirst('/', '')}',
      );
      debugPrint('PDF TITLE => $pdfTitle');
      debugPrint('PDF URL => $pdfUri');

      // Open the existing PDF viewer.
      Get.to(
            () => const PdfViewerScreen(),
        arguments: {
          'url': pdfUri.toString(),
          'title': pdfTitle.isEmpty ? 'Class Work' : pdfTitle,
        },
      );
    } catch (e, stackTrace) {
      debugPrint('OPEN CLASSWORK ERROR => $e');
      debugPrint('$stackTrace');

      if (mounted) {
        _showMessage('Unable to open PDF.');
      }
    } finally {
      if (mounted) {
        setState(() {
          openingSubject = false;
          selectedSubjectId = null;
        });
      }
    }
  }

  // ============================================================
  // SUBJECT CARD - NO ICONS
  // ============================================================

  Widget _subjectCard(ClassWorkSubject subject) {
    final isSelected =
        openingSubject &&
            selectedSubjectId == subject.subjectId;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFEAEAEA),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: openingSubject
              ? null
              : () => _openSubject(subject),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 18.w,
              vertical: 20.h,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    subject.subjectName,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF222222),
                    ),
                  ),
                ),
                if (isSelected)
                  SizedBox(
                    height: 18.w,
                    width: 18.w,
                    child: const CircularProgressIndicator(
                      color: maincolor,
                      strokeWidth: 2,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SUBJECT LIST SCREEN UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Class Work'),

            Expanded(
              child: RefreshIndicator(
                color: maincolor,
                onRefresh: _loadSubjects,
                child: loading && subjects.isEmpty
                    ? const Center(
                  child: CircularProgressIndicator(
                    color: maincolor,
                  ),
                )
                    : subjects.isEmpty
                    ? ListView(
                  physics:
                  const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: 120.h),
                    Center(
                      child: Text(
                        listError ??
                            'No subjects available',
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    if (listError != null)
                      Padding(
                        padding: EdgeInsets.all(18.w),
                        child: Center(
                          child: TextButton(
                            onPressed: _loadSubjects,
                            child: const Text('Retry'),
                          ),
                        ),
                      ),
                  ],
                )
                    : ListView.builder(
                  physics:
                  const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    16.w,
                    18.h,
                    16.w,
                    24.h,
                  ),
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    return _subjectCard(subjects[index]);
                  },
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
// CLASS WORK DETAILS SCREEN
// ============================================================

class ClassWorkDetailsScreen extends StatefulWidget {
  final String title;
  final String subjectId;
  final String sessionId;
  final String classId;
  final String secId;
  final String detailsApi;
  final dynamic initialData;

  const ClassWorkDetailsScreen({
    super.key,
    required this.title,
    required this.subjectId,
    required this.sessionId,
    required this.classId,
    required this.secId,
    required this.detailsApi,
    this.initialData,
  });

  @override
  State<ClassWorkDetailsScreen> createState() =>
      _ClassWorkDetailsScreenState();
}

class _ClassWorkDetailsScreenState
    extends State<ClassWorkDetailsScreen> {
  bool loading = false;
  dynamic result;

  @override
  void initState() {
    super.initState();

    // Data already fetched on subject click.
    result = widget.initialData;

    if (result == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadDetails();
      });
    }
  }

  // ============================================================
  // REFRESH CLASS WORK
  // ============================================================

  Future<void> _loadDetails() async {
    if (loading) return;

    setState(() {
      loading = true;
    });

    try {
      final payload = {
        'session_id': widget.sessionId,
        'class_id': widget.classId,
        'sec_id': widget.secId,
        'subject_id': widget.subjectId,
      };

      debugPrint('========== CLASS WORK REFRESH ==========');
      debugPrint('URL => ${widget.detailsApi}');
      debugPrint('PAYLOAD => $payload');

      final response = await ApiServices().postData(
        uri: widget.detailsApi,
        context: context,
        data: payload,
      );

      if (response == null) {
        debugPrint('CLASS WORK REFRESH => Null response');
        return;
      }

      debugPrint('HTTP STATUS => ${response.statusCode}');
      debugPrint('RESPONSE => ${response.body}');

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        return;
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map) return;

      if ('${decoded['status']}' != '1') {
        if (mounted) {
          setState(() => result = null);
        }
        return;
      }

      if (!mounted) return;

      setState(() {
        result = decoded['data'];
      });
    } catch (e) {
      debugPrint('CLASS WORK REFRESH ERROR => $e');
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  bool get _isEmpty {
    if (result == null) return true;

    if (result is List) {
      return (result as List).isEmpty;
    }

    if (result is Map) {
      return (result as Map).isEmpty;
    }

    if (result is String) {
      return (result as String).trim().isEmpty;
    }

    return false;
  }

  // ============================================================
  // DETAILS UI - NO ICONS
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: widget.title),

            Expanded(
              child: RefreshIndicator(
                color: maincolor,
                onRefresh: _loadDetails,
                child: ListView(
                  physics:
                  const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(18.w),
                  children: [
                    Container(
                      padding: EdgeInsets.all(18.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(18.r),
                      ),
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF222222),
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    if (loading)
                      const LinearProgressIndicator(
                        color: maincolor,
                      ),

                    if (_isEmpty && !loading)
                      const Center(
                        child: Text(
                          'No class work available',
                        ),
                      ),

                    if (!_isEmpty)
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.circular(16.r),
                        ),
                        child: SelectableText(
                          const JsonEncoder.withIndent('  ')
                              .convert(result),
                          style: TextStyle(
                            fontSize: 12.sp,
                            height: 1.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
