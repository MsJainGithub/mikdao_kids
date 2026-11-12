import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../config/themeConfig.dart';
import '../providers/profileProvider.dart';
import '../widgets/app_header.dart';

class StudentDetailScreen extends StatefulWidget {
  const StudentDetailScreen({Key? key}) : super(key: key);

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProfileProvider>();

      provider.getProfileData(context);
      provider.getPartBData(context);
    });
  }

  Future<void> _refreshData() async {
    final provider = context.read<ProfileProvider>();

    await provider.getProfileData(context);
    await provider.getPartBData(context);
  }

  @override
  Widget build(BuildContext context) {
    final pp = context.watch<ProfileProvider>();
    final u = pp.dataUser;

    final name = '${u?.fname ?? ''} ${u?.lname ?? ''}'.trim();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Profile',
              // subtitle: name.isEmpty
              //     ? 'Student information'
              //     : name.toUpperCase(),
            ),

            Expanded(
              child: u == null
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : RefreshIndicator(
                color: maincolor,
                backgroundColor: Colors.white,
                onRefresh: _refreshData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    16.w,
                    16.h,
                    16.w,
                    30.h,
                  ),
                  child: Column(
                    children: [
                      // PERSONAL DETAILS
                      _AccordionSection(
                        title: 'Personal Details',
                        icon: Icons.person_outline_rounded,
                        initiallyExpanded: true,
                        rows: [
                          _InfoRow(
                            'Name',
                            name.isEmpty ? '—' : name,
                          ),
                          _InfoRow(
                            'Date of Birth',
                            _formatDob(u.dob),
                          ),
                          _InfoRow(
                            'Aadhaar No',
                            _value(u.aadhar),
                          ),
                          _InfoRow(
                            'Gender',
                            _value(u.gender),
                          ),
                          _InfoRow(
                            'Registration No',
                            _value(u.admNo),
                          ),
                          _InfoRow(
                            'Category',
                            pp.selectedCategory.name,
                          ),
                          _InfoRow(
                            'Religion',
                            pp.selectedReligion.name,
                          ),
                          _InfoRow(
                            'Minority',
                            pp.selectedMinorityCategory.name,
                          ),
                        ],
                      ),

                      SizedBox(height: 12.h),

                      // ADDRESS
                      _AccordionSection(
                        title: 'Address',
                        icon: Icons.location_on_outlined,
                        rows: [
                          _InfoRow(
                            'Address',
                            _value(u.address),
                          ),
                          _InfoRow('City', _value(u.city)),
                          _InfoRow('State', _value(u.state)),
                          _InfoRow('Pincode', _value(u.pincode)),
                        ],
                      ),

                      SizedBox(height: 12.h),

                      // FAMILY DETAILS
                      _AccordionSection(
                        title: 'Family Details',
                        icon: Icons.family_restroom_rounded,
                        rows: [
                          _InfoRow(
                            'Father Name',
                            _value(u.fathername),
                          ),
                          _InfoRow(
                            'Mobile No',
                            _value(u.fmo),
                          ),
                          _InfoRow(
                            'Mother Name',
                            _value(u.mname),
                          ),
                          _InfoRow(
                            'Mobile No',
                            _value(u.mno),
                          ),
                          _InfoRow(
                            'Guardian Name',
                            _value(u.guardianname),
                          ),
                          _InfoRow(
                            'Mobile No',
                            _value(u.guardianmobileno),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _value(dynamic value) {
    final s = value?.toString().trim() ?? '';
    return s.isEmpty ? '—' : s;
  }

  String _formatDob(dynamic value) {
    if (value == null) return '—';

    final raw = value.toString().trim();

    if (raw.isEmpty) return '—';

    try {
      final date = DateTime.parse(raw);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return raw;
    }
  }
}

// ============================================================
// ACCORDION SECTION
// ============================================================

class _AccordionSection extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<_InfoRow> rows;
  final bool initiallyExpanded;

  const _AccordionSection({
    required this.title,
    required this.icon,
    required this.rows,
    this.initiallyExpanded = false,
  });

  @override
  State<_AccordionSection> createState() => _AccordionSectionState();
}

class _AccordionSectionState extends State<_AccordionSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: const Color(0xFFEAEAEA),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.035),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // HEADER
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(18.r),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 13.h,
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(9.w),
                    decoration: BoxDecoration(
                      color: maincolor.withOpacity(.08),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      widget.icon,
                      color: maincolor,
                      size: 20.sp,
                    ),
                  ),

                  SizedBox(width: 11.w),

                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 15.5.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF222222),
                      ),
                    ),
                  ),

                  AnimatedRotation(
                    turns: _isExpanded ? .5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey.shade600,
                      size: 25.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // CONTENT
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.fromLTRB(
                15.w,
                0,
                15.w,
                6.h,
              ),
              child: Column(
                children: widget.rows.map((row) {
                  return _InfoRowWidget(row: row);
                }).toList(),
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// INFO ROW
// ============================================================

class _InfoRowWidget extends StatelessWidget {
  final _InfoRow row;

  const _InfoRowWidget({
    required this.row,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 11.h,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade100,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              row.keyName,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            flex: 6,
            child: Text(
              row.value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: const Color(0xFF242424),
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// INFO ROW MODEL
// ============================================================

class _InfoRow {
  final String keyName;
  final String value;

  const _InfoRow(
      this.keyName,
      this.value,
      );
}
