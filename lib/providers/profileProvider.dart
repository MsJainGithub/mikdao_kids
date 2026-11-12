import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:mikado_kids/config/themeConfig.dart';
import 'package:mikado_kids/modals/userDetailsModal.dart';
import 'package:mikado_kids/providers/userProvider.dart';
import 'package:mikado_kids/services/apiServices.dart';
import 'package:http/http.dart' as http;
import '../config/appConfig.dart';
import '../generated/assets.dart';
import '../modals/partBDataModal.dart';
import '../services/imagepicker.dart';
import '../widgets/toast.dart';

class ProfileProvider extends ChangeNotifier {
  DataUser? dataUser;

  // getProfileData(BuildContext context) {
  //   dataUser = null;
  //   notifyListeners();
  //
  //   UserProvider up = Provider.of<UserProvider>(context, listen: false);
  //   ApiServices()
  //       .postData(
  //       uri: userDetail,
  //       data: {"id": up.userId.toString()},
  //       context: context)
  //       .then((response) {
  //     if (response != null) {
  //       // dataUser = userDetailModalFromJson(response.body).data;
  //       //
  //       // var d = userDetailModalFromJson(response.body).data;
  //       final modal = userDetailModalFromJson(response.body);
  //       final d = modal.data;
  //
  //       dataUser = d;
  //       if(d.passwordset=="0"){
  //         Get.offAllNamed('/passwordResetScreen',arguments: [1]);
  //       }
  //       studentFNameClt.text = d.fname;
  //       studentLNameClt.text = d.lname;
  //       studentAadharCardNoClt.text = d.aadhar;
  //
  //       studentDOBClt.text = d.dob;
  //       studentStateClt.text = d.state;
  //       studentCityClt.text = d.city;
  //
  //       studentAddressClt.text = d.address;
  //       studentPincodeClt.text = d.pincode;
  //       studentBrotherNameClt.text = d.bname;
  //       studentBrotherSchoolNameClt.text = d.bschool;
  //       studentBrotherClassClt.text = d.bclass;
  //       studentSisterNameClt.text = d.sisname;
  //       studentSisterClassClt.text = d.sisclass;
  //       studentSisterSchoolNameClt.text = d.sisschool;
  //
  //       fatherNameClt.text = d.fathername;
  //       fatherMobileNoClt.text = d.fmo;
  //       fatherPanNoClt.text = d.fpan;
  //       fatherOfficeAddressClt.text = d.foffice;
  //       fatherAadharNoClt.text = d.faadhar;
  //       fatherQualificationClt.text = d.feducation;
  //       fatherOccupationClt.text = d.foccupation;
  //
  //       motherNameClt.text = d.mname;
  //       motherMobileNoClt.text = d.mno;
  //       motherPanNoClt.text = d.mpan;
  //       motherOfficeAddressClt.text = d.moffice;
  //       motherAadharNoClt.text = d.maadhar;
  //       motherQualificationClt.text = d.meducation;
  //       motherOccupationClt.text = d.moocupation;
  //       gardienMobileClt.text = d.guardianmobileno;
  //       gardienNameClt.text = d.guardianname;
  //       changeGender(d.gender.toString().toLowerCase()=="male"?1:2);
  //       // changeCategory(int.parse(d.category));
  //       // if(d.religion!="")
  //       //   changeReligion(int.parse(d.religion.toString()));
  //       // changeMinorityCategory(int.parse(d.minority));
  //       changeCategory(
  //         int.tryParse(d.category.toString()) ?? 1,
  //       );
  //
  //       final religionValue = int.tryParse(d.religion.toString());
  //       if (religionValue != null) {
  //         changeReligion(religionValue);
  //       }
  //
  //       changeMinorityCategory(
  //         int.tryParse(d.minority.toString()) ?? 1,
  //       );
  //       changeCityType(d.cityType.toString().toLowerCase()=="rural"?1:2);
  //       notifyListeners();
  //     }
  //   });
  // }

  Future<void> getProfileData(BuildContext context) async {
    dataUser = null;
    notifyListeners();

    final UserProvider up =
    Provider.of<UserProvider>(context, listen: false);

    try {
      final response = await ApiServices().postData(
        uri: userDetail,
        data: {"id": up.userId.toString()},
        context: context,
      );

      if (response == null) return;

      final modal = userDetailModalFromJson(response.body);
      final d = modal.data;

      dataUser = d;

      if (d.passwordset.toString() == "0") {
        Get.offAllNamed('/passwordResetScreen', arguments: [1]);
        return;
      }

      studentFNameClt.text = d.fname.toString();
      studentLNameClt.text = d.lname.toString();
      studentAadharCardNoClt.text = d.aadhar.toString();

      studentDOBClt.text = d.dob.toString();
      studentStateClt.text = d.state.toString();
      studentCityClt.text = d.city.toString();

      studentAddressClt.text = d.address.toString();
      studentPincodeClt.text = d.pincode.toString();

      studentBrotherNameClt.text = d.bname.toString();
      studentBrotherSchoolNameClt.text = d.bschool.toString();
      studentBrotherClassClt.text = d.bclass.toString();

      studentSisterNameClt.text = d.sisname.toString();
      studentSisterClassClt.text = d.sisclass.toString();
      studentSisterSchoolNameClt.text = d.sisschool.toString();

      fatherNameClt.text = d.fathername.toString();
      fatherMobileNoClt.text = d.fmo.toString();
      fatherPanNoClt.text = d.fpan.toString();
      fatherOfficeAddressClt.text = d.foffice.toString();
      fatherAadharNoClt.text = d.faadhar.toString();
      fatherQualificationClt.text = d.feducation.toString();
      fatherOccupationClt.text = d.foccupation.toString();

      motherNameClt.text = d.mname.toString();
      motherMobileNoClt.text = d.mno.toString();
      motherPanNoClt.text = d.mpan.toString();
      motherOfficeAddressClt.text = d.moffice.toString();
      motherAadharNoClt.text = d.maadhar.toString();
      motherQualificationClt.text = d.meducation.toString();
      motherOccupationClt.text = d.moocupation.toString();

      gardienMobileClt.text = d.guardianmobileno.toString();
      gardienNameClt.text = d.guardianname.toString();

      changeGender(
        d.gender.toString().toLowerCase() == "male" ? 1 : 2,
      );

      changeCategory(
        int.tryParse(d.category.toString()) ?? 1,
      );

      final religionValue = int.tryParse(d.religion.toString());
      if (religionValue != null) {
        changeReligion(religionValue);
      }

      // changeMinorityCategory(
      //   int.tryParse(d.minority.toString()) ?? 1,
      // );
      final minorityValue = int.tryParse(
        d.minority?.toString().trim() ?? '',
      );

      changeMinorityCategory(minorityValue);
      changeCityType(
        d.cityType.toString().toLowerCase() == "rural" ? 1 : 2,
      );

      notifyListeners();
    } catch (e, stackTrace) {
      log(
        'Error loading profile: $e',
        stackTrace: stackTrace,
      );
    }
  }

