import 'package:flutter/material.dart';
import 'package:praxis/common/style/design_tokens.dart';

/// 统一的输入框组件
class PraxisTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  const PraxisTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.focusNode,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      focusNode: focusNode,
      textInputAction: textInputAction,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(suffixIcon),
                onPressed: onSuffixIconTap,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          borderSide: BorderSide(
            color: theme.dividerColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          borderSide: BorderSide(
            color: DesignTokens.primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          borderSide: BorderSide(
            color: DesignTokens.errorColor,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing4,
          vertical: DesignTokens.spacing4,
        ),
      ),
    );
  }
}

