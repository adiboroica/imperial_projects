import 'package:flutter/material.dart';

import '../constants.dart';

class SportDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const SportDropdown({super.key, this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.sports_soccer),
      title: DropdownButton<String>(
        value: value == '' ? null : value,
        hint: const Text('Select sport'),
        items: sports.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class RoleDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const RoleDropdown({super.key, this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.sports),
      title: DropdownButton<String>(
        value: value == '' ? null : value,
        hint: const Text('Select role'),
        items: roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
