import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../providers/wallet.dart';
import '../widgets/appbar.dart';
import '../widgets/text_widget.dart';

import '../widgets/button.dart';

class Wallet extends StatefulWidget {
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;
  const Wallet({super.key, this.scaffoldMessengerKey});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  TextEditingController amt = TextEditingController();
  late Razorpay razorpay;
  String amount = 'Add amount to wallet';
  String balance = 'balance ₹100';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    final ScaffoldMessengerState scaffoldKey =
        widget.scaffoldMessengerKey!.currentState as ScaffoldMessengerState;
    scaffoldKey.showSnackBar(SnackBar(
      content: Text('${response.paymentId}'),
      duration: Duration(seconds: 5),
      backgroundColor: Colors.green,
    ));
    // Do something when payment succeeds
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    final ScaffoldMessengerState scaffoldKey =
        widget.scaffoldMessengerKey!.currentState as ScaffoldMessengerState;
    scaffoldKey.showSnackBar(SnackBar(
      content: Text('${response.message}'),
      duration: Duration(seconds: 5),
      backgroundColor: Colors.red,
    ));
    // Do something when payment fails
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    final ScaffoldMessengerState scaffoldKey =
        widget.scaffoldMessengerKey!.currentState as ScaffoldMessengerState;
    scaffoldKey.showSnackBar(SnackBar(
      content: Text('${response.walletName}'),
      duration: Duration(seconds: 5),
      backgroundColor: Colors.green,
    ));
    // Do something when an external wallet was selected
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    return Scaffold(
      appBar: purohithAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () {
                          amt.text = "100";
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              ImageIcon(
                                AssetImage('assets/rupee.png'),
                                size: 30,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "100",
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () {
                          amt.text = "200";
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              ImageIcon(
                                AssetImage('assets/rupee.png'),
                                size: 30,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "200",
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () {
                          amt.text = "300";
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              ImageIcon(
                                AssetImage('assets/rupee.png'),
                                size: 30,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "300",
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () {
                          amt.text = "400";
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              ImageIcon(
                                AssetImage('assets/rupee.png'),
                                size: 30,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "400",
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () {
                          amt.text = "500";
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              ImageIcon(
                                AssetImage('assets/rupee.png'),
                                size: 30,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "500",
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () {
                          amt.text = "1000";
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              ImageIcon(
                                AssetImage('assets/rupee.png'),
                                size: 30,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "1000",
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextWidget(
                  controller: amt,
                  hintText: amount,
                ),
              ],
            ),
            Button(
                onTap: () {
                  walletProvider.addAmount(int.parse(amt.text.trim()));
                  openCheckout();
                },
                buttonname: "Add Amount")
          ],
        ),
      ),
    );
  }

  void openCheckout() {
    var options = {
      'key': 'rzp_test_SFe3T4rnttohMI',
      'amount': num.parse(amt.text) * 100,
      'name': 'Purohithulu',
      'description': 'wallet',
      'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'}
    };
    razorpay.open(options);
  }
}
