import 'package:flutter/material.dart';

// Reusable QR Code Dialog Widget
class QrCodeDialog extends StatelessWidget {
  final String qrImageUrl;
  final String? title;
  final String? subtitle;

  const QrCodeDialog({
    Key? key,
    required this.qrImageUrl,
    this.title = 'Scan QR Code',
    this.subtitle = 'Scan this QR code to complete payment',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title ?? '',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Subtitle
            if (subtitle != null)
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),

            const SizedBox(height: 20),

            // QR Code with container and shadow
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  qrImageUrl,
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      width: 250,
                      height: 250,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 250,
                      height: 250,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.error_outline,
                        size: 50,
                        color: Colors.red,
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Close button at bottom
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),

                  ),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Static method to show the dialog easily
  static Future<void> show(
      BuildContext context, {
        required String qrImageUrl,
        String? title,
        String? subtitle,
      }) {
    return showDialog(
      context: context,
      builder: (context) => QrCodeDialog(
        qrImageUrl: qrImageUrl,
        title: title,
        subtitle: subtitle,
      ),
    );
  }
}

// Usage Example:
class PaymentButton extends StatelessWidget {
  final Color maincolor;
  final String qrCodeUrl;

  const PaymentButton({
    Key? key,
    required this.maincolor,
    required this.qrCodeUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Method 1: Using the static show method
        QrCodeDialog.show(
          context,
          qrImageUrl: qrCodeUrl,
          title: '',
          subtitle: 'Scan this QR code to complete your payment',
        );

        // Method 2: Using showDialog directly
        // showDialog(
        //   context: context,
        //   builder: (context) => QrCodeDialog(
        //     qrImageUrl: qrCodeUrl,
        //     title: 'Payment QR Code',
        //     subtitle: 'Scan this QR code to complete your payment',
        //   ),
        // );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: maincolor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Text("Pay Now"),
    );
  }
}


// Alternative: Using your existing provider pattern
// ElevatedButton(
//   onPressed: () {
//     if (feeProvider.feeDetail?.qr != null) {
//       QrCodeDialog.show(
//         context,
//         qrImageUrl: feeProvider.feeDetail!.qr!,
//       );
//     }
//   },
//   style: ElevatedButton.styleFrom(
//     backgroundColor: maincolor,
//     foregroundColor: Colors.white,
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(10),
//     ),
//   ),
//   child: const Text("Pay Now"),
// );