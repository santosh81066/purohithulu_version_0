import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';

import '../controller/apicalls.dart';
import '../model/booking.dart';
import 'package:flutter/material.dart';

class CustomBookingTile extends StatefulWidget {
  final BookingData bookingData;

  const CustomBookingTile({super.key, required this.bookingData});

  @override
  State<CustomBookingTile> createState() => _CustomBookingTileState();
}

class _CustomBookingTileState extends State<CustomBookingTile> {
  final otpController = TextEditingController();
  @override
  void dispose() {
    otpController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool noLiveBookings = true;
    final FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference bookingRef = database.ref().child('bookings');
    print('bookingid:${widget.bookingData.id}');
    var apicalls = Provider.of<ApiCalls>(context, listen: false);
    return StreamBuilder<Map<String, dynamic>?>(
      stream: bookingStatusStream(widget.bookingData.id!, bookingRef),
      builder: (BuildContext context,
          AsyncSnapshot<Map<String, dynamic>?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // return const CircularProgressIndicator(
          //   strokeWidth: 2.0,
          //   backgroundColor: Colors.lightGreen,

          //);
          return Container();
        }
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        Map<String, dynamic> bookingDataMap = snapshot.data!;
        String? bookingStatus = bookingDataMap['booking status'] != null
            ? bookingDataMap['booking status']
            : "Null";

        String userUid = bookingDataMap['userUid'];
        if (!(bookingStatus == 'r' ||
            bookingStatus == 'c' ||
            bookingStatus == 'Null')) {
          noLiveBookings = false;
        } else {
          noLiveBookings = true;
        }
        return noLiveBookings == true
            ? Container()
            : Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.bookingData.purohitCategory!,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Amount: ${widget.bookingData.amount}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Address: ${widget.bookingData.address}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Time: ${widget.bookingData.time}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<DatabaseEvent>(
                      stream: FirebaseDatabase.instance
                          .ref()
                          .child('users')
                          .child(userUid)
                          .onValue,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting ||
                            !snapshot.hasData ||
                            snapshot.data?.snapshot.value == null) {
                          return const CircularProgressIndicator();
                        }

                        var snapshotValue = snapshot.data!.snapshot.value;
                        if (snapshotValue is! Map<dynamic, dynamic>) {
                          // handle this situation as needed
                          return const CircularProgressIndicator();
                        }

                        Map<dynamic, dynamic> userData = snapshotValue;
                        var mobileNo = userData['mobileno'];
                        switch (bookingStatus) {
                          case 'a':
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      child: TextField(
                                        controller: otpController,
                                        keyboardType: TextInputType.number,
                                        style: const TextStyle(fontSize: 18),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          labelText:
                                              'start otp to start booking',
                                          hintText: 'Enter OTP',
                                          hintStyle: const TextStyle(
                                              color: Colors.grey),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 24, vertical: 16),
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        String enteredOtp = otpController.text;
                                        String databaseOtp =
                                            bookingDataMap['startotp']
                                                .toString();
                                        if (databaseOtp == enteredOtp) {
                                          apicalls.updateBookingStatusById(
                                              widget.bookingData.id!, 'o');
                                        } else {
                                          print("Entered OTP: $enteredOtp");
                                          print("Database OTP: $databaseOtp");
                                          print("OTP does not match");
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      "OTP Mismatch"),
                                                  content: const Text(
                                                      "The OTP you entered does not match. Please try again."),
                                                  actions: [
                                                    TextButton(
                                                      child: const Text("OK"),
                                                      onPressed: () {
                                                        // Dismiss the alert dialog
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    )
                                                  ],
                                                );
                                              });

                                          // Handle OTP mismatch as per your requirement
                                        }
                                      },
                                      child: const Text('Submit'),
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      "Contact No:",
                                      style: TextStyle(
                                          color: Colors.blue, fontSize: 16),
                                    ),
                                    Text(
                                      mobileNo.toString(),
                                      style: const TextStyle(
                                          color: Colors.blue, fontSize: 16),
                                    ),
                                  ],
                                )
                              ],
                            );
                          case 'o':
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      child: TextField(
                                        controller: otpController,
                                        keyboardType: TextInputType.number,
                                        style: const TextStyle(fontSize: 18),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          labelText:
                                              'End otp to complete booking',
                                          hintText: 'Enter OTP',
                                          hintStyle: const TextStyle(
                                              color: Colors.grey),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 24, vertical: 16),
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        String enteredOtp = otpController.text;
                                        String databaseOtp =
                                            bookingDataMap['endotp'].toString();
                                        if (databaseOtp == enteredOtp) {
                                          apicalls.updateBookingStatusById(
                                              widget.bookingData.id!, 'c');
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      "Booking complete"),
                                                  content: const Text(
                                                      "Booking has been completed"),
                                                  actions: [
                                                    TextButton(
                                                      child: const Text("OK"),
                                                      onPressed: () {
                                                        // Dismiss the alert dialog
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    )
                                                  ],
                                                );
                                              });
                                        } else {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      "OTP Mismatch"),
                                                  content: const Text(
                                                      "The OTP you entered does not match. Please try again."),
                                                  actions: [
                                                    TextButton(
                                                      child: const Text("OK"),
                                                      onPressed: () {
                                                        // Dismiss the alert dialog
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    )
                                                  ],
                                                );
                                              });

                                          // Handle OTP mismatch as per your requirement
                                        }
                                      },
                                      child: const Text('Submit'),
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Contact No",
                                      style: TextStyle(
                                          color: Colors.blue, fontSize: 16),
                                    ),
                                    Text(
                                      mobileNo.toString(),
                                      style: const TextStyle(
                                          color: Colors.blue, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          default:
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    apicalls.updateBookingStatusById(
                                        widget.bookingData.id!, 'a');
                                  },
                                  child: const Text('Accept'),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.green,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    apicalls.updateBookingStatusById(
                                        widget.bookingData.id!, 'r');
                                  },
                                  child: const Text('Reject'),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.red,
                                  ),
                                ),
                              ],
                            );
                        }
                        // Display mobile number instead of 'Call' button
                      },
                    ),
                  ],
                ),
              );
      },
    );
  }

  Stream<Map<String, dynamic>?> bookingStatusStream(
      int bookingDataId, DatabaseReference bookingRef) {
    List<Map<String, dynamic>> bookings = [];
    return bookingRef.onValue.map((event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> userData =
            event.snapshot.value as Map<dynamic, dynamic>;
        for (var key in userData.keys) {
          Map<dynamic, dynamic> userBookings =
              userData[key].cast<dynamic, dynamic>();
          for (var bookingKey in userBookings.keys) {
            Map<dynamic, dynamic> bookingData =
                userBookings[bookingKey].cast<dynamic, dynamic>();
            if (bookingData['id'] == bookingDataId) {
              // Include the user UID in the returned data
              bookingData['userUid'] = key;

              return bookingData.cast<String, dynamic>();
            }
          }
        }
      }
      return null;
    });
  }
}
