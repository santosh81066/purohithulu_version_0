class Bookings {
  final int? statusCode;
  final bool? success;
  final List<String>? messages;
  final List<BookingData>? data;

  Bookings({
    this.statusCode,
    this.success,
    this.messages,
    this.data,
  });

  Bookings.fromJson(Map<String, dynamic> json)
      : statusCode = json['statusCode'] as int?,
        success = json['success'] as bool?,
        messages = (json['messages'] as List?)
            ?.map((dynamic e) => e as String)
            .toList(),
        data = (json['data'] as List?)
            ?.map(
                (dynamic e) => BookingData.fromJson(e as Map<String, dynamic>))
            .toList();

  Map<String, dynamic> toJson() => {
        'statusCode': statusCode,
        'success': success,
        'messages': messages,
        'data': data?.map((e) => e.toJson()).toList()
      };
}

class BookingData {
  final int? id;
  final String? address;
  final String? time;
  final double? amount;
  final double? minutes;
  final int? userid;
  final dynamic bookingStatus;
  final dynamic startotp;
  final dynamic endotp;
  final String? purohitCategory;
  final dynamic goutram;
  final String? eventName;
  final dynamic purohithName;
  final String? username;

  BookingData({
    this.id,
    this.address,
    this.time,
    this.amount,
    this.minutes,
    this.userid,
    this.bookingStatus,
    this.startotp,
    this.endotp,
    this.purohitCategory,
    this.goutram,
    this.eventName,
    this.purohithName,
    this.username,
  });

  BookingData.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        address = json['address'] as String?,
        time = json['time'] as String?,
        amount = (json['amount'] as num?)?.toDouble(),
        minutes = (json['minutes'] as num?)?.toDouble(),
        userid = json['userid'] as int?,
        bookingStatus = json['status'],
        startotp = json['startotp'],
        endotp = json['endotp'],
        purohitCategory = json['purohit_category'] as String?,
        goutram = json['goutram'],
        eventName = json['event_name'] as String?,
        purohithName = json['purohith_name'],
        username = json['username'] as String?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'address': address,
        'time': time,
        'amount': amount,
        'minutes': minutes,
        'userid': userid,
        'status': bookingStatus,
        'startotp': startotp,
        'endotp': endotp,
        'purohit_category': purohitCategory,
        'goutram': goutram,
        'event_name': eventName,
        'purohith_name': purohithName,
        'username': username
      };
}
