import 'package:flutter/material.dart';
import 'package:flutter_hex_color/flutter_hex_color.dart';

class Button extends StatelessWidget {
  final String? buttonname;
  final onTap;
  final double? height;
  final double? width;
  final double? fontSize;
  final double? buttonTopMargin;
  final double? buttonBottomMargin;
  final double? buttonRightMargin;
  final double? buttonLeftMargin;
  final double? circularRadius;
  const Button(
      {Key? key,
      this.buttonBottomMargin = 15,
      this.buttonname,
      this.onTap,
      this.height = 50,
      this.width, //140
      this.fontSize = 20,
      this.buttonTopMargin = 15,
      this.buttonLeftMargin = 15,
      this.buttonRightMargin = 15,
      this.circularRadius = 30})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          top: buttonTopMargin!,
          bottom: buttonBottomMargin!,
          left: buttonLeftMargin!,
          right: buttonRightMargin!),
      height: height,
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [HexColor('#fcba03'), HexColor('#fc9403')],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(circularRadius!),
      ),
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
          shadowColor: MaterialStateProperty.all(Colors.transparent),
        ),
        onPressed: onTap,
        child: Text(
          buttonname!,
          style: TextStyle(fontSize: fontSize, color: Colors.white),
        ),
      ),
    );
  }
}
