// To parse this JSON data, do
//
//     final feeDetailModal = feeDetailModalFromJson(jsonString);

import 'dart:convert';

FeeDetailModal feeDetailModalFromJson(String str) => FeeDetailModal.fromJson(json.decode(str));

String feeDetailModalToJson(FeeDetailModal data) => json.encode(data.toJson());

class FeeDetailModal {
  String? subTotal;
  String? discount;
  String? siblingDiscount;
  String? lumsumDiscount;
  String? paid;
  String? fine;
  String? due;
  String? totalPaidWithFine;
  String? unpaid_amount;
  String? fee_status;
  String? qr;
  String? show_image;
  List<DetailFee>? detail;
  int? status;

  FeeDetailModal({
    this.subTotal,
    this.discount,
    this.siblingDiscount,
    this.lumsumDiscount,
    this.paid,
    this.fine,
    this.totalPaidWithFine,
    this.detail,
    this.status,
    this.due,
    this.fee_status,
    this.qr,
    this.show_image,
    this.unpaid_amount,
  });

  factory FeeDetailModal.fromJson(Map<String, dynamic> json) => FeeDetailModal(
    subTotal: json["sub_total"],
    discount: json["discount"],
    siblingDiscount: json["sibling_discount"],
    lumsumDiscount: json["lumsum_discount"],
    paid: json["paid"],
    fine: json["fine"],
    fee_status: json["fee_status"],
    totalPaidWithFine: json["total_paid_with_fine"],
    detail: json["detail"] == null ? [] : List<DetailFee>.from(json["detail"]!.map((x) => DetailFee.fromJson(x))),
    status: json["status"],
    qr: json["qr"],
    unpaid_amount: json["unpaid_amount"],
    show_image: json["show_image"],
    due: json["due"],
  );

  Map<String, dynamic> toJson() => {
    "sub_total": subTotal,
    "discount": discount,
    "sibling_discount": siblingDiscount,
    "lumsum_discount": lumsumDiscount,
    "paid": paid,
    "fine": fine,
    "fee_status": fee_status,
    "total_paid_with_fine": totalPaidWithFine,
    "detail": detail == null ? [] : List<dynamic>.from(detail!.map((x) => x.toJson())),
    "status": status,
    "qr": qr,
    "show_image": show_image,
    "unpaid_amount": unpaid_amount,
    "due": due,
  };
}

class DetailFee {
  String? receiptno;
  DateTime? date;
  String? collectBy;
  String? remarks;
  String? payvia;
  String? fullAmount;
  String? discount;
  String? siblingDiscount;
  String? lumAmt;
  String? fine;
  String? amount;

  DetailFee({
    this.receiptno,
    this.date,
    this.collectBy,
    this.remarks,
    this.payvia,
    this.fullAmount,
    this.discount,
    this.siblingDiscount,
    this.lumAmt,
    this.fine,
    this.amount,
  });

  factory DetailFee.fromJson(Map<String, dynamic> json) => DetailFee(
    receiptno: json["receiptno"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    collectBy: json["collect_by"],
    remarks: json["remarks"],
    payvia: json["payvia"],
    fullAmount: json["full_amount"],
    discount: json["discount"],
    siblingDiscount: json["sibling_discount"],
    lumAmt: json["lum_amt"],
    fine: json["fine"],
    amount: json["amount"],
  );

  Map<String, dynamic> toJson() => {
    "receiptno": receiptno,
    "date": "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
    "collect_by": collectBy,
    "remarks": remarks,
    "payvia": payvia,
    "full_amount": fullAmount,
    "discount": discount,
    "sibling_discount": siblingDiscount,
    "lum_amt": lumAmt,
    "fine": fine,
    "amount": amount,
  };
}
