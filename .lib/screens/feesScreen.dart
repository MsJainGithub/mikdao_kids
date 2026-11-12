import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mikado_kids/config/themeConfig.dart';
import 'package:mikado_kids/generated/assets.dart';

class FeesScreen extends StatefulWidget {
  const FeesScreen({Key? key}) : super(key: key);

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  @override
  Widget build(BuildContext context) {
    final Size size  = MediaQuery.of(context).size;
    return  Scaffold(
      appBar: AppBar(title: Text("Fees"),),
      body: Container(
        height: size.height,
        width: size.width,
        child: ListView(
          padding: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 10),
          children: [
            FeesWidgets(title: "Total Fees",data: "\u20b9 250000",imgurl: Assets.assetsTotalpay2,),
            SizedBox(height: 15,),
            FeesWidgets(title: "Total Paid",data: "\u20b9 250000",imgurl: Assets.assetsTotalpayfee,),
            SizedBox(height: 15,),
            FeesWidgets(title: "Adjusted/Waived/Concession Amount",data: "\u20b9 250000",imgurl: Assets.assetsAdgu,),
            SizedBox(height: 15,),
            FeesWidgets(title: "Total Due",data: "\u20b9 250000",imgurl: Assets.assetsDue,),
            SizedBox(height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(onPressed: (){}, child: Text("Pay Now"),style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.withOpacity(0.8)),),
                ElevatedButton(onPressed: (){
                  Get.toNamed('/feesDetailPage');
                }, child: Text("Fee Detail"),style: ElevatedButton.styleFrom(backgroundColor: maincolor),),
                ElevatedButton(onPressed: (){
                  Get.toNamed('/feeReceiptPage');

                }, child: Text("Fee Receipt"),style: ElevatedButton.styleFrom(backgroundColor: maincolor),),
              ],
            ),

          ],
        ),
      ),
    );
  }
}

class FeesWidgets extends StatelessWidget {
  const FeesWidgets({
    super.key, required this.title, required this.imgurl, required this.data,

  });

final String title;
final String data;
final String imgurl;

  @override
  Widget build(BuildContext context) {
    final Size size  = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),

        image: DecorationImage(
          fit: BoxFit.cover,
          colorFilter: ColorFilter.srgbToLinearGamma(),
          image: AssetImage(imgurl),
        ),
      ),
      child: Container(
        padding: EdgeInsets.only(left: 15,right: 15,top: 15,bottom: 15),
        decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.5),borderRadius: BorderRadius.circular(12),),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20),),
          Text(data,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 25),),
        ],
      ),
      ),
    );
  }
}
