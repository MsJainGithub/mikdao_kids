// To parse this JSON data, do
//
//     final installmentModal = installmentModalFromJson(jsonString);

import 'dart:convert';

InstallmentModal installmentModalFromJson(String str) => InstallmentModal.fromJson(json.decode(str));

String installmentModalToJson(InstallmentModal data) => json.encode(data.toJson());

class InstallmentModal {
  DataInstalment? data;
  String? message;
  int? status;

  InstallmentModal({
    this.data,
    this.message,
    this.status,
  });

  factory InstallmentModal.fromJson(Map<String, dynamic> json) => InstallmentModal(
    data: json["data"] == null ? null : DataInstalment.fromJson(json["data"]),
    message: json["message"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": data?.toJson(),
    "message": message,
    "status": status,
  };
}

class DataInstalment {
  String? name;
  String? docFile;
  List<Installment>? installment;

  DataInstalment({
    this.name,
    this.docFile,
    this.installment,
  });

  factory DataInstalment.fromJson(Map<String, dynamic> json) => DataInstalment(
    name: json["name"],
    docFile: json["doc_file"],
    installment: json["installment"] == null ? [] : List<Installment>.from(json["installment"]!.map((x) => Installment.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "doc_file": docFile,
    "installment": installment == null ? [] : List<dynamic>.from(installment!.map((x) => x.toJson())),
  };
}

class Installment {
  String? installment;
  String? amount;
  DateTime? date;
  String? status;
  dynamic is_blink;

  Installment({
    this.installment,
    this.amount,
    this.date,
    this.status,
    this.is_blink,
  });

  factory Installment.fromJson(Map<String, dynamic> json) => Installment(
    installment: json["installment"],
    amount: json["amount"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    status: json["status"],
    is_blink: json["is_blink"],
  );

  Map<String, dynamic> toJson() => {
    "installment": installment,
    "amount": amount,
    "date": "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
    "status": status,
    "is_blink": is_blink,
  };
}
