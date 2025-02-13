import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'dart:math';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:purohithulu/model/booking.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/categories.dart';
import '../model/location.dart';
import '../model/profiledata.dart' as profile;
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http/retry.dart';
import '../functions/flutterfunctions.dart';
import '../model/profiledata.dart';
import '../utilities/purohithapi.dart';

import 'package:provider/provider.dart';
import 'package:http_parser/http_parser.dart' as parser;
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/callduration.dart';
import 'auth.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:firebase_database/firebase_database.dart';

class ApiCalls extends ChangeNotifier {
  String? token;
  String? ftoken;
  String? userid;
  Map? categoryTypes;
  List? categories;
  List<int> selected_box = [];
  List<int> selectedCatId = [];
  String? messages;
  List? users = [];
  Map? user;
  // In your ApiCalls class
  Categories? categorieModel = Categories(); // Initialize with empty model
  Location? location;
  int? locationId;
  bool _isSwitched = false;
  var zegoController = ZegoUIKitPrebuiltCallController();
  bool get isSwitched => _isSwitched;
  int? callcost;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List? bookings = [];
  profile.ProfileData? userDetails;
  Bookings? purohithBookings;
  var isloading = false;
  static double? costPerSecond;
  String? sub;
  static Timer? timer;
  bool isonline = false;

  bool get isOnline => isonline;
  ApiCalls({this.token, this.ftoken, this.userid});
  loading({String? result}) {
    isloading = !isloading;
    print(result == null ? 'result:' : result);
    notifyListeners();
  }

  set isOnline(bool value) {
    isonline = value;
    notifyListeners();
  }

  void toggleSwitched() {
    _isSwitched = !_isSwitched;
    notifyListeners();
  }

  void updatesubcat(String cat) {
    sub = cat;
    notifyListeners();
  }

  void selectedCat(int val) {
    if (selectedCatId.contains(val)) {
      selectedCatId.remove(val);
    } else {
      selectedCatId.add(val);
    }
    print(selectedCatId);
    notifyListeners();
  }

  void update(String token, String ftoken) {
    this.token = token;
    ftoken = ftoken;
  }

  void updateFtoken(String token) {
    ftoken = token;
  }

  void updateId(int val) {
    if (selected_box.contains(val)) {
      selected_box.remove(val);
    } else {
      selected_box.add(val);
    }
    print(selected_box);
    notifyListeners();
  }

