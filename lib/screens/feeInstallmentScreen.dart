
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../modals/feeDetailModal.dart';
import '../modals/installMentModal.dart';
import '../providers/feeProvider.dart';
import '../providers/paymentProvider.dart';

class FeeInstallmentScreen extends StatefulWidget {
  const FeeInstallmentScreen({super.key});

  @override
  State<FeeInstallmentScreen> createState() => _FeeInstallmentScreenState();
}
class _FeeInstallmentScreenState extends State<FeeInstallmentScreen>
    with TickerProviderStateMixin {

  late TabController _tabController;
  late AnimationController _dueCardController;
  final Set<String> selectedInstallments = {};

  /// Current amount controller.
  final TextEditingController amountController = TextEditingController();
  double? _lastCalculatedAmount;
  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 3,
      vsync: this,
    );
    _dueCardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final feeProvider = context.read<FeeProvider>();
      feeProvider.getFeeDetail(context);
      feeProvider.getInstalmentDetail(context);
      feeProvider.getSession(context);
      _syncAmount(feeProvider);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _dueCardController.dispose();
    amountController.dispose();
    super.dispose();
  }

// ============================================================
// HELPERS
// ============================================================
  bool _shouldSelectInstallment(
      Installment item,
      ) {
// Already paid → never selected
    if (_fullyPaid(item, context.read<FeeProvider>())) {
      return false;
    }

    final date = _parseDate(item.date);

    if (date == null) {
      return false;
    }

    final today = DateTime.now();

    final installmentDate = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final todayDate = DateTime(
      today.year,
      today.month,
      today.day,
    );

// Due installment → selected by default
    return !installmentDate.isAfter(todayDate);
  }
  Future<void> _refreshFeeData() async {
    final feeProvider = context.read<FeeProvider>();

// Clear old selection
    selectedInstallments.clear();

// Refresh API data
    feeProvider.getFeeDetail(context);
    feeProvider.getInstalmentDetail(context);
    feeProvider.getSession(context);

// Give provider/API calls time to update
    await Future.delayed(
      const Duration(milliseconds: 800),
    );

    if (!mounted) return;

// Select all due installments
    for (final item in _getDueInstallments(feeProvider)) {
      selectedInstallments.add(
        _installmentKey(item),
      );
    }

// Sync amount
    _syncAmount(feeProvider);

    setState(() {});
  }

  void _initializeInstallmentSelection(
      FeeProvider feeProvider,
      ) {
    final dueInstallments = _getDueInstallments(
      feeProvider,
    );

    for (final item in dueInstallments) {
      final key = _installmentKey(item);

// Due installments always selected
      selectedInstallments.add(key);
    }
  }

  void _initializeDefaultInstallments(
      FeeProvider feeProvider,
      ) {
    if (!mounted) return;

// Due installments default selected
    for (final item in _getDueInstallments(feeProvider)) {
      selectedInstallments.add(_installmentKey(item));
    }

// Calculate amount immediately
    final total = _calculateSelectedAmount(feeProvider);

    _lastCalculatedAmount = total;
    amountController.text = total.toStringAsFixed(0);

    setState(() {});
  }

  double _parseAmount(dynamic value) {
    return double.tryParse(
      value?.toString().replaceAll(',', '').trim() ?? '0',
    ) ??
        0;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    final text = value.toString().trim();

    if (text.isEmpty) return null;

    try {
      return DateTime.parse(text);
    } catch (_) {
      return null;
    }
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  String _installmentKey(Installment item) {
    return '${item.installment}_${item.date}_${item.amount}';
  }

// Hide installments explicitly marked partially paid by the API.
  bool _isPartiallyPaid(Installment item) {
    final status = (item.status ?? '').trim().toUpperCase()
        .replaceAll(RegExp(r'[\s_-]+'), '');
    return status == 'PARTIAL' || status == 'PARTIALLYPAID' ||
        status == 'PARTIALPAID' || status == 'PARTPAYMENT';
  }

  bool _isPaid(Installment item) {
    final status = item.status?.trim().toUpperCase() ?? '';

    return status == 'PAID';
  }

// Allocate recorded payments in installment order (FIFO). If the API
// provides per-installment paid amounts, prefer those on the server.
  Map<String, double> _remainingByInstallment(FeeProvider provider) {
    final items = provider.instalmentDetail?.installment ?? <Installment>[];
    final balances = <String, double>{};
    final fee = provider.feeDetail;
    final details = fee?.detail ?? <DetailFee>[];
    final total = items.fold<double>(0, (sum, i) => sum + _parseAmount(i.amount));
    double paid = _parseAmount(fee?.paid);
    if (paid <= 0 && details.isNotEmpty) {
      paid = details.fold<double>(0, (sum, d) => sum + _parseAmount(d.amount));
    }
    // Do not interpret an absent/zero API balance as "all paid".
    // Use payment history first, then a reliable positive paid field.
    paid = paid.clamp(0.0, total).toDouble();
    for (final item in items) {
      final original = _parseAmount(item.amount);
      final applied = paid.clamp(0.0, original).toDouble();
      balances[_installmentKey(item)] = original - applied;
      paid -= applied;
    }
    return balances;
  }

  double _remainingFor(Installment item, FeeProvider provider) =>
      _remainingByInstallment(provider)[_installmentKey(item)] ?? _parseAmount(item.amount);

  bool _fullyPaid(Installment item, FeeProvider provider) {
    final original = _parseAmount(item.amount);
    final remaining = _remainingFor(item, provider);
    if (original > 0 && remaining <= 0.005) return true;
    // Trust explicit PAID only when there is no recorded allocation contradicting it.
    final fee = provider.feeDetail;
    final hasPaymentData = _parseAmount(fee?.paid) > 0 || (fee?.detail?.isNotEmpty ?? false);
    return !hasPaymentData && _isPaid(item);
  }

  bool _partiallyPaid(Installment item, FeeProvider provider) {
    final original = _parseAmount(item.amount);
    final remaining = _remainingFor(item, provider);
    return (remaining > 0.005 && remaining < original - 0.005) ||
        (_isPartiallyPaid(item) && !_fullyPaid(item, provider));
  }

  bool _isDue(Installment item) {
    final date = _parseDate(item.date);

    if (date == null) {
      return false;
    }

    final today = _dateOnly(DateTime.now());
    final installmentDate = _dateOnly(date);

    return !installmentDate.isAfter(today);
  }

  bool _isFuture(Installment item) {
    final date = _parseDate(item.date);

    if (date == null) {
      return false;
    }

    final today = _dateOnly(DateTime.now());
    final installmentDate = _dateOnly(date);

    return installmentDate.isAfter(today);
  }

  String _money(dynamic value) {
    final amount = _parseAmount(value);

    return '₹${amount.toStringAsFixed(0)}';
  }

// ============================================================
// DUE INSTALLMENTS
//
// ============================================================

  List<Installment> _getDueInstallments(
      FeeProvider feeProvider,
      ) {
    final installments = (feeProvider.instalmentDetail?.installment ?? <Installment>[]);

    return installments.where((item) {
      if (_fullyPaid(item, feeProvider)) {
        return false;
      }

      return _isDue(item);
    }).toList();
  }

// ============================================================
// FUTURE INSTALLMENTS
//
// Available through ADD button.
// ============================================================

// ============================================================
// DEFAULT AMOUNT
// ============================================================

  double _calculateDefaultAmount(
      FeeProvider feeProvider,
      ) {
    final dueInstallments = _getDueInstallments(feeProvider);

    return dueInstallments.fold<double>(
      0,
          (total, item) {
        return total + _remainingFor(item, feeProvider);
      },
    );
  }

// ============================================================
// ADDITIONAL AMOUNT
// ============================================================

  double _calculateSelectedAmount(
      FeeProvider feeProvider,
      ) {
    double total = 0;

    final installments = (feeProvider.instalmentDetail?.installment ?? <Installment>[]);

    for (final item in installments) {
      if (_fullyPaid(item, feeProvider)) {
        continue;
      }

      final key = _installmentKey(item);

      final due = _isDue(item);
      final upcomingSelected =
          _isFuture(item) && selectedInstallments.contains(key);

// Due = always selected
// Upcoming = selected only when user checks it
      if (due || upcomingSelected) {
        total += _remainingFor(item, feeProvider);
      }
    }

    return total;
  }

// ============================================================
// TOTAL PAYABLE
// ============================================================

  double _calculatePayableAmount(
      FeeProvider feeProvider,
      ) {
    return _calculateSelectedAmount(feeProvider);
  }

// ============================================================
// UPDATE AMOUNT FIELD
// ============================================================

  void _syncAmount(FeeProvider feeProvider) {
    final amount = _calculateSelectedAmount(feeProvider);
    if (_lastCalculatedAmount == amount) return;
    _lastCalculatedAmount = amount;
    final value = amount.toStringAsFixed(0);
    if (amountController.text != value) amountController.text = value;
  }

// Validate the manually entered partial payment before creating an order.
  double? _validatedPaymentAmount(double maximumAmount) {
    final amount = double.tryParse(amountController.text.trim().replaceAll(',', ''));
    if (amount == null || !amount.isFinite || amount <= 0 || amount > maximumAmount) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Enter an amount greater than 0 and not more than ₹${maximumAmount.toStringAsFixed(2)}'),
      ));
      return null;
    }
    return amount;
  }

