import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../config/themeConfig.dart';
import '../providers/earlyDepartureProvider.dart';
import '../widgets/app_header.dart';

class EarlyDepartureScreen extends StatefulWidget {
  const EarlyDepartureScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<EarlyDepartureScreen> createState() =>
      _EarlyDepartureScreenState();
}

class _EarlyDepartureScreenState
    extends State<EarlyDepartureScreen> {
  bool _showForm = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
      context.read<EarlyDepartureProvider>();

      provider.getDepartureRequests(context);
      provider.getUserInfo(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EarlyDepartureProvider>(
      builder: (
          context,
          provider,
          child,
          ) {
        return Scaffold(
          backgroundColor: const Color(0xFFF6F8FC),

          appBar: PreferredSize(
            preferredSize: Size.fromHeight(
              82.h + MediaQuery.of(context).padding.top,
            ),
            child: SafeArea(
              top: true,
              bottom: false,
              child: AppHeader(
                title: _showForm
                    ? "New Request"
                    : "Early Departure",
                subtitle: _showForm
                    ? "Create a new request"
                    : "Manage your requests",
                showBack: true,
                onBack: () {
                  if (_showForm) {
                    provider.clearForm();

                    setState(() {
                      _showForm = false;
                    });
                  } else {
                    Get.back();
                  }
                },
              ),
            ),
          ),

          body: SafeArea(
            top: false,
            bottom: true,
            child: provider.isLoading
                ? _buildLoader()
                : AnimatedSwitcher(
              duration: const Duration(
                milliseconds: 250,
              ),
              child: _showForm
                  ? _buildForm(provider)
                  : _buildList(provider),
            ),
          ),

          floatingActionButton:
          !_showForm && !provider.isLoading
              ? _buildAddButton(provider)
              : null,
        );
      },
    );
  }


  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar(
      EarlyDepartureProvider provider,
      ) {
    return AppBar(
      backgroundColor: maincolor,
      elevation: 0,
      centerTitle: false,

      leading: IconButton(
        onPressed: () {
          if (_showForm) {
            provider.clearForm();

            setState(() {
              _showForm = false;
            });
          } else {
            Get.back();
          }
        },
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
        ),
      ),

      title: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            _showForm
                ? "New Request"
                : "Early Departure",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          Text(
            _showForm
                ? "Create a new request"
                : "Manage your requests",
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.white.withOpacity(0.75),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOADER
  // ============================================================

  Widget _buildLoader() {
    return Center(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Container(
            height: 58.w,
            width: 58.w,
            padding: EdgeInsets.all(15.w),
            decoration: BoxDecoration(
              color: maincolor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: maincolor,
            ),
          ),

          Gap(16.h),

          Text(
            "Loading...",
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ADD BUTTON
  // ============================================================

  Widget _buildAddButton(
      EarlyDepartureProvider provider,
      ) {
    return FloatingActionButton.extended(
      backgroundColor: maincolor,
      elevation: 4,

      onPressed: () {
        provider.clearForm();

        setState(() {
          _showForm = true;
        });
      },

      icon: const Icon(
        Icons.add_rounded,
        color: Colors.white,
      ),

      label: Text(
        "New Request",
        style: TextStyle(
          color: Colors.white,
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============================================================
  // LIST
  // ============================================================

  Widget _buildList(
      EarlyDepartureProvider provider,
      ) {
    if (provider.departureList.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: maincolor,

      onRefresh: () async {
        await provider.getDepartureRequests(
          context,
        );
      },

      child: ListView.builder(
        physics:
        const AlwaysScrollableScrollPhysics(),

        padding: EdgeInsets.fromLTRB(
          16.w,
          18.h,
          16.w,
          100.h,
        ),

        itemCount:
        provider.departureList.length,

        itemBuilder: (
            context,
            index,
            ) {
          final item =
          provider.departureList[index];

          return _buildRequestCard(item);
        },
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return RefreshIndicator(
      color: maincolor,

      onRefresh: () async {
        await context
            .read<EarlyDepartureProvider>()
            .getDepartureRequests(context);
      },

      child: ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),

        children: [
          SizedBox(
            height:
            MediaQuery.of(context).size.height *
                0.65,
            child: Center(
              child: Padding(
                padding:
                EdgeInsets.symmetric(
                  horizontal: 30.w,
                ),

                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  children: [
                    Container(
                      height: 100.w,
                      width: 100.w,

                      decoration:
                      BoxDecoration(
                        color: maincolor
                            .withOpacity(0.08),
                        shape:
                        BoxShape.circle,
                      ),

                      child: Icon(
                        Icons
                            .exit_to_app_rounded,
                        size: 46.sp,
                        color: maincolor,
                      ),
                    ),

                    Gap(20.h),

                    Text(
                      "No Requests Yet",
                      textAlign:
                      TextAlign.center,
                      style: TextStyle(
                        fontSize: 19.sp,
                        fontWeight:
                        FontWeight.w700,
                        color:
                        Colors.black87,
                      ),
                    ),

                    Gap(8.h),

                    Text(
                      "You haven't submitted any early departure requests yet.",
                      textAlign:
                      TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.sp,
                        height: 1.5,
                        color:
                        Colors.grey.shade600,
                      ),
                    ),

                    Gap(22.h),

                    OutlinedButton.icon(
                      onPressed: () {
                        final provider =
                        context.read<
                            EarlyDepartureProvider>();

                        provider.clearForm();

                        setState(() {
                          _showForm = true;
                        });
                      },

                      icon: Icon(
                        Icons.add_rounded,
                        color: maincolor,
                      ),

                      label: Text(
                        "Create Request",
                        style: TextStyle(
                          color: maincolor,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),

                      style:
                      OutlinedButton.styleFrom(
                        padding:
                        EdgeInsets.symmetric(
                          horizontal: 22.w,
                          vertical: 12.h,
                        ),

                        side:
                        BorderSide(
                          color: maincolor,
                        ),

                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius
                              .circular(
                            12.r,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REQUEST CARD
  // ============================================================

  Widget _buildRequestCard(
      EarlyDepartureModel item,
      ) {
    Color statusColor = Colors.orange;

    final status =
    item.status.toLowerCase().trim();

    if (status == "approved") {
      statusColor = Colors.green;
    } else if (status == "rejected") {
      statusColor = Colors.red;
    } else if (status == "cancelled") {
      statusColor = Colors.grey;
    }

    final displayStatus =
    item.status.isEmpty
        ? "Pending"
        : item.status;

    return Container(
      margin:
      EdgeInsets.only(bottom: 14.h),

      padding:
      EdgeInsets.all(15.w),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(18.r),

        border: Border.all(
          color:
          Colors.grey.shade100,
        ),

        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withOpacity(0.035),
            blurRadius: 14,
            offset:
            const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              Container(
                height: 46.w,
                width: 46.w,

                decoration:
                BoxDecoration(
                  color:
                  maincolor.withOpacity(
                    0.09,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    13.r,
                  ),
                ),

                child: Icon(
                  Icons
                      .exit_to_app_rounded,
                  color: maincolor,
                  size: 24.sp,
                ),
              ),

              Gap(12.w),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    Text(
                      "Early Departure",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight:
                        FontWeight.w700,
                        color:
                        Colors.black87,
                      ),
                    ),

                    Gap(5.h),

                    Row(
                      children: [
                        Icon(
                          Icons
                              .calendar_today_outlined,
                          size: 12.sp,
                          color:
                          Colors.grey.shade500,
                        ),

                        Gap(5.w),

                        Expanded(
                          child: Text(
                            item.date,
                            style:
                            TextStyle(
                              fontSize:
                              11.sp,
                              color: Colors
                                  .grey
                                  .shade600,
                            ),
                          ),
                        ),

                        if (item.time
                            .isNotEmpty) ...[
                          Icon(
                            Icons
                                .access_time_rounded,
                            size: 12.sp,
                            color: Colors
                                .grey
                                .shade500,
                          ),

                          Gap(5.w),

                          Text(
                            item.time,
                            style:
                            TextStyle(
                              fontSize:
                              11.sp,
                              color: Colors
                                  .grey
                                  .shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 6.h,
                ),

                decoration:
                BoxDecoration(
                  color:
                  statusColor.withOpacity(
                    0.10,
                  ),

                  borderRadius:
                  BorderRadius.circular(
                    20.r,
                  ),
                ),

                child: Text(
                  displayStatus,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10.sp,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          Gap(14.h),

          Container(
            height: 1,
            color:
            Colors.grey.shade100,
          ),

          Gap(12.h),

          _buildDetailRow(
            icon:
            Icons.person_outline_rounded,
            label: "Person",
            value: item.person,
          ),

          Gap(9.h),

          _buildDetailRow(
            icon:
            Icons.phone_outlined,
            label: "Contact",
            value: item.contact,
          ),

          Gap(9.h),

          _buildDetailRow(
            icon:
            Icons.description_outlined,
            label: "Reason",
            value: item.reason,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        Container(
          height: 30.w,
          width: 30.w,

          decoration:
          BoxDecoration(
            color:
            Colors.grey.shade100,
            borderRadius:
            BorderRadius.circular(
              8.r,
            ),
          ),

          child: Icon(
            icon,
            size: 16.sp,
            color:
            Colors.grey.shade600,
          ),
        ),

        Gap(9.w),

        SizedBox(
          width: 65.w,

          child: Padding(
            padding:
            EdgeInsets.only(
              top: 5.h,
            ),

            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color:
                Colors.grey.shade600,
                fontWeight:
                FontWeight.w500,
              ),
            ),
          ),
        ),

        Gap(5.w),

        Expanded(
          child: Padding(
            padding:
            EdgeInsets.only(
              top: 5.h,
            ),

            child: Text(
              value.isEmpty
                  ? "-"
                  : value,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight:
                FontWeight.w600,
                color:
                Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FORM
  // ============================================================

  Widget _buildForm(
      EarlyDepartureProvider provider,
      ) {
    return SingleChildScrollView(
      keyboardDismissBehavior:
      ScrollViewKeyboardDismissBehavior
          .onDrag,

      padding:
      EdgeInsets.fromLTRB(
        16.w,
        18.h,
        16.w,
        35.h,
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          // ======================================================
          // HEADER INFO
          // ======================================================

          // _buildInfoCard(),
          //
          // Gap(22.h),

          // ======================================================
          // DEPARTURE DETAILS
          // ======================================================

          _buildSectionHeader(
            icon:
            Icons.access_time_rounded,
            title: "Departure Details",
            subtitle:
            "Choose your departure date and time",
          ),

          Gap(12.h),

          _buildLabel("Date"),

          Gap(7.h),

          _buildDatePicker(provider),

          Gap(15.h),

          _buildLabel("Time"),

          Gap(7.h),

          _buildTimePicker(provider),

          Gap(24.h),

          // ======================================================
          // PERSON DETAILS
          // ======================================================

          _buildSectionHeader(
            icon:
            Icons.person_outline_rounded,
            title: "Person Details",
            subtitle:
            "Select who will accompany or collect you",
          ),

          Gap(12.h),

          _buildLabel("Person"),

          Gap(7.h),

          _buildPersonDropdown(provider),

          if (provider.selectedPerson ==
              "Other") ...[
            Gap(15.h),

            _buildLabel("Person Name"),

            Gap(7.h),

            _buildTextField(
              controller:
              provider
                  .otherPersonController,

              hintText:
              "Enter person's name",

              prefixIcon:
              Icons
                  .person_outline_rounded,

              textInputType:
              TextInputType.name,
            ),
          ],

          Gap(24.h),

          // ======================================================
          // CONTACT DETAILS
          // ======================================================

          _buildSectionHeader(
            icon:
            Icons.phone_outlined,
            title: "Contact Details",
            subtitle:
            "Provide a reachable contact number",
          ),

          Gap(12.h),

          _buildTextField(
            controller:
            provider.contactController,

            hintText:
            "Enter contact number",

            prefixIcon:
            Icons.phone_outlined,

            textInputType:
            TextInputType.phone,

            maxLength: 10,
          ),

          Gap(24.h),

          // ======================================================
          // REASON
          // ======================================================

          _buildSectionHeader(
            icon:
            Icons.description_outlined,
            title: "Reason",
            subtitle:
            "Tell us why you need to leave early",
          ),

          Gap(12.h),

          _buildTextField(
            controller:
            provider.reasonController,

            hintText:
            "Enter reason for early departure",

            prefixIcon:
            Icons.description_outlined,

            maxLines: 4,

            textInputType:
            TextInputType.multiline,
          ),

          Gap(28.h),

          // ======================================================
          // SUBMIT
          // ======================================================

          SizedBox(
            width: double.infinity,
            height: 52.h,

            child:
            ElevatedButton(
              onPressed:
              provider.isSubmitting
                  ? null
                  : () =>
                  _submit(provider),

              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                maincolor,

                disabledBackgroundColor:
                maincolor
                    .withOpacity(
                  0.55,
                ),

                elevation: 0,

                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    14.r,
                  ),
                ),
              ),

              child:
              provider.isSubmitting
                  ? SizedBox(
                height: 23.w,
                width: 23.w,
                child:
                const CircularProgressIndicator(
                  strokeWidth:
                  2.2,
                  color:
                  Colors.white,
                ),
              )
                  : Row(
                mainAxisAlignment:
                MainAxisAlignment
                    .center,
                children: [
                  const Icon(
                    Icons
                        .send_rounded,
                    color:
                    Colors.white,
                    size: 19,
                  ),

                  Gap(8.w),

                  Text(
                    "Submit Request",
                    style:
                    TextStyle(
                      fontSize:
                      14.sp,
                      fontWeight:
                      FontWeight.w700,
                      color:
                      Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Gap(12.h),

          // ======================================================
          // CANCEL
          // ======================================================

          SizedBox(
            width: double.infinity,
            height: 50.h,

            child:
            OutlinedButton(
              onPressed:
              provider.isSubmitting
                  ? null
                  : () {
                provider
                    .clearForm();

                setState(() {
                  _showForm =
                  false;
                });
              },

              style:
              OutlinedButton.styleFrom(
                backgroundColor:
                Colors.white,

                side:
                BorderSide(
                  color:
                  Colors.grey.shade300,
                ),

                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    14.r,
                  ),
                ),
              ),

              child: Text(
                "Cancel",
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight:
                  FontWeight.w600,
                  color:
                  Colors.grey.shade700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO CARD
  // ============================================================

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,

      padding:
      EdgeInsets.all(15.w),

      decoration:
      BoxDecoration(
        gradient:
        LinearGradient(
          colors: [
            maincolor.withOpacity(0.12),
            maincolor.withOpacity(0.05),
          ],
          begin:
          Alignment.topLeft,
          end:
          Alignment.bottomRight,
        ),

        borderRadius:
        BorderRadius.circular(
          16.r,
        ),

        border:
        Border.all(
          color:
          maincolor.withOpacity(
            0.08,
          ),
        ),
      ),

      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Container(
            height: 40.w,
            width: 40.w,

            decoration:
            BoxDecoration(
              color: maincolor,
              borderRadius:
              BorderRadius.circular(
                11.r,
              ),
            ),

            child: const Icon(
              Icons
                  .info_outline_rounded,
              color: Colors.white,
            ),
          ),

          Gap(11.w),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Text(
                  "Early Departure Request",
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight:
                    FontWeight.w700,
                    color:
                    Colors.black87,
                  ),
                ),

                Gap(4.h),

                Text(
                  "Please provide accurate details before submitting your request.",
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    height: 1.4,
                    color:
                    Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        Container(
          height: 38.w,
          width: 38.w,

          decoration:
          BoxDecoration(
            color:
            maincolor.withOpacity(
              0.09,
            ),
            borderRadius:
            BorderRadius.circular(
              10.r,
            ),
          ),

          child: Icon(
            icon,
            color: maincolor,
            size: 20.sp,
          ),
        ),

        Gap(10.w),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight:
                  FontWeight.w700,
                  color:
                  Colors.black87,
                ),
              ),

              Gap(2.h),

              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  color:
                  Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LABEL
  // ============================================================

  Widget _buildLabel(
      String label,
      ) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight:
        FontWeight.w600,
        color:
        Colors.black87,
      ),
    );
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Widget _buildDatePicker(
      EarlyDepartureProvider provider,
      ) {
    final hasDate =
        provider.selectedDate != null;

    return InkWell(
      onTap: () =>
          _selectDate(provider),

      borderRadius:
      BorderRadius.circular(
        14.r,
      ),

      child: Container(
        height: 54.h,

        padding:
        EdgeInsets.symmetric(
          horizontal: 14.w,
        ),

        decoration:
        BoxDecoration(
          color: Colors.white,

          borderRadius:
          BorderRadius.circular(
            14.r,
          ),

          border:
          Border.all(
            color:
            hasDate
                ? maincolor.withOpacity(
              0.35,
            )
                : Colors.grey.shade200,
          ),

          boxShadow: [
            BoxShadow(
              color:
              Colors.black.withOpacity(
                0.025,
              ),
              blurRadius: 8,
              offset:
              const Offset(0, 3),
            ),
          ],
        ),

        child: Row(
          children: [
            Icon(
              Icons
                  .calendar_today_outlined,
              size: 20.sp,
              color: maincolor,
            ),

            Gap(11.w),

            Expanded(
              child: Text(
                hasDate
                    ? _formatDate(
                  provider
                      .selectedDate!,
                )
                    : "Select departure date",

                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: hasDate
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: hasDate
                      ? Colors.black87
                      : Colors.grey.shade500,
                ),
              ),
            ),

            Icon(
              Icons
                  .keyboard_arrow_down_rounded,
              size: 21.sp,
              color:
              Colors.grey.shade500,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TIME PICKER
  // ============================================================

  Widget _buildTimePicker(
      EarlyDepartureProvider provider,
      ) {
    final hasTime =
        provider.selectedTime != null;

    return InkWell(
      onTap: () =>
          _selectTime(provider),

      borderRadius:
      BorderRadius.circular(
        14.r,
      ),

      child: Container(
        height: 54.h,

        padding:
        EdgeInsets.symmetric(
          horizontal: 14.w,
        ),

        decoration:
        BoxDecoration(
          color: Colors.white,

          borderRadius:
          BorderRadius.circular(
            14.r,
          ),

          border:
          Border.all(
            color:
            hasTime
                ? maincolor.withOpacity(
              0.35,
            )
                : Colors.grey.shade200,
          ),

          boxShadow: [
            BoxShadow(
              color:
              Colors.black.withOpacity(
                0.025,
              ),
              blurRadius: 8,
              offset:
              const Offset(0, 3),
            ),
          ],
        ),

        child: Row(
          children: [
            Icon(
              Icons
                  .access_time_outlined,
              size: 21.sp,
              color: maincolor,
            ),

            Gap(11.w),

            Expanded(
              child: Text(
                hasTime
                    ? provider
                    .selectedTime!
                    .format(context)
                    : "Select time (9:00 AM - 4:00 PM)",

                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: hasTime
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: hasTime
                      ? Colors.black87
                      : Colors.grey.shade500,
                ),
              ),
            ),

            Icon(
              Icons
                  .keyboard_arrow_down_rounded,
              size: 21.sp,
              color:
              Colors.grey.shade500,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PERSON DROPDOWN
  // ============================================================

  Widget _buildPersonDropdown(
      EarlyDepartureProvider provider,
      ) {
    return Container(
      decoration:
      BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(
          14.r,
        ),

        border:
        Border.all(
          color:
          Colors.grey.shade200,
        ),

        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withOpacity(
              0.025,
            ),
            blurRadius: 8,
            offset:
            const Offset(0, 3),
          ),
        ],
      ),

      child:
      DropdownButtonHideUnderline(
        child:
        DropdownButton<String>(
          value:
          provider.selectedPerson,

          isExpanded: true,

          padding:
          EdgeInsets.symmetric(
            horizontal: 13.w,
          ),

          hint: Row(
            children: [
              Container(
                height: 32.w,
                width: 32.w,

                decoration:
                BoxDecoration(
                  color: Colors.grey
                      .shade100,
                  borderRadius:
                  BorderRadius.circular(
                    9.r,
                  ),
                ),

                child: Icon(
                  Icons
                      .person_outline_rounded,
                  size: 18.sp,
                  color:
                  Colors.grey.shade600,
                ),
              ),

              Gap(10.w),

              Text(
                "Select Person",
                style: TextStyle(
                  fontSize: 13.sp,
                  color:
                  Colors.grey.shade600,
                ),
              ),
            ],
          ),

          icon: Icon(
            Icons
                .keyboard_arrow_down_rounded,
            color:
            Colors.grey.shade600,
          ),

          items: provider.persons.map(
                (person) {
              String personName = "";

              if (person == "Father") {
                personName =
                    provider.fatherName;
              } else if (person ==
                  "Mother") {
                personName =
                    provider.motherName;
              } else if (person ==
                  "Guardian") {
                personName =
                    provider.guardianName;
              }

              return DropdownMenuItem<
                  String>(
                value: person,

                child: Row(
                  children: [
                    Container(
                      height: 34.w,
                      width: 34.w,

                      decoration:
                      BoxDecoration(
                        color: maincolor
                            .withOpacity(
                          0.08,
                        ),
                        borderRadius:
                        BorderRadius
                            .circular(
                          9.r,
                        ),
                      ),

                      child: Icon(
                        _getPersonIcon(
                          person,
                        ),
                        color: maincolor,
                        size: 18.sp,
                      ),
                    ),

                    Gap(10.w),

                    Expanded(
                      child: person ==
                          "Other"
                          ? Text(
                        "Other",
                        style:
                        TextStyle(
                          fontSize:
                          13.sp,
                          fontWeight:
                          FontWeight
                              .w600,
                          color: Colors
                              .black87,
                        ),
                      )
                          : Column(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          Text(
                            person,
                            style:
                            TextStyle(
                              fontSize:
                              10.sp,
                              color: Colors
                                  .grey
                                  .shade600,
                            ),
                          ),

                          Gap(1.h),

                          Text(
                            personName
                                .isEmpty
                                ? "-"
                                : personName,
                            maxLines: 1,
                            overflow:
                            TextOverflow
                                .ellipsis,
                            style:
                            TextStyle(
                              fontSize:
                              13.sp,
                              fontWeight:
                              FontWeight
                                  .w600,
                              color: Colors
                                  .black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ).toList(),

          onChanged:
          provider.isSubmitting
              ? null
              : (value) {
            provider
                .setPerson(
              value,
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // PERSON ICON
  // ============================================================

  IconData _getPersonIcon(
      String person,
      ) {
    switch (person) {
      case "Father":
        return Icons.man_outlined;

      case "Mother":
        return Icons.woman_outlined;

      case "Guardian":
        return Icons
            .supervisor_account_outlined;

      default:
        return Icons
            .person_outline_rounded;
    }
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController
    controller,

    required String hintText,

    required IconData prefixIcon,

    TextInputType? textInputType,

    int maxLines = 1,

    int? maxLength,
  }) {
    return TextField(
      controller: controller,

      keyboardType:
      textInputType,

      maxLines: maxLines,

      maxLength: maxLength,

      inputFormatters:
      textInputType ==
          TextInputType.phone
          ? [
        FilteringTextInputFormatter
            .digitsOnly,
      ]
          : null,

      style: TextStyle(
        fontSize: 13.sp,
        fontWeight:
        FontWeight.w500,
        color: Colors.black87,
      ),

      decoration:
      InputDecoration(
        hintText:
        hintText,

        hintStyle:
        TextStyle(
          fontSize: 12.5.sp,
          color:
          Colors.grey.shade500,
          fontWeight:
          FontWeight.w400,
        ),

        prefixIcon:
        Padding(
          padding:
          EdgeInsets.only(
            left: 4.w,
            right: 4.w,
          ),

          child: Icon(
            prefixIcon,
            color: maincolor,
            size: 20.sp,
          ),
        ),

        prefixIconConstraints:
        BoxConstraints(
          minWidth: 48.w,
        ),

        filled: true,

        fillColor:
        Colors.white,

        contentPadding:
        EdgeInsets.symmetric(
          horizontal: 13.w,
          vertical: 15.h,
        ),

        counterText:
        maxLength != null
            ? null
            : "",

        border:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            14.r,
          ),

          borderSide:
          BorderSide(
            color:
            Colors.grey.shade200,
          ),
        ),

        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            14.r,
          ),

          borderSide:
          BorderSide(
            color:
            Colors.grey.shade200,
          ),
        ),

        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            14.r,
          ),

          borderSide:
          BorderSide(
            color: maincolor,
            width: 1.4,
          ),
        ),

        disabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            14.r,
          ),

          borderSide:
          BorderSide(
            color:
            Colors.grey.shade200,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectDate(
      EarlyDepartureProvider provider,
      ) async {
    final now =
    DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final picked =
    await showDatePicker(
      context: context,

      initialDate:
      today.add(
        const Duration(
          days: 1,
        ),
      ),

      firstDate: today,

      lastDate:
      today.add(
        const Duration(
          days: 3,
        ),
      ),

      helpText:
      "Select Departure Date",

      cancelText:
      "Cancel",

      confirmText:
      "Select",

      builder:
          (
          context,
          child,
          ) {
        return Theme(
          data:
          Theme.of(context)
              .copyWith(
            colorScheme:
            ColorScheme.light(
              primary:
              maincolor,
            ),
          ),
          child:
          child!,
        );
      },
    );

    if (picked != null) {
      provider.setDate(
        picked,
      );
    }
  }

  // ============================================================
  // TIME PICKER
  // ============================================================

  Future<void> _selectTime(
      EarlyDepartureProvider provider,
      ) async {
    final picked =
    await showTimePicker(
      context: context,

      initialTime:
      const TimeOfDay(
        hour: 12,
        minute: 0,
      ),

      helpText:
      "Select Departure Time",

      cancelText:
      "Cancel",

      confirmText:
      "Select",

      builder:
          (
          context,
          child,
          ) {
        return MediaQuery(
          data:
          MediaQuery.of(context)
              .copyWith(
            alwaysUse24HourFormat:
            false,
          ),

          child:
          Theme(
            data:
            Theme.of(context)
                .copyWith(
              colorScheme:
              ColorScheme.light(
                primary:
                maincolor,
              ),
            ),

            child:
            child!,
          ),
        );
      },
    );

    if (picked == null) {
      return;
    }

    if (!provider.isValidTime(
      picked,
    )) {
      Get.snackbar(
        "Invalid Time",
        "Early departure time must be between 9:00 AM and 4:00 PM.",

        snackPosition:
        SnackPosition.BOTTOM,

        backgroundColor:
        Colors.red.shade100,

        colorText:
        Colors.red.shade900,

        margin:
        EdgeInsets.all(12.w),

        borderRadius:
        12.r,

        icon: Icon(
          Icons
              .error_outline_rounded,
          color:
          Colors.red.shade700,
        ),
      );

      return;
    }

    provider.setTime(
      picked,
    );
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<void> _submit(
      EarlyDepartureProvider provider,
      ) async {
    FocusScope.of(context).unfocus();

    // ----------------------------------------------------------
    // BASIC VALIDATION
    // ----------------------------------------------------------

    if (provider.selectedDate == null) {
      _showError(
        "Please select departure date.",
      );
      return;
    }

    if (provider.selectedTime == null) {
      _showError(
        "Please select departure time.",
      );
      return;
    }

    if (provider.selectedPerson == null) {
      _showError(
        "Please select a person.",
      );
      return;
    }

    if (provider.selectedPerson ==
        "Other" &&
        provider.otherPersonController.text
            .trim()
            .isEmpty) {
      _showError(
        "Please enter person's name.",
      );
      return;
    }

    if (provider.contactController.text
        .trim()
        .length !=
        10) {
      _showError(
        "Please enter a valid 10 digit contact number.",
      );
      return;
    }

    if (provider.reasonController.text
        .trim()
        .isEmpty) {
      _showError(
        "Please enter reason for early departure.",
      );
      return;
    }

    // ----------------------------------------------------------
    // SUBMIT
    // ----------------------------------------------------------

    final success =
    await provider.submitRequest(
      context,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      setState(() {
        _showForm = false;
      });

      Get.snackbar(
        "Success",
        "Early departure request submitted successfully.",

        snackPosition:
        SnackPosition.BOTTOM,

        backgroundColor:
        Colors.green.shade100,

        colorText:
        Colors.green.shade900,

        margin:
        EdgeInsets.all(12.w),

        borderRadius:
        12.r,

        icon: Icon(
          Icons
              .check_circle_outline_rounded,
          color:
          Colors.green.shade700,
        ),
      );
    }
  }

  // ============================================================
  // ERROR SNACKBAR
  // ============================================================

  void _showError(
      String message,
      ) {
    Get.snackbar(
      "Required",
      message,

      snackPosition:
      SnackPosition.BOTTOM,

      backgroundColor:
      Colors.red.shade100,

      colorText:
      Colors.red.shade900,

      margin:
      EdgeInsets.all(12.w),

      borderRadius:
      12.r,

      icon: Icon(
        Icons
            .error_outline_rounded,
        color:
        Colors.red.shade700,
      ),
    );
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(
      DateTime date,
      ) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }
}
