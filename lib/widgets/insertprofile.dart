import 'dart:async';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import '../functions/flutterfunctions.dart';

class InsertProfile extends StatelessWidget {
  const InsertProfile(
      {super.key,
      this.buttonName,
      this.imageIcon,
      this.insertCategory,
      this.label,
      this.index});

  final String? buttonName;
  final String? label;
  final Function? imageIcon;

  final Function? insertCategory;
  final int? index;
  @override
  Widget build(BuildContext context) {
    var flutterFunctions = Provider.of<FlutterFunctions>(context);
    return Column(
      children: [
        flutterFunctions.imageFileList!.length == 2
            ? Container(
                width: 30,
                child: Image.file(
                    File(flutterFunctions.imageFileList![index!].path)))
            : TextButton.icon(
                onPressed: () {
                  imageIcon!();
                },
                icon: Icon(Icons.image),
                label: Text(label!)),
        flutterFunctions.imageFileList!.length == 2
            ? TextButton(
                onPressed: () {
                  imageIcon!();
                },
                child: Text("Change Icon"))
            : Container(),
      ],
    );
  }
}
