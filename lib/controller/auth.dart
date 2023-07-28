import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:purohithulu/utilities/purohithapi.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';

import '../screens/wellcomescreen.dart';
import 'apicalls.dart';

class Auth extends ChangeNotifier {
  var isloading = false;
  String? verificationId;
  String? fToken;
  String? frefreshToken;
  String? userId;
  int? sessionId;
  String? accessToken;
  DateTime? accessTokenExpiryDate;
  String? refreshToken;
  DateTime? refreshTokenExpiryDate;
  Timer? authTimer;
  String? messages;
  FirebaseAuth auth = FirebaseAuth.instance;
  String? get accesstoken {
    if (accessTokenExpiryDate != null &&
        accessTokenExpiryDate!.isAfter(DateTime.now()) &&
        accessToken != null) {
      return accessToken;
    }
    return null;
  }

  String? get refreshtoken {
    if (refreshTokenExpiryDate != null &&
        refreshTokenExpiryDate!.isAfter(DateTime.now()) &&
        refreshToken != null) {
      return refreshToken;
    }
    return null;
  }

  bool get authorized {
    return accesstoken != null;
  }

  loading() {
    isloading = !isloading;
    print(isloading);
    notifyListeners();
  }

  bool get isAuth {
    return refreshtoken != null;
  }

  Future<bool> tryAutoLogin() async {
    print('try auto login started');

    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractData =
        json.decode(prefs.getString('userData')!) as Map<String, dynamic>;

    final expiryDate = DateTime.parse(extractData['refreshExpiry']);
    final accessExpiry = DateTime.parse(extractData['accessTokenExpiry']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    sessionId = extractData['sessionId'];
    refreshToken = extractData['refreshToken'];
    accessToken = extractData['accessToken'];
    refreshTokenExpiryDate = expiryDate;
    accessTokenExpiryDate = accessExpiry;
    fToken = prefs.getString('firebaseToken');
    print('from try autologiin:$fToken');

    print('access token:$accessToken');
    notifyListeners();
    //autologout();

    return true;
  }

  Future<String> restoreAccessToken(BuildContext context) async {
    print('restoreAccessToken is started');
    final url = '${PurohitApi().baseUrl}${PurohitApi().login}/$sessionId';
    final prefs = await SharedPreferences.getInstance();
    try {
      loading();
      var response = await http.patch(Uri.parse(url),
          headers: {
            'Authorization': accessToken!,
            'Content-Type': 'application/json; charset=UTF-8'
          },
          body: json.encode({"refresh_token": refreshToken}));
      print('restore access token:${response.statusCode}');
      var userDetails = json.decode(response.body);
      switch (response.statusCode) {
        case 401:
          logout(context);
          tryAutoLogin();
          loading();
          notifyListeners();
          break;
        case 200:
          sessionId = userDetails['data']['session_id'];
          accessToken = userDetails['data']['access_token'];
          accessTokenExpiryDate = DateTime.now().add(
              Duration(seconds: userDetails['data']['access_token_expiry']));
          refreshToken = userDetails['data']['refresh_token'];
          refreshTokenExpiryDate = DateTime.now().add(
              Duration(seconds: userDetails['data']['refresh_token_expiry']));

          final userData = json.encode({
            'sessionId': sessionId,
            'refreshToken': refreshToken,
            'refreshExpiry': refreshTokenExpiryDate!.toIso8601String(),
            'accessToken': accessToken,
            'accessTokenExpiry': accessTokenExpiryDate!.toIso8601String()
          });
          prefs.setString('userData', userData);
          loading();
          notifyListeners();
      }
      print('from restore access token:$userDetails');
    } catch (e) {
      print(e);
    }
    print('restoreaccesstoken:$accessToken');
    return accessToken!;
  }

  Future purohitLogin(String mobile, BuildContext context, String uId) async {
    final url = PurohitApi().baseUrl + PurohitApi().login;

    print(mobile);

    loading();

    var response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({'mobileno': mobile}));
    loading();
    var userDetails = json.decode(response.body);
    var statuscode = response.statusCode;
    print(userDetails);
    switch (response.statusCode) {
      case 400:
        messages = userDetails['messages'].toString();
        break;
      case 201:
        userId = uId;
        messages = userDetails['messages'].toString();
        sessionId = userDetails['data']['session_id'];
        accessToken = userDetails['data']['access_token'];
        accessTokenExpiryDate = DateTime.now().add(
          Duration(seconds: userDetails['data']['access_token_expires_in']),
        );
        refreshToken = userDetails['data']['refresh_token'];
        refreshTokenExpiryDate = DateTime.now().add(
          Duration(seconds: userDetails['data']['refresh_token_expires_in']),
        );

        //print('this is from Auth response is:$accessToken');
        notifyListeners();
        final prefs = await SharedPreferences.getInstance();
        final userData = json.encode({
          'userId': userId,
          'frefreshtoken': frefreshToken,
          'sessionId': sessionId,
          'refreshToken': refreshToken,
          'refreshExpiry': refreshTokenExpiryDate!.toIso8601String(),
          'accessToken': accessToken,
          'accessTokenExpiry': accessTokenExpiryDate!.toIso8601String()
        });

        Future.delayed(Duration.zero).then((value) {
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => const WellcomeScreen()));
        });

