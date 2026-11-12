import 'dart:convert';

// const String baseU = "https://portal.mikadoeducation.com/";
const String baseU = "https://portal.mikadoeducation.com/";

const String baseUrl = "${baseU}"+"mikadoworld_ambamata/api/";

const String userDetail = "${baseUrl}" + "userinfo.php";
const String login = "${baseUrl}" + "login1.php";
const String editDetail = "${baseUrl}" + "editdetail.php";
const String infoPartB = "${baseUrl}" + "infopartb.php";
const String editPartB = "${baseUrl}" + "editpartb.php";
const String passwordedit = "${baseUrl}" + "passwordedit.php";
const String deviceverfication = "${baseUrl}" + "deviceverfication.php";
const String getsession = "${baseUrl}" + "session.php";
const String getfeedata = "${baseUrl}" + "feedata.php";
const String getCalender = "${baseUrl}" + "calendar.php";
const String getMonthlyPlanner = "${baseUrl}" + "monthlyplanner.php";
const String getTimeTable = "${baseUrl}" + "timetable.php";
const String getSyllabus = "${baseUrl}" + "syllabus.php";
const String getInstalmentDetailUrl = "${baseUrl}" + "iinstallment.php";
const String notificationUrl = "${baseUrl}" + "notification.php";



loginBody({required email, required password,required version}) {
  return {
    "email": email,
    "pass": password,
    "version":version
  };
}
passwordResetBody({required id,oldpassword,newpassword}) {
  return {
    "id": id,
    "password":newpassword,
    if(oldpassword!=null)
      "old_pass":oldpassword
  };
}


partBdataBody({required id}) {
  return {
    "id": id,

  };
}

Map<String, String> gernalDetailBody(
    {id,
    fname,
    lname,
    gender,

    dob,
    saadhar,

    religion,


    state,
    city,
    address,
    pincode,
    city_type,
    previous_medium,
    previous_result,
    category,
    previous_class,
    brother_name,
    brother_class,
    brother_school,
    sister_name,
    sister_class,
    sister_school,
    gurdian_name,
    gurdian_mobile,
    father_name,
    mother_name,
    mother_occupation,
    father_occupation,

    father_mobile,
    mother_mobile,
    father_aadhar,
    father_pan,
    mother_aadhar,
    mother_pan,
    father_office,
    mother_office,
    father_education,
    mother_education,
      minority,
    }) {
  return {
    "id":id,
    "fname":fname,
    "lname":lname,
    "gender":gender,

    "dob":dob,
    "saadhar":saadhar,

    "religion":religion,

    "state":state,
    "city":city,
    "address":address,

    "pincode":pincode,
    "city_type":city_type,
    "previous_medium":previous_medium,
    "previous_result":previous_result,
    "category":category,
    "previous_class":previous_class,
    "brother_name":brother_name,
    "brother_class":brother_class,
    "brother_school":brother_school,
    "sister_name":sister_name,
    "sister_class":sister_class,
    "sister_school":sister_school,
    "gurdian_name":gurdian_name,
    "gurdian_mobile":gurdian_mobile,
    "father_name":father_name,
    "mother_name":mother_name,
    "mother_occupation":mother_occupation,
    "father_occupation":father_occupation,

    "father_mobile":father_mobile,
    "mother_mobile":mother_mobile,
    "father_aadhar":father_aadhar,
    "father_pan":father_pan,
    "mother_aadhar":mother_aadhar,
    "mother_pan":mother_pan,
    "father_office":father_office,
    "mother_office":mother_office,
    "father_education":father_education,
    "mother_education":mother_education,
    "minority":minority
  };
}

partBDataSubmitBody(
student_id,
first_name,
last_name,
blood_group,
st_height,
st_weight,
mother_tounge,
poverty,
disadvantage,
status_previous,
last_year,
grade,
last_passed,
last_marks,
last_attendance,
term_condition,


    ){
  return {
  "student_id":student_id,
  "first_name":first_name,
  "last_name":last_name,
  "blood_group":blood_group,
  "st_height":st_height,
  "st_weight":st_weight,
  "mother_tounge":mother_tounge,
  "poverty":poverty,
  "disadvantage":disadvantage,
  "status_previous":status_previous,
  "last_year":last_year,
  "grade":grade,
  "last_passed":last_passed,
  "last_marks":last_marks,
  "last_attendance":last_attendance,
  "term_condition":term_condition,
  };
}



