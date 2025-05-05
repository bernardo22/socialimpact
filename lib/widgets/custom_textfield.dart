// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool isRequired;
  final bool isEmail;
  final bool isNumber;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool obscureText; 
  final bool enableVisibilityToggle; 

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.isRequired = false,
    this.isEmail = false,
    this.isNumber = false,
    this.keyboardType,
    this.validator,
    this.enabled = true,
    this.obscureText = false, 
    this.enableVisibilityToggle = true, 
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscured = true; 

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText; 
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: widget.controller,
        keyboardType: widget.keyboardType ??
            (widget.isNumber
                ? TextInputType.number
                : widget.isEmail
                    ? TextInputType.emailAddress
                    : TextInputType.text),
        obscureText: widget.obscureText && _isObscured, 
        decoration: InputDecoration(
          labelText: widget.label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          suffixIcon: widget.obscureText && widget.enableVisibilityToggle
              ? IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                )
              : null, // No suffix icon if visibility toggle is disabled
        ),
        validator: widget.validator ??
            (value) {
              if (widget.isRequired && (value == null || value.trim().isEmpty)) {
                return 'O campo "${widget.label}" é obrigatório.';
              }
              if (widget.isEmail &&
                  value != null &&
                  value.isNotEmpty &&
                  !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                      .hasMatch(value)) {
                return 'Insira um email válido.';
              }
              if (widget.isNumber &&
                  value != null &&
                  value.isNotEmpty &&
                  double.tryParse(value) == null) {
                return 'Insira um número válido.';
              }
              return null;
            },
        enabled: widget.enabled,
      ),
    );
  }
}