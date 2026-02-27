import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {
  final Razorpay _razorpay = Razorpay();
  final String _keyId = 'rzp_test_SK3czV5wEJKwOX';

  void init({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onFailure,
    required Function(ExternalWalletResponse) onExternalWallet,
  }) {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onFailure);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
  }

  void openCheckout({
    required double amount,
    String contact = '',
    String email = '',
    required String description,
  }) {
    var options = {
      'key': _keyId,
      'amount': (amount * 100)
          .toInt(), // amount in the smallest currency unit (paise)
      'name': 'Famio Project',
      'description': description,
      'prefill': {'contact': contact, 'email': email},
      'external': {
        'wallets': ['paytm'],
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      rethrow;
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}
