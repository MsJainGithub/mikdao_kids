import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';


Future <XFile?>takeImageFromCamera(BuildContext context) async {
  // final dir = await path_provider.getTemporaryDirectory();
  Navigator.pop(context);
  XFile? file = await ImagePicker()
      .pickImage(source: ImageSource.camera,
      //maxHeight: 675,
      maxWidth: 600);

  print(File(file!.path).lengthSync());

  return file;
}

Future <XFile?>takeImageFromGallery(BuildContext context) async {
  Navigator.pop(context);

  XFile? file = await ImagePicker()
      .pickImage(source: ImageSource.gallery,
      //maxHeight: 675,
      maxWidth: 600
  );

  print(File(file!.path).lengthSync());

 return file;
}

