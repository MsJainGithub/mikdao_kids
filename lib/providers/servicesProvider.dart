
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:mikado_kids/providers/profileProvider.dart';
import '../config/appConfig.dart';
import '../services/apiServices.dart';
import '../widgets/toast.dart';
import 'feeProvider.dart';

class ServicesProvider extends ChangeNotifier {
  String? pdfUrl;


  Future<void> getData(
      BuildContext context,
      String url,
      String title,
      ) async {
    final classId =
        Provider.of<ProfileProvider>(context, listen: false)
            .dataUser
            ?.class_id;

    final feeProvider =
    Provider.of<FeeProvider>(context, listen: false);

    final currentSessionId = feeProvider.currentSessionId;

    pdfUrl = null;
    notifyListeners();

    try {
      final payload = {
        "session_id": currentSessionId,
        "class_id": classId ?? "",
      };

      debugPrint('========== $title ==========');
      debugPrint('API URL => $url');
      debugPrint('API PAYLOAD => $payload');

      final response = await ApiServices().postData(
        uri: url,
        context: context,
        data: payload,
      );

      if (response == null) {
        _showComingSoon(title);
        return;
      }

      debugPrint('API RESPONSE => ${response.body}');

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        _showComingSoon(title);
        return;
      }

      final dynamic data = decoded['data'];

      final dynamic document =
      data is Map ? data['doc_file'] : null;

      final String filePath =
          document?.toString().trim() ?? '';

      // PDF is not available
      if (filePath.isEmpty ||
          filePath.toLowerCase() == 'null' ||
          filePath.toLowerCase() == 'undefined') {
        _showComingSoon(title);
        return;
      }

      final uri = Uri.tryParse(filePath);

      if (uri == null) {
        _showComingSoon(title);
        return;
      }

      // Resolve relative paths and preserve full URLs.
      final Uri resolvedUri;

      if (uri.hasScheme) {
        resolvedUri = uri;
      } else {
        final relativePath = filePath.startsWith('/')
            ? filePath.substring(1)
            : filePath;

        resolvedUri = Uri.parse(basepdf).resolve(relativePath);
      }

      if (resolvedUri.scheme != 'https' &&
          resolvedUri.scheme != 'http') {
        _showComingSoon(title);
        return;
      }

      pdfUrl = resolvedUri.toString();

      debugPrint('FINAL PDF URL => $pdfUrl');

      notifyListeners();

      Get.toNamed(
        '/pdfViewerScreen',
        arguments: {
          'url': pdfUrl,
          'title': title,
        },
      );
    } catch (e, stackTrace) {
      debugPrint('PDF ERROR => $e');
      debugPrint('$stackTrace');

      _showComingSoon(title);
    }
  }

  void _showComingSoon(String title) {
    Get.dialog(
      CupertinoAlertDialog(
        title: const Text('Coming Soon'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            '$title is not available right now. Please check back soon.',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Get.back();
            },
            child: const Text('OK'),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }
}

// import 'dart:convert';
//
// import 'package:flutter/cupertino.dart';
// import 'package:get/get.dart';
// import 'package:school/providers/profileProvider.dart';
// import 'package:provider/provider.dart';
//
// import '../config/appConfig.dart';
// import '../services/apiServices.dart';
// import '../widgets/toast.dart';
// import 'feeProvider.dart';
//
// class ServicesProvider extends ChangeNotifier {
//   String? pdfUrl;
//
//   Future<void> getData(
//       BuildContext context,
//       String url,
//       String title,
//       ) async {
//     final classId =
//         Provider.of<ProfileProvider>(context, listen: false)
//             .dataUser
//             ?.class_id;
//
//     final feeProvider =
//     Provider.of<FeeProvider>(context, listen: false);
//
//     final currentSessionId = feeProvider.currentSessionId;
//
//     pdfUrl = null;
//     notifyListeners();
//
//     try {
//       final payload = {
//         "session_id": currentSessionId,
//         "class_id": classId ?? "",
//       };
//
//       debugPrint('========== $title ==========');
//       debugPrint('API URL => $url');
//       debugPrint('API PAYLOAD => $payload');
//
//       final response = await ApiServices().postData(
//         uri: url,
//         context: context,
//         data: payload,
//       );
//
//       if (response == null) {
//         showToastE(message: 'Unable to fetch $title');
//         return;
//       }
//
//       debugPrint('API RESPONSE => ${response.body}');
//
//       final decoded = jsonDecode(response.body);
//
//       if (decoded is! Map<String, dynamic>) {
//         showToastE(message: 'Invalid API response');
//         return;
//       }
//
//       final data = decoded['data'];
//
//       final dynamic document =
//       data is Map ? data['doc_file'] : null;
//
//       final filePath = document?.toString().trim() ?? '';
//
//       if (filePath.isEmpty || filePath.toLowerCase() == 'null') {
//         showToastE(
//           message: decoded['message']?.toString() ??
//               '$title PDF not available',
//         );
//         return;
//       }
//
//       final uri = Uri.tryParse(filePath);
//
//       if (uri == null) {
//         showToastE(message: 'Invalid PDF path');
//         return;
//       }
//
//       // Full HTTPS URL or server-relative file path
//       final resolvedUri = uri.hasScheme
//           ? uri
//           : Uri.parse(baseU).resolveUri(uri);
//
//       if (resolvedUri.scheme != 'https' &&
//           resolvedUri.scheme != 'http') {
//         showToastE(message: 'Invalid PDF URL');
//         return;
//       }
//
//       pdfUrl = resolvedUri.toString();
//
//       debugPrint('FINAL PDF URL => $pdfUrl');
//
//       notifyListeners();
//
//       Get.toNamed(
//         '/pdfViewerScreen',
//         arguments: {
//           'url': pdfUrl,
//           'title': title,
//         },
//       );
//     } catch (e) {
//       debugPrint('PDF ERROR => $e');
//
//       showToastE(
//         message: 'Failed to open $title',
//       );
//     }
//   }
// }
// // import 'dart:convert';
// //
// // import 'package:flutter/cupertino.dart';
// // import 'package:get/get.dart';
// // import 'package:school/providers/profileProvider.dart';
// // import 'package:provider/provider.dart';
// //
// // import '../services/apiServices.dart';
// // import '../widgets/toast.dart';
// // import 'feeProvider.dart';
// //
// // class ServicesProvider extends ChangeNotifier {
// //   String? pdfUrl;
// //
// //   Future<void> getData(BuildContext context, url, title) async {
// //     final classId =
// //         Provider.of<ProfileProvider>(context, listen: false).dataUser?.class_id;
// //     final currentSessionId =
// //         Provider.of<FeeProvider>(context, listen: false).currentSessionId;
// //     final currentSession =
// //         Provider.of<FeeProvider>(context, listen: false).currentSession;
// //     pdfUrl = null;
// //     notifyListeners();
// //     ApiServices().postData(uri: url, context: context, data: {
// //       "session_id": currentSessionId,
// //       "class_id": classId ?? "",
// //     }).then((value) {
// //       if (value != null) {
// //         pdfUrl = json.decode(value.body)["data"]["doc_file"];
// //         if (pdfUrl != null) {
// //           Get.toNamed('/pdfViewerScreen', arguments: {
// //             "url": pdfUrl,
// //             "title": "${title}"
// //             // "title": "${title}-${currentSession}"
// //           });
// //         } else {
// //           showToastE(message: json.decode(value.body)["message"]);
// //         }
// //
// //         notifyListeners();
// //       }
// //     });
// //   }
// // }
