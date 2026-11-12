import 'package:date_time_picker/date_time_picker.dart';


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';




Widget CustomizeDatePicker(
    { TextEditingController? clt,
    required String text,
      DateTime?firstDay,
      DateTime?lastDate,
    String? Function(String?)? onChange,
    String? Function(String?)? onVal,
    bool enabled = true,

    }) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      DateTimePicker(

        dateMask: "dd-MM-yyyy",
        controller: clt,

        decoration: InputDecoration(
          // prefixIcon: Icon(Icons.calendar_month,size: 20,color: Colors.grey,),
            label: Text(text,style: TextStyle(color: Colors.grey),),
            hintStyle: TextStyle(color: Color(0xff5B6469)),
            contentPadding:
                EdgeInsets.only(left: 15,right: 15,bottom: 5,top: 8),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey)
            ),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey)
            )
            ),
        firstDate: firstDay??DateTime(-21000),
        validator: onVal,

        lastDate: lastDate??DateTime(20000),
        onChanged:onChange,
        enabled: enabled,
        autovalidate: true,

        onSaved: (val) {},
      ),
    ],
  );
}
