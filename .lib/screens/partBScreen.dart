import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../config/themeConfig.dart';
import '../providers/profileProvider.dart';
import '../widgets/dataWidget.dart';
import '../widgets/toast.dart';

class PartBScreen extends StatefulWidget {
  const PartBScreen({super.key, required this.isEditable});

  final bool isEditable;

  @override
  State<PartBScreen> createState() => _PartBScreenState();
}

class _PartBScreenState extends State<PartBScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      body: SafeArea(child: ParentDetailWidget()),
    );
  }

  Widget ParentDetailWidget(){
    final ProfileProvider pp = Provider.of<ProfileProvider>(context,listen: false);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Padding(
        padding: const EdgeInsets.only(left: 5,right: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10,),
            ProfileTextField(title: "First Name Of Student As Per Aadhaar Card",clt: pp.BFirstNameClt, readonly: !widget.isEditable,),
            Gap(12),
            ProfileTextField(title: "Last Name Of Student As Per Aadhaar Card",clt: pp.BLastNameClt, readonly: !widget.isEditable,),


            Gap(12),
            ProfileTextField(title: "Blood Group",clt: pp.BBloodClt, readonly: !widget.isEditable,),
            Gap(12),
            ProfileTextField(title: "Student's Height(in CMs)",type: TextInputType.number,clt: pp.BHeightClt, readonly: !widget.isEditable,),
            Gap(12),
            ProfileTextField(title: "Student's Weight(in KGs)",type: TextInputType.number,clt: pp.BWeightClt, readonly: !widget.isEditable,),
            Gap(12),

            ProfileTextField(title: "Mother Tongue of the student",clt: pp.BMotherToungeClt, readonly: !widget.isEditable,),
            Gap(12),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Whether belong to below poverty line",style: TextStyle(fontWeight: FontWeight.w600),),
                  Row(
                    children: [

                      Radio(
                          visualDensity: VisualDensity(horizontal: -4),
                          value: 1, groupValue:pp.valuePoverty, onChanged: widget.isEditable ? (c){
                        pp.changePoverty(c);
                      } : null),
                      Text("Yes"),
                      Gap(15),
                      Radio(
                          visualDensity: VisualDensity(horizontal: -4),
                          value: 2, groupValue: pp.valuePoverty, onChanged: widget.isEditable ? (c){
                        pp.changePoverty(c);
                      } : null),
                      Text("No"),
                    ],
                  ),
                ],
              ),
            ),
            Gap(12),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Disadvantage group weaker section",style: TextStyle(fontWeight: FontWeight.w600),),
                  Row(
                    children: [

                      Radio(
                          visualDensity: VisualDensity(horizontal: -4),
                          value: 1, groupValue:pp.valueDisadvantage, onChanged: widget.isEditable ? (c){
                        pp.changeValueDisadvantage(c);
                      } : null),
                      Text("Yes"),
                      Gap(15),
                      Radio(
                          visualDensity: VisualDensity(horizontal: -4),
                          value: 2, groupValue: pp.valueDisadvantage, onChanged: widget.isEditable ? (c){
                        pp.changeValueDisadvantage(c);
                      } : null),
                      Text("No"),
                    ],
                  ),
                ],
              ),
            ),
            Gap(12),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("If studying in class 1st then status of previous year",style: TextStyle(fontWeight: FontWeight.w600),),
                  Wrap(
                      children: List.generate(pp.previousYearList.length, (index) {
                        return Container(
                          child: Row(
                            children: [
                              Radio(
                                  visualDensity: VisualDensity(horizontal: -4),
                                  value:pp.previousYearList[index].val , groupValue: pp.selectedPreviousYear.val, onChanged: widget.isEditable ? (c){
                                pp.changePreviousYear(c);
                              } : null),
                              Text(pp.previousYearList[index].name),
                            ],
                          ),
                        );
                      })
                  ),
                ],
              ),
            ),
            Gap(12),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("If studying in class 1st then status of previous year",style: TextStyle(fontWeight: FontWeight.w600),),
                  DropdownButtonHideUnderline(
                    child: DropdownButton2(
                      isExpanded: true,
                      hint: Text(
                        'Select Years',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      items: pp.years
                          .map((item) => DropdownItem(
                        value: item,
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ))
                          .toList(),
                      valueListenable: pp.selectedYear,
                      onChanged: widget.isEditable ? (value) {
                        pp.changeSelectedYear(value);
                      } : null,
                      buttonStyleData: const ButtonStyleData(
                        padding: EdgeInsets.symmetric(horizontal: 0),
                        height: 40,
                        width: double.infinity,
                      ),
                      // menuItemStyleData: const MenuItemStyleData(
                      //   height: 40,
                      // ),
                      menuItemStyleData: const MenuItemStyleData(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Gap(12),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("If studying in class 1st then grade of previous year",style: TextStyle(fontWeight: FontWeight.w600),),
                  DropdownButtonHideUnderline(
                    child:
                    // DropdownButton2(
                    //   isExpanded: true,
                    //   hint: Text(
                    //     'Select Grade',
                    //     style: TextStyle(
                    //       fontSize: 14,
                    //       color: Theme.of(context).hintColor,
                    //     ),
                    //   ),
                    //   // items: pp.grade
                    //   //     .map((item) => DropdownMenuItem(
                    //   //   value: item,
                    //   //   child: Text(
                    //   //     item,
                    //   //     style: const TextStyle(
                    //   //       fontSize: 14,
                    //   //     ),
                    //   //   ),
                    //   // ))
                    //   //     .toList(),
                    //   items: pp.grade
                    //       .map(
                    //         (item) => DropdownItem<String>(
                    //       value: item,
                    //       height: 40,
                    //       child: Text(item),
                    //     ),
                    //   )
                    //       .toList(),
                    //
                    //   valueListenable: pp.selectedGrade,
                    //
                    //   onChanged: (String? value) {
                    //     pp.changeSelectedGrade(value);
                    //   },
                    //   value: pp.selectedGrade,
                    //   onChanged: widget.isEditable ? (value) {
                    //     pp.changeSelectedGrade(value);
                    //   } : null,
                    //   buttonStyleData: const ButtonStyleData(
                    //     padding: EdgeInsets.symmetric(horizontal: 0),
                    //     height: 40,
                    //     width: double.infinity,
                    //   ),
                    //   menuItemStyleData: const MenuItemStyleData(
                    //     height: 40,
                    //   ),
                    // ),
                      DropdownButton2<String>(
                        isExpanded: true,

                        hint: const Text("Select Grade"),

                        items: pp.grade
                            .map(
                              (item) => DropdownItem<String>(
                            value: item,
                            height: 40,
                            child: Text(item),
                          ),
                        )
                            .toList(),

                        valueListenable: pp.selectedGrade,

                        onChanged: widget.isEditable
                            ? (String? value) {
                          pp.changeSelectedGrade(value);
                        }
                            : null,

                        buttonStyleData: const ButtonStyleData(
                          height: 40,
                          width: double.infinity,
                        ),
                      )
                  ),
                ],
              ),
            ),
            Gap(12),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Passed in last year annual examination",style: TextStyle(fontWeight: FontWeight.w600),),
                  Row(
                    children: [

                      Radio(
                          visualDensity: VisualDensity(horizontal: -4),
                          value: 1, groupValue:pp.valuePassedLastYear, onChanged: widget.isEditable ? (c){
                        pp.changeValuePassedLastYear(c);
                      } : null),
                      Text("Yes"),
                      Gap(15),
                      Radio(
                          visualDensity: VisualDensity(horizontal: -4),
                          value: 2, groupValue: pp.valuePassedLastYear, onChanged: widget.isEditable ? (c){
                        pp.changeValuePassedLastYear(c);

                      } : null),
                      Text("No"),
                    ],
                  ),
                ],
              ),
            ),
            Gap(12),
            ProfileTextField(title: "Marks obtained in last year annual examination (in %)",type: TextInputType.number,clt: pp.BLastMark, readonly: !widget.isEditable,),
            Gap(12),
            ProfileTextField(title: "No of days child attended school in previous year _",type: TextInputType.number,clt: pp.BLastAttendance, readonly: !widget.isEditable,),
            Gap(22),
            Text("Terms and Conditions",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
            SizedBox(height: 10,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(pp.termsAndCondition.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          child: Icon(Icons.circle,size: 10,),
                          padding: EdgeInsets.only(top: 5),
                        ),
                        Gap(10),
                        Expanded(child: Text(pp.termsAndCondition[index],textAlign: TextAlign.start,))
                      ],
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 10,),
            Row(
              children: [
                Checkbox(value: pp.termeCheck, onChanged: widget.isEditable ? (v){
                  pp.changeTermCheck(v);
                } : null),

                Text("I Accepted Term And Condition"),
              ],
            ),
            Gap(22),
            if (widget.isEditable) GestureDetector(
              onTap: (){
                if(pp.termeCheck==false){
                  showToastE(message: "Please check terms and condition");
                }else{
                  pp.submitePartBData(context);
                }


              },
              child: Container(
                alignment: Alignment.center,
                height: 34.h,
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    gradient: LinearGradient(
                        colors: [
                          redMainColor,
                          redMainColor.withOpacity(0.8),
                          redMainColor.withOpacity(0.5),
                        ]
                    )
                ),
                child: Text("Submit",style: TextStyle(color: Colors.white,fontSize: 15,fontWeight: FontWeight.bold),),
              ),
            ),



          ],
        ),
      ),
    );
  }

}
