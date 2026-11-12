import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:number_to_words_english/number_to_words_english.dart';
import 'package:provider/provider.dart';
import '../config/themeConfig.dart';
import '../generated/assets.dart';
import '../providers/feeProvider.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;

import '../widgets/InstallmentWidget.dart';
import '../widgets/qrDisplay.dart';
import '../widgets/qrWidget.dart';

class FeeInstallmentScreen extends StatefulWidget {
  const FeeInstallmentScreen({super.key});

  @override
  State<FeeInstallmentScreen> createState() => _FeeInstallmentScreenState();
}

class _FeeInstallmentScreenState extends State<FeeInstallmentScreen> {

  bool _isZero(String? value) {
    if (value == null) return true;
    final parsed = double.tryParse(value.trim());
    return (parsed ?? 0) == 0;
  }

  bool _hasRemark(String? value) {
    if (value == null) return false;
    final t = value.trim();
    if (t.isEmpty) return false;
    if (t.toLowerCase() == 'null') return false;
    return true;
  }

  List<Widget> _spaced(List<Widget> items) {
    final List<Widget> out = [];
    for (int i = 0; i < items.length; i++) {
      out.add(items[i]);
      if (i != items.length - 1) out.add(Gap(5));
    }
    return out;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<FeeProvider>().getFeeDetail(context);
      context.read<FeeProvider>().getInstalmentDetail(context);
    });
    super.initState();
  }

  int currentIndex = -1;

  changeSelectIndex(int index){
    setState(() {
      if(currentIndex == index){
        currentIndex = -1;
      }else{
        currentIndex = index;
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final feeProvider = context.watch<FeeProvider>();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: maincolor,
          elevation: 0,
          title: const Text("Fee Installment"),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TabBar(
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [maincolor, maincolor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: maincolor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey.shade600,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                tabs: const [

                  Tab(
                    height: 48,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_rounded, size: 20),
                        SizedBox(width: 6),
                        Text("Fee Detail"),
                      ],
                    ),
                  ),
                  Tab(
                    height: 48,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.list_alt_rounded, size: 20),
                        SizedBox(width: 6),
                        Text("Installments"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildFeeDetailTab(feeProvider, size),
            _buildInstallmentDetailTab(feeProvider),

          ],
        ),
      ),
    );
  }

  Widget _buildInstallmentDetailTab(FeeProvider feeProvider) {
    if (feeProvider.instalmentDetail == null) {
      return const Center(child: SizedBox());
    }
    final details = feeProvider.noInstalmentData;
    if (details) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.inbox_rounded, size: 42, color: Colors.grey),
            SizedBox(height: 8),
            Text("No installment data available",
                style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              FeeCardTop(
                title: "Current Session",
                data: feeProvider.currentSession,
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Modern Cards
          Column(
            children: List.generate(feeProvider.instalmentDetail!.installment!.length, (index) {
              var data = feeProvider.instalmentDetail!.installment![index];
              return InstalmentWidget(
                name: data.installment??"",
                date: data.date!,
                amount: data.amount!,
                status: data.status!,
                isBlink: data.is_blink??false,
              );
            })
          ),
        ],
      ),
    );
  }



  Widget _buildFeeDetailTab(FeeProvider feeProvider, Size size) {
    if (feeProvider.feeDetail == null) {
      return Center(child: SizedBox());
    }

    if (feeProvider.feeDetail!.fee_status == "unpaid") {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Material(
            elevation: 5,
            child: Container(
              padding: EdgeInsets.only(right: 10,left: 10,top: 10,bottom: 10),
              alignment: Alignment.center,

              width: size.width,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Fee is not paid yet"),
                    Gap(10),
                    FeeCardTop(
                    title: "Total amount",
                    data: "\u20b9 ${feeProvider.feeDetail!.unpaid_amount ?? "0"}",
                                            ),
                    if(feeProvider.feeDetail!.show_image == "Yes")
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          PaymentButton(maincolor: maincolor,qrCodeUrl: feeProvider.feeDetail!.qr!,).paddingOnly(left: 10),
                        ],
                      ),

                  ],
                ),
              ),
            ),
          ).paddingAll(20),
        ],
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Gap(5),
            //  Text("${feeProvider.feeDetail!.fee_status.toString().capitalizeFirst} Paid",style: TextStyle(color: maincolor,fontSize: 12,fontWeight: FontWeight.bold),).paddingOnly(left: 15),
              FeeCardTop(title: "Current Session",data: feeProvider.currentSession,).paddingOnly(right: 15),
            ],
          ),

          Gap(5),
          if(feeProvider.feeDetail!.show_image == "Yes" && feeProvider.feeDetail!.qr != null && feeProvider.feeDetail!.detail!.isEmpty)
            ModernQrDisplay(qrImageUrl: feeProvider.feeDetail!.qr!,),
          ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: feeProvider.feeDetail!.detail!.length,
              itemBuilder: (context,index){
                var data = feeProvider.feeDetail!.detail![index];
                return  Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Material(
                        elevation: 5,
                        borderRadius: BorderRadius.circular(5),
                        child: InkWell(
                          onTap: (){
                            changeSelectIndex(index);
                          },
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
                                  radius: 20,
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
                                              Text("${data.receiptno}",style: TextStyle(color: Colors.black,fontSize: 12),),
                                            ],
                                          ),
                                          Text("\u20b9${data.amount}",style: TextStyle(color: maincolor,fontSize: 12,),textAlign: TextAlign.end,),
                                        ],
                                      ),
                                      SizedBox(height: 8,),
                                      Row(
                                        children: [
                                          Text("Payment Mode :",style: TextStyle(color: Colors.grey,fontSize: 12),),
                                          Text("${data.payvia}",style: TextStyle(color: Colors.black,fontSize: 12),),
                                        ],
                                      ),
                                      SizedBox(height: 8,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("${DateFormat("dd-MM-yyyy").format(data.date!)}",style: TextStyle(color: Colors.grey,fontSize: 12),),
                                          Icon(Icons.keyboard_arrow_down_rounded,color: Colors.grey,)
                                        ],
                                      ),

                                    ],
                                  ),
                                ),


                              ],
                            ),
                          ),
                        ),
                      ),
                      if(index == currentIndex)
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(width: 1,color: maincolor),
                              right: BorderSide(width: 1,color: maincolor),
                              bottom: BorderSide(width: 1,color: maincolor),
                            ),
                          ),
                          padding: EdgeInsets.all(15),
                          child: Builder(
                            builder: (context) {
                              final List<Widget> items = [];
                              items.add(FeeCard(title: "Collect by", data: "${data.collectBy}"));
                              //items.add(FeeCard(title: "Fee Amount", data: "\u20b9${data.fullAmount}"));
                              if(!_isZero(data.discount)) {
                                items.add(FeeCard(title: "Discount", data: "\u20b9${data.discount}"));
                              }
                              if(!_isZero(data.siblingDiscount)) {
                                items.add(FeeCard(title: "Sibling Discount", data: "\u20b9${data.siblingDiscount}"));
                              }
                              if(!_isZero(data.lumAmt)) {
                                items.add(FeeCard(title: "Lumsum Discount", data: "\u20b9${data.lumAmt}"));
                              }
                              if(!_isZero(data.fine)) {
                                items.add(FeeCard(title: "Fine", data: "\u20b9${data.fine}"));
                              }
                              if(_hasRemark(data.remarks)) {
                                items.add(Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Remark",style: TextStyle(color: Colors.black,fontSize: 12,fontWeight: FontWeight.bold),),
                                    Gap(2),
                                    Text("${data.remarks}",style: TextStyle(color: Colors.grey,fontSize: 12,fontWeight: FontWeight.w500),),
                                  ],
                                ));
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _spaced(items),
                              );
                            },
                          ),
                        ).paddingOnly(top: 10)
                    ],
                  ),
                );
              }),
          Builder(
            builder: (context) {
              final List<Widget> totalItems = [];
              totalItems.add(FeeCardTop(title: "Fee Amount", data: "\u20b9 ${feeProvider.feeDetail!.detail!.last.fullAmount}"));
              if(!_isZero(feeProvider.feeDetail!.discount)) {
                totalItems.add(FeeCardTop(title: "Discount", data: "\u20b9 ${feeProvider.feeDetail!.discount}"));
              }
              if(!_isZero(feeProvider.feeDetail!.siblingDiscount)) {
                totalItems.add(FeeCardTop(title: "Sibling Discount", data: "\u20b9 ${feeProvider.feeDetail!.siblingDiscount}"));
              }
              if(!_isZero(feeProvider.feeDetail!.lumsumDiscount)) {
                totalItems.add(FeeCardTop(title: "Lumpsum Discount", data: "\u20b9 ${feeProvider.feeDetail!.lumsumDiscount}"));
              }
              totalItems.add(FeeCardTop(title: "Total Paid", data: "\u20b9 ${feeProvider.feeDetail!.paid}",textColor: Colors.green,));

              if(feeProvider.feeDetail!.fee_status == "partly" && !_isZero(feeProvider.feeDetail!.due)) {
                totalItems.add(FeeCardTop(title: "Due", data: "\u20b9 ${feeProvider.feeDetail!.due}",textColor: Colors.red,));
              }
              if(!_isZero(feeProvider.feeDetail!.fine)) {
                totalItems.add(FeeCardTop(title: "Fine", data: "\u20b9 ${feeProvider.feeDetail!.fine}"));
              }

              //totalItems.add(FeeCardTop(title: "Total Paid(With Fine)", data: "\u20b9 ${feeProvider.feeDetail!.totalPaidWithFine}"));

              return Padding(
                padding: EdgeInsets.only(left: 15,right: 15),
                child: Row(
                  mainAxisAlignment:
                  feeProvider.feeDetail!.show_image == "Yes"?
                  MainAxisAlignment.spaceBetween:MainAxisAlignment.end,
                  children: [
                    if(feeProvider.feeDetail!.show_image == "Yes")
                    PaymentButton(maincolor: maincolor,qrCodeUrl: feeProvider.feeDetail!.qr!,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ..._spaced(totalItems),
                       // Text('( ${NumberToWordsEnglish.convert(num.parse(double.parse(feeProvider.feeDetail!.totalPaidWithFine!).round().toString()))} )',style: TextStyle(color: Colors.grey,fontSize: 12),),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class FeeCard extends StatelessWidget {
  const FeeCard({super.key, required this.title, required this.data});
  final String title,data;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text("$title :",style: TextStyle(color: Colors.grey,fontSize: 12),),
        Expanded(child: Text("$data",style: TextStyle(color: Colors.black,fontSize: 12),)),
      ],
    );
  }
}
class FeeCardTop extends StatelessWidget {
   FeeCardTop({super.key, required this.title, required this.data,this.textColor});
  final String title,data;
  final Color? textColor;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text("$title :",style: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold),),
        Gap(10),
        Text("$data",style: TextStyle(color: textColor??Colors.grey,fontSize: 14),),
      ],
    );
  }
}