// ============================================================
// HEADER
// ============================================================

  Widget _buildHeader(
      FeeProvider feeProvider,
      ) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFB50000),
            Color(0xFFE31A1A),
            Color(0xFFFF3B3B),
          ],
          stops: [
            0.0,
            0.55,
            1.0,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(45),
          bottomRight: Radius.circular(45),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          16,
          12,
          16,
          20,
        ),
        child: SizedBox(
          height: 55,
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Fee Overview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
// if (feeProvider.currentSession.isNotEmpty)
//   Text(
//     'Session: ${feeProvider.currentSession}',
//     style: const TextStyle(
//       color: Colors.white,
//       fontWeight: FontWeight.bold,
//       fontSize: 12,
//     ),
//   ),
                  ],
                ),
              ),
              const SizedBox(width: 22),
            ],
          ),
        ),
      ),
    );
  }

// ============================================================
// SUMMARY CARDS
// ============================================================

  Widget _buildFeeSummaryCards(
      FeeProvider feeProvider,
      ) {
    if (feeProvider.feeDetail == null) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final data = feeProvider.feeDetail!;
    final detail = data.detail ?? [];

    double totalFee = 0;

    if (detail.isNotEmpty) {
      totalFee = _parseAmount(
        detail.last.fullAmount,
      );
    }

    if (totalFee == 0) {
      final paid = _parseAmount(data.paid);

      final due = _parseAmount(
        data.due?.isNotEmpty == true ? data.due : data.unpaid_amount,
      );

      totalFee = paid + due;
    }

    final paidAmount = _parseAmount(data.paid) > 0
        ? _parseAmount(data.paid)
        : detail.fold<double>(0, (sum, d) => sum + _parseAmount(d.amount));

    final dueAmount = (data.due?.isNotEmpty == true || data.unpaid_amount?.isNotEmpty == true)
        ? _parseAmount(data.due?.isNotEmpty == true ? data.due : data.unpaid_amount)
        : (totalFee - paidAmount).clamp(0.0, double.infinity).toDouble();
    return Row(
      children: [
        _buildSummaryCard(
          'Fee Amount',
          _money(totalFee),
          const LinearGradient(
            colors: [
              Color(0xFF333333),
              Color(0xFF000000),
            ],
          ),
          Icons.account_balance_wallet_outlined,
        ),
        const SizedBox(width: 10),
        _buildSummaryCard(
          'Total Paid',
          _money(paidAmount),
          const LinearGradient(
            colors: [
              Color(0xFF00C853),
              Color(0xFF2E7D32),
            ],
          ),
          Icons.check_circle_outline,
        ),
        const SizedBox(width: 10),
        _buildSummaryCard(
          'Due Amount',
          _money(dueAmount),
          const LinearGradient(
            colors: [
              Color(0xFFFF5252),
              Color(0xFFD50000),
            ],
          ),
          Icons.warning_amber_rounded,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title,
      String value,
      Gradient gradient,
      IconData icon,
      ) {
    final Color color = (gradient as LinearGradient).colors.first;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(.20),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.20),
              blurRadius: 18,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: gradient,
              ),
              child: Icon(
                icon,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

// ============================================================
// TAB BAR
// ============================================================

// Widget _buildTabs() {
//   return Container(
//     margin: const EdgeInsets.only(top: 20),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(14),
//       border: Border.all(
//         color: Colors.grey.shade200,
//       ),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(.05),
//           blurRadius: 8,
//           offset: const Offset(0, 3),
//         ),
//       ],
//     ),
//     child: TabBar(
//       controller: _tabController,
//       // indicator: BoxDecoration(
//       //   color: Colors.red,
//       //   borderRadius: BorderRadius.circular(12),
//       // ),
//       indicator: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [
//             Color(0xFFB50000),
//             Color(0xFFE31A1A),
//             Color(0xFFFF3B3B),
//           ],
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//         ),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       indicatorPadding: const EdgeInsets.all(3),
//       dividerColor: Colors.transparent,
//       labelColor: Colors.white,
//       unselectedLabelColor: Colors.grey.shade700,
//       labelStyle: const TextStyle(
//         fontSize: 12,
//         fontWeight: FontWeight.bold,
//       ),
//       unselectedLabelStyle: const TextStyle(
//         fontSize: 12,
//         fontWeight: FontWeight.w500,
//       ),
//       tabs: const [
//         Tab(
//           text: 'Fee Details',
//         ),
//         Tab(
//           text: 'Installment',
//         ),
//         Tab(
//           text: 'Payment History',
//         ),
//       ],
//     ),
//   );
// }
  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,

        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFB50000),
              Color(0xFFE31A1A),
              Color(0xFFFF3B3B),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),

        indicatorPadding: const EdgeInsets.all(3),
        dividerColor: Colors.transparent,

        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade700,

        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),

        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),

