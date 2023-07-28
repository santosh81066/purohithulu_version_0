import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:animated_switch/animated_switch.dart';
import 'package:provider/provider.dart';
import '../controller/apicalls.dart';
import 'package:async/async.dart';

AppBar purohithAppBar(BuildContext context, {String? title}) {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final String? uid = currentUser?.uid;
  DatabaseReference firebaseRealtimeUserRef =
      FirebaseDatabase.instance.ref().child('presence');
  DatabaseReference firebaseRealtimeUserWallet =
      FirebaseDatabase.instance.ref().child('wallet');
  firebaseRealtimeUserRef.child(uid!).onValue.listen((event) {
    print('Presence node event: ${event.snapshot.value}');
  });
  StreamZip<dynamic> streams = StreamZip<dynamic>([
    firebaseRealtimeUserRef.child(uid!).onValue,
    firebaseRealtimeUserWallet.child(uid).onValue
  ]);
  return AppBar(
    title: title == null ? const Text('') : Text(title),
    actions: [
      Consumer<ApiCalls>(
        builder: (context, user, child) {
          return user.userDetails == null
              ? const CircularProgressIndicator()
              : Row(
                  children: [
                    StreamBuilder(
                      stream: streams,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<dynamic>> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (!snapshot.hasData ||
                            snapshot.data![0].snapshot.value == null) {
                          return const Text('Sorry server is down');
                        }

                        Map<dynamic, dynamic> userData =
                            (snapshot.data![0] as DatabaseEvent).snapshot.value
                                as Map<dynamic, dynamic>;
                        bool isOnline = userData['isonline'] == true;
                        double amount = 0;
                        print('Snapshot Data 1: $isOnline');

                        if (snapshot.data![1].snapshot.value != null) {
                          Map<dynamic, dynamic> walletData =
                              (snapshot.data![1] as DatabaseEvent)
                                  .snapshot
                                  .value as Map<dynamic, dynamic>;

                          if (walletData['amount'] != null) {
                            amount = walletData['amount'].toDouble();
                          }
                        }

                        return Row(
                          children: [
                            Consumer<ApiCalls>(
                              builder: (context, toggle, child) {
                                return AnimatedSwitch(
                                  value: isOnline,
                                  onChanged: (bool state) async {
                                    bool currentSwitchState =
                                        toggle.userDetails == null
                                            ? false
                                            : toggle.userDetails!.data == null
                                                ? false
                                                : toggle.userDetails!.data![0]
                                                            .isonline ==
                                                        0
                                                    ? false
                                                    : true;
                                    if (currentSwitchState != state) {
                                      await toggle.toggleOorF(
                                          toggle.userDetails!.data![0].id!,
                                          context,
                                          state);
                                      currentSwitchState = state;
                                    }
                                  },
                                  width:
                                      MediaQuery.of(context).size.width * 1 / 4,
                                  textOn: "Online",
                                  textOff: "Offline",
                                  textStyle: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                );
                              },
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.pushNamed(context, "wallet");
                              },
                              icon: const Icon(Icons.wallet),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Text(
                                  amount == null
                                      ? '0'
                                      : amount.toStringAsFixed(2),
                                  style: TextStyle(fontSize: 18)),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                );
        },
      )
    ],
  );
}
