import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../config/appConfig.dart';
import '../providers/feeProvider.dart';
import '../providers/profileProvider.dart';
import '../providers/userProvider.dart';
import '../services/apiServices.dart';

/// ICICI UAT redirect URLs must be checked against a bank-confirmed allowlist.
/// These are the two UAT hosts observed in the integration. Confirm with ICICI.
bool isValidIciciPaymentUrl(String value) {
  final uri = Uri.tryParse(value.trim());
  if (uri == null) return false;
  const allowedHosts = {
    'pgpayuat.icicibank.com',
    'pgpayuat.icici.bank.in',
  };
  return uri.scheme.toLowerCase() == 'https' &&
      allowedHosts.contains(uri.host.toLowerCase()) &&
      uri.userInfo.isEmpty &&
      !uri.hasPort &&
      uri.fragment.isEmpty &&
      uri.path == '/tsp/pg/api/v2/authRedirect' &&
      (uri.queryParameters['tranCtx']?.isNotEmpty ?? false);
}

class PaymentProvider extends ChangeNotifier {
  bool isLoading = false;
  String currentOrderId = '';
  double payableAmount = 0;

  Future<void> createOrder({
    required BuildContext context,
    required double amount,
    required List<String> installmentNames,
  }) async {
    if (isLoading) return;
    if (!amount.isFinite || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid payment amount')),
      );
      return;
    }

    final email = await showDialog<String>(
      context: context,
      builder: (_) => _PaymentDetailsDialog(amount: amount),
    );
    if (email == null || !context.mounted) return;

    isLoading = true;
    payableAmount = amount;
    currentOrderId = '';
    notifyListeners();

    try {
      final fee = Provider.of<FeeProvider>(context, listen: false);
      final profile = Provider.of<ProfileProvider>(context, listen: false);
      final user = Provider.of<UserProvider>(context, listen: false);

      final response = await ApiServices().postData(
        uri: createOrderUrl,
        context: context,
        data: {
          'action': 'create',
          'student_id': user.userId.toString(),
          'student_name':
          '${profile.dataUser?.fname ?? ''} ${profile.dataUser?.lname ?? ''}'.trim(),
          'admission_no': profile.dataUser?.admNo?.toString() ?? '',
          'session_id': fee.currentSessionId.toString(),
          'class_id': profile.dataUser?.class_id?.toString() ?? '',
          'installment_names': installmentNames.join(','),
          'amount': amount.toStringAsFixed(2),
          'email': email,
          'mobile': profile.dataUser?.guardianmobileno?.toString() ?? '',
        },
      );
      if (response == null || !context.mounted) return;

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid payment server response');
      }
      if (decoded['status'] != 1) {
        throw Exception(decoded['message']?.toString() ?? 'Unable to initiate payment');
      }
      final data = decoded['data'];
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Missing payment details');
      }
      final orderId = data['order_id']?.toString() ?? '';
      final paymentUrl = data['payment_url']?.toString() ?? '';
      if (orderId.isEmpty) throw Exception('Missing payment order ID');
      currentOrderId = orderId;
      if (!isValidIciciPaymentUrl(paymentUrl)) {
        throw Exception('Invalid ICICI gateway URL. Check approved UAT hostname.');
      }

      // WebView returns after callback or after the user closes the payment page.
      // Neither outcome is proof of payment; always check the server.
      await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => IciciPaymentPage(paymentUrl: paymentUrl),
        ),
      );
      if (!context.mounted) return;
      await verifyPayment(context);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment: $error')),
        );
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyPayment(BuildContext context) async {
    if (currentOrderId.isEmpty || !context.mounted) return;

    final response = await ApiServices().postData(
      uri: createOrderUrl,
      context: context,
      data: {'action': 'status', 'order_id': currentOrderId},
    );
    if (response == null || !context.mounted) return;

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic> || decoded['status'] != 1) {
      final message = decoded is Map
          ? decoded['message']?.toString()
          : null;
      throw Exception(message ?? 'Payment status check failed');
    }
    final details = decoded['data'];
    if (details is! Map<String, dynamic>) {
      throw const FormatException('Invalid payment status response');
    }
    final status = (details['payment_status']?.toString() ?? 'PENDING').toUpperCase();

    if (status == 'SUCCESS') {
      final fee = Provider.of<FeeProvider>(context, listen: false);
      await fee.getFeeDetail(context);
      if (!context.mounted) return;
      await fee.getInstalmentDetail(context);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment verified successfully')),
      );
      // Do not pop here: the payment WebView route has already been closed.
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'PENDING'
                ? 'Payment is pending. Check again later before retrying.'
                : 'Payment status: $status',
          ),
        ),
      );
    }
  }
}

class IciciPaymentPage extends StatefulWidget {
  final String paymentUrl;

  const IciciPaymentPage({super.key, required this.paymentUrl});

  @override
  State<IciciPaymentPage> createState() => _IciciPaymentPageState();
}

class _IciciPaymentPageState extends State<IciciPaymentPage> {
  late final WebViewController controller;
  int progress = 0;
  bool hasError = false;
  bool isClosing = false;

  bool _isOurReturnUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null &&
        uri.scheme == 'https' &&
        uri.host.toLowerCase() == 'barman-retake-duffel.ngrok-free.dev' &&
        uri.path == '/mikadoworld_ambamata/api/icici_return.php';
  }

  void _closeAfterReturn() {
    if (!mounted || isClosing) return;
    isClosing = true;
    // Schedule route pop outside the navigation callback.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop(true);
    });
  }

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (value) {
            if (mounted) setState(() => progress = value);
          },
          onPageFinished: (url) {
            // Wait until the return page loads so a callback can reach PHP.
            if (_isOurReturnUrl(url)) _closeAfterReturn();
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == true && mounted) {
              setState(() => hasError = true);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Secure ICICI Payment')),
      body: Column(
        children: [
          if (progress < 100) LinearProgressIndicator(value: progress / 100),
          if (hasError)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Payment page could not be loaded. Close and check status.'),
            ),
          Expanded(child: WebViewWidget(controller: controller)),
        ],
      ),
    );
  }
}

class _PaymentDetailsDialog extends StatefulWidget {
  final double amount;
  const _PaymentDetailsDialog({required this.amount});

  @override
  State<_PaymentDetailsDialog> createState() => _PaymentDetailsDialogState();
}

class _PaymentDetailsDialogState extends State<_PaymentDetailsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.lock_outline_rounded, size: 42, color: theme.colorScheme.primary),
              const SizedBox(height: 12),
              Text(
                'Secure fee payment',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Review your amount and enter an email for payment updates.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(.45),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text('Total amount payable'),
                    const SizedBox(height: 6),
                    Text(
                      '₹${widget.amount.toStringAsFixed(2)}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(
                  labelText: 'Email address',
                  hintText: 'parent@example.com',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final email = (value ?? '').trim();
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    Navigator.of(context).pop(_emailController.text.trim());
                  }
                },
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Proceed to Pay'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(height: 6),
              const Text(
                'Payment is processed securely by ICICI Bank.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
