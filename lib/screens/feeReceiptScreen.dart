import 'package:flutter/material.dart';
import 'package:mikado_kids/config/themeConfig.dart';
import 'package:mikado_kids/generated/assets.dart';

class FeeReceitScreen extends StatefulWidget {
  const FeeReceitScreen({Key? key}) : super(key: key);

  @override
  State<FeeReceitScreen> createState() => _FeeReceitScreenState();
}

class _FeeReceitScreenState extends State<FeeReceitScreen> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return  Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Fee Receipt"),),
      body: Column(
        children: [
          Container(
            height: 200,
            width: size.width,
            decoration: BoxDecoration(image: DecorationImage(
                image: AssetImage(Assets.assetsPaymentrecpit)
            )),
          ),
          Text("Download your Fee receipt at anytime",style: TextStyle(color: maincolor),),
          Expanded(child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context,index){
                return  Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(5),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(

                          color: Colors.white,borderRadius: BorderRadius.circular(5)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage(Assets.assetsRec),
                            backgroundColor: Colors.grey,
                            radius: 35,
                          ),
                          SizedBox(width: 10,),
                          Expanded(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text("Receipt :",style: TextStyle(color: Colors.grey,fontSize: 12),),
                                        Text("CAS/HMF/23-24/0855",style: TextStyle(color: Colors.black,fontSize: 12),),
                                      ],
                                    ),
                                    Text("\u20b94709",style: TextStyle(color: maincolor,fontSize: 12,),textAlign: TextAlign.end,),
                                  ],
                                ),
                                SizedBox(height: 8,),
                                Row(
                                  children: [
                                    Text("Payment Mode :",style: TextStyle(color: Colors.grey,fontSize: 12),),
                                    Text("Online",style: TextStyle(color: Colors.black,fontSize: 12),),
                                  ],
                                ),
                                SizedBox(height: 8,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("01 May,2023 :",style: TextStyle(color: Colors.grey,fontSize: 12),),
                                    Icon(Icons.cloud_download,color: Colors.grey,)
                                  ],
                                ),

                              ],
                            ),
                          ),


                        ],
                      ),
                    ),
                  ),
                );
              })),
        ],
      ),
    );
  }
}
