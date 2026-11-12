import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../config/appConfig.dart';
import '../services/apiServices.dart';
import '../providers/userProvider.dart';
import '../widgets/toast.dart';

class EarlyDepartureProvider extends ChangeNotifier {
  // ============================================================
  // FORM STATE
  // ============================================================

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  String? selectedPerson;

  final TextEditingController otherPersonController =
  TextEditingController();

  final TextEditingController contactController =
  TextEditingController();

  final TextEditingController reasonController =
  TextEditingController();

  // ============================================================
  // PERSON API STATE
  // ============================================================

  String fatherName = "";
  String motherName = "";
  String guardianName = "";

  bool isUserInfoLoading = false;
  String? userInfoError;

  /// Dropdown values.
  ///
  /// Father/Mother/Guardian names are fetched from API.
  /// Other remains manual.
  List<String> persons = [];

  // ============================================================
  // LIST STATE
  // ============================================================

  List<EarlyDepartureModel> departureList = [];

  bool isLoading = false;
  bool isSubmitting = false;

  // ============================================================
  // SETTERS
  // ============================================================

  void setDate(DateTime? date) {
    selectedDate = date;
    notifyListeners();
  }

  void setTime(TimeOfDay? time) {
    selectedTime = time;
    notifyListeners();
  }

  void setPerson(String? person) {
    selectedPerson = person;

    if (person != "Other") {
      otherPersonController.clear();
    }

    notifyListeners();
  }

  // ============================================================
  // PERSON DISPLAY NAME
  // ============================================================

  String getPersonDisplayName(String person) {
    switch (person) {
      case "Father":
        return fatherName;

      case "Mother":
        return motherName;

      case "Guardian":
        return guardianName;

      case "Other":
        return "Enter manually";

      default:
        return "";
    }
  }

  // ============================================================
  // ACTUAL SELECTED PERSON NAME
  // ============================================================

  String getSelectedPersonName() {
    switch (selectedPerson) {
      case "Father":
        return fatherName.trim();

      case "Mother":
        return motherName.trim();

      case "Guardian":
        return guardianName.trim();

      case "Other":
        return otherPersonController.text.trim();

      default:
        return "";
    }
  }

  // ============================================================
  // USER INFO API
  // ============================================================

