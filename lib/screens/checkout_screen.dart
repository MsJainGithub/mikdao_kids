import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/paymentProvider.dart';

class CheckoutScreen extends StatelessWidget {
  final double amount;
  // final int installmentId;
  final List<String> installmentNames;

  const CheckoutScreen({
    super.key,
    required this.amount,
    // required this.installmentId,
    required this.installmentNames,
  });

  Widget buildTile(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Consumer<PaymentProvider>(
      builder: (_, payment, __) {

        return Scaffold(

          backgroundColor: const Color(0xfff5f6fa),

          appBar: AppBar(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            title: const Text("Checkout"),
            centerTitle: true,
          ),

          body: Padding(
            padding: const EdgeInsets.all(16),

            child: Column(

              children: [

                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(16),

                    child: Column(

                      children: [

                        buildTile(
                          "Fee Amount",
                          "₹ ${amount.toStringAsFixed(2)}",
                        ),

                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Card(
                  elevation: 2,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(20),

                    child: Row(

                      children: [

                        const Expanded(
                          child: Text(
                            "Total Payable",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),

                        Text(
                          "₹ ${amount.toStringAsFixed(2)}",

                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),

                      ],
                    ),
                  ),
                ),

                const Spacer(),

                SizedBox(

                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    onPressed: payment.isLoading
                        ? null
                        : () {

                      payment.createOrder(

                        context: context,

                        amount: amount,
                        installmentNames: installmentNames,
                        // installmentId: installmentId,
                      );
                    },

                    child: payment.isLoading

                        ? const CircularProgressIndicator(
                      color: Colors.white,
                    )

                        : const Text(

                      "Proceed To Pay",

                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
