// To parse this JSON data, do
//
//     final sessionModal = sessionModalFromJson(jsonString);

import 'dart:convert';

SessionModal sessionModalFromJson(String str) => SessionModal.fromJson(json.decode(str));

String sessionModalToJson(SessionModal data) => json.encode(data.toJson());

class SessionModal {
  List<DatumSession>? data;
  String? currentSession;
  String? message;
  int? status;

  SessionModal({
    this.data,
    this.currentSession,
    this.message,
    this.status,
  });

  factory SessionModal.fromJson(Map<String, dynamic> json) => SessionModal(
    data: json["data"] == null ? [] : List<DatumSession>.from(json["data"]!.map((x) => DatumSession.fromJson(x))),
    currentSession: json["current_session"],
    message: json["message"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "current_session": currentSession,
    "message": message,
    "status": status,
  };
}

class DatumSession {
  String? id;
  String? schoolYear;

  DatumSession({
    this.id,
    this.schoolYear,
  });

  factory DatumSession.fromJson(Map<String, dynamic> json) => DatumSession(
    id: json["id"],
    schoolYear: json["school_year"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "school_year": schoolYear,
  };
}
