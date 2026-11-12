// To parse this JSON data, do
//
//     final userDetailModal = userDetailModalFromJson(jsonString);

import 'dart:convert';

UserDetailModal userDetailModalFromJson(String str) => UserDetailModal.fromJson(json.decode(str));

String userDetailModalToJson(UserDetailModal data) => json.encode(data.toJson());

class UserDetailModal {
  DataUser data;
  int status;

  UserDetailModal({
    required this.data,
    required this.status,
  });

  factory UserDetailModal.fromJson(Map<String, dynamic> json) => UserDetailModal(
    data: DataUser.fromJson(json["data"]),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": data.toJson(),
    "status": status,
  };
}

class DataUser {
  dynamic passwordset;
  dynamic fname;
  dynamic lname;
  dynamic aadhar;
  dynamic gender;
  dynamic category;
  dynamic religion;
  dynamic minority;
  dynamic dob;
  dynamic state;
  dynamic city;
  dynamic cityType;
  dynamic address;
  dynamic pincode;
  dynamic bname;
  dynamic bclass;
  dynamic bschool;
  dynamic sisname;
  dynamic sisclass;
  dynamic sisschool;
  dynamic schoolName;
  dynamic admNo;
  dynamic fathername;
  dynamic fmo;
  dynamic mname;
  dynamic mno;
  dynamic foccupation;
  dynamic feducation;
  dynamic moocupation;
  dynamic meducation;
  dynamic faadhar;
  dynamic maadhar;
  dynamic foffice;
  dynamic moffice;
  dynamic fpan;
  dynamic mpan;
  dynamic image;
  dynamic dataClass;
  dynamic section;
  dynamic guardianname;
  dynamic guardianmobileno;
  dynamic class_id;
  dynamic section_id;

  DataUser({
    required this.passwordset,
    required this.fname,
    required this.lname,
    required this.aadhar,
    required this.gender,
    required this.category,
    required this.religion,
    required this.minority,
    required this.dob,
    required this.state,
    required this.city,
    required this.cityType,
    required this.address,
    required this.pincode,
    required this.bname,
    required this.bclass,
    required this.bschool,
    required this.sisname,
    required this.sisclass,
    required this.sisschool,
    required this.schoolName,
    required this.admNo,
    required this.fathername,
    required this.fmo,
    required this.mname,
    required this.mno,
    required this.foccupation,
    required this.feducation,
    required this.moocupation,
    required this.meducation,
    required this.faadhar,
    required this.maadhar,
    required this.foffice,
    required this.moffice,
    required this.fpan,
    required this.mpan,
    required this.image,
    required this.dataClass,
    required this.section,
    required this.guardianname,
    required this.guardianmobileno,
     this.class_id,
  });

  factory DataUser.fromJson(Map<String, dynamic> json) => DataUser(
    passwordset: json["passwordset"]??"",
    fname: json["fname"]??"",
    lname: json["lname"]??"",
    aadhar: json["aadhar"]??"",
    gender: json["gender"]??1,
    category: json["category"]??1,
    religion: json["religion"]??1,
    minority: json["minority"]??1,
    dob: json["dob"]??"",
    state: json["state"]??"",
    city: json["city"]??"",
    cityType: json["city_type"]??1,
    address: json["address"]??"",
    pincode: json["pincode"]??"",
    bname: json["bname"]??"",
    bclass: json["bclass"]??"",
    bschool: json["bschool"]??"",
    sisname: json["sisname"]??"",
    sisclass: json["sisclass"]??"",
    sisschool: json["sisschool"]??"",
    schoolName: json["school_name"]??"",
    admNo: json["adm_no"]??"",
    fathername: json["fathername"]??"",
    fmo: json["fmo"]??"",
    mname: json["mname"]??"",
    mno: json["mno"]??"",
    foccupation: json["foccupation"]??"",
    feducation: json["feducation"]??"",
    moocupation: json["moocupation"]??"",
    meducation: json["meducation"]??"",
    faadhar: json["faadhar"]??"",
    maadhar: json["maadhar"]??"",
    foffice: json["foffice"]??"",
    moffice: json["moffice"]??"",
    fpan: json["fpan"]??"",
    mpan: json["mpan"]??"",
    image: json["image"],
    dataClass: json["class"]??"",
    section: json["section"]??"",
    guardianname: json["guardianname"]??"",
    guardianmobileno: json["guardianmobileno"]??"",
    class_id: json["class_id"]??"",
  );

  Map<String, dynamic> toJson() => {
    "passwordset": passwordset,
    "fname": fname,
    "lname": lname,
    "aadhar": aadhar,
    "gender": gender,
    "category": category,
    "religion": religion,
    "minority": minority,
    "dob": dob,
    "state": state,
    "city": city,
    "city_type": cityType,
    "address": address,
    "pincode": pincode,
    "bname": bname,
    "bclass": bclass,
    "bschool": bschool,
    "sisname": sisname,
    "sisclass": sisclass,
    "sisschool": sisschool,
    "school_name": schoolName,
    "adm_no": admNo,
    "fathername": fathername,
    "fmo": fmo,
    "mname": mname,
    "mno": mno,
    "foccupation": foccupation,
    "feducation": feducation,
    "moocupation": moocupation,
    "meducation": meducation,
    "faadhar": faadhar,
    "maadhar": maadhar,
    "foffice": foffice,
    "moffice": moffice,
    "fpan": fpan,
    "mpan": mpan,
    "image": image,
    "class": dataClass,
    "section": section,
    "guardianname": guardianname,
    "guardianmobileno": guardianmobileno,
    "class_id": class_id,
  };
}