// Important for wrapping
        labelPadding: const EdgeInsets.symmetric(
          horizontal: 4,
        ),

        tabs: const [
          Tab(
            child: Text(
              'Fee Details',
              textAlign: TextAlign.center,
              maxLines: 2,
              softWrap: true,
            ),
          ),

          Tab(
            child: Text(
              'Installment',
              textAlign: TextAlign.center,
              maxLines: 2,
              softWrap: true,
            ),
          ),

          Tab(
            child: Text(
              'Payment History',
              textAlign: TextAlign.center,
              maxLines: 2,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  /// ============================================================
  /// FEE DETAILS TAB
  /// ============================================================
  Widget _buildFeeDetailsTab(
      FeeProvider feeProvider,
      ) {
    final installments =
    (feeProvider.instalmentDetail?.installment ?? <Installment>[]);

    if (installments.isEmpty) {
      return RefreshIndicator(
        color: Colors.red,
        backgroundColor: Colors.white,
        strokeWidth: 3,
        onRefresh: _refreshFeeData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(
            top: 16,
            bottom: 30,
          ),
          children: const [
            SizedBox(height: 150),
            Center(
              child: Text(
                'No fee installment data available',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.red,
      backgroundColor: Colors.white,
      strokeWidth: 3,
      onRefresh: _refreshFeeData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          top: 16,
          bottom: 30,
        ),
        children: [
          ...installments.asMap().entries.map(
                (entry) {
              return _buildInstallmentTimelineItem(
                entry.value,
                entry.key,
                installments.length,
                feeProvider,
              );
            },
          ),

          const SizedBox(height: 10),

          _buildPaymentButton(feeProvider),
        ],
      ),
    );
  }

  Widget _buildPaymentButton(
      FeeProvider feeProvider,
      ) {
    final totalAmount = _calculateSelectedAmount(feeProvider);

// Manual amount must not be overwritten during rebuild.

    if (totalAmount <= 0) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.grey.shade300,
            ),
          ),
          child: TextField(
            controller: amountController,
            readOnly: false,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            decoration: const InputDecoration(
              labelText: 'Amount to Pay',
              prefixIcon: Icon(
                Icons.currency_rupee,
                color: Colors.red,
              ),
              border: InputBorder.none,
              floatingLabelStyle: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFB50000),
                  Color(0xFFE31A1A),
                  Color(0xFFFF3B3B),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () async {
                final paymentAmount = _validatedPaymentAmount(totalAmount);
                if (paymentAmount == null) return;

                final paymentProvider = Provider.of<PaymentProvider>(
                  context,
                  listen: false,
                );

                final installments =
                (feeProvider.instalmentDetail?.installment ?? <Installment>[]);

                final selected = installments.where(
                      (item) {
                    if (_fullyPaid(item, feeProvider)) {
                      return false;
                    }

                    final key = _installmentKey(item);

// Due always included
                    if (_isDue(item)) {
                      return true;
                    }

// Upcoming only if selected
                    return selectedInstallments.contains(key);
                  },
                ).toList();

                final names = selected
                    .map(
                      (item) => item.installment ?? '',
                )
                    .where(
                      (name) => name.isNotEmpty,
                )
                    .toList();

                await paymentProvider.createOrder(
                  context: context,
                  amount: paymentAmount,
                  installmentNames: names,
                );
              },
              child: const Text(
                'Pay Now',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }




  Widget _buildInstallmentTimelineItem(
      Installment item,
      int index,
      int total,
      FeeProvider feeProvider,
      ) {
    final key = _installmentKey(item);

    final date = _parseDate(item.date);
    final amount = _remainingFor(item, feeProvider);
    final originalAmount = _parseAmount(item.amount);
    final paidAmount = (originalAmount - amount).clamp(0.0, originalAmount).toDouble();

// ==========================================================
// STATUS
// ==========================================================

    final paid = _fullyPaid(item, feeProvider);
    final partial = _partiallyPaid(item, feeProvider);
    final due = _isDue(item);
    final upcoming = _isFuture(item);

// ==========================================================
// SELECTION
//
// PAID     -> Never selected
// DUE      -> Always selected
// UPCOMING -> Selected only by checkbox
// ==========================================================

    final isSelected = !paid &&
        (due || selectedInstallments.contains(key));

// ==========================================================
// DUE CARD ANIMATION
// ==========================================================

    final bool isDueCard = due && !paid;

// ==========================================================
// STATUS GRADIENT
// ==========================================================

    final Gradient statusGradient;

    if (paid) {
      statusGradient = const LinearGradient(
        colors: [
          Color(0xFF00C853),
          Color(0xFF2E7D32),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (due) {
      statusGradient = const LinearGradient(
        colors: [
          Color(0xFFFF5252),
          Color(0xFFD50000),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else {
      statusGradient = const LinearGradient(
        colors: [
          Color(0xFFFFB300),
          Color(0xFFF57C00),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }

    final Color statusColor =
        statusGradient.colors.first;

// ==========================================================
// ANIMATION
// ==========================================================

    return AnimatedBuilder(
      animation: _dueCardController,
      builder: (context, child) {
// --------------------------------------------------------
// Only unpaid DUE card will animate
// --------------------------------------------------------

        final double pulse = isDueCard
            ? _dueCardController.value
            : 0.0;

// --------------------------------------------------------
// Opacity
// --------------------------------------------------------

        final double cardOpacity = isDueCard
            ? 0.72 + (pulse * 0.28)
            : 1.0;

// --------------------------------------------------------
// Border
// --------------------------------------------------------

        final Color borderColor = isDueCard
            ? Colors.red.withOpacity(
          0.20 + (pulse * 0.55),
        )
            : statusColor.withOpacity(.15);

        final double borderWidth = isDueCard
            ? 1.0 + (pulse * 0.8)
            : 1.0;

// --------------------------------------------------------
// Glow
// --------------------------------------------------------

        final Color shadowColor = isDueCard
            ? Colors.red.withOpacity(
          0.08 + (pulse * 0.25),
        )
            : statusColor.withOpacity(.15);

        final double blurRadius = isDueCard
            ? 10 + (pulse * 12)
            : 12;

        final double spreadRadius = isDueCard
            ? pulse * 2
            : 0;

        return Opacity(
          opacity: cardOpacity,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
// ======================================================
// DATE
// ======================================================

                if (date != null) ...[
                  SizedBox(
                    width: 70,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        DateFormat('dd MMM').format(date),
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],

// ======================================================
// TIMELINE DOT + LINE
// ======================================================

                Column(
                  children: [
                    Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        gradient: statusGradient,
                        shape: BoxShape.circle,
                        boxShadow: isDueCard
                            ? [
                          BoxShadow(
                            color: Colors.red.withOpacity(
                              0.20 + (pulse * 0.30),
                            ),
                            blurRadius:
                            5 + (pulse * 5),
                            spreadRadius: pulse,
                          ),
                        ]
                            : null,
                      ),
                    ),

                    if (index != total - 1)
                      Expanded(
                        child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: List.generate(
                            18,
                                (_) => Padding(
                              padding:
                              const EdgeInsets.symmetric(
                                vertical: 2,
                              ),
                              child: Container(
                                width: 2,
                                height: 3,
                                decoration: BoxDecoration(
                                  gradient:
                                  statusGradient,
                                  borderRadius:
                                  BorderRadius.circular(
                                    2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 14),

// ======================================================
// INSTALLMENT CARD
// ======================================================

                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(
                      bottom: 16,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected && !paid
                          ? statusColor.withOpacity(.05)
                          : Colors.white,

                      borderRadius:
                      BorderRadius.circular(16),

// ------------------------------------------------
// Animated border for unpaid DUE
// ------------------------------------------------

                      border: Border.all(
                        color: borderColor,
                        width: borderWidth,
                      ),

// ------------------------------------------------
// Animated glow for unpaid DUE
// ------------------------------------------------

                      boxShadow: [
                        BoxShadow(
                          color: shadowColor,
                          blurRadius: blurRadius,
                          spreadRadius: spreadRadius,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),

                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
// ==================================================
// NAME + STATUS
// ==================================================

                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.installment
                                    ?.replaceFirst(
                                  RegExp(
                                    r'Installment(?=\d)',
                                  ),
                                  'Installment ',
                                ) ??
                                    'Installment ${index + 1}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ),

// ------------------------------------------------
// STATUS BADGE
// ------------------------------------------------

                            Container(
                              padding:
                              const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: isDueCard
                                    ? Colors.red.withOpacity(
                                  0.10 +
                                      (pulse * 0.15),
                                )
                                    : statusColor
                                    .withOpacity(.15),
                                borderRadius:
                                BorderRadius.circular(
                                  20,
                                ),
                              ),
                              child: Text(
                                paid
                                    ? 'PAID'
                                    : partial
                                    ? 'PARTIAL'
                                    : due
                                    ? 'DUE'
                                    : 'UPCOMING',
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 10,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

// ==================================================
// AMOUNT + CHECKBOX
// ==================================================

                        Row(
                          children: [
// ----------------------------------------------
// AMOUNT ICON
// ----------------------------------------------

                            Icon(
                              Icons.currency_rupee,
                              size: 18,
                              color: statusColor,
                            ),

                            const SizedBox(width: 7),

// ----------------------------------------------
// AMOUNT
// ----------------------------------------------

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Paid: ${_money(paidAmount)}',
                                    style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 3),
                                Text('Remaining: ${_money(amount)}',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              ],
                            ),

                            const Spacer(),

// =================================================
// CHECKBOX
//
// IMPORTANT:
// Checkbox is shown ONLY when:
//
// upcoming == true
// AND
// paid == false
//
// So:
// UPCOMING + PAID -> NO CHECKBOX
// UPCOMING + UNPAID -> CHECKBOX
// =================================================

                            if (upcoming && !paid) ...[
                              const SizedBox(width: 5),

                              Checkbox(
                                value: isSelected,
                                activeColor: Colors.red,
                                materialTapTargetSize:
                                MaterialTapTargetSize
                                    .shrinkWrap,
                                visualDensity:
                                VisualDensity.compact,

                                onChanged: (value) {
                                  if (paid) {
                                    return;
                                  }

                                  setState(() {
                                    if (value == true) {
                                      selectedInstallments
                                          .add(key);
                                    } else {
                                      selectedInstallments
                                          .remove(key);
                                    }

// ------------------------------------
// Update amount immediately
// ------------------------------------

                                    final selectedAmount =
                                    _calculateSelectedAmount(
                                      feeProvider,
                                    );

                                    _lastCalculatedAmount = selectedAmount;
                                    amountController.text = selectedAmount.toStringAsFixed(0);
                                  });
                                },
                              ),
                            ],
                          ],
                        ),

// ==================================================
// DUE INFORMATION
// ==================================================

                        if (due && !paid) ...[
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              Icon(
                                Icons.lock_outline,
                                size: 13,
                                color: Colors.red.shade700,
                              ),

                              const SizedBox(width: 5),

                              Expanded(
                                child: Text(
                                  'Due amount included in payment',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight:
                                    FontWeight.w600,
                                    color:
                                    Colors.red.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

// ==================================================
// UPCOMING SELECTED INFORMATION
// ==================================================

                        if (upcoming &&
                            !paid &&
                            isSelected) ...[
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              const Icon(
                                Icons
                                    .check_circle_outline,
                                size: 13,
                                color: Colors.orange,
                              ),

                              const SizedBox(width: 5),

                              Expanded(
                                child: Text(
                                  'Selected for payment',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight:
                                    FontWeight.w600,
                                    color: Colors
                                        .orange.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryItem(
      DetailFee d,
      int index,
      ) {
    final amount = _parseAmount(d.amount);

    return Container(
      margin: const EdgeInsets.fromLTRB(
        12,
        4,
        12,
        12,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (d.date != null)
                Expanded(
                  child: Text(
                    DateFormat('dd MMM yyyy').format(d.date!),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              Expanded(
                child: Text(
                  'Receipt #${d.receiptno ?? '-'}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                _money(amount),
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(
            height: 1,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Collected By',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      d.collectBy ?? '-',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 35,
                color: Colors.grey.shade300,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Mode',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        d.payvia ?? '-',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// ============================================================
// DISCOUNT SUMMARY
//
// discount + siblingDiscount + lumsumDiscount
// ============================================================
  Widget _buildDiscountSummary(
      FeeDetailModal data,
      ) {
    final discount = _parseAmount(data.discount);
    final siblingDiscount = _parseAmount(data.siblingDiscount);
    final lumsumDiscount = _parseAmount(data.lumsumDiscount);

    final totalOtherAmount =
        discount + siblingDiscount + lumsumDiscount;

// Other Amount = 0 hai to section hide rahega
    if (totalOtherAmount <= 0) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Other Amount',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            _money(totalOtherAmount),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }


  Widget _discountRow(
      String title,
      double amount,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            _money(amount),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

// ============================================================
// PAYMENT SECTION
// ============================================================

  Widget _buildPaymentSection(
      FeeProvider feeProvider,
      ) {
    final installments = (feeProvider.instalmentDetail?.installment ?? <Installment>[]);

// ----------------------------------------------------------
// Get selected unpaid installments
// ----------------------------------------------------------

    final selectedItems = installments.where((item) {
      final key = _installmentKey(item);

      return selectedInstallments.contains(key) && !_fullyPaid(item, feeProvider);
    }).toList();

// ----------------------------------------------------------
// Calculate selected amount
// ----------------------------------------------------------

    final totalAmount = selectedItems.fold<double>(
      0,
          (total, item) {
        return total + _remainingFor(item, feeProvider);
      },
    );

// ----------------------------------------------------------
// Keep amount controller synchronized
// ----------------------------------------------------------

// Keep manually edited amount unchanged on rebuild.

// ----------------------------------------------------------
// Nothing selected
// ----------------------------------------------------------

    if (selectedItems.isEmpty || totalAmount <= 0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
// ========================================================
// SELECTED INSTALLMENTS
// ========================================================

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selected Installments',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              ...selectedItems.map(
                    (item) {
                  final date = _parseDate(item.date);

                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 9,
                    ),
                    child: Row(
                      children: [
// ----------------------------------------
// CHECK ICON
// ----------------------------------------

                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.red,
                            size: 17,
                          ),
                        ),

                        const SizedBox(width: 9),

// ----------------------------------------
// INSTALLMENT NAME + DATE
// ----------------------------------------

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.installment ?? 'Installment',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (date != null) ...[
                                const SizedBox(height: 3),
                                Text(
                                  DateFormat(
                                    'dd MMM yyyy',
                                  ).format(date),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

// ----------------------------------------
// AMOUNT
// ----------------------------------------

                        Text(
                          _money(item.amount),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const Divider(
                height: 20,
              ),

// ==================================================
// TOTAL
// ==================================================

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _money(totalAmount),
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 15),

// ========================================================
// AMOUNT TO PAY
// ========================================================

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.05),
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: amountController,
            readOnly: false,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            decoration: const InputDecoration(
              labelText: 'Amount to Pay',
              prefixIcon: Icon(
                Icons.currency_rupee,
                color: Colors.red,
              ),
              border: InputBorder.none,
              floatingLabelStyle: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ),

        const SizedBox(height: 15),

// ========================================================
// PAY NOW
// ========================================================

        SizedBox(
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFB50000),
                  Color(0xFFE31A1A),
                  Color(0xFFFF3B3B),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                disabledBackgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () async {
// ----------------------------------------------
// Safety check
// ----------------------------------------------

                final paymentAmount = _validatedPaymentAmount(totalAmount);
                if (paymentAmount == null) return;

// ----------------------------------------------
// Payment Provider
// ----------------------------------------------

                final paymentProvider = Provider.of<PaymentProvider>(
                  context,
                  listen: false,
                );

// ----------------------------------------------
// Selected installment names
// ----------------------------------------------

                final names = selectedItems
                    .map(
                      (item) => item.installment ?? '',
                )
                    .where(
                      (name) => name.isNotEmpty,
                )
                    .toList();

// ----------------------------------------------
// Create Razorpay order
// ----------------------------------------------

                await paymentProvider.createOrder(
                  context: context,
                  amount: paymentAmount,
                  installmentNames: names,
                );
              },
              child: const Text(
                'Pay Now',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

// ============================================================
// MAIN BUILD
// ============================================================

  @override
  Widget build(BuildContext context) {
    final feeProvider = context.watch<FeeProvider>();
    _syncAmount(feeProvider);

    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      body: SafeArea(
        child: Column(
          children: [
// ==================================================
// HEADER
// ==================================================

            _buildHeader(feeProvider),

// ==================================================
// BODY
// ==================================================

            Expanded(
              child: Column(
                children: [
// ==================================================
// SUMMARY + TABS
// ==================================================

                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      19,
                      16,
                      19,
                      20,
                    ),
                    child: Column(
                      children: [
// ==================================================
// SUMMARY
// ==================================================

                        _buildFeeSummaryCards(
                          feeProvider,
                        ),

                        const SizedBox(height: 16),

// ==================================================
// TABS
// ==================================================

                        _buildTabs(),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

// ==================================================
// TAB CONTENT
// ==================================================

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 19,
                      ),
                      child: TabBarView(
                        controller: _tabController,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildFeeDetailsTab(
                            feeProvider,
                          ),
                          _buildInstallmentTab(
                            feeProvider,
                          ),
                          _buildPaymentHistoryTab(
                            feeProvider,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildInstallmentTab(
      FeeProvider feeProvider,
      ) {
    final installments =
    (feeProvider.instalmentDetail?.installment ?? <Installment>[]);

    if (installments.isEmpty) {
      return RefreshIndicator(
        color: Colors.red,
        backgroundColor: Colors.white,
        strokeWidth: 3,
        onRefresh: _refreshFeeData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(
            top: 16,
            bottom: 30,
          ),
          children: const [
            SizedBox(height: 150),
            Center(
              child: Text(
                'No installment data available',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.red,
      backgroundColor: Colors.white,
      strokeWidth: 3,
      onRefresh: _refreshFeeData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          top: 16,
          bottom: 30,
        ),
        children: [
          ...installments.asMap().entries.map(
                (entry) {
              return _buildFeeDetailItem(
                entry.value,
                entry.key,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistoryTab(
      FeeProvider feeProvider,
      ) {
    if (feeProvider.feeDetail == null) {
      return RefreshIndicator(
        color: Colors.red,
        backgroundColor: Colors.white,
        strokeWidth: 3,
        onRefresh: _refreshFeeData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 200),
            Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            ),
          ],
        ),
      );
    }

    final data = feeProvider.feeDetail!;
    final detail = data.detail ?? [];

    if (detail.isEmpty) {
      return RefreshIndicator(
        color: Colors.red,
        backgroundColor: Colors.white,
        strokeWidth: 3,
        onRefresh: _refreshFeeData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(
            top: 16,
            bottom: 30,
          ),
          children: const [
            SizedBox(height: 150),
            Center(
              child: Text(
                'No payment history available',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.red,
      backgroundColor: Colors.white,
      strokeWidth: 3,
      onRefresh: _refreshFeeData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          top: 16,
          bottom: 30,
        ),
        children: [
          ...detail.asMap().entries.map(
                (entry) {
              return _buildHistoryItem(
                entry.value,
                entry.key,
              );
            },
          ),

          const SizedBox(height: 14),

          _buildDiscountSummary(data),
        ],
      ),
    );
  }
  Widget _buildFeeDetailItem(
      Installment item,
      int index,
      ) {
    final amount = _parseAmount(item.amount);
    final date = _parseDate(item.date);

    final paid = _fullyPaid(item, context.read<FeeProvider>());
    final isDue = _isDue(item);

    final Gradient statusGradient;
    final IconData statusIcon;

    if (paid) {
      statusGradient = const LinearGradient(
        colors: [
          Color(0xFF00C853),
          Color(0xFF2E7D32),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      statusIcon = Icons.check_circle;
    } else if (isDue) {
      statusGradient = const LinearGradient(
        colors: [
          Color(0xFFFF5252),
          Color(0xFFD50000),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      statusIcon = Icons.warning_amber_rounded;
    } else {
      statusGradient = const LinearGradient(
        colors: [
          Color(0xFFFFB300),
          Color(0xFFF57C00),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      statusIcon = Icons.calendar_month;
    }

    final Color statusColor = (statusGradient as LinearGradient).colors.first;

    final statusText = paid
        ? 'PAID'
        : isDue
        ? 'DUE'
        : 'UPCOMING';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(.15),
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(.15),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: statusGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              statusIcon,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
// Text(
//   item.installment ??
//       'Installment ${index + 1}',
//   style: const TextStyle(
//     fontSize: 15,
//     fontWeight: FontWeight.bold,
//   ),
// ),
                Text(
                  item.installment?.replaceFirst(
                    RegExp(r'Installment(?=\d)'),
                    'Installment ',
                  ) ??
                      'Installment ${index + 1}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                if (date != null)
                  Text(
                    DateFormat(
                      'dd MMM yyyy',
                    ).format(date),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _money(amount),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),
            ],
          ),
        ],
      ),
    );
  }
}