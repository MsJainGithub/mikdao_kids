import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../config/themeConfig.dart';
import '../providers/profileProvider.dart';
import '../widgets/CustomizeDatePicker.dart';
import '../widgets/dataWidget.dart';

class PartAScreen extends StatefulWidget {
  const PartAScreen({super.key, required this.isEditable});

  final bool isEditable;

  @override
  State<PartAScreen> createState() => _PartAScreenState();
}

class _PartAScreenState extends State<PartAScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      body: SafeArea(child: _academicDetailWidget()),
    );
  }

  Widget _academicDetailWidget() {
    final ProfileProvider pp = Provider.of<ProfileProvider>(context, listen: false);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Student Details",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: maincolor,
                  ),
                ),
                Divider(height: 24.h),

                ProfileTextField(title: "First Name", clt: pp.studentFNameClt, readonly: !widget.isEditable),
                Gap(16.h),

                ProfileTextField(title: "Last Name", clt: pp.studentLNameClt, readonly: !widget.isEditable),
                Gap(16.h),

                CustomizeDatePicker(text: "Date of Birth", clt: pp.studentDOBClt, enabled: widget.isEditable),
                Gap(16.h),

                ProfileTextField(title: "Aadhar Number", clt: pp.studentAadharCardNoClt, readonly: !widget.isEditable),
                Gap(16.h),

                _buildGenderSelection(pp),
                Gap(16.h),

                _buildCategorySelection(pp),
                Gap(16.h),

                _buildReligionSelection(pp),
                Gap(16.h),

                _buildMinoritySelection(pp),
                Gap(16.h),

                ProfileTextField(title: "State", clt: pp.studentStateClt, readonly: !widget.isEditable),
                Gap(12.h),
                ProfileTextField(title: "City", clt: pp.studentCityClt, readonly: !widget.isEditable),
                Gap(12.h),

                _buildCityTypeSelection(pp),
                Gap(12.h),

                ProfileTextField(title: "Address", clt: pp.studentAddressClt, readonly: !widget.isEditable),
                Gap(12.h),
                ProfileTextField(title: "Pin code", clt: pp.studentPincodeClt, type: TextInputType.number, readonly: !widget.isEditable),
                Gap(12.h),

                ProfileTextField(title: "Brother/Sister Name", clt: pp.studentBrotherNameClt, readonly: !widget.isEditable),
                Gap(12.h),
                ProfileTextField(title: "Brother/Sister Class", clt: pp.studentBrotherClassClt, readonly: !widget.isEditable),
                Gap(12.h),
                ProfileTextField(title: "Brother/Sister School name", clt: pp.studentBrotherSchoolNameClt, readonly: !widget.isEditable),
                Gap(12.h),
                ProfileTextField(title: "Sister Name", clt: pp.studentSisterNameClt, readonly: !widget.isEditable),
                Gap(12.h),
                ProfileTextField(title: "Sister Class", clt: pp.studentSisterClassClt, readonly: !widget.isEditable),
                Gap(12.h),
                ProfileTextField(title: "Sister School name", clt: pp.studentSisterSchoolNameClt, readonly: !widget.isEditable),
                Gap(22.h),

                Text("Family Detail", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                Gap(10.h),
                ProfileTextField(title: "Father name", clt: pp.fatherNameClt, readonly: !widget.isEditable),
                Gap(12.h),
                ProfileTextField(title: "Father Qualification", clt: pp.fatherQualificationClt, readonly: !widget.isEditable),
                Gap(12.h),
                ProfileTextField(title: "Father Occupation", clt: pp.fatherOccupationClt, readonly: !widget.isEditable),
                Gap(12.h),
                ProfileTextField(title: "Father Aadhar no.", clt: pp.fatherAadharNoClt, readonly: !widget.isEditable),
                Gap(12.h),
                ProfileTextField(title: "Father Office Address", clt: pp.fatherOfficeAddressClt, readonly: !widget.isEditable),
                Gap(12.h),
                ProfileTextField(title: "Father mobile no.", clt: pp.fatherMobileNoClt, type: TextInputType.number, readonly: !widget.isEditable),
                Gap(12.h),
                ProfileTextField(title: "Father Pan no.", clt: pp.fatherPanNoClt, readonly: !widget.isEditable),
                Gap(12.h),
                ProfileTextField(title: "Mother name", clt: pp.motherNameClt, readonly: !widget.isEditable),
                Gap(12.h),
                ProfileTextField(title: "Mother Qualification", clt: pp.motherQualificationClt, readonly: !widget.isEditable),
                Gap(12.h),
                ProfileTextField(title: "Mother Occupation", clt: pp.motherOccupationClt, readonly: !widget.isEditable),
                Gap(12.h),
                ProfileTextField(title: "Mother Aadhar no.", clt: pp.motherAadharNoClt, readonly: !widget.isEditable),
                Gap(12.h),
                ProfileTextField(title: "Mother Office Address", clt: pp.motherOfficeAddressClt, readonly: !widget.isEditable),
                Gap(12.h),
                ProfileTextField(title: "Mother mobile no.", clt: pp.motherMobileNoClt, type: TextInputType.number, readonly: !widget.isEditable),
                Gap(12.h),
                ProfileTextField(title: "Mother Pan no.", clt: pp.motherPanNoClt, readonly: !widget.isEditable),
                Gap(22.h),

                Text("Guardian Detail", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                Gap(10.h),
                ProfileTextField(title: "Name", clt: pp.gardienNameClt, readonly: !widget.isEditable),
                Gap(12.h),
                ProfileTextField(title: "Mobile No", clt: pp.gardienMobileClt, readonly: !widget.isEditable),
                Gap(22.h),
                if (widget.isEditable)
                  GestureDetector(
                    onTap: () {
                      pp.hangelSubmit(context);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 40.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        gradient: LinearGradient(
                          colors: [
                            redMainColor,
                            redMainColor.withOpacity(0.8),
                            redMainColor.withOpacity(0.5),
                          ],
                        ),
                      ),
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSelection(ProfileProvider pp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Gender", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
        Row(
          children: [
            Radio(
              activeColor: maincolor,
              value: 1,
              groupValue: pp.selectedGender,
              onChanged: widget.isEditable ? (c) => pp.changeGender(c) : null,
            ),
            Text("Male", style: TextStyle(fontSize: 14.sp)),
            Gap(24.w),
            Radio(
              activeColor: maincolor,
              value: 2,
              groupValue: pp.selectedGender,
              onChanged: widget.isEditable ? (c) => pp.changeGender(c) : null,
            ),
            Text("Female", style: TextStyle(fontSize: 14.sp)),
          ],
        ),
      ],
    );
  }

  Widget _buildCategorySelection(ProfileProvider pp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Category", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
        Wrap(
          spacing: 8.w,
          children: List.generate(pp.categoryList.length, (index) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio(
                  activeColor: maincolor,
                  value: pp.categoryList[index].val,
                  groupValue: pp.selectedCategory.val,
                  onChanged: widget.isEditable ? (c) => pp.changeCategory(c) : null,
                ),
                Text(pp.categoryList[index].name, style: TextStyle(fontSize: 14.sp)),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildReligionSelection(ProfileProvider pp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Religion", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
        Wrap(
          children: List.generate(pp.religion.length, (index) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio(
                  value: pp.religion[index].val,
                  groupValue: pp.selectedReligion.val,
                  onChanged: widget.isEditable ? (c) => pp.changeReligion(c) : null,
                ),
                Text(pp.religion[index].name),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMinoritySelection(ProfileProvider pp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Minority Group", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
        Wrap(
          children: List.generate(pp.minorityCategoryList.length, (index) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio(
                  value: pp.minorityCategoryList[index].val,
                  groupValue: pp.selectedMinorityCategory.val,
                  onChanged: widget.isEditable ? (c) => pp.changeMinorityCategory(c) : null,
                ),
                Text(pp.minorityCategoryList[index].name),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCityTypeSelection(ProfileProvider pp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("City Type", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
        Row(
          children: [
            Radio(
              value: 1,
              groupValue: pp.selectedCityType,
              onChanged: widget.isEditable ? (c) => pp.changeCityType(c) : null,
            ),
            const Text("Rural"),
            Gap(15.w),
            Radio(
              value: 2,
              groupValue: pp.selectedCityType,
              onChanged: widget.isEditable ? (c) => pp.changeCityType(c) : null,
            ),
            const Text("Urban"),
          ],
        ),
      ],
    );
  }
}
