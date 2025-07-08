import 'package:flutter/material.dart';

class CommonTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final void Function(String)? onChanged;
  final int? maxLength;

  const CommonTextField({
    super.key,
    this.controller,
    this.hintText = '',
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardAppearance: Brightness.dark,
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      maxLength: maxLength,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 20,
        ),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.5),
            width: 0.5,
          ),
        ),
      ),
    );
  }
}