  Religion selectedReligion = Religion(name: "Hindu", val: 1);
  List<Religion> religion = [
    Religion(name: "Hindu", val: 1),
    Religion(name: "Muslim", val: 2),
    Religion(name: "Sikh", val: 3),
    Religion(name: "Christian", val: 4),
    Religion(name: "Jain", val: 5),
    Religion(name: "Budh", val: 6),
    Religion(name: "Parsi", val: 7),
    Religion(name: "Others", val: 8),
  ];

  Category selectedCategory = Category(name: "GEN", val: 1);
  List<Category> categoryList = [
    Category(name: "GEN", val: 1),
    Category(name: "OBC", val: 2),
    Category(name: "SC", val: 3),
    Category(name: "ST", val: 4),
    Category(name: "SBC", val: 5),
  ];
  // Category selectedMinorityCategory = Category(name: "Jain", val: 1);
  Category selectedMinorityCategory = Category(name: "-", val: 0);
  List<Category> minorityCategoryList = [
    Category(name: "Jain", val: 1),
    Category(name: "Sikh", val: 2),
    Category(name: "Christian", val: 3),
    Category(name: "Budh", val: 4),
    Category(name: "Parsi", val: 5),
    Category(name: "Muslim", val: 6),
    Category(name: "Other", val: 7),
  ];

  Category selectedPreviousYear = Category(name: "Not Applicable", val: 1);
  List<Category> previousYearList = [
    Category(name: "Not Applicable", val: 1),
    Category(name: "Same School", val: 2),
    Category(name: "Another School", val: 3),
    Category(name: "Anganwadi / ECCE", val: 4),
    Category(name: "None", val: 5),
  ];

  List years = [
    "2023-24",
    "2024-25",
    "2025-26",
    "2026-27",
    "2027-28",
    "2028-29",
    "2029-30",
    "2030-31",
    "2031-32",
    "2032-33",
  ];
  List grade = ["A+", "A", "B+", "B", "C+", "C", "D+", "D"];

  var selectedYear;
  var selectedGrade;

  changeSelectedYear(value) {
    selectedYear = value;
    notifyListeners();
  }

  changeSelectedGrade(value) {
    selectedGrade = value;
    notifyListeners();
  }

  int selectedGender = 1;
  int selectedResult = 1;
  int selectedMedium = 1;

  int selectedCityType = 1;

  changeGender(c) {
    selectedGender = c!;
    notifyListeners();
  }

  changeCategory(c) {
    selectedCategory = categoryList.firstWhere((element) => element.val == c,orElse: ()=>Category(name: "GEN", val: 1));
    notifyListeners();
  }

  changeReligion(c) {
    selectedReligion = religion.firstWhere((element) => element.val == c,orElse: ()=>Religion(name: "Hindu", val: 1));
    notifyListeners();
  }

  changeCityType(c) {
    selectedCityType = c!;
    notifyListeners();
  }

  changeResult(c) {
    selectedResult = c!;
    notifyListeners();
  }

  changeMedium(c) {
    selectedMedium = c!;
    notifyListeners();
  }

  // changeMinorityCategory(c) {
  //   selectedMinorityCategory = minorityCategoryList.firstWhere((element) => element.val == c,orElse: ()=>Category(name: "Jain", val: 1));
  //   notifyListeners();
  // }
  changeMinorityCategory(c) {
    final value = int.tryParse(c?.toString() ?? '');

    if (value == null || value == 0) {
      selectedMinorityCategory = Category(name: "-", val: 0);
    } else {
      selectedMinorityCategory = minorityCategoryList.firstWhere(
            (element) => element.val == value,
        orElse: () => Category(name: "-", val: 0),
      );
    }

    notifyListeners();
  }

  changePreviousYear(c) {
    selectedPreviousYear =
        previousYearList.firstWhere((element) => element.val == c, orElse: () {
          return Category(name: "None", val: 5);
        });
    notifyListeners();
  }

  TextEditingController srNoClt = TextEditingController();
  TextEditingController studentAadharCardNoClt = TextEditingController();
  TextEditingController studentFNameClt = TextEditingController();
  TextEditingController studentLNameClt = TextEditingController();
  TextEditingController studentBloodGroupClt = TextEditingController();
  TextEditingController studentLanguage = TextEditingController();
  TextEditingController studentCastClt = TextEditingController();
  TextEditingController studentEmailClt = TextEditingController();
  TextEditingController studentStateClt = TextEditingController();
  TextEditingController studentCityClt = TextEditingController();

  TextEditingController studentDOBClt = TextEditingController();
  TextEditingController studentAddressClt = TextEditingController();
  TextEditingController studentPincodeClt = TextEditingController();
  TextEditingController studentBrotherNameClt = TextEditingController();
  TextEditingController studentBrotherClassClt = TextEditingController();
  TextEditingController studentBrotherSchoolNameClt = TextEditingController();
  TextEditingController studentSisterNameClt = TextEditingController();
  TextEditingController studentSisterClassClt = TextEditingController();
  TextEditingController studentSisterSchoolNameClt = TextEditingController();
  TextEditingController incomeClt = TextEditingController();

  TextEditingController fatherNameClt = TextEditingController();
  TextEditingController motherNameClt = TextEditingController();
  TextEditingController fatherQualificationClt = TextEditingController();
  TextEditingController motherQualificationClt = TextEditingController();
  TextEditingController fatherOccupationClt = TextEditingController();
  TextEditingController motherOccupationClt = TextEditingController();
  TextEditingController fatherAadharNoClt = TextEditingController();
  TextEditingController motherAadharNoClt = TextEditingController();
  TextEditingController fatherOfficeAddressClt = TextEditingController();
  TextEditingController motherOfficeAddressClt = TextEditingController();
  TextEditingController fatherMobileNoClt = TextEditingController();
  TextEditingController motherMobileNoClt = TextEditingController();
  TextEditingController fatherPanNoClt = TextEditingController();
  TextEditingController motherPanNoClt = TextEditingController();

  TextEditingController gardienNameClt = TextEditingController();
  TextEditingController gardienMobileClt = TextEditingController();

  TextEditingController previousSchoolNameClt = TextEditingController();
  TextEditingController previousSchoolClassClt = TextEditingController();

