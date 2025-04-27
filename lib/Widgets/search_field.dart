import 'package:besodatahub/Widgets/Prebuilds/textfield.dart';
import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final TextEditingController ctrl;
  final bool enabled;
  const SearchField({super.key, required this.enabled, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return MyTextField(
      enabled: enabled,
      outsidePadding: const EdgeInsets.all(8),
      controller: ctrl,
      label: "Suche...",
      style: themeData.textTheme.bodySmall,
      maxLines: 1,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.never,
        fillColor: Colors.grey.shade100,
      ),
    );
  }
}