  Future<void> getUserInfo(BuildContext context) async {
    final UserProvider up = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    if (up.userId.isEmpty) {
      fatherName = "";
      motherName = "";
      guardianName = "";

      persons = ["Other"];

      userInfoError =
      "Student information not found.";

      notifyListeners();
      return;
    }

    isUserInfoLoading = true;
    userInfoError = null;

    notifyListeners();

    try {
      final response = await ApiServices().postData(
        uri: userDetail,

        context: context,

        // IMPORTANT:
        // ProfileProvider mein bhi exactly "id" use ho raha hai.
        data: {
          "id": up.userId.toString(),
        },

        showToast: false,
      );

      if (response == null) {
        throw Exception(
          "No response from user info API",
        );
      }

      debugPrint(
        "User info response: ${response.body}",
      );

      final decoded =
      json.decode(response.body);

      if (decoded["status"] == 1 &&
          decoded["data"] != null) {
        final Map<String, dynamic> data =
        Map<String, dynamic>.from(
          decoded["data"],
        );

        // API fields
        fatherName =
            data["fathername"]?.toString().trim() ?? "";

        motherName =
            data["mname"]?.toString().trim() ?? "";

        guardianName =
            data["guardianname"]?.toString().trim() ?? "";

        // Build dropdown
        _buildPersonsList();

        userInfoError = null;

        debugPrint(
          "Father: $fatherName",
        );

        debugPrint(
          "Mother: $motherName",
        );

        debugPrint(
          "Guardian: $guardianName",
        );

        debugPrint(
          "Persons: $persons",
        );
      } else {
        fatherName = "";
        motherName = "";
        guardianName = "";

        persons = ["Other"];

        userInfoError =
            decoded["message"]?.toString() ??
                "Unable to load family details.";
      }
    } catch (e) {
      debugPrint(
        "User info error: $e",
      );

      fatherName = "";
      motherName = "";
      guardianName = "";

      persons = ["Other"];

      userInfoError =
      "Unable to load person details.";
    } finally {
      isUserInfoLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // BUILD PERSON LIST
  // ============================================================

  void _buildPersonsList() {
    persons = [];

    if (fatherName.isNotEmpty) {
      persons.add("Father");
    }

    if (motherName.isNotEmpty) {
      persons.add("Mother");
    }

    if (guardianName.isNotEmpty) {
      persons.add("Guardian");
    }

    // Other always available
    persons.add("Other");

    // Reset invalid selection
    if (selectedPerson != null &&
        !persons.contains(selectedPerson)) {
      selectedPerson = null;
    }
  }

  // ============================================================
  // DATE VALIDATION
  // ============================================================

  bool isValidDate(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final lastDate = today.add(
      const Duration(days: 3),
    );

    final selected = DateTime(
      date.year,
      date.month,
      date.day,
    );

    return !selected.isBefore(today) &&
        !selected.isAfter(lastDate);
  }

  // ============================================================
  // TIME VALIDATION
  // ============================================================

  bool isValidTime(TimeOfDay time) {
    final totalMinutes =
        time.hour * 60 + time.minute;

    const startMinutes = 9 * 60;
    const endMinutes = 16 * 60;

    return totalMinutes >= startMinutes &&
        totalMinutes <= endMinutes;
  }

  // ============================================================
  // FORM VALIDATION
  // ============================================================

  bool validateForm() {
    if (selectedDate == null) {
      _showError(
        "Please select departure date.",
      );
      return false;
    }

    if (selectedTime == null) {
      _showError(
        "Please select departure time.",
      );
      return false;
    }

    if (!isValidDate(selectedDate!)) {
      _showError(
        "Departure date must be within the allowed date range.",
      );
      return false;
    }

    if (!isValidTime(selectedTime!)) {
      _showError(
        "Departure time must be between 9:00 AM and 4:00 PM.",
      );
      return false;
    }

    if (selectedPerson == null) {
      _showError(
        "Please select person details.",
      );
      return false;
    }

    final personName =
    getSelectedPersonName();

    if (personName.isEmpty) {
      _showError(
        "Please enter/select person's name.",
      );
      return false;
    }

    final contact =
    contactController.text.trim();

    if (contact.isEmpty) {
      _showError(
        "Please enter contact details.",
      );
      return false;
    }

    if (contact.length != 10) {
      _showError(
        "Please enter a valid 10 digit contact number.",
      );
      return false;
    }

    final reason =
    reasonController.text.trim();

    if (reason.isEmpty) {
      _showError(
        "Please enter reason.",
      );
      return false;
    }

    return true;
  }

  // ============================================================
  // LOAD REQUESTS
  // ============================================================

  Future<void> getDepartureRequests(
      BuildContext context,
      ) async {
    final UserProvider up =
    Provider.of<UserProvider>(
      context,
      listen: false,
    );

    if (up.userId.isEmpty) {
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final response =
      await ApiServices().postData(
        uri: earlyDepartureList,
        context: context,
        data: {
          "student_id":
          up.userId.toString(),
        },
        showToast: false,
      );

      if (response != null) {
        debugPrint(
          "Early departure list response: "
              "${response.body}",
        );

        final decoded =
        json.decode(response.body);

        final data = decoded["data"];

        if (data is List) {
          departureList = data
              .map(
                (e) =>
                EarlyDepartureModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
          )
              .toList();
        } else {
          departureList = [];
        }
      }
    } catch (e) {
      debugPrint(
        "Early departure list error: $e",
      );

      departureList = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // SUBMIT REQUEST
  // ============================================================

  Future<bool> submitRequest(
      BuildContext context,
      ) async {
    if (!validateForm()) {
      return false;
    }

    final UserProvider up =
    Provider.of<UserProvider>(
      context,
      listen: false,
    );

    if (up.userId.isEmpty) {
      _showError(
        "Student information not found.",
      );
      return false;
    }

    isSubmitting = true;
    notifyListeners();

    /*
     * IMPORTANT:
     *
     * This returns:
     *
     * Father   -> MANISH JAIN
     * Mother   -> SAPNA JAIN
     * Guardian -> MANJULA JAIN
     * Other    -> manually entered name
     */
    final String person =
    getSelectedPersonName();

    final String date =
        "${selectedDate!.year}-"
        "${selectedDate!.month.toString().padLeft(2, '0')}-"
        "${selectedDate!.day.toString().padLeft(2, '0')}";

    final String time =
        "${selectedTime!.hour.toString().padLeft(2, '0')}:"
        "${selectedTime!.minute.toString().padLeft(2, '0')}";

    try {
      final response =
      await ApiServices().postData(
        uri: earlyDepartureSubmit,
        context: context,
        data: {
          "student_id":
          up.userId.toString(),

          "departure_date":
          date,

          "departure_time":
          time,

          "person_name":
          person,

          "contact":
          contactController.text.trim(),

          "reason":
          reasonController.text.trim(),
        },
      );

      if (response != null) {
        debugPrint(
          "Early departure submit response: "
              "${response.body}",
        );

        final decoded =
        json.decode(response.body);

        final message =
            decoded["message"]?.toString() ??
                "Early departure request submitted successfully.";

        showToastE(
          message: message,
        );

        clearForm();

        await getDepartureRequests(
          context,
        );

        return true;
      }
    } catch (e) {
      debugPrint(
        "Early departure submit error: $e",
      );

      _showError(
        "Something went wrong. Please try again.",
      );
    } finally {
      isSubmitting = false;
      notifyListeners();
    }

    return false;
  }

  // ============================================================
  // CLEAR FORM
  // ============================================================

  void clearForm() {
    selectedDate = null;
    selectedTime = null;
    selectedPerson = null;

    otherPersonController.clear();
    contactController.clear();
    reasonController.clear();

    notifyListeners();
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(String message) {
    Get.snackbar(
      "Required",
      message,
      snackPosition:
      SnackPosition.BOTTOM,
      backgroundColor:
      Colors.red.shade50,
      colorText:
      Colors.red.shade900,
      margin:
      const EdgeInsets.all(12),
      borderRadius: 12,
      icon: const Icon(
        Icons.error_outline,
        color: Colors.red,
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    otherPersonController.dispose();
    contactController.dispose();
    reasonController.dispose();

    super.dispose();
  }
}

// ================================================================
// MODEL
// ================================================================

class EarlyDepartureModel {
  final String id;
  final String date;
  final String time;
  final String person;
  final String contact;
  final String reason;
  final String status;

  EarlyDepartureModel({
    required this.id,
    required this.date,
    required this.time,
    required this.person,
    required this.contact,
    required this.reason,
    required this.status,
  });

  factory EarlyDepartureModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return EarlyDepartureModel(
      id: json["id"]?.toString() ?? "",

      date: json["date"]?.toString() ??
          json["departure_date"]?.toString() ??
          "",

      time: json["time"]?.toString() ??
          json["departure_time"]?.toString() ??
          "",

      person:
      json["person_name"]?.toString() ??
          "",

      contact:
      json["contact"]?.toString() ??
          "",

      reason:
      json["reason"]?.toString() ??
          "",

      status:
      json["status"]?.toString() ??
          "Pending",
    );
  }
}

// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:provider/provider.dart';
//
// import '../config/appConfig.dart';
// import '../services/apiServices.dart';
// import '../providers/userProvider.dart';
// import '../widgets/toast.dart';
//
// class EarlyDepartureProvider extends ChangeNotifier {
//   // ============================================================
//   // FORM STATE
//   // ============================================================
//
//   DateTime? selectedDate;
//   TimeOfDay? selectedTime;
//
//   String? selectedPerson;
//
//   final List<String> persons = [
//     "Father",
//     "Mother",
//     "Guardian",
//     "Brother",
//     "Sister",
//     "Other",
//   ];
//
//   final TextEditingController otherPersonController =
//   TextEditingController();
//
//   final TextEditingController contactController =
//   TextEditingController();
//
//   final TextEditingController reasonController =
//   TextEditingController();
//
//   // ============================================================
//   // LIST STATE
//   // ============================================================
//
//   List<EarlyDepartureModel> departureList = [];
//
//   bool isLoading = false;
//   bool isSubmitting = false;
//
//   // ============================================================
//   // SETTERS
//   // ============================================================
//
//   void setDate(DateTime? date) {
//     selectedDate = date;
//     notifyListeners();
//   }
//
//   void setTime(TimeOfDay? time) {
//     selectedTime = time;
//     notifyListeners();
//   }
//
//   void setPerson(String? person) {
//     selectedPerson = person;
//
//     if (person != "Other") {
//       otherPersonController.clear();
//     }
//
//     notifyListeners();
//   }
//
//   // ============================================================
//   // DATE VALIDATION
//   // ============================================================
//
//   bool isValidDate(DateTime date) {
//     final now = DateTime.now();
//
//     final today = DateTime(
//       now.year,
//       now.month,
//       now.day,
//     );
//
//     final lastDate = today.add(
//       const Duration(days: 3),
//     );
//
//     final selected = DateTime(
//       date.year,
//       date.month,
//       date.day,
//     );
//
//     return !selected.isBefore(today) &&
//         !selected.isAfter(lastDate);
//   }
//
//   // ============================================================
//   // TIME VALIDATION
//   // ============================================================
//
//   bool isValidTime(TimeOfDay time) {
//     final totalMinutes =
//         time.hour * 60 + time.minute;
//
//     const startMinutes = 9 * 60;
//     const endMinutes = 16 * 60;
//
//     return totalMinutes >= startMinutes &&
//         totalMinutes <= endMinutes;
//   }
//
//   // ============================================================
//   // FORM VALIDATION
//   // ============================================================
//
//   bool validateForm() {
//     if (selectedDate == null) {
//       _showError(
//         "Please select departure date.",
//       );
//       return false;
//     }
//
//     if (selectedTime == null) {
//       _showError(
//         "Please select departure time.",
//       );
//       return false;
//     }
//
//     if (!isValidDate(selectedDate!)) {
//       _showError(
//         "Departure date must be within the allowed date range.",
//       );
//       return false;
//     }
//
//     if (!isValidTime(selectedTime!)) {
//       _showError(
//         "Departure time must be between 9:00 AM and 4:00 PM.",
//       );
//       return false;
//     }
//
//     if (selectedPerson == null) {
//       _showError(
//         "Please select person details.",
//       );
//       return false;
//     }
//
//     if (selectedPerson == "Other" &&
//         otherPersonController.text.trim().isEmpty) {
//       _showError(
//         "Please enter person's name.",
//       );
//       return false;
//     }
//
//     final contact =
//     contactController.text.trim();
//
//     if (contact.isEmpty) {
//       _showError(
//         "Please enter contact details.",
//       );
//       return false;
//     }
//
//     if (contact.length != 10) {
//       _showError(
//         "Please enter a valid 10 digit contact number.",
//       );
//       return false;
//     }
//
//     if (reasonController.text.trim().isEmpty) {
//       _showError(
//         "Please enter reason.",
//       );
//       return false;
//     }
//
//     return true;
//   }
//
//   // ============================================================
//   // LOAD REQUESTS
//   // ============================================================
//
//   Future<void> getDepartureRequests(BuildContext context) async {
//     final UserProvider up = Provider.of<UserProvider>(
//       context,
//       listen: false,
//     );
//
//     if (up.userId.isEmpty) {
//       return;
//     }
//
//     isLoading = true;
//     notifyListeners();
//
//     try {
//       final response = await ApiServices().postData(
//         uri: earlyDepartureList,
//         context: context,
//         data: {
//           // IMPORTANT:
//           // early_departure_list.php expects student_id
//           "student_id": up.userId.toString(),
//         },
//         showToast: false,
//       );
//
//       if (response != null) {
//         debugPrint("Early departure list response: ${response.body}");
//
//         final decoded = json.decode(response.body);
//
//         final data = decoded["data"];
//
//         if (data is List) {
//           departureList = data
//               .map(
//                 (e) => EarlyDepartureModel.fromJson(
//               Map<String, dynamic>.from(e),
//             ),
//           )
//               .toList();
//         } else {
//           departureList = [];
//         }
//       }
//     } catch (e) {
//       debugPrint(
//         "Early departure list error: $e",
//       );
//
//       departureList = [];
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }
//
//
//   // ============================================================
//   // SUBMIT REQUEST
//   // ============================================================
//
//   Future<bool> submitRequest(
//       BuildContext context,
//       ) async {
//     if (!validateForm()) {
//       return false;
//     }
//
//     final UserProvider up =
//     Provider.of<UserProvider>(
//       context,
//       listen: false,
//     );
//
//     if (up.userId.isEmpty) {
//       _showError(
//         "Student information not found.",
//       );
//       return false;
//     }
//
//     isSubmitting = true;
//     notifyListeners();
//
//     final String person =
//     selectedPerson == "Other"
//         ? otherPersonController.text.trim()
//         : selectedPerson!;
//
//     final String date =
//         "${selectedDate!.year}-"
//         "${selectedDate!.month.toString().padLeft(2, '0')}-"
//         "${selectedDate!.day.toString().padLeft(2, '0')}";
//
//     final String time =
//         "${selectedTime!.hour.toString().padLeft(2, '0')}:"
//         "${selectedTime!.minute.toString().padLeft(2, '0')}";
//
//     try {
//       final response =
//       await ApiServices().postData(
//         uri: earlyDepartureSubmit,
//         context: context,
//         data: {
//           "student_id":
//           up.userId.toString(),
//
//           "departure_date":
//           date,
//
//           "departure_time":
//           time,
//
//           "person_name":
//           person,
//
//           "contact":
//           contactController.text.trim(),
//
//           "reason":
//           reasonController.text.trim(),
//         },
//       );
//
//       if (response != null) {
//         final decoded =
//         json.decode(response.body);
//
//         final message =
//             decoded["message"]?.toString() ??
//                 "Early departure request submitted successfully.";
//
//         showToastE(
//           message: message,
//         );
//
//         clearForm();
//
//         await getDepartureRequests(
//           context,
//         );
//
//         return true;
//       }
//     } catch (e) {
//       debugPrint(
//         "Early departure submit error: $e",
//       );
//
//       _showError(
//         "Something went wrong. Please try again.",
//       );
//     } finally {
//       isSubmitting = false;
//       notifyListeners();
//     }
//
//     return false;
//   }
//
//   // ============================================================
//   // CLEAR FORM
//   // ============================================================
//
//   void clearForm() {
//     selectedDate = null;
//     selectedTime = null;
//     selectedPerson = null;
//
//     otherPersonController.clear();
//     contactController.clear();
//     reasonController.clear();
//
//     notifyListeners();
//   }
//
//   // ============================================================
//   // ERROR
//   // ============================================================
//
//   void _showError(String message) {
//     Get.snackbar(
//       "Required",
//       message,
//       snackPosition:
//       SnackPosition.BOTTOM,
//       backgroundColor:
//       Colors.red.shade100,
//       colorText:
//       Colors.red.shade900,
//       margin:
//       const EdgeInsets.all(12),
//     );
//   }
//
//   // ============================================================
//   // DISPOSE
//   // ============================================================
//
//   @override
//   void dispose() {
//     otherPersonController.dispose();
//     contactController.dispose();
//     reasonController.dispose();
//
//     super.dispose();
//   }
// }
//
//
// // ================================================================
// // MODEL
// // ================================================================
//
// class EarlyDepartureModel {
//   final String id;
//   final String date;
//   final String time;
//   final String person;
//   final String contact;
//   final String reason;
//   final String status;
//
//   EarlyDepartureModel({
//     required this.id,
//     required this.date,
//     required this.time,
//     required this.person,
//     required this.contact,
//     required this.reason,
//     required this.status,
//   });
//
//   factory EarlyDepartureModel.fromJson(
//       Map<String, dynamic> json,
//       ) {
//     return EarlyDepartureModel(
//       id: json["id"]?.toString() ?? "",
//       date: json["date"]?.toString() ??
//           json["departure_date"]?.toString() ??
//           "",
//       time: json["time"]?.toString() ??
//           json["departure_time"]?.toString() ??
//           "",
//       person: json["person_name"]?.toString() ?? "",
//       contact: json["contact"]?.toString() ?? "",
//       reason: json["reason"]?.toString() ?? "",
//       status: json["status"]?.toString() ??
//           "Pending",
//     );
//   }
// }