  XFile? profilePicture;

  ///////////////////// Part B ////////////////////
  TextEditingController BFirstNameClt = TextEditingController();
  TextEditingController BLastNameClt = TextEditingController();
  TextEditingController BBloodClt = TextEditingController();
  TextEditingController BHeightClt = TextEditingController();
  TextEditingController BWeightClt = TextEditingController();
  TextEditingController BMotherToungeClt = TextEditingController();

  TextEditingController BCityType = TextEditingController();

  TextEditingController BLastMark = TextEditingController();
  TextEditingController BLastAttendance = TextEditingController();

  hangelSubmit(BuildContext context) async {
    final UserProvider up = Provider.of<UserProvider>(context, listen: false);
    var body = gernalDetailBody(
        id: up.userId.toString(),
        fname: studentFNameClt.text,
        lname: studentLNameClt.text,
        gender: selectedGender == 1 ? "Male" : "Female",

        dob: studentDOBClt.text,
        saadhar: studentAadharCardNoClt.text,

        religion: selectedReligion.val.toString(),

        state: studentStateClt.text,
        city: studentCityClt.text,
        city_type: selectedCityType == 1 ? "Rural" : "Urban",
        address: studentAddressClt.text,
        pincode: studentPincodeClt.text,
        previous_medium: selectedMedium == 1 ? "English" : "Hindi",
        previous_result: selectedResult == 1 ? "Pass" : "Fail",
        category: selectedCategory.val.toString(),
        previous_class: previousSchoolClassClt.text,
        brother_name: studentBrotherNameClt.text,
        brother_class: studentBrotherClassClt.text,
        brother_school: studentBrotherSchoolNameClt.text,
        sister_class: studentSisterClassClt.text,
        sister_name: studentSisterNameClt.text,
        sister_school: studentSisterSchoolNameClt.text,
        gurdian_name: gardienNameClt.text,
        gurdian_mobile: gardienMobileClt.text,
        father_name: fatherNameClt.text,
        mother_name: motherNameClt.text,

        father_occupation: fatherOccupationClt.text,
        mother_occupation: motherOccupationClt.text,
        father_education: fatherQualificationClt.text,
        mother_education: motherQualificationClt.text,
        father_mobile: fatherMobileNoClt.text,
        mother_mobile: motherMobileNoClt.text,
        father_aadhar: fatherAadharNoClt.text,
        mother_aadhar: motherAadharNoClt.text,
        father_office: fatherOfficeAddressClt.text,
        mother_office: motherOfficeAddressClt.text,
        father_pan: fatherPanNoClt.text,
        mother_pan: motherPanNoClt.text,
        minority: selectedMinorityCategory.val.toString());
    //print(body);
    try {
      EasyLoading.show();
      var request = http.MultipartRequest('POST', Uri.parse(editDetail));
      request.fields.addAll(body);
      if (profilePicture != null)
        request.files.add(await http.MultipartFile.fromPath(
            'student_picture', profilePicture!.path));
      log(request.fields.toString());
      http.StreamedResponse response = await request.send();
      print(response.statusCode);
      final res = await http.Response.fromStream(response);
      log(res.body);
      if (response.statusCode == 200) {
        showToastE(message: "${json.decode(res.body)["message"]}");
        EasyLoading.dismiss();
        getProfileData(context);
        return "${json.decode(res.body)["message"]}";
      } else if (res.statusCode == 202) {
        EasyLoading.dismiss();
        showToastE(message: "${json.decode(res.body)["message"]}");
      } else {
        EasyLoading.dismiss();
        showToastE(message: "${json.decode(res.body)["message"]}");
      }
    } catch (e) {
      EasyLoading.dismiss();
      showToastE(message: "error in handel profile update ${e.toString()}");
      print("error in handel profile update ${e.toString()}");
    }
  }

  showImagePickBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        context: context,
        builder: (context) {
          return Container(
              padding:
              EdgeInsets.only(left: 10, top: 25, right: 15, bottom: 20),
              height: 180,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        takeImageFromGallery(context).then((value) {
                          if (value != null) {
                            profilePicture = XFile(value.path);
                            notifyListeners();
                          }
                        });
                      },
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            child: Image.asset(
                              Assets.assetsGallery,
                              height: 85,
                              width: 85,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Gallery",
                            style: TextStyle(fontSize: 18),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        takeImageFromCamera(context).then((value) {
                          if (value != null) {
                            profilePicture = XFile(value.path);
                            notifyListeners();
                          }
                        });
                      },
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            child: Image.asset(
                              Assets.assetsCamera,
                              height: 85,
                              width: 85,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Camera",
                            style: TextStyle(fontSize: 18),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ));
        });
  }

  List termsAndCondition = [
    "I hereby agree to abide by the rules as laid by the school from time to time.",
    "I also agree to take behavioural & academic responsibilities of the child.",
    "I will not hold the school responsible for any unavoidable mishaps or accidents. Fees once paid are non-refundable in nature",
    "All the information given here is correct.",
  ];

  var valuePoverty = 1;
  var valueDisadvantage = 1;
  var valuePassedLastYear = 1;
  var termeCheck = false;

  changePoverty(value) {
    valuePoverty = value;
    notifyListeners();
  }

  changeValueDisadvantage(value) {
    valueDisadvantage = value;
    notifyListeners();
  }

  changeValuePassedLastYear(value) {
    valuePassedLastYear = value;
    notifyListeners();
  }

  changeTermCheck(value) {
    termeCheck = value;
    notifyListeners();
  }

  getPartBData(BuildContext context) {
    final UserProvider up = Provider.of<UserProvider>(context, listen: false);
    try {
      ApiServices()
          .postData(
          uri: infoPartB,
          data: partBdataBody(id: up.userId.toString()),
          context: context,showToast: false
      )
          .then((value) {
        if (value != null) {
          var d = partBDataModalFromJson(value.body.toString()).data;
          BFirstNameClt.text = d.firstName;
          BLastNameClt.text = d.lastName;
          BBloodClt.text = d.blood;
          BHeightClt.text = d.height;
          BWeightClt.text = d.weight;
          BMotherToungeClt.text = d.motherTounge;
          BLastMark.text = d.lastMarks;
          BLastAttendance.text = d.lastAttendance;
          valuePoverty = d.poverty.toString().toLowerCase() == "yes" ? 1 : 2;
          valueDisadvantage =
          d.disadvantage.toString().toLowerCase() == "yes" ? 1 : 2;
          changePreviousYear(int.parse(d.statusPrevious.toString()));
          changeSelectedYear(d.lastYear.toString());
          changeSelectedGrade(d.grade);
          valuePassedLastYear =
          d.lastPassed.toString().toLowerCase() == "yes" ? 1 : 2;
          changeTermCheck(
              d.termCondition.toString().toLowerCase() == "on" ? true : false);
        }
      });
    } catch (e) {}
  }

  submitePartBData(BuildContext context) {
    final UserProvider up = Provider.of<UserProvider>(context, listen: false);
    ApiServices()
        .postData(
      uri: editPartB,
      context: context,
      data: partBDataSubmitBody(
          up.userId.toString(),
          BFirstNameClt.text,
          BLastNameClt.text,
          BBloodClt.text,
          BHeightClt.text,
          BWeightClt.text,
          BMotherToungeClt.text,
          valuePoverty == 1 ? "yes" : "no",
          valueDisadvantage == 1 ? "yes" : "no",
          selectedPreviousYear.val.toString(),
          selectedYear ?? "",
          selectedGrade ?? "",
          valuePassedLastYear == 1 ? "yes" : "no",
          BLastMark.text,
          BLastAttendance.text,
          termeCheck == true ? "on" : "off"),
    ).then((value) {
      if (value != null) {
        showToastE(message: json.decode(value.body)["message"]);
        getPartBData(context);
      }
    });
  }

  showLogoutPopout(){
    return  Get.generalDialog(
      pageBuilder: (BuildContext buildContext, Animation animation,
          Animation secondaryAnimation) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
            contentPadding: EdgeInsets.zero,
            // this padding user for outside of alert padding
            insetPadding: EdgeInsets.symmetric(horizontal: 18),
            content: Container(
              padding: EdgeInsets.only(top: 20,left: 20,right: 20,bottom: 20),
              height: 80, // Change as per your requirement
              width: Get.width,
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Are You Sure You Want To Logout!"),
                ],
              ) ,

            ),
            actions: [
              ElevatedButton(onPressed: (){
                final UserProvider ub = Provider.of<UserProvider>(buildContext,listen: false);
                ub.clearUserData();
                clearFields();
              }, child: Text("Ok",style: TextStyle(color: Colors.white),),style: ElevatedButton.styleFrom(backgroundColor: maincolor),),
              SizedBox(width: 8,),
              ElevatedButton(onPressed: (){
                Get.back();
              }, child: Text("Cancel",style: TextStyle(color: Colors.white),),style: ElevatedButton.styleFrom(backgroundColor: maincolor),),
            ],
          ),
    );
  }
  TextEditingController newpasswordClt = TextEditingController();
  TextEditingController conformpasswordClt = TextEditingController();
  TextEditingController oldpasswordClt = TextEditingController();
  changePassword(BuildContext context,newpassword,oldpassword){
    final UserProvider up = Provider.of<UserProvider>(context, listen: false);
    ApiServices().postData(uri: passwordedit, context: context,data: passwordResetBody(
        id: up.userId.toString(),oldpassword: oldpassword,newpassword: newpassword)).then((value) {
      if(value!=null){
        showToastE(message: json.decode(value.body)["message"]);
        clearFields();
        up.clearUserData();
      }
    });
  }



  clearFields(){
    dataUser = null;
    selectedReligion = Religion(name: "Hindu", val: 1);
    selectedCategory = Category(name: "GEN", val: 1);
    // selectedMinorityCategory = Category(name: "-", val: 1);
    selectedMinorityCategory = Category(name: "-", val: 0);
    selectedPreviousYear = Category(name: "Not Applicable", val: 1);
    selectedYear = null;
    selectedGrade = null;
    selectedGender = 1;
    selectedResult = 1;
    selectedMedium = 1;
    selectedCityType = 1;
    srNoClt.clear();
    studentAadharCardNoClt.clear();
    studentFNameClt.clear();
    studentLNameClt.clear();
    studentBloodGroupClt.clear();
    studentLanguage.clear();
    studentCastClt.clear();
    studentEmailClt.clear();
    studentStateClt.clear();
    studentCityClt.clear();

    studentDOBClt.clear();
    studentAddressClt.clear();
    studentPincodeClt.clear();
    studentBrotherNameClt.clear();
    studentBrotherClassClt.clear();
    studentBrotherSchoolNameClt.clear();
    studentSisterNameClt.clear();
    studentSisterClassClt.clear();
    studentSisterSchoolNameClt.clear();
    incomeClt.clear();

    fatherNameClt.clear();
    motherNameClt.clear();
    fatherQualificationClt.clear();
    motherQualificationClt.clear();
    fatherOccupationClt.clear();
    motherOccupationClt.clear();
    fatherAadharNoClt.clear();
    motherAadharNoClt.clear();
    fatherOfficeAddressClt.clear();
    motherOfficeAddressClt.clear();
    fatherMobileNoClt.clear();
    motherMobileNoClt.clear();
    fatherPanNoClt.clear();
    motherPanNoClt.clear();
    gardienNameClt.clear();
    gardienMobileClt.clear();
    previousSchoolNameClt.clear();
    previousSchoolClassClt.clear();
    BFirstNameClt.clear();
    BLastNameClt.clear();
    BBloodClt.clear();
    BHeightClt.clear();
    BWeightClt.clear();
    BMotherToungeClt.clear();
    BCityType.clear();
    BLastMark.clear();
    BLastAttendance.clear();
    newpasswordClt.clear();
    conformpasswordClt .clear();
    oldpasswordClt .clear();
    valuePoverty = 1;
    valueDisadvantage = 1;
    valuePassedLastYear = 1;
    termeCheck = false;
    notifyListeners();
  }


}

class Religion {
  String name;
  int val;

  Religion({required this.name, required this.val});
}

class Category {
  String name;
  int val;

  Category({required this.name, required this.val});
}

// import 'dart:convert';
// import 'dart:developer';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:mikado_kids/config/themeConfig.dart';
// import 'package:mikado_kids/modals/userDetailsModal.dart';
// import 'package:mikado_kids/providers/userProvider.dart';
// import 'package:mikado_kids/services/apiServices.dart';
// import 'package:http/http.dart' as http;
// import '../config/appConfig.dart';
// import '../generated/assets.dart';
// import '../modals/partBDataModal.dart';
// import '../services/imagepicker.dart';
// import '../widgets/toast.dart';

// class ProfileProvider extends ChangeNotifier {
//   DataUser? dataUser;

