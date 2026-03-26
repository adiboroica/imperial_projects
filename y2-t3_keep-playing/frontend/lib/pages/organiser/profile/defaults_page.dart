import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:keep_playing_frontend/api/organiser.dart';
import 'package:keep_playing_frontend/models/organiser.dart';
import 'package:keep_playing_frontend/state/auth_cubit.dart';
import 'package:keep_playing_frontend/widgets/app_theme.dart';
import 'package:keep_playing_frontend/widgets/confirmation_dialog.dart';
import 'package:keep_playing_frontend/widgets/exit_guard.dart';
import 'package:keep_playing_frontend/widgets/loading_indicator.dart';
import 'package:keep_playing_frontend/widgets/sport_role_dropdowns.dart';

import 'organiser_cubit.dart';

class DefaultsPage extends StatefulWidget {
  const DefaultsPage({super.key});

  @override
  State<DefaultsPage> createState() => _DefaultsPageState();
}

class _DefaultsPageState extends State<DefaultsPage> {
  late String? _sport;
  late String? _role;
  late final TextEditingController _locationController;
  late final TextEditingController _priceController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final org = context.read<OrganiserCubit>().state;
    _sport = org.defaultSport.isNotEmpty ? org.defaultSport : null;
    _role = org.defaultRole.isNotEmpty ? org.defaultRole : null;
    _locationController = TextEditingController(text: org.defaultLocation);
    _priceController = TextEditingController(
      text: org.defaultPrice?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExitGuard(
      title: 'Discard Changes?',
      content: 'Any unsaved changes to your defaults will be lost.',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Defaults'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: _isSaving
            ? const LoadingScreen()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppTheme.paddingMedium),
                    SportDropdown(
                      value: _sport,
                      onChanged: (value) => setState(() => _sport = value),
                    ),
                    RoleDropdown(
                      value: _role,
                      onChanged: (value) => setState(() => _role = value),
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Default Location',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Default Price',
                        prefixIcon: Icon(Icons.price_change),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: AppTheme.paddingLarge),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _handleSave,
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: AppTheme.buttonFontSize,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _handleSave() async {
    final priceText = _priceController.text.trim();
    int? price;
    if (priceText.isNotEmpty) {
      price = int.tryParse(priceText);
      if (price == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid price')),
        );
        return;
      }
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const ConfirmationDialog(title: 'Save defaults?'),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isSaving = true);

    final defaults = OrganiserDefaults(
      defaultSport: _sport ?? '',
      defaultRole: _role ?? '',
      defaultLocation: _locationController.text.trim(),
      defaultPrice: price,
    );

    try {
      final apiOrganiser = ApiOrganiser(client: context.read<AuthCubit>().apiClient);
      final response = await apiOrganiser.updateDefaults(defaults: defaults);

      if (!mounted) return;
      setState(() => _isSaving = false);

      if (response.statusCode == 200) {
        await context.read<OrganiserCubit>().reload();
        if (mounted) Navigator.of(context).pop();
      } else {
        await showDialog(
          context: context,
          builder: (_) => const RequestFailedDialog(),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      await showDialog(
        context: context,
        builder: (_) => const RequestFailedDialog(),
      );
    }
  }
}
