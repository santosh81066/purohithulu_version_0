import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

import 'dart:async';
import 'package:provider/provider.dart';
import 'package:purohithulu/controller/apicalls.dart';

import 'package:purohithulu/widgets/app_drawer.dart';
import 'package:purohithulu/widgets/appbar.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/bookinglist.dart';

class WellcomeScreen extends StatefulWidget {
  const WellcomeScreen({super.key});

  @override
  State<WellcomeScreen> createState() => _WellcomeScreenState();
}

class _WellcomeScreenState extends State<WellcomeScreen>
    with WidgetsBindingObserver {
  final fbuser = FirebaseAuth.instance.currentUser;

  DatabaseReference firebaseRealtimeUserRef =
      FirebaseDatabase.instance.ref().child('presence');

  @override
  void initState() {
    super.initState();
    InAppUpdate.checkForUpdate().then((info) => updateInfo = info);
    var apicalls = Provider.of<ApiCalls>(context, listen: false);
    final uid = fbuser?.uid;

    if (uid != null) {
      apicalls.setupPresenceSystem(uid, context);
    }
    Future.delayed(Duration.zero)
        .then((value) =>
            Provider.of<ApiCalls>(context, listen: false).getUser(context))
        .then((value) => apicalls.onUserLogin(
            apicalls.userDetails!.data![0].id.toString(),
            apicalls.userDetails!.data![0].username!,
            context))
        .then((value) => apicalls.getBooking(context))
        .then((value) => apicalls.getUserPic(context));

    //listenForCall();
  }

  Future<bool> onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you want to exit an App'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  AppUpdateInfo? updateInfo;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
          drawer: const AppDrawer(
              //userid: apicalls.users![0]['id'],
              //status: apicalls.users![0]['userstatus']
              ),
          appBar: purohithAppBar(context),
          body: updateInfo?.updateAvailability ==
                  UpdateAvailability.updateAvailable
              ? FutureBuilder(
                  future: Future.delayed(Duration.zero),
                  builder: (context, snapshot) {
                    // If future is complete, show dialog
                    if (snapshot.connectionState == ConnectionState.done) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Update Available'),
                            content: const Text(
                                'A new version of this app is available.'),
                            actions: <Widget>[
                              ElevatedButton(
                                child: const Text('UPDATE'),
                                onPressed: () {
                                  InAppUpdate.startFlexibleUpdate().then((_) {
                                    InAppUpdate.completeFlexibleUpdate();
                                  });
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                    // Show splash screen while waiting
                    return Consumer<ApiCalls>(
                      builder: (context, booking, child) {
                        return Scaffold(
                          body: booking.purohithBookings == null
                              ? const Center(child: Text('Sorry no bookings'))
                              : BookingsList(
                                  bookingsData:
                                      booking.purohithBookings!.data ?? []),
                        );
                      },
                    );
                  },
                )
              : Consumer<ApiCalls>(
                  builder: (context, booking, child) {
                    print("Bookings data: ${booking.purohithBookings}");
                    // Add these prints
                    print(
                        "Bookings data length: ${booking.purohithBookings?.data?.length}");
                    print(
                        "Raw bookings data: ${booking.purohithBookings?.data?.map((b) => b.toJson())}");

                    return booking.purohithBookings == null
                        ? const Center(child: Text('Sorry no bookings'))
                        : BookingsList(
                            bookingsData: booking.purohithBookings!.data ?? []);
                  },
                )),
    );
  }
}