//   // getProfileData(BuildContext context) {
//   //   dataUser = null;
//   //   notifyListeners();
//   //
//   //   UserProvider up = Provider.of<UserProvider>(context, listen: false);
//   //   ApiServices()
//   //       .postData(
//   //       uri: userDetail,
//   //       data: {"id": up.userId.toString()},
//   //       context: context)
//   //       .then((response) {
//   //     if (response != null) {
//   //       // dataUser = userDetailModalFromJson(response.body).data;
//   //       //
//   //       // var d = userDetailModalFromJson(response.body).data;
//   //       final modal = userDetailModalFromJson(response.body);
//   //       final d = modal.data;
//   //
//   //       dataUser = d;
//   //       if(d.passwordset=="0"){
//   //         Get.offAllNamed('/passwordResetScreen',arguments: [1]);
//   //       }
//   //       studentFNameClt.text = d.fname;
//   //       studentLNameClt.text = d.lname;
//   //       studentAadharCardNoClt.text = d.aadhar;
//   //
//   //       studentDOBClt.text = d.dob;
//   //       studentStateClt.text = d.state;
//   //       studentCityClt.text = d.city;
//   //
//   //       studentAddressClt.text = d.address;
//   //       studentPincodeClt.text = d.pincode;
//   //       studentBrotherNameClt.text = d.bname;
//   //       studentBrotherSchoolNameClt.text = d.bschool;
//   //       studentBrotherClassClt.text = d.bclass;
//   //       studentSisterNameClt.text = d.sisname;
//   //       studentSisterClassClt.text = d.sisclass;
//   //       studentSisterSchoolNameClt.text = d.sisschool;
//   //
//   //       fatherNameClt.text = d.fathername;
//   //       fatherMobileNoClt.text = d.fmo;
//   //       fatherPanNoClt.text = d.fpan;
//   //       fatherOfficeAddressClt.text = d.foffice;
//   //       fatherAadharNoClt.text = d.faadhar;
//   //       fatherQualificationClt.text = d.feducation;
//   //       fatherOccupationClt.text = d.foccupation;
//   //
//   //       motherNameClt.text = d.mname;
//   //       motherMobileNoClt.text = d.mno;
//   //       motherPanNoClt.text = d.mpan;
//   //       motherOfficeAddressClt.text = d.moffice;
//   //       motherAadharNoClt.text = d.maadhar;
//   //       motherQualificationClt.text = d.meducation;
//   //       motherOccupationClt.text = d.moocupation;
//   //       gardienMobileClt.text = d.guardianmobileno;
//   //       gardienNameClt.text = d.guardianname;
//   //       changeGender(d.gender.toString().toLowerCase()=="male"?1:2);
//   //       // changeCategory(int.parse(d.category));
//   //       // if(d.religion!="")
//   //       //   changeReligion(int.parse(d.religion.toString()));
//   //       // changeMinorityCategory(int.parse(d.minority));
//   //       changeCategory(
//   //         int.tryParse(d.category.toString()) ?? 1,
//   //       );
//   //
//   //       final religionValue = int.tryParse(d.religion.toString());
//   //       if (religionValue != null) {
//   //         changeReligion(religionValue);
//   //       }
//   //
//   //       changeMinorityCategory(
//   //         int.tryParse(d.minority.toString()) ?? 1,
//   //       );
//   //       changeCityType(d.cityType.toString().toLowerCase()=="rural"?1:2);
//   //       notifyListeners();
//   //     }
//   //   });
//   // }

//   Future<void> getProfileData(BuildContext context) async {
//     dataUser = null;
//     notifyListeners();

//     final UserProvider up =
//     Provider.of<UserProvider>(context, listen: false);

//     try {
//       final response = await ApiServices().postData(
//         uri: userDetail,
//         data: {"id": up.userId.toString()},
//         context: context,
//       );

//       if (response == null) return;

//       final modal = userDetailModalFromJson(response.body);
//       final d = modal.data;

//       dataUser = d;

//       if (d.passwordset.toString() == "0") {
//         Get.offAllNamed('/passwordResetScreen', arguments: [1]);
//         return;
//       }

//       studentFNameClt.text = d.fname.toString();
//       studentLNameClt.text = d.lname.toString();
//       studentAadharCardNoClt.text = d.aadhar.toString();

//       studentDOBClt.text = d.dob.toString();
//       studentStateClt.text = d.state.toString();
//       studentCityClt.text = d.city.toString();

//       studentAddressClt.text = d.address.toString();
//       studentPincodeClt.text = d.pincode.toString();

//       studentBrotherNameClt.text = d.bname.toString();
//       studentBrotherSchoolNameClt.text = d.bschool.toString();
//       studentBrotherClassClt.text = d.bclass.toString();

//       studentSisterNameClt.text = d.sisname.toString();
//       studentSisterClassClt.text = d.sisclass.toString();
//       studentSisterSchoolNameClt.text = d.sisschool.toString();

//       fatherNameClt.text = d.fathername.toString();
//       fatherMobileNoClt.text = d.fmo.toString();
//       fatherPanNoClt.text = d.fpan.toString();
//       fatherOfficeAddressClt.text = d.foffice.toString();
//       fatherAadharNoClt.text = d.faadhar.toString();
//       fatherQualificationClt.text = d.feducation.toString();
//       fatherOccupationClt.text = d.foccupation.toString();

//       motherNameClt.text = d.mname.toString();
//       motherMobileNoClt.text = d.mno.toString();
//       motherPanNoClt.text = d.mpan.toString();
//       motherOfficeAddressClt.text = d.moffice.toString();
//       motherAadharNoClt.text = d.maadhar.toString();
//       motherQualificationClt.text = d.meducation.toString();
//       motherOccupationClt.text = d.moocupation.toString();

//       gardienMobileClt.text = d.guardianmobileno.toString();
//       gardienNameClt.text = d.guardianname.toString();

//       changeGender(
//         d.gender.toString().toLowerCase() == "male" ? 1 : 2,
//       );

//       changeCategory(
//         int.tryParse(d.category.toString()) ?? 1,
//       );

//       final religionValue = int.tryParse(d.religion.toString());
//       if (religionValue != null) {
//         changeReligion(religionValue);
//       }

//       changeMinorityCategory(
//         int.tryParse(d.minority.toString()) ?? 1,
//       );

//       changeCityType(
//         d.cityType.toString().toLowerCase() == "rural" ? 1 : 2,
//       );

//       notifyListeners();
//     } catch (e, stackTrace) {
//       log(
//         'Error loading profile: $e',
//         stackTrace: stackTrace,
//       );
//     }
//   }

//   Religion selectedReligion = Religion(name: "Hindu", val: 1);
//   List<Religion> religion = [
//     Religion(name: "Hindu", val: 1),
//     Religion(name: "Muslim", val: 2),
//     Religion(name: "Sikh", val: 3),
//     Religion(name: "Christian", val: 4),
//     Religion(name: "Jain", val: 5),
//     Religion(name: "Budh", val: 6),
//     Religion(name: "Parsi", val: 7),
//     Religion(name: "Others", val: 8),
//   ];

