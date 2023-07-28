import '../model/booking.dart';
import 'package:flutter/material.dart';

import 'customebookingtile.dart';

class BookingsList extends StatelessWidget {
  final List<BookingData> bookingsData;

  const BookingsList({super.key, required this.bookingsData});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: bookingsData.length,
      itemBuilder: (context, index) {
        return CustomBookingTile(bookingData: bookingsData[index]);
      },
    );
  }
}
