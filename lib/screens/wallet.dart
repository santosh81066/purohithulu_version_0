import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:purohithulu/controller/apicalls.dart';

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
  final User? currentUser = FirebaseAuth.instance.currentUser;
  String? uid;
  TextEditingController upiController = TextEditingController();
  DatabaseReference firebaseRealtimeUserRef =
      FirebaseDatabase.instance.ref().child('presence');
  DatabaseReference firebaseRealtimeUserWallet =
      FirebaseDatabase.instance.ref().child('wallet');
  double? walletamount;
  String upi = 'Please enter upi address';
  String amount = 'Please enter amount to withdraw';
  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the alert dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    uid = currentUser?.uid;
    _retrieveWalletAmount();
  }

  _retrieveWalletAmount() {
    firebaseRealtimeUserWallet
        .child(uid!)
        .child('amount')
        .onValue
        .listen((event) {
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        walletamount = double.parse(snapshot.value.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: purohithAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                TextWidget(
                  controller: amt,
                  hintText: amount,
                ),
                SizedBox(height: 16),
                TextWidget(
                  controller: upiController,
                  hintText: upi,
                ),
              ],
            ),
            Consumer<ApiCalls>(
              builder: (context, withdraw, child) {
                return Button(
                    onTap: () {
                      double? enteredAmount;
                      try {
                        enteredAmount = double.parse(amt.text.trim());
                      } catch (e) {
                        _showDialog(
                            'Error', 'Please enter a valid withdrawal amount.');
                        return;
                      }

                      // Check if entered amount is lesser or equal to the wallet amount
                      if (enteredAmount <= walletamount!) {
                        String dateAndTime = DateFormat('dd/MM/yyyy HH:mm')
                            .format(DateTime.now());

                        // This assumes your function returns a Future<int> representing the status code.
                        withdraw
                            .withdrawAmount(enteredAmount, context,
                                upiController.text.trim(), dateAndTime)
                            .then((statusCode) {
                          if (statusCode == 201) {
                            _showDialog('Success',
                                'Please wait while we transfer your amount with in 24 hrs.');
                          } else {
                            // Handle other status codes or general errors here
                            _showDialog('Error',
                                'An error occurred while processing your withdrawal.');
                          }
                        }).catchError((error) {
                          // This will handle any errors that occur during the future execution
                          _showDialog('Error', 'Unexpected error: $error.');
                        });
                      } else {
                        _showDialog('Insufficient Funds',
                            'You do not have enough funds for this withdrawal.');
                      }
                    },
                    buttonname: "Withdraw Amount");
              },
            )
          ],
        ),
      ),
    );
  }
}
