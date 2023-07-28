import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import '../controller/apicalls.dart';

import '../controller/auth.dart';
import '../functions/flutterfunctions.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/button.dart';
import '../widgets/text_widget.dart';

class OtpScreen extends StatefulWidget {
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;
  const OtpScreen({super.key, this.scaffoldMessengerKey});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  TextEditingController mobileno = TextEditingController();
  TextEditingController mobile = TextEditingController();

  String registerButton = 'Register';
  String hintMobileNo = 'Please enter mobile no';

  String button = 'send otp';

  @override
  void initState() {
    Provider.of<ApiCalls>(context, listen: false).getCatogories(context);
    Provider.of<ApiCalls>(context, listen: false).getLocation(context);

    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    mobileno.dispose();
    mobile.dispose();

    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ScaffoldMessengerState scaffoldKey =
        widget.scaffoldMessengerKey!.currentState as ScaffoldMessengerState;
    var functions = Provider.of<FlutterFunctions>(context, listen: false);
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 10,
            margin: const EdgeInsets.all(20),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(5),
                  child: TextWidget(hintText: hintMobileNo, controller: mobile),
                ),
                Consumer<FlutterFunctions>(
                  builder: (context, value, child) {
                    return value.isloading
                        ? const CircularProgressIndicator()
                        : Button(
                            buttonname: button,
                            onTap: value.isloading
                                ? null
                                : () {
                                    functions.phoneAuth(
                                        context,
                                        '+91${mobile.text.trim()}',
                                        scaffoldKey);
                                  },
                          );
                  },
                ),
                Button(
                    onTap: () {
                      Navigator.of(context).pushNamed('registeruser');
                    },
                    buttonname: registerButton)
              ],
            ),
          ),
        ],
      )),
    );
  }
}
