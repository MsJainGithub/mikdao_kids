import 'dart:convert';

PaymentOrderModal paymentOrderModalFromJson(String str) =>
    PaymentOrderModal.fromJson(json.decode(str));

String paymentOrderModalToJson(PaymentOrderModal data) =>
    json.encode(data.toJson());

class PaymentOrderModal {
  bool status;
  String? message;
  PaymentData? data;

  PaymentOrderModal({
    required this.status,
    this.message,
    this.data,
  });

  factory PaymentOrderModal.fromJson(Map<String, dynamic> json) =>
      PaymentOrderModal(
        status: json["status"] == true || json["status"] == 1,
        message: json["message"],
        data: json["data"] == null
            ? null
            : PaymentData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class PaymentData {
  String orderId;
  double amount;

  PaymentData({
    required this.orderId,
    required this.amount,
  });

  factory PaymentData.fromJson(Map<String, dynamic> json) => PaymentData(
    orderId: json["order_id"].toString(),
    amount: double.parse(json["amount"].toString()),
  );

  Map<String, dynamic> toJson() => {
    "order_id": orderId,
    "amount": amount,
  };
}