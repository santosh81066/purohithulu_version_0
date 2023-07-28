import 'dart:async';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:purohithulu/functions/flutterfunctions.dart';
//import 'package:purohithulu/controller/fluterr_functions.dart';
import 'package:purohithulu/widgets/button.dart';
import 'package:purohithulu/widgets/text_widget.dart';
import 'package:purohithulu/controller/apicalls.dart';

class InsertPan extends StatelessWidget {
  const InsertPan(
      {super.key,
      this.catergoryType,
      this.categoryName,
      this.buttonName,
      this.imageIcon,
      this.handlerone,
      this.insertCategory,
      this.label,
      this.index});
  final TextEditingController? catergoryType;
  final String? categoryName;
  final String? buttonName;
  final String? label;
  final Function? imageIcon;
  final Function? handlerone;
  final Function? insertCategory;
  final int? index;
  @override
  Widget build(BuildContext context) {
    var flutterFunctions = Provider.of<FlutterFunctions>(context);
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(5.0),
          child: TextWidget(
            controller: catergoryType!,
            hintText: categoryName,
          ),
        ),
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
