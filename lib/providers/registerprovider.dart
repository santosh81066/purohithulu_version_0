import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as parser;
import 'package:image_picker/image_picker.dart';

import '../utilities/purohithapi.dart';

class RegisterAsPurohithProvider with ChangeNotifier {
  bool _isLoading = false;
  String _messages = '';
  int _statusCode = 0;

  bool get isLoading => _isLoading;
  String get messages => _messages;
  int get statusCode => _statusCode;

  String generateRandomLetters(int length) {
    var random = Random();
    var letters = List.generate(length, (_) => random.nextInt(26) + 97);
    return String.fromCharCodes(letters);
  }

  Future<int> register({
    // Changed return type to Future<int>
    required String mobileno,
    required String experience,
    required String languages,
    required String userName,
    required BuildContext context,
    required String locationId,
    required List<int> selectedCatId,
    required List<XFile>? imageFileList,
  }) async {
    String randomLetters = generateRandomLetters(10);
    var catIdString = selectedCatId.isNotEmpty
        ? Uri.encodeComponent(selectedCatId.join(","))
        : '';

    var url = "${PurohitApi().baseUrl}${PurohitApi().register}$catIdString/";
    print("Received Category IDs: $selectedCatId");
    var data = {
      "mobileno": mobileno,
      "role": "p",
      "username": userName,
      "userstatus": "0",
      "adhar": "${randomLetters}_adhar",
      "profilepic": "${randomLetters}_profilepic",
      "expirience": experience,
      "lang": languages,
      "isonline": "0",
      "location": locationId
    };

    var separator = '/';
    //var url ="${PurohitApi().baseUrl}${PurohitApi().register}$catIdString$separator";
    Map<String, String> obj = {"attributes": json.encode(data).toString()};

    try {
      _isLoading = true;
      notifyListeners();

      var request = http.MultipartRequest('POST', Uri.parse(url));

      if (imageFileList != null && imageFileList.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath(
          "imagefile[]",
          imageFileList[0].path,
          contentType: parser.MediaType("image", "jpg"),
        ));
      }

      request.fields.addAll(obj);
      final response = await request.send();
      final res = await http.Response.fromStream(response);

      final responseData = json.decode(res.body);

      // _statusCode = responseData['statuscode'];
      //_messages = responseData['messages'];

      _isLoading = false;
      notifyListeners();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('User Registered'),
            //content: Text(_messages),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  // if (_statusCode == 200) {
                  //   Navigator.of(context).pushReplacementNamed('wellcome');
                  //}
                },
              ),
            ],
          );
        },
      );

      return res.statusCode; // Now properly returns an int
    } catch (e, stackTrace) {
      _isLoading = false;
      //_messages = "An error occurred: $e";
      print("Error stack trace: $stackTrace");
      notifyListeners();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error Try Again'),
            //content: Text(_messages)
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

      return 500; // Return an error status code in case of exception
    }
  }
}