        //autologout();

        await prefs.setString('userData', userData);
        break;
    }
    return statuscode;
  }

  Future<void> logout(BuildContext cont) async {
    var apicalls = Provider.of<ApiCalls>(cont, listen: false);
    print('logout started');
    await apicalls.toggleOorF(apicalls.userDetails!.data![0].id!, cont, false);
    final url = '${PurohitApi().baseUrl}${PurohitApi().session}/$sessionId';
    print(url);
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

          req.headers['Authorization'] = accessToken;
        }
      },
    );
    var response = await client.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': accessToken!
      },
    );

    var userStatus = json.decode(response.body);
    print(userStatus);

    if (authTimer != null) {
      authTimer!.cancel();
      authTimer = null;
    }
    print(userStatus);
    refreshToken = null;
    refreshTokenExpiryDate = null;

    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  Future<void> signInWithPhoneNumber(String smsCode, BuildContext context,
      String phoneNumber, ScaffoldMessengerState scaffoldKey) async {
    final prefs = await SharedPreferences.getInstance();
    verificationId = prefs.getString('verificationid');
    var authentication = Provider.of<Auth>(context, listen: false);

    try {
      loading();
      AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId!, smsCode: smsCode);

      await auth.signInWithCredential(credential).then((value) async {
        if (value.user != null) {
          var user = auth.currentUser!;
          fToken = user.phoneNumber;
          print('from auth $fToken');
          await prefs.setString('firebaseToken', fToken!);
          userId = value.user!.uid;
          print('this is from signInWithCredential$value');
          user.getIdToken().then((value) => {fToken = value});

          frefreshToken = value.user!.refreshToken;

          await authentication
              .purohitLogin(phoneNumber, context, value.user!.uid)
              .then((response) {
            switch (response) {
              case 400:
                scaffoldKey.showSnackBar(SnackBar(
                  content: Text('${authentication.messages}'),
                  duration: Duration(seconds: 5),
                ));
                break;
              case 201:
                scaffoldKey.showSnackBar(SnackBar(
                  content: Text('${authentication.messages}'),
                  duration: Duration(seconds: 5),
                ));
            }
          });
          print("Verification Successful");
        }
        loading();
      });

      notifyListeners();
    } catch (e) {
      loading();
    }
  }

  Future<void> registerWithPhoneNumber(
      String smsCode,
      BuildContext context,
      String phoneNumber,
      String description,
      String languages,
      String userName,
      ScaffoldMessengerState scaffoldKey,
      List prices) async {
    final prefs = await SharedPreferences.getInstance();

    verificationId = prefs.getString('verificationid');
    var authentication = Provider.of<Auth>(context, listen: false);
    var apiCalls = Provider.of<ApiCalls>(context, listen: false);
    // var phoneNumber = prefs.getString('phoneNumber');
    print(phoneNumber);
    //print("hello $verificationId");
    try {
      loading();
      AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId!, smsCode: smsCode);

      await auth.signInWithCredential(credential).then((value) async {
        if (value.user != null) {
          var user = auth.currentUser!;
          fToken = await user.getIdToken();
          userId = value.user!.uid;
          // print('this is from signInWithCredential$value');

          frefreshToken = value.user!.refreshToken;

          await apiCalls
              .register("$phoneNumber", description, languages, userName,
                  context, prices)
              .then((response) async {
            switch (response) {
              case 400:
                scaffoldKey.showSnackBar(SnackBar(
                  content: Text('${authentication.messages}'),
                  duration: Duration(seconds: 5),
                ));
                break;
              case 201:
                user.getIdToken().then((value) => {fToken = value});
                final firebaseUrl =
                    '${PurohitApi().firebaseUsersUrl}?auth=$fToken';
                var firebaseresponse = await http.post(Uri.parse(firebaseUrl),
                    body: json.encode({
                      'createdby': userId,
                      'username': userName,
                      'status': apiCalls.users![0]['isonline'],
                      "role": "p",
                    }));
                var firebaseDetails = json.decode(firebaseresponse.body);
                print(firebaseDetails);
                scaffoldKey.showSnackBar(SnackBar(
                  content: Text('${authentication.messages}'),
                  duration: Duration(seconds: 5),
                ));
            }
          });
          print("Verification Successful");
        }
        loading();
      });

      notifyListeners();
    } catch (e) {
      loading();
    }
  }
}
