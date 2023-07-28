import 'dart:io';

import '../controller/apicalls.dart';
import '../controller/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../functions/flutterfunctions.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var flutterFunction = Provider.of<FlutterFunctions>(context);
    var apicalls = Provider.of<ApiCalls>(context);
    return Drawer(
      child: Column(
        children: [
          AppBar(
            actions: [
              Row(
                children: [
                  Text('Welcome: ${apicalls.userDetails!.data![0].username} '),
                  FutureBuilder<File?>(
                    future: flutterFunction.getImageFile(context),
                    builder:
                        (BuildContext context, AsyncSnapshot<File?> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData && snapshot.data != null) {
                          final file = snapshot.data!;

                          return CircleAvatar(
                            radius: 50.0,
                            backgroundImage: FileImage(file),
                          );
                        } else {
                          return const CircleAvatar(
                            radius: 50.0,
                            child: Icon(Icons.person, size: 50.0),
                          );
                        }
                      } else {
                        return const CircleAvatar(
                          radius: 50.0,
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Booking History"),
            onTap: () {
              Navigator.of(context).pushNamed('bookingHistory');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("My Profile"),
            onTap: () {
              //Navigator.of(context).pushReplacementNamed('users');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Contact Us"),
            onTap: () {
              // Navigator.of(context)
              //     .pushReplacementNamed(UserProductsScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text("Logout"),
            onTap: () async {
              //Navigator.pop(context);
              // Navigator.of(context).pushReplacementNamed('/');
              await Provider.of<Auth>(context, listen: false)
                  .logout(context)
                  .then((value) => Navigator.of(context)
                      .pushNamedAndRemoveUntil(
                          '/', (Route<dynamic> route) => false));
            },
          ),
        ],
      ),
    );
  }
}
