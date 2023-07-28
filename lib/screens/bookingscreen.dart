import 'package:flutter/material.dart';

import '../widgets/appbar.dart';
import 'package:provider/provider.dart';
import '../controller/apicalls.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({
    super.key,
  });

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  @override
  void initState() {
    Provider.of<ApiCalls>(context, listen: false).getBooking(context);

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //debugDumpRenderTree();
    return Scaffold(
      appBar: purohithAppBar(context, title: 'Booking History'),
      //bottomNavigationBar: const BottemNavigationBar(),
      body: Consumer<ApiCalls>(
        builder: (context, value, child) {
          value.purohithBookings!.data!.sort((a, b) => b.id!.compareTo(a.id!));
          return value.purohithBookings == null ||
                  value.purohithBookings!.data == null ||
                  value.purohithBookings!.data!.isEmpty
              ? const Center(
                  child: Text("Sorry there are no bookings to show"),
                )
              : ListView.builder(
                  itemCount: value.purohithBookings!.data!.length,
                  itemBuilder: (context, index) {
                    String status = "";
                    if (value.purohithBookings!.data != null) {
                      switch (
                          value.purohithBookings!.data![index].bookingStatus) {
                        case 'w':
                          status = 'User is waiting for your confermation';
                          break;
                        case "o":
                          status = "Booking is in progress";
                          break;
                        case "c":
                          status = "Booking has been completed";
                          break;
                        case "a":
                          status = "booking has been accepted";
                          break;
                        case "r":
                          status = "Booking has been rejected";
                      }
                    }

                    return Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Booking ID: ${value.purohithBookings!.data?[index].id}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            Text(
                              value.purohithBookings!.data![index]
                                  .purohitCategory!,
                              style: const TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            Text(
                              'Address: ${value.purohithBookings!.data![index].address}',
                              style: const TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Amount: ${value.purohithBookings!.data![index].amount}',
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                                Text(
                                  'Minutes: ${value.purohithBookings!.data![index].minutes}',
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              'Time: ${value.purohithBookings!.data![index].time}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 10.0),
                            Text(
                              maxLines: 5,
                              status,
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}
