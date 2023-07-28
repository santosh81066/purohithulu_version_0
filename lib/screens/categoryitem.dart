import 'package:flutter/material.dart';

class CategoryItem extends StatefulWidget {
  final String title;
  final bool isSelected;
  final Function(bool?) onChanged;
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;

  const CategoryItem({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onChanged,
    required this.controller,
    required this.hintText,
    required this.validator,
  });

  @override
  _CategoryItemState createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CheckboxListTile(
          value: widget.isSelected,
          onChanged: widget.onChanged,
          title: Text(widget.title),
        ),
        TextFormField(
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hintText,
            labelStyle: TextStyle(color: Colors.grey),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
          cursorColor: Colors.grey,
          controller: widget.controller,
        ),
      ],
    );
  }
}
