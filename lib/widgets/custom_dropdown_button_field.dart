import 'package:app_plaza_flutter/themes/app_theme.dart';
import 'package:flutter/material.dart';

class CustomDropdownButtonFormField<T> extends StatefulWidget {
  final String hint;
  final T? initialValue;
  final List<T> items;
  final void Function(T? value)? onChanged;
  final String? Function(T? value)? validator;
  final Icon icon;

  const CustomDropdownButtonFormField({
    super.key,
    required this.hint,
    required this.initialValue,
    required this.items,
    this.validator,
    this.onChanged,
    this.icon = const Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
  });

  @override
  State<CustomDropdownButtonFormField<T>> createState() =>
      _CustomDropdownButtonFormFieldState<T>();
}

class _CustomDropdownButtonFormFieldState<T>
    extends State<CustomDropdownButtonFormField<T>> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      hint: Text(widget.hint),
      initialValue: widget.initialValue,
      items: widget.items.map((T element) {
        return DropdownMenuItem(
          value: element,
          child: Text(element.toString()),
        );
      }).toList(),
      onChanged: widget.onChanged,
      validator: widget.validator,
      icon: widget.icon,
    );
  }
}
