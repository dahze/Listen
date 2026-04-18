import 'package:flutter/material.dart';
import 'package:listen/core/constants/app_colors.dart';

class AuthFormField extends StatelessWidget {
  final String label;
  final String hint;
  final bool obscure;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const AuthFormField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.obscure = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(color: AppColors.kTextPrimary),
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }
}
