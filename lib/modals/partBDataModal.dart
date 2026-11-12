// To parse this JSON data, do
//
//     final partBDataModal = partBDataModalFromJson(jsonString);

import 'dart:convert';

PartBDataModal partBDataModalFromJson(String str) => PartBDataModal.fromJson(json.decode(str));

String partBDataModalToJson(PartBDataModal data) => json.encode(data.toJson());

class PartBDataModal {
  DataPartB data;
  int status;

  PartBDataModal({
    required this.data,
    required this.status,
  });

  factory PartBDataModal.fromJson(Map<String, dynamic> json) => PartBDataModal(
    data: DataPartB.fromJson(json["data"]),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": data.toJson(),
    "status": status,
  };
}

class DataPartB {
  dynamic firstName;
  dynamic lastName;
  dynamic blood;
  dynamic height;
  dynamic weight;
  dynamic motherTounge;
  dynamic poverty;
  dynamic disadvantage;
  dynamic statusPrevious;
  dynamic lastYear;
  dynamic cityType;
  dynamic grade;
  dynamic lastPassed;
  dynamic lastMarks;
  dynamic lastAttendance;
  dynamic termCondition;

  DataPartB({
    required this.firstName,
    required this.lastName,
    required this.blood,
    required this.height,
    required this.weight,
    required this.motherTounge,
    required this.poverty,
    required this.disadvantage,
    required this.statusPrevious,
    required this.lastYear,
    required this.cityType,
    required this.grade,
    required this.lastPassed,
    required this.lastMarks,
    required this.lastAttendance,
    required this.termCondition,
  });

  factory DataPartB.fromJson(Map<String, dynamic> json) => DataPartB(
    firstName: json["first_name"],
    lastName: json["last_name"],
    blood: json["blood"],
    height: json["height"],
    weight: json["weight"],
    motherTounge: json["mother_tounge"],
    poverty: json["poverty"],
    disadvantage: json["disadvantage"],
    statusPrevious: json["status_previous"],
    lastYear: json["last_year"],
    cityType: json["city_type"],
    grade: json["grade"],
    lastPassed: json["last_passed"],
    lastMarks: json["last_marks"],
    lastAttendance: json["last_attendance"],
    termCondition: json["term_condition"],
  );

  Map<String, dynamic> toJson() => {
    "first_name": firstName,
    "last_name": lastName,
    "blood": blood,
    "height": height,
    "weight": weight,
    "mother_tounge": motherTounge,
    "poverty": poverty,
    "disadvantage": disadvantage,
    "status_previous": statusPrevious,
    "last_year": lastYear,
    "city_type": cityType,
    "grade": grade,
    "last_passed": lastPassed,
    "last_marks": lastMarks,
    "last_attendance": lastAttendance,
    "term_condition": termCondition,
  };
}
