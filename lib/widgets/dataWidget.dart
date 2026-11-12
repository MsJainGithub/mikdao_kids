
import 'package:flutter/material.dart';

import '../config/themeConfig.dart';

class ProfileTextField extends StatelessWidget {
  const ProfileTextField({
    super.key, required this.title, this.clt, this.readonly, this.type,
  });

  final String title;
  final bool? readonly;
  final TextEditingController? clt;
  final TextInputType? type;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: TextStyle(fontSize: 13),
      controller: clt,
      keyboardType: type,
      readOnly: readonly??false,
      decoration: InputDecoration(
          isDense: true,
          label: Text(title,style: TextStyle(color: Colors.grey),),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey)
          ),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey)
          )
      ),
    );
  }
}

class ProfileContainer extends StatelessWidget {
  const ProfileContainer({
    super.key, required this.title, required this.imageUrl, required this.ontap, required this.isSelected,
  });
  final String title;
  final String imageUrl;
  final GestureTapCallback ontap;
  final bool isSelected;


  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: ontap,
        child: Material(
          elevation: isSelected?13:2,
          borderRadius: BorderRadius.circular(5),
          child: Container(
            height: 120,
            decoration: BoxDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: maincolor.withOpacity(0.2),
                  child: Image.asset(imageUrl,height: 30,width: 30,),
                ),
                SizedBox(height: 10,),
                Text(title,style: TextStyle(fontSize: 12),textAlign: TextAlign.center,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}