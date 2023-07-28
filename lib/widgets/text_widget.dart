import 'package:flutter/material.dart';

class TextWidget extends StatelessWidget {
  const TextWidget(
      {super.key,
      required this.controller,
      required this.hintText,
      this.ofsecuretext,
      this.initialvalue});
  final TextEditingController controller;
  final String? hintText;
  final bool? ofsecuretext;
  final String? initialvalue;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialvalue,
      obscureText: ofsecuretext == null ? false : ofsecuretext!,
      controller: controller,
      decoration: InputDecoration(
          border: const OutlineInputBorder(), hintText: hintText),
    );
  }
}
