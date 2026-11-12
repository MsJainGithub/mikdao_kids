import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:mikado_kids/config/themeConfig.dart';
import 'package:mikado_kids/generated/assets.dart';

import '../widgets/cardselectWidget.dart';
class FeeDetailPage extends StatefulWidget {
  const FeeDetailPage({Key? key}) : super(key: key);

  @override
  State<FeeDetailPage> createState() => _FeeDetailPageState();
}

class _FeeDetailPageState extends State<FeeDetailPage> {




  List colors = [maincolor, Colors.deepOrange, Colors.grey, Colors.cyan, Colors.deepPurple];


  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return  Scaffold(

      appBar: AppBar(title: Text("Fees Detail"),),
      body: Column(
        children: [
      Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: CardSelector(
        cards: List.generate(colors.length, (index) {
          return Material(
            child: Container(
              padding: EdgeInsets.only(left: 15,right: 10,top: 1,bottom: 10),
              decoration: BoxDecoration(
                  color: colors[index],borderRadius: BorderRadius.circular(12),
              image: DecorationImage(image: AssetImage(Assets.assetsLayers),
                fit: BoxFit.cover,
              ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Fee Installment ${index+1}",style: TextStyle(fontSize: 18,color: Colors.white),),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total Fee",style: TextStyle(fontSize: 15,color: Colors.white),),
                          Text("4740.0",style: TextStyle(fontSize: 15,color: Colors.white),),
                        ],
                      ),
                      SizedBox(height: 5,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total Paid",style: TextStyle(fontSize: 15,color: Colors.white),),
                          Text("4740.0",style: TextStyle(fontSize: 15,color: Colors.white),),
                        ],
                      ),
                      SizedBox(height: 5,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Due Fees",style: TextStyle(fontSize: 15,color: Colors.white),),
                          Text("0.0",style: TextStyle(fontSize: 15,color: Colors.white),),
                        ],
                      ),
                    ],
                  ),

                ],
              ),
            ),
          );
        }),
        mainCardWidth: size.width/1.1,
        mainCardHeight: 180,
        mainCardPadding: -10,
        cardAnimationDurationMs: 200,
        cardsGap: 30.0,
        dropTargetWidth: 10.0,
        onChanged: (i){
          print(i);
        },
      ),
    ),
          SizedBox(height: 15,),
          Container(
            alignment: Alignment.center,
            height: 40,
            width: size.width,
            decoration: BoxDecoration(color: Colors.grey),
            child: Text("Previous Pending Fee: 0.00",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
          ),
          SizedBox(height: 25,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Material(
              elevation: 5,
              borderRadius: BorderRadius.circular(5),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(

                    color: Colors.white,borderRadius: BorderRadius.circular(5)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("TUITION FEE",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),),
                        Text("01 Apr,2023",style: TextStyle(color: Colors.grey[600]),),
                      ],
                    ),
                    SizedBox(height: 25,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Total Fee : 4740.00",style: TextStyle(color: maincolor,fontSize: 13),),
                        Text("Paid Fee : 4740.00",style: TextStyle(color: Colors.green,fontSize: 13),),
                        Text("Due Fee : 0.00",style: TextStyle(color: Colors.redAccent,fontSize: 13),),
                      ],
                    )


                  ],
                ),
              ),
            ),
          ),
        ],
      )
    );
  }
}