  Future<void> fetchCategories(BuildContext context) async {
    final url = PurohitApi().baseUrl + PurohitApi().getcatogory;

    try {
      var response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      Map<String, dynamic> categoryTypes = json.decode(response.body);

      categorieModel = Categories.fromJson(categoryTypes);

      notifyListeners();
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<void> login(BuildContext cont) async {
    final url = PurohitApi().baseUrl + PurohitApi().getcatogory;

    try {
      var response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      categoryTypes = json.decode(response.body);
      if (categoryTypes!['data'] != null) {
        categories = categoryTypes!['data'];
      }
      // print(categories);

      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future finalregister(
      String mobileno,
      String adhar,
      String profilepic,
      String expirience,
      String languages,
      String userName,
      BuildContext context,
      List price) async {
    print("from api calls register:${price.map((e) => e).toList()}");
    var flutterFunctions =
        Provider.of<FlutterFunctions>(context, listen: false);
    var catIdString = selectedCatId.isNotEmpty ? selectedCatId.join(",") : '';
    String randomLetters = generateRandomLetters(10);

    var data = {
      "mobileno": mobileno,
      "role": "p",
      "username": userName,
      "userstatus": "0",
      "adhar": "${randomLetters}_adhar",
      "profilepic": "${randomLetters}_profilepic",
      "expirience": expirience,
      "lang": languages,
      "isonline": "0",
      "location": locationId
    };
    var separator = '/';

    List<List<String>> priceList = [];
    for (var i = 0; i < price.length; i++) {
      List<String> subcatPrices = [];
      for (var j = 0; j < price[i].length; j++) {
        String text = price[i][j].text;

        if (text.isNotEmpty) {
          subcatPrices.add(text);
        }
        // Do something with the text value
      }
      priceList.add(subcatPrices);
    }
    String prices = priceList.map((e) => e.join(',')).join(',');
    prices = prices.replaceAll(RegExp(r',+$'), ''); // remove trailing commas
    prices = prices.replaceAll(RegExp(r',,'), ','); // remove trailing commas

    var url =
        "${PurohitApi().baseUrl}${PurohitApi().register}$catIdString$separator$prices";
    Map<String, String> obj = {"attributes": json.encode(data).toString()};
    print('Price for category: $url');
    try {
      loading();
      //print(isloading);
      var response = http.MultipartRequest('POST', Uri.parse(url))
        ..files.add(await http.MultipartFile.fromPath(
            "imagefile[]", flutterFunctions.imageFileList![0].path,
            contentType: parser.MediaType("image", "jpg")))
        ..files.add(await http.MultipartFile.fromPath(
            "imagefile[]", flutterFunctions.imageFileList![1].path,
            contentType: parser.MediaType("image", "jpg")))
        ..fields.addAll(obj);
      final send = await response.send();
      final res = await http.Response.fromStream(send);
      var statuscode = res.statusCode;
      loading();
      //print('mobileno:$mobileno,');
      user = json.decode(res.body);
      // print(response.fields);

      // print(isloading);
      if (user!['data'] != null) {
        users = user!['data'];
        messages = user!['messages'].toString();
        // var firebaseresponse = await http.post(Uri.parse(firebaseUrl),
        //     body: json.encode({'status': apiCalls.users![0]['isonline']}));
        // var firebaseDetails = json.decode(firebaseresponse.body);
      }
      messages = user!['messages'].toString();
      print(messages);
      notifyListeners();
      return statuscode;
    } catch (e) {
      messages = e.toString();
      print(e);
    }
  }

  Future register(String mobileno, String expirience, String languages,
      String userName, BuildContext context, List price) async {
    print("from api calls register:${price.map((e) => e).toList()}");
    var flutterFunctions =
        Provider.of<FlutterFunctions>(context, listen: false);
    var catIdString = selectedCatId.isNotEmpty ? selectedCatId.join(",") : '';
    String randomLetters = generateRandomLetters(10);

    var data = {
      "mobileno": mobileno,
      "role": "p",
      "username": userName,
      "userstatus": "0",
      "adhar": "${randomLetters}_adhar",
      "profilepic": "${randomLetters}_profilepic",
      "expirience": expirience,
      "lang": languages,
      "isonline": "0",
      "location": locationId
    };
    var separator = '/';
    List<List<String>> priceList = [];
    for (var i = 0; i < price.length; i++) {
      List<String> subcatPrices = [];
      for (var j = 0; j < price[i].length; j++) {
        String text = price[i][j].text;

        if (text.isNotEmpty) {
          subcatPrices.add(text);
        }
        // Do something with the text value
      }
      priceList.add(subcatPrices);
    }
    String prices = priceList.map((e) => e.join(',')).join(',');
    prices = prices.replaceAll(RegExp(r',+$'), ''); // remove trailing commas
    prices = prices.replaceAll(RegExp(r',,'), ','); // remove trailing commas

    var url =
        "${PurohitApi().baseUrl}${PurohitApi().register}$catIdString$separator$prices";
    Map<String, String> obj = {"attributes": json.encode(data).toString()};
    print('Price for category: $url');
    try {
      loading();
      //print(isloading);
      var response = http.MultipartRequest('POST', Uri.parse(url))
        ..files.add(await http.MultipartFile.fromPath(
            "imagefile[]", flutterFunctions.imageFileList![0].path,
            contentType: parser.MediaType("image", "jpg")))
        ..files.add(await http.MultipartFile.fromPath(
            "imagefile[]", flutterFunctions.imageFileList![1].path,
            contentType: parser.MediaType("image", "jpg")))
        ..fields.addAll(obj);
      final send = await response.send();
      final res = await http.Response.fromStream(send);
      var statuscode = res.statusCode;
      loading();
      //print('mobileno:$mobileno,');
      user = json.decode(res.body);
      // print(response.fields);

      // print(isloading);
      if (user!['data'] != null) {
        users = user!['data'];
        messages = user!['messages'].toString();
        // var firebaseresponse = await http.post(Uri.parse(firebaseUrl),
        //     body: json.encode({'status': apiCalls.users![0]['isonline']}));
        // var firebaseDetails = json.decode(firebaseresponse.body);
      }
      messages = user!['messages'].toString();
      print(messages);
      notifyListeners();
      return statuscode;
    } catch (e) {
      messages = e.toString();
      print(e);
    }
  }

  Future toggleOorF(int userid, BuildContext context, bool userstatus) async {
    final fbuser = FirebaseAuth.instance.currentUser;
    final uid = fbuser?.uid;
    print("toggleOorF started");
    final url = '${PurohitApi().baseUrl}${PurohitApi().updateUser}/$userid';
    try {
      final client = RetryClient(
        http.Client(),
        retries: 4,
        when: (response) {
          return response.statusCode == 401 ? true : false;
        },
        onRetry: (req, res, retryCount) async {
          if (retryCount == 0 && res?.statusCode == 401) {
            var accessToken = await Provider.of<Auth>(context, listen: false)
                .restoreAccessToken(context);
            req.headers['Authorization'] = accessToken;
          }
        },
      );
      var response = await client.patch(Uri.parse(url),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': token!
          },
          body: json.encode({"isonline": userstatus}));

      var userDetails = json.decode(response.body);
      print('toggleOorF:$userDetails');
      if (response.statusCode == 201) {
        Future.delayed(Duration.zero).then((value) {
          var apicalls = Provider.of<ApiCalls>(context, listen: false);
          UserProfileData newUserData = UserProfileData(
            id: apicalls.userDetails!.data![0].id,
            username: apicalls.userDetails!.data![0].username,
            mobileno: apicalls.userDetails!.data![0].mobileno,
            profilepic: apicalls.userDetails!.data![0].profilepic,
            adhar: apicalls.userDetails!.data![0].adhar,
            languages: apicalls.userDetails!.data![0].languages,
            expirience: apicalls.userDetails!.data![0].expirience,
            role: apicalls.userDetails!.data![0].role,
            adharno: apicalls.userDetails!.data![0].adharno,
            location: apicalls.userDetails!.data![0].location,
            isonline: userstatus == false ? 0 : 1,
          );
          apicalls.updateUserModel(
              apicalls.userDetails!.data![0].id.toString(), newUserData);
          messages = userDetails['messages'].toString();
        });

        try {
          print('userstatus:  $userstatus');
          // Update Realtime Database
          final userRef = FirebaseDatabase.instance
              .ref()
              .child('presence')
              .child(uid.toString());
          await userRef.update({
            'isonline': userstatus,
            'id': userid,
            // Add more fields if needed
          });
        } catch (e) {
          print('Error updating Firebase Realtime Database: $e');
        }
      } else if (response.statusCode == 400) {
        messages = userDetails['messages'].toString();
      }
      //print(messages);
      notifyListeners();
      return response.statusCode;
    } catch (e) {
      print(e);
    }
  }

  Future<void> getBooking(BuildContext cont) async {
    final url = PurohitApi().baseUrl + PurohitApi().getBookings;

    try {
      final client = RetryClient(
        http.Client(),
        retries: 4,
        when: (response) {
          return response.statusCode == 401 ? true : false;
        },
        onRetry: (req, res, retryCount) async {
          //print('retry started $token');

          if (retryCount == 0 && res?.statusCode == 401) {
            var accessToken = await Provider.of<Auth>(cont, listen: false)
                .restoreAccessToken(cont);
            // Only this block can run (once) until done
            print('retry $accessToken');
            req.headers['Authorization'] = accessToken;
          }
        },
      );
      var response = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': token!
        },
      );

      Map<String, dynamic> bookingResponse = json.decode(response.body);
      print('booking history:$bookingResponse');
      purohithBookings = Bookings.fromJson(bookingResponse);

      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> getUser(BuildContext cont) async {
    final url = PurohitApi().baseUrl + PurohitApi().session;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final fbuser = FirebaseAuth.instance.currentUser;
    loading();
    try {
      final client = RetryClient(
        http.Client(),
        retries: 4,
        when: (response) {
          return response.statusCode == 401 ? true : false;
        },
        onRetry: (req, res, retryCount) async {
          //print('retry started $token');

          if (retryCount == 0 && res?.statusCode == 401) {
            var accessToken = await Provider.of<Auth>(cont, listen: false)
                .restoreAccessToken(cont);
            // Only this block can run (once) until done
            print('retry $accessToken');
            req.headers['Authorization'] = accessToken;
          }
        },
      );
      var response = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': token!
        },
      );
      switch (response.statusCode) {
        case 201:
          Map<String, dynamic> userResponse = json.decode(response.body);
          userDetails = profile.ProfileData.fromJson(userResponse);
          if (userDetails != null &&
              userDetails!.data != null &&
              userDetails!.data!.isNotEmpty) {
            final databaseReference =
                FirebaseDatabase.instance.ref().child('presence');
            final userIsonlineRef = databaseReference.child(fbuser!.uid);
            userIsonlineRef.once().then((DatabaseEvent event) async {
              if (!event.snapshot.exists) {
                await userIsonlineRef.set({
                  'isonline':
                      userDetails!.data![0].isonline == 0 ? false : true,
                  'id': userDetails!.data![0].id,
                  // Add more fields if needed
                });
              }
            });
            // await _firestore
            //     .collection('users')
            //     .doc(userDetails!.data![0].id.toString())
            //     .set({
            //   'isonline': userDetails!.data![0].isonline == 0 ? false : true,
            //   'id': userDetails!.data![0].id,
            //   // Add more fields if needed
            // });
          }

          break;
      }

      // Check if any user details are null and set profile status accordingly
      if (userDetails?.data?[0].username == null ||
          userDetails?.data?[0].profilepic == null ||
          userDetails?.data?[0].placeofbirth == null ||
          userDetails?.data?[0].dateofbirth == null) {
        prefs.setBool('profile', false);
      } else {
        prefs.setBool('profile', true);
        prefs.setBool("drawer", false);
      }

      print(
          "this is from getuser:${userDetails?.data?[0].id}status code ${response.statusCode}");
      notifyListeners();
    } catch (e) {
      print(e);
    }
    loading();
  }

  void onUserLogin(String userId, String userName, BuildContext context) {
    final fbuser = FirebaseAuth.instance.currentUser;
    final uid = fbuser?.uid;
    final userRef =
        FirebaseDatabase.instance.ref().child('presence').child(uid.toString());

    ZegoUIKitPrebuiltCallInvitationService().init(
      appID: 381310215 /*input your AppID*/,
      appSign:
          "b27d415148d2f0d29cecb53b33709a09d9e5153705520c6ad5bf3f3c2d33b3ba" /*input your AppSign*/,
      userID: userId,
      userName: userName,
      events: ZegoUIKitPrebuiltCallEvents(
        onCallEnd: (event, defaultAction) async {
          await userRef.update({
            'inCall': false,

            // Add more fields if needed
          });
          CallDurationWidget.stopTimer(context);
        },
      ),
      invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(
        onOutgoingCallAccepted: (String callID, ZegoCallUser calee) async {
          CallDurationWidget.startTimer(callcost!, context);
          await userRef.update({
            'inCall': true,

            // Add more fields if needed
          });
        },
        onIncomingCallDeclineButtonPressed: () {
          CallDurationWidget.stopTimer(context);
        },
      ),
      plugins: [ZegoUIKitSignalingPlugin()],
      requireConfig: (ZegoCallInvitationData data) {
        final config = (data.invitees.length > 1)
            ? ZegoCallType.voiceCall == data.type
                ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
                : ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
            : ZegoCallType.voiceCall == data.type
                ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
                : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

        // ..durationConfig.onDurationUpdate = (Duration duration) {
        //   if (duration.inSeconds >= 20 * 60) {
        //     zegoController.hangUp(context);
        //   }
        // };
        // final customdata = data.customData;
        // print("customdata:$customdata");
        // callcost = int.parse(customdata);
        config.duration.isVisible = true;
        // config.onHangUp = () async {
        //   await userRef.update({
        //     'inCall': false,

        //     // Add more fields if needed
        //   });
        //   CallDurationWidget.stopTimer(context);
        // };
        // config.onOnlySelfInRoom = (context) async {
        //   await userRef.update({
        //     'inCall': false,

        //     // Add more fields if needed
        //   });
        //   CallDurationWidget.stopTimer(context);

        //   Navigator.pop(context);
        // };

        config.audioVideoViewConfig = ZegoPrebuiltAudioVideoViewConfig(
          foregroundBuilder: (context, size, user, extraInfo) {
            final screenSize = MediaQuery.of(context).size;
            final isSmallView = size.height < screenSize.height / 2;
            if (isSmallView) {
              return Container();
            } else {
              return const CallDurationWidget();
            }
          },
        );

        /// support minimizing, show minimizing button
        config.topMenuBarConfig.isVisible = true;
        // config.topMenuBarConfig.buttons
        //     .insert(0, ZegoMenuBarButtonName.minimizingButton);
        config
          ..turnOnCameraWhenJoining = false
          ..turnOnMicrophoneWhenJoining = true
          ..useSpeakerWhenJoining = true;

        config.bottomMenuBarConfig = ZegoBottomMenuBarConfig(
          maxCount: 5,
          buttons: [
            ZegoMenuBarButtonName.toggleMicrophoneButton,
            ZegoMenuBarButtonName.switchAudioOutputButton,
            ZegoMenuBarButtonName.hangUpButton,
          ],
        );
        return config;
      },
    );
  }

  Future<void> updateUserModel(
      String id, profile.UserProfileData newUser) async {
    print("user model:${userDetails!.data![0].id}");
    final prodIndex = userDetails!.data!.indexWhere((prod) {
      print("Current prod.id: ${prod.id}, id to find: $id");
      return prod.id.toString() == id;
    });

    print("$prodIndex $id");
    if (prodIndex != -1) {
      userDetails!.data![prodIndex] = newUser;
      notifyListeners();
    }
    notifyListeners();
  }

  Future<void> getLocation(BuildContext context) async {
    final url = '${PurohitApi().baseUrl}${PurohitApi().location}';
    try {
      final client = RetryClient(
        http.Client(),
        retries: 4,
        when: (response) {
          return response.statusCode == 401 ? true : false;
        },
        onRetry: (req, res, retryCount) async {
          //print('retry started $token');

          if (retryCount == 0 && res?.statusCode == 401) {
            print('going to restore access token from get location');
            var accessToken = await Provider.of<Auth>(context, listen: false)
                .restoreAccessToken(context);
            // Only this block can run (once) until done

            req.headers['Authorization'] = accessToken;
          }
        },
      );
      print('from get location $token');
      var response = await client.get(
        Uri.parse(url),
      );
      Map<String, dynamic> locationBody = json.decode(response.body);
      location = Location.fromJson(locationBody);

      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  String generateRandomLetters(int length) {
    var random = Random();
    var letters = List.generate(length, (_) => random.nextInt(26) + 97);
    return String.fromCharCodes(letters);
  }

  void setupPresenceSystem(String uid, BuildContext context) async {
    final databaseReference = FirebaseDatabase.instance.ref().child('presence');
    final userStatusRef = databaseReference.child(uid).child('status');
    final userIsonlineRef = databaseReference.child(uid).child('isonline');
    if (userStatusRef != null) {
      await userStatusRef.onDisconnect().set('disconnected').then((_) {
        userStatusRef.set('connected');
      });
      await userIsonlineRef.onDisconnect().set(false);
    }
  }

  Future<void> updateBookingStatusById(
      int bookingDataId, String newStatus) async {
    final FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference bookingRef = database.ref().child('bookings');

    // Retrieve all user IDs
    bookingRef.once().then((DatabaseEvent event) {
      DataSnapshot usersSnapshot = event.snapshot;
      Map<String, dynamic>? usersData =
          (usersSnapshot.value as Map<dynamic, dynamic>?)
              ?.map((key, value) => MapEntry(key as String, value));

      if (usersData != null) {
        // Iterate through the user IDs to find the booking with the given booking data ID
        for (String userId in usersData.keys) {
          // Iterate through the bookings for the current user
          Map<String, dynamic>? bookingsData =
              (usersData[userId] as Map<dynamic, dynamic>?)
                  ?.map((key, value) => MapEntry(key as String, value));

          if (bookingsData != null) {
            for (String bookingId in bookingsData.keys) {
              // Check if the current booking has the required booking data ID
              if (bookingsData[bookingId]['id'] == bookingDataId) {
                // Update the booking status
                bookingRef.child(userId).child(bookingId).update({
                  'booking status': newStatus,
                });
                return; // Exit the function once the booking is updated
              }
            }
          }
        }
      }
    });
  }

  Future<void> getUserPic(BuildContext cont) async {
    final url = PurohitApi().baseUrl + PurohitApi().userProfile;
    if (userDetails == null || userDetails!.data == null) {
      final client = RetryClient(
        http.Client(),
        retries: 4,
        when: (response) {
          return response.statusCode == 401 ? true : false;
        },
        onRetry: (req, res, retryCount) async {
          if (retryCount == 0 && res?.statusCode == 401) {
            var accessToken = await Provider.of<Auth>(cont, listen: false)
                .restoreAccessToken(cont);
            // Only this block can run (once) until done
            req.headers['Authorization'] = accessToken;
          }
        },
      );
      var response = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': token!
        },
      );
      //Map<String, dynamic> userResponse = json.decode(response.body);
      final Uint8List resbytes = response.bodyBytes;

      switch (response.statusCode) {
        case 200:
          try {
            // Attempt to create an Image object from the image bytes
            // final image = Image.memory(resbytes);
            final tempDir = await getTemporaryDirectory();
            final file = File('${tempDir.path}/profile');
            await file.writeAsBytes(resbytes);
            if (userDetails!.data != null) {
              userDetails!.data![0].xfile = XFile(file.path);
            }

            notifyListeners();
            // If the image was created successfully, the bytes are in a valid format
          } catch (e) {
            // If an error is thrown, the bytes are not in a valid format
          }
      }
    }

    // print(
    //     "this is from getuserPic:${userDetails!.data![0].xfile!.readAsBytes()}");
  }

  Future withdrawAmount(double amount, BuildContext context, String upi,
      String? dateAndTime) async {
    final fbuser = FirebaseAuth.instance.currentUser;
    final uid = fbuser?.uid;
    print(dateAndTime);
    final url = '${PurohitApi().baseUrl}${PurohitApi().withdrawAmount}';
    try {
      final client = RetryClient(
        http.Client(),
        retries: 4,
        when: (response) {
          return response.statusCode == 401 ? true : false;
        },
        onRetry: (req, res, retryCount) async {
          if (retryCount == 0 && res?.statusCode == 401) {
            var accessToken = await Provider.of<Auth>(context, listen: false)
                .restoreAccessToken(context);
            req.headers['Authorization'] = accessToken;
          }
        },
      );
      var response = await client.post(Uri.parse(url),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': token!
          },
          body: json.encode(
              {"upi": upi, 'amount': amount, 'dateandtime': dateAndTime}));

      var userDetails = json.decode(response.body);
      print('toggleOorF:$userDetails');
      if (response.statusCode == 201) {
        final userRef = FirebaseDatabase.instance
            .ref()
            .child('wallet')
            .child(uid!)
            .child('amount');
        double? currentAmount;
        await userRef.once().then((DatabaseEvent event) {
          DataSnapshot snapshot = event.snapshot;
          currentAmount = double.tryParse(snapshot.value?.toString() ?? '0.0');
        });
        print('this is $currentAmount and this is $amount');
        if (currentAmount == null || currentAmount! < amount) {
          print("Not enough funds!");
          return; // You might want to handle this case differently
        }

// Deduct the amount
        double newAmount = currentAmount! - amount;
        try {
          // Update Realtime Database
          final userRef = FirebaseDatabase.instance
              .ref()
              .child('wallet')
              .child(uid.toString());
          await userRef.update({
            'amount': newAmount,

            // Add more fields if needed
          });
        } catch (e) {
          print('Error updating Firebase Realtime Database: $e');
        }
      } else if (response.statusCode == 400) {
        messages = userDetails['messages'].toString();
      }
      //print(messages);
      notifyListeners();
      return response.statusCode;
    } catch (e) {
      print(e);
    }
  }
}
