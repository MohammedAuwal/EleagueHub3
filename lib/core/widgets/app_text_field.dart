import 'package:flutter/material.dart';

import 'glass.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Glass(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: 16,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        onChanged: onChanged,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelStyle: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.75),
          ),
          hintStyle: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.45),
          ),
        ),
      ),
    );
  }
}
