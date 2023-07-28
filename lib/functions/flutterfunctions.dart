import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io' as platform;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../controller/apicalls.dart';

class FlutterFunctions extends ChangeNotifier {
  XFile? imageFile;
  String? fToken;
  String? verificationId;
  bool isloading = false;
  int countdown = 45;
  bool wait = true;
  List<XFile>? imageFileList = [];
  final ImagePicker _picker = ImagePicker();
  FirebaseAuth auth = FirebaseAuth.instance;
  waitTime() {
    wait = !wait;
    notifyListeners();
  }

  updateTimer() {
    countdown--;

    notifyListeners();
  }

  loading({String? result}) {
    isloading = !isloading;
    print(result == null ? 'result:' : result);
    notifyListeners();
  }

  Future<void> onImageButtonPress(ImageSource source,
      {BuildContext? context}) async {
    try {
      print('button pressed');
      final XFile? pickedFile = await _picker.pickImage(source: source);
      imageFile = pickedFile;
      imageFileList!.add(pickedFile!);

      print(imageFileList![0].path);
      notifyListeners();
    } catch (e) {
      print("$e");
    }
  }

  Future<void> phoneAuth(BuildContext context, String phoneNumber,
      ScaffoldMessengerState scaffoldKey) async {
    print(phoneNumber);
    //var completer = Completer<bool>();

    loading(result: 'loading is true in phone auth');

    //print(isloading);
    await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted:
            (PhoneAuthCredential phoneAuthCredential) async {},
        verificationFailed: (FirebaseException exception) {
          loading();
          print(isloading);
          print("verification failed: $exception");
          scaffoldKey.showSnackBar(SnackBar(
            content: Text('${exception.toString()}'),
            duration: Duration(seconds: 5),
          ));
        },
        codeSent: (String verificationid, [int? forceresendingtoken]) async {
          scaffoldKey.showSnackBar(const SnackBar(
            content: Text('verification code sent to your mobile'),
            duration: Duration(seconds: 5),
          ));
          Navigator.of(context).pushNamed('verifyotp', arguments: phoneNumber);
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('verificationid', verificationid);
          loading(result: 'loading should be false after code sent');
          //print(isloading);
        },
        timeout: const Duration(seconds: 30),
        codeAutoRetrievalTimeout: (String verificationid) {});
    notifyListeners();

    //return completer.future;
  }

  Future<void> registerPhoneAuth(
      BuildContext context,
      String phoneNumber,
      String description,
      String languages,
      String username,
      ScaffoldMessengerState scaffoldKey,
      List price) async {
    print("from register phone auth: $phoneNumber");
    //var completer = Completer<bool>();
    try {
      loading();

      //print(isloading);
      await auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted:
              (PhoneAuthCredential phoneAuthCredential) async {},
          verificationFailed: (FirebaseException exception) {
            loading();
            print(isloading);
            print("verification failed: $exception");
            scaffoldKey.showSnackBar(SnackBar(
              content: Text('${exception.toString()}'),
              duration: Duration(seconds: 5),
            ));
          },
          codeSent: (String verificationid, [int? forceresendingtoken]) async {
            print("from registerPhoneAuth: ${price.map((e) => e).toList()}");
            scaffoldKey.showSnackBar(const SnackBar(
              content: Text('please verify  mobile no to register'),
              duration: Duration(seconds: 5),
            ));
            Navigator.of(context).pushNamed('registerotp', arguments: {
              'phonenumber': phoneNumber,
              "description": description,
              "languages": languages,
              "username": username,
              "price": price
            });
            final prefs = await SharedPreferences.getInstance();
            prefs.setString('verificationid', verificationid);
            loading();
            //print(isloading);
          },
          timeout: const Duration(seconds: 30),
          codeAutoRetrievalTimeout: (String verificationid) {});
      notifyListeners();
    } catch (e) {
      print(e);
      scaffoldKey.showSnackBar(SnackBar(
        content: Text('${e.toString()}'),
        duration: Duration(seconds: 5),
      ));
    }

    //return completer.future;
  }

  void onMakeCall(context, String userId, String username) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ZegoSendCallInvitationButton(
          isVideoCall: false, // set to false for voice call
          invitees: [
            ZegoUIKitUser(id: userId, name: 'Target User'),
          ],
        ),
      ),
    );
  }

  Future<platform.File?> getImageFile(BuildContext context) async {
    var apicalls = Provider.of<ApiCalls>(context, listen: false);
    if (apicalls.userDetails != null) {
      final data = apicalls.userDetails!.data![0];
      if (data.xfile == null) {
        return null;
      }
      final platform.File file = platform.File(data.xfile!.path);
      return file;
    }

    return null;
  }
}
