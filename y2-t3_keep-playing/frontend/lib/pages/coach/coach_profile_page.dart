import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:keep_playing_frontend/state/auth_cubit.dart';
import 'package:keep_playing_frontend/widgets/app_theme.dart';

class CoachProfilePage extends StatelessWidget {
  const CoachProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().currentUser;

    if (user == null) {
      return const Center(child: Text('No user data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.person, size: 80, color: AppTheme.primaryColor),
          const SizedBox(height: AppTheme.paddingLarge),
          _ReadOnlyField(label: 'Username', value: user.username),
          const SizedBox(height: AppTheme.paddingMedium),
          _ReadOnlyField(label: 'Email', value: user.email),
          const SizedBox(height: AppTheme.paddingMedium),
          _ReadOnlyField(label: 'First Name', value: user.firstName),
          const SizedBox(height: AppTheme.paddingMedium),
          _ReadOnlyField(label: 'Last Name', value: user.lastName),
          const SizedBox(height: AppTheme.paddingMedium),
          _ReadOnlyField(label: 'Location', value: user.location),
        ],
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;

  const _ReadOnlyField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