//   Category selectedCategory = Category(name: "GEN", val: 1);
//   List<Category> categoryList = [
//     Category(name: "GEN", val: 1),
//     Category(name: "OBC", val: 2),
//     Category(name: "SC", val: 3),
//     Category(name: "ST", val: 4),
//     Category(name: "SBC", val: 5),
//   ];
//   Category selectedMinorityCategory = Category(name: "Jain", val: 1);
//   List<Category> minorityCategoryList = [
//     Category(name: "Jain", val: 1),
//     Category(name: "Sikh", val: 2),
//     Category(name: "Christian", val: 3),
//     Category(name: "Budh", val: 4),
//     Category(name: "Parsi", val: 5),
//     Category(name: "Muslim", val: 6),
//     Category(name: "Other", val: 7),
//   ];

//   Category selectedPreviousYear = Category(name: "Not Applicable", val: 1);
//   List<Category> previousYearList = [
//     Category(name: "Not Applicable", val: 1),
//     Category(name: "Same School", val: 2),
//     Category(name: "Another School", val: 3),
//     Category(name: "Anganwadi / ECCE", val: 4),
//     Category(name: "None", val: 5),
//   ];

//   List years = [
//     "2023-24",
//     "2024-25",
//     "2025-26",
//     "2026-27",
//     "2027-28",
//     "2028-29",
//     "2029-30",
//     "2030-31",
//     "2031-32",
//     "2032-33",
//   ];
//   List grade = ["A+", "A", "B+", "B", "C+", "C", "D+", "D"];

//   var selectedYear;
//   var selectedGrade;

//   changeSelectedYear(value) {
//     selectedYear = value;
//     notifyListeners();
//   }

//   changeSelectedGrade(value) {
//     selectedGrade = value;
//     notifyListeners();
//   }

//   int selectedGender = 1;
//   int selectedResult = 1;
//   int selectedMedium = 1;

//   int selectedCityType = 1;

//   changeGender(c) {
//     selectedGender = c!;
//     notifyListeners();
//   }

//   changeCategory(c) {
//     selectedCategory = categoryList.firstWhere((element) => element.val == c,orElse: ()=>Category(name: "GEN", val: 1));
//     notifyListeners();
//   }

//   changeReligion(c) {
//     selectedReligion = religion.firstWhere((element) => element.val == c,orElse: ()=>Religion(name: "Hindu", val: 1));
//     notifyListeners();
//   }

//   changeCityType(c) {
//     selectedCityType = c!;
//     notifyListeners();
//   }

//   changeResult(c) {
//     selectedResult = c!;
//     notifyListeners();
//   }

//   changeMedium(c) {
//     selectedMedium = c!;
//     notifyListeners();
//   }

//   changeMinorityCategory(c) {
//     selectedMinorityCategory = minorityCategoryList.firstWhere((element) => element.val == c,orElse: ()=>Category(name: "Jain", val: 1));
//     notifyListeners();
//   }

//   changePreviousYear(c) {
//     selectedPreviousYear =
//         previousYearList.firstWhere((element) => element.val == c, orElse: () {
//           return Category(name: "None", val: 5);
//         });
//     notifyListeners();
//   }

//   TextEditingController srNoClt = TextEditingController();
//   TextEditingController studentAadharCardNoClt = TextEditingController();
//   TextEditingController studentFNameClt = TextEditingController();
//   TextEditingController studentLNameClt = TextEditingController();
//   TextEditingController studentBloodGroupClt = TextEditingController();
//   TextEditingController studentLanguage = TextEditingController();
//   TextEditingController studentCastClt = TextEditingController();
//   TextEditingController studentEmailClt = TextEditingController();
//   TextEditingController studentStateClt = TextEditingController();
//   TextEditingController studentCityClt = TextEditingController();

//   TextEditingController studentDOBClt = TextEditingController();
//   TextEditingController studentAddressClt = TextEditingController();
//   TextEditingController studentPincodeClt = TextEditingController();
//   TextEditingController studentBrotherNameClt = TextEditingController();
//   TextEditingController studentBrotherClassClt = TextEditingController();
//   TextEditingController studentBrotherSchoolNameClt = TextEditingController();
//   TextEditingController studentSisterNameClt = TextEditingController();
//   TextEditingController studentSisterClassClt = TextEditingController();
//   TextEditingController studentSisterSchoolNameClt = TextEditingController();
//   TextEditingController incomeClt = TextEditingController();

//   TextEditingController fatherNameClt = TextEditingController();
//   TextEditingController motherNameClt = TextEditingController();
//   TextEditingController fatherQualificationClt = TextEditingController();
//   TextEditingController motherQualificationClt = TextEditingController();
//   TextEditingController fatherOccupationClt = TextEditingController();
//   TextEditingController motherOccupationClt = TextEditingController();
//   TextEditingController fatherAadharNoClt = TextEditingController();
//   TextEditingController motherAadharNoClt = TextEditingController();
//   TextEditingController fatherOfficeAddressClt = TextEditingController();
//   TextEditingController motherOfficeAddressClt = TextEditingController();
//   TextEditingController fatherMobileNoClt = TextEditingController();
//   TextEditingController motherMobileNoClt = TextEditingController();
//   TextEditingController fatherPanNoClt = TextEditingController();
//   TextEditingController motherPanNoClt = TextEditingController();

//   TextEditingController gardienNameClt = TextEditingController();
//   TextEditingController gardienMobileClt = TextEditingController();

//   TextEditingController previousSchoolNameClt = TextEditingController();
//   TextEditingController previousSchoolClassClt = TextEditingController();

//   XFile? profilePicture;

//   ///////////////////// Part B ////////////////////
//   TextEditingController BFirstNameClt = TextEditingController();
//   TextEditingController BLastNameClt = TextEditingController();
//   TextEditingController BBloodClt = TextEditingController();
//   TextEditingController BHeightClt = TextEditingController();
//   TextEditingController BWeightClt = TextEditingController();
//   TextEditingController BMotherToungeClt = TextEditingController();

//   TextEditingController BCityType = TextEditingController();

//   TextEditingController BLastMark = TextEditingController();
//   TextEditingController BLastAttendance = TextEditingController();

//   hangelSubmit(BuildContext context) async {
//     final UserProvider up = Provider.of<UserProvider>(context, listen: false);
//     var body = gernalDetailBody(
//         id: up.userId.toString(),
//         fname: studentFNameClt.text,
//         lname: studentLNameClt.text,
//         gender: selectedGender == 1 ? "Male" : "Female",

