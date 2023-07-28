import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../providers/wallet.dart';

class CallDurationWidget extends StatelessWidget {
  const CallDurationWidget({Key? key}) : super(key: key);

  static DateTime callStartTime = DateTime.now();
  static ValueNotifier<DateTime> timeListenable =
      ValueNotifier<DateTime>(DateTime.now());
  static ValueNotifier<bool> shouldEndCall = ValueNotifier<bool>(false);

  static Timer? timer;
  static double? costPerSecond;
  static void stopTimer(BuildContext context) {
    timer?.cancel();
    timer = null;
  }

  static void startTimer(int callRate, BuildContext context) {
    final fbuser = FirebaseAuth.instance.currentUser;
    final FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference userWalletRef =
        database.ref().child('wallet').child(fbuser!.uid);

    costPerSecond = callRate / 20 / 60;
    print('call rate:$costPerSecond');
    timer?.cancel();
    callStartTime = DateTime.now();
    timeListenable.value = callStartTime;
    userWalletRef.once().then((DatabaseEvent event) {
      dynamic amountValue = event.snapshot.value != null
          ? (event.snapshot.value as Map<dynamic, dynamic>)['amount']
          : null;

      double walletBalance = amountValue is num ? amountValue.toDouble() : 0;

      timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        timeListenable.value = DateTime.now();
        final duration = timeListenable.value.difference(callStartTime);
        walletBalance += costPerSecond!;
        print('wallet balance: $walletBalance');
        if (event.snapshot.hasChild('amount')) {
          await userWalletRef.update({'amount': walletBalance});
        } else {
          await userWalletRef.child('amount').set(walletBalance);
        }

        // Check if walletBalance <= 0 or call duration reaches 20 mins
        if (duration.inMinutes >= 20) {
          Navigator.of(context).pop();
          print('time is less then 5');

          // Update wallet balance in database

          stopTimer(context);
          // Navigator.of(context).pop();
          // End the call using the Zego SDK
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: CallDurationWidget.timeListenable,
      builder: (context, DateTime currentTime, _) {
        final duration =
            currentTime.difference(CallDurationWidget.callStartTime);
        final durationText = duration.toText();
        debugPrint(durationText);
        return Stack(
          children: [
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  durationText,
                  style: const TextStyle(color: Colors.white, fontSize: 30),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}

extension DurationToText on Duration {
  String toText() {
    var microseconds = inMicroseconds;
    var hours = (microseconds ~/ Duration.microsecondsPerHour).abs();
    microseconds = microseconds.remainder(Duration.microsecondsPerHour);
    if (microseconds < 0) microseconds = -microseconds;
    var minutes = microseconds ~/ Duration.microsecondsPerMinute;
    microseconds = microseconds.remainder(Duration.microsecondsPerMinute);
    var minutesPadding = minutes < 10 ? "0" : "";
    var seconds = microseconds ~/ Duration.microsecondsPerSecond;
    microseconds = microseconds.remainder(Duration.microsecondsPerSecond);
    var secondsPadding = seconds < 10 ? "0" : "";
    return '$hours:$minutesPadding$minutes:$secondsPadding$seconds';
  }
}
