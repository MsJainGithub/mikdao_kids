import 'package:flutter/material.dart';
import 'studentDetailScreen.dart';

/// Read-only profile entry point.
/// The actual profile UI lives in StudentDetailScreen so every profile entry
/// in the app uses the same non-editable key/value presentation.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const StudentDetailScreen();
}