//         dob: studentDOBClt.text,
//         saadhar: studentAadharCardNoClt.text,

//         religion: selectedReligion.val.toString(),

//         state: studentStateClt.text,
//         city: studentCityClt.text,
//         city_type: selectedCityType == 1 ? "Rural" : "Urban",
//         address: studentAddressClt.text,
//         pincode: studentPincodeClt.text,
//         previous_medium: selectedMedium == 1 ? "English" : "Hindi",
//         previous_result: selectedResult == 1 ? "Pass" : "Fail",
//         category: selectedCategory.val.toString(),
//         previous_class: previousSchoolClassClt.text,
//         brother_name: studentBrotherNameClt.text,
//         brother_class: studentBrotherClassClt.text,
//         brother_school: studentBrotherSchoolNameClt.text,
//         sister_class: studentSisterClassClt.text,
//         sister_name: studentSisterNameClt.text,
//         sister_school: studentSisterSchoolNameClt.text,
//         gurdian_name: gardienNameClt.text,
//         gurdian_mobile: gardienMobileClt.text,
//         father_name: fatherNameClt.text,
//         mother_name: motherNameClt.text,

//         father_occupation: fatherOccupationClt.text,
//         mother_occupation: motherOccupationClt.text,
//         father_education: fatherQualificationClt.text,
//         mother_education: motherQualificationClt.text,
//         father_mobile: fatherMobileNoClt.text,
//         mother_mobile: motherMobileNoClt.text,
//         father_aadhar: fatherAadharNoClt.text,
//         mother_aadhar: motherAadharNoClt.text,
//         father_office: fatherOfficeAddressClt.text,
//         mother_office: motherOfficeAddressClt.text,
//         father_pan: fatherPanNoClt.text,
//         mother_pan: motherPanNoClt.text,
//         minority: selectedMinorityCategory.val.toString());
//     //print(body);
//     try {
//       EasyLoading.show();
//       var request = http.MultipartRequest('POST', Uri.parse(editDetail));
//       request.fields.addAll(body);
//       if (profilePicture != null)
//         request.files.add(await http.MultipartFile.fromPath(
//             'student_picture', profilePicture!.path));
//       log(request.fields.toString());
//       http.StreamedResponse response = await request.send();
//       print(response.statusCode);
//       final res = await http.Response.fromStream(response);
//       log(res.body);
//       if (response.statusCode == 200) {
//         showToastE(message: "${json.decode(res.body)["message"]}");
//         EasyLoading.dismiss();
//         getProfileData(context);
//         return "${json.decode(res.body)["message"]}";
//       } else if (res.statusCode == 202) {
//         EasyLoading.dismiss();
//         showToastE(message: "${json.decode(res.body)["message"]}");
//       } else {
//         EasyLoading.dismiss();
//         showToastE(message: "${json.decode(res.body)["message"]}");
//       }
//     } catch (e) {
//       EasyLoading.dismiss();
//       showToastE(message: "error in handel profile update ${e.toString()}");
//       print("error in handel profile update ${e.toString()}");
//     }
//   }

//   showImagePickBottomSheet(BuildContext context) {
//     return showModalBottomSheet(
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(30), topRight: Radius.circular(30))),
//         context: context,
//         builder: (context) {
//           return Container(
//               padding:
//               EdgeInsets.only(left: 10, top: 25, right: 15, bottom: 20),
//               height: 180,
//               width: double.infinity,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Expanded(
//                     child: InkWell(
//                       onTap: () {
//                         takeImageFromGallery(context).then((value) {
//                           if (value != null) {
//                             profilePicture = XFile(value.path);
//                             notifyListeners();
//                           }
//                         });
//                       },
//                       child: Column(
//                         children: [
//                           Container(
//                             alignment: Alignment.center,
//                             height: 70,
//                             width: 70,
//                             decoration: BoxDecoration(shape: BoxShape.circle),
//                             child: Image.asset(
//                               Assets.assetsGallery,
//                               height: 85,
//                               width: 85,
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                           SizedBox(
//                             height: 10,
//                           ),
//                           Text(
//                             "Gallery",
//                             style: TextStyle(fontSize: 18),
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: InkWell(
//                       onTap: () {
//                         takeImageFromCamera(context).then((value) {
//                           if (value != null) {
//                             profilePicture = XFile(value.path);
//                             notifyListeners();
//                           }
//                         });
//                       },
//                       child: Column(
//                         children: [
//                           Container(
//                             alignment: Alignment.center,
//                             height: 70,
//                             width: 70,
//                             decoration: BoxDecoration(shape: BoxShape.circle),
//                             child: Image.asset(
//                               Assets.assetsCamera,
//                               height: 85,
//                               width: 85,
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                           SizedBox(
//                             height: 10,
//                           ),
//                           Text(
//                             "Camera",
//                             style: TextStyle(fontSize: 18),
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ));
//         });
//   }

//   List termsAndCondition = [
//     "I hereby agree to abide by the rules as laid by the school from time to time.",
//     "I also agree to take behavioural & academic responsibilities of the child.",
//     "I will not hold the school responsible for any unavoidable mishaps or accidents. Fees once paid are non-refundable in nature",
//     "All the information given here is correct.",
//   ];

//   var valuePoverty = 1;
//   var valueDisadvantage = 1;
//   var valuePassedLastYear = 1;
//   var termeCheck = false;

//   changePoverty(value) {
//     valuePoverty = value;
//     notifyListeners();
//   }

//   changeValueDisadvantage(value) {
//     valueDisadvantage = value;
//     notifyListeners();
//   }

//   changeValuePassedLastYear(value) {
//     valuePassedLastYear = value;
//     notifyListeners();
//   }

//   changeTermCheck(value) {
//     termeCheck = value;
//     notifyListeners();
//   }

//   getPartBData(BuildContext context) {
//     final UserProvider up = Provider.of<UserProvider>(context, listen: false);
//     try {
//       ApiServices()
//           .postData(
//           uri: infoPartB,
//           data: partBdataBody(id: up.userId.toString()),
//           context: context,showToast: false
//       )
//           .then((value) {
//         if (value != null) {
//           var d = partBDataModalFromJson(value.body.toString()).data;
//           BFirstNameClt.text = d.firstName;
//           BLastNameClt.text = d.lastName;
//           BBloodClt.text = d.blood;
//           BHeightClt.text = d.height;
//           BWeightClt.text = d.weight;
//           BMotherToungeClt.text = d.motherTounge;
//           BLastMark.text = d.lastMarks;
//           BLastAttendance.text = d.lastAttendance;
//           valuePoverty = d.poverty.toString().toLowerCase() == "yes" ? 1 : 2;
//           valueDisadvantage =
//           d.disadvantage.toString().toLowerCase() == "yes" ? 1 : 2;
//           changePreviousYear(int.parse(d.statusPrevious.toString()));
//           changeSelectedYear(d.lastYear.toString());
//           changeSelectedGrade(d.grade);
//           valuePassedLastYear =
//           d.lastPassed.toString().toLowerCase() == "yes" ? 1 : 2;
//           changeTermCheck(
//               d.termCondition.toString().toLowerCase() == "on" ? true : false);
//         }
//       });
//     } catch (e) {}
//   }

//   submitePartBData(BuildContext context) {
//     final UserProvider up = Provider.of<UserProvider>(context, listen: false);
//     ApiServices()
//         .postData(
//       uri: editPartB,
//       context: context,
//       data: partBDataSubmitBody(
//           up.userId.toString(),
//           BFirstNameClt.text,
//           BLastNameClt.text,
//           BBloodClt.text,
//           BHeightClt.text,
//           BWeightClt.text,
//           BMotherToungeClt.text,
//           valuePoverty == 1 ? "yes" : "no",
//           valueDisadvantage == 1 ? "yes" : "no",
//           selectedPreviousYear.val.toString(),
//           selectedYear ?? "",
//           selectedGrade ?? "",
//           valuePassedLastYear == 1 ? "yes" : "no",
//           BLastMark.text,
//           BLastAttendance.text,
//           termeCheck == true ? "on" : "off"),
//     ).then((value) {
//       if (value != null) {
//         showToastE(message: json.decode(value.body)["message"]);
//         getPartBData(context);
//       }
//     });
//   }

//   showLogoutPopout(){
//     return  Get.generalDialog(
//       pageBuilder: (BuildContext buildContext, Animation animation,
//           Animation secondaryAnimation) =>
//           AlertDialog(
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.all(Radius.circular(20))),
//             contentPadding: EdgeInsets.zero,
//             // this padding user for outside of alert padding
//             insetPadding: EdgeInsets.symmetric(horizontal: 18),
//             content: Container(
//               padding: EdgeInsets.only(top: 20,left: 20,right: 20,bottom: 20),
//               height: 80, // Change as per your requirement
//               width: Get.width,
//               child:Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Text("Are You Sure You Want To Logout!"),
//                 ],
//               ) ,

