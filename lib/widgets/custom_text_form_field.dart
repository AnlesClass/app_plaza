import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final int maxLength;
  final int maxLines;
  final IconData? icon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomTextFormField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.maxLength = 64,
    this.maxLines = 1,
    this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    // Para alternar visibilidad. Estado simple.
    final ValueNotifier<bool> obscureTextNotifier = ValueNotifier<bool>(
      isPassword,
    );

    return AnimatedBuilder(
      animation: Listenable.merge([controller, obscureTextNotifier]),
      builder: (context, child) {
        final bool isObscured = obscureTextNotifier.value;

        return TextFormField(
          controller: controller,
          maxLength: maxLength,
          maxLines: isPassword ? 1 : maxLines,
          obscureText: isPassword ? isObscured : false,
          keyboardType: keyboardType,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
              color: Color(0xFF701321),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            prefixIcon: icon != null
                ? Icon(icon, color: const Color(0xFF701321), size: 20)
                : null,

            // Ícono Suffix
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      isObscured
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () => obscureTextNotifier.value = !isObscured,
                  )
                : (controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.cancel_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: () => controller.clear(),
                        )
                      : null),

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            counterText: "${controller.text.length}/$maxLength",

            // Borde normal y enfocado
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF701321), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF701321), width: 2),
            ),

            // Bordes de error: normal y enfocado
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        );
      },
    );
  }
}
