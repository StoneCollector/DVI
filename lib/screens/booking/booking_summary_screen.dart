import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dreamventz/config/supabase_config.dart';
import 'package:dreamventz/models/cart_item.dart';
import 'package:dreamventz/services/cart_service.dart';
import 'package:dreamventz/services/order_service.dart';
import 'package:dreamventz/utils/constants.dart';

class BookingSummaryScreen extends StatefulWidget {
  final int subtotalAmount;
  final List<CartDisplayItem> cartItems;

  const BookingSummaryScreen({super.key, required this.subtotalAmount, required this.cartItems});

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  late Razorpay _razorpay;
  bool _isProcessing = false;

  late int _taxAmount;
  late int _finalTotal;

  @override
  void initState() {
    super.initState();
    _taxAmount = (widget.subtotalAmount * 0.18).round(); // 18% GST calculation
    _finalTotal = widget.subtotalAmount + _taxAmount;

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (!mounted) return;
    setState(() => _isProcessing = false);
    
    // Save to DB and clear cart
    try {
      final paymentId = response.paymentId ?? 'UNKNOWN';
      await OrderService().createOrder(widget.cartItems, _finalTotal, paymentId);
      await CartService().clearCart();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment Successful! Tracking ID: $paymentId'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate to home to reset stack, ideally user can then to go Orders page
      Navigator.pushNamedAndRemoveUntil(context, AppConstants.homeRoute, (route) => false);
    } catch (e) {
      if (!mounted) return;
      debugPrint('Error finalizing order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment Successful but order processing failed. Contact support.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    setState(() => _isProcessing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: ${response.message}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;
    setState(() => _isProcessing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External Wallet Selected: ${response.walletName}'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _startPayment() {
    final keyId = dotenv.env['RAZORPAY_KEY_ID'];
    
    if (keyId == null || keyId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Payment configuration missing from env.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    // Provide user data from Supabase if authenticated
    final user = SupabaseConfig.currentUser;
    final email = user?.email ?? "";
    final phone = user?.phone ?? "";

    var options = {
      'key': keyId,
      'amount': _finalTotal * 100, // exact paise
      'name': 'Dreamventz',
      'description': 'Event Booking Service',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        'contact': phone,
        'email': email,
      },
      'theme': {
        'color': '#ffc107', // Amber color matching app theme
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() => _isProcessing = false);
      debugPrint('Error: $e');
    }
  }

  String _formatInr(int value) {
    final String number = value.toString();
    if (number.length <= 3) return '₹$number';
    final String lastThree = number.substring(number.length - 3);
    String remaining = number.substring(0, number.length - 3);
    final List<String> groups = [];
    while (remaining.length > 2) {
      groups.insert(0, remaining.substring(remaining.length - 2));
      remaining = remaining.substring(0, remaining.length - 2);
    }
    if (remaining.isNotEmpty) groups.insert(0, remaining);
    return '₹${groups.join(',')},$lastThree';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f3f8),
      appBar: AppBar(
        backgroundColor: const Color(0xfff5f3f8),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Booking Summary',
          style: GoogleFonts.urbanist(
            color: const Color(0xff14111e),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff17141f)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAmountSummary(),
            const SizedBox(height: 20),
            _buildPaymentMethodsInfo(),
            const SizedBox(height: 20),
            _buildTermsAndConditions(),
            const SizedBox(height: 100), // padding for bottom button
          ],
        ),
      ),
      bottomSheet: _buildBottomPayArea(),
    );
  }

  Widget _buildAmountSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffe6e2ee)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Breakdown',
            style: GoogleFonts.urbanist(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xff14111e),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal (after discounts)', style: GoogleFonts.urbanist(fontSize: 15)),
              Text(_formatInr(widget.subtotalAmount), style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Taxes (GST 18%)', style: GoogleFonts.urbanist(fontSize: 15)),
              Text(_formatInr(_taxAmount), style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(color: Color(0xffe6e2ee)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Final Amount',
                style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              Text(
                _formatInr(_finalTotal),
                style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xff247344)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffe6e2ee)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Accepted Payment Methods',
            style: GoogleFonts.urbanist(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xff14111e),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildMethodBadge(Icons.credit_card, 'Cards'),
              _buildMethodBadge(Icons.account_balance, 'Net Banking'),
              _buildMethodBadge(Icons.mobile_friendly, 'UPI'),
              _buildMethodBadge(Icons.account_balance_wallet, 'Wallets'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMethodBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xfff5f3f8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xff5f586d)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.urbanist(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xff5f586d),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xfffff8e1), // Light warning/notice color
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromARGB(255, 212, 175, 55).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xff9a7011), size: 20),
              const SizedBox(width: 8),
              Text(
                'Disclaimers & Terms',
                style: GoogleFonts.urbanist(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xff9a7011),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '• By making this payment, you agree to the standard terms of Dreamventz.\n'
            '• Orders are subject to venue and vendor availability, confirmed shortly after payment is realized.\n'
            '• Cancellation policies vary by specific vendor logic—applicable up to 5 days before the event.',
            style: GoogleFonts.urbanist(
              fontSize: 13,
              height: 1.5,
              color: const Color(0xff5c440a),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPayArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Final Request',
                  style: GoogleFonts.urbanist(fontSize: 13, color: const Color(0xff5f586d)),
                ),
                Text(
                  _formatInr(_finalTotal),
                  style: GoogleFonts.urbanist(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xff14111e),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff181510),
                  foregroundColor: const Color(0xfff8cf3f),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 0,
                ),
                onPressed: _isProcessing ? null : _startPayment,
                child: _isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xfff8cf3f)),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.security, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Pay Now',
                            style: GoogleFonts.urbanist(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