//             ),
//             actions: [
//               ElevatedButton(onPressed: (){
//                 final UserProvider ub = Provider.of<UserProvider>(buildContext,listen: false);
//                 ub.clearUserData();
//                 clearFields();
//               }, child: Text("Ok",style: TextStyle(color: Colors.white),),style: ElevatedButton.styleFrom(backgroundColor: maincolor),),
//               SizedBox(width: 8,),
//               ElevatedButton(onPressed: (){
//                 Get.back();
//               }, child: Text("Cancel",style: TextStyle(color: Colors.white),),style: ElevatedButton.styleFrom(backgroundColor: maincolor),),
//             ],
//           ),
//     );
//   }
//   TextEditingController newpasswordClt = TextEditingController();
//   TextEditingController conformpasswordClt = TextEditingController();
//   TextEditingController oldpasswordClt = TextEditingController();
//   changePassword(BuildContext context,newpassword,oldpassword){
//     final UserProvider up = Provider.of<UserProvider>(context, listen: false);
//     ApiServices().postData(uri: passwordedit, context: context,data: passwordResetBody(
//         id: up.userId.toString(),oldpassword: oldpassword,newpassword: newpassword)).then((value) {
//       if(value!=null){
//         showToastE(message: json.decode(value.body)["message"]);
//         clearFields();
//         up.clearUserData();
//       }
//     });
//   }



//   clearFields(){
//     dataUser = null;
//     selectedReligion = Religion(name: "Hindu", val: 1);
//     selectedCategory = Category(name: "GEN", val: 1);
//     selectedMinorityCategory = Category(name: "-", val: 1);
//     selectedPreviousYear = Category(name: "Not Applicable", val: 1);
//     selectedYear = null;
//     selectedGrade = null;
//     selectedGender = 1;
//     selectedResult = 1;
//     selectedMedium = 1;
//     selectedCityType = 1;
//     srNoClt.clear();
//     studentAadharCardNoClt.clear();
//     studentFNameClt.clear();
//     studentLNameClt.clear();
//     studentBloodGroupClt.clear();
//     studentLanguage.clear();
//     studentCastClt.clear();
//     studentEmailClt.clear();
//     studentStateClt.clear();
//     studentCityClt.clear();

//     studentDOBClt.clear();
//     studentAddressClt.clear();
//     studentPincodeClt.clear();
//     studentBrotherNameClt.clear();
//     studentBrotherClassClt.clear();
//     studentBrotherSchoolNameClt.clear();
//     studentSisterNameClt.clear();
//     studentSisterClassClt.clear();
//     studentSisterSchoolNameClt.clear();
//     incomeClt.clear();

//     fatherNameClt.clear();
//     motherNameClt.clear();
//     fatherQualificationClt.clear();
//     motherQualificationClt.clear();
//     fatherOccupationClt.clear();
//     motherOccupationClt.clear();
//     fatherAadharNoClt.clear();
//     motherAadharNoClt.clear();
//     fatherOfficeAddressClt.clear();
//     motherOfficeAddressClt.clear();
//     fatherMobileNoClt.clear();
//     motherMobileNoClt.clear();
//     fatherPanNoClt.clear();
//     motherPanNoClt.clear();
//     gardienNameClt.clear();
//     gardienMobileClt.clear();
//     previousSchoolNameClt.clear();
//     previousSchoolClassClt.clear();
//     BFirstNameClt.clear();
//     BLastNameClt.clear();
//     BBloodClt.clear();
//     BHeightClt.clear();
//     BWeightClt.clear();
//     BMotherToungeClt.clear();
//     BCityType.clear();
//     BLastMark.clear();
//     BLastAttendance.clear();
//     newpasswordClt.clear();
//     conformpasswordClt .clear();
//     oldpasswordClt .clear();
//     valuePoverty = 1;
//     valueDisadvantage = 1;
//     valuePassedLastYear = 1;
//     termeCheck = false;
//     notifyListeners();
//   }


// }

// class Religion {
//   String name;
//   int val;

//   Religion({required this.name, required this.val});
// }

// class Category {
//   String name;
//   int val;

//   Category({required this.name, required this.val});
// }
