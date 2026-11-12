// To parse this JSON data, do
//
//     final notificationModal = notificationModalFromJson(jsonString);

import 'dart:convert';

NotificationModal notificationModalFromJson(String str) => NotificationModal.fromJson(json.decode(str));

String notificationModalToJson(NotificationModal data) => json.encode(data.toJson());

class NotificationModal {
  List<DatumNotificaltion>? data;
  String? message;
  int? status;

  NotificationModal({
    this.data,
    this.message,
    this.status,
  });

  factory NotificationModal.fromJson(Map<String, dynamic> json) => NotificationModal(
    data: json["data"] == null ? [] : List<DatumNotificaltion>.from(json["data"]!.map((x) => DatumNotificaltion.fromJson(x))),
    message: json["message"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "message": message,
    "status": status,
  };
}

class DatumNotificaltion {
  String? title;
  String? docFile;
  String? description;

  DatumNotificaltion({
    this.title,
    this.docFile,
    this.description,
  });

  factory DatumNotificaltion.fromJson(Map<String, dynamic> json) => DatumNotificaltion(
    title: json["title"],
    docFile: json["doc_file"],
    description: json["description"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "doc_file": docFile,
    "description": description,
  };
}
