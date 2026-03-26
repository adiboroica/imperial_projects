import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:keep_playing_frontend/api/organiser.dart';
import 'package:keep_playing_frontend/api/users.dart';
import 'package:keep_playing_frontend/models/user.dart';
import 'package:keep_playing_frontend/state/auth_cubit.dart';
import 'package:keep_playing_frontend/widgets/app_theme.dart';
import 'package:keep_playing_frontend/widgets/confirmation_dialog.dart';
import 'package:keep_playing_frontend/widgets/error_display.dart';
import 'package:keep_playing_frontend/widgets/exit_guard.dart';
import 'package:keep_playing_frontend/widgets/loading_indicator.dart';

import 'organiser_cubit.dart';

class BlockedPage extends StatefulWidget {
  const BlockedPage({super.key});

  @override
  State<BlockedPage> createState() => _BlockedPageState();
}

class _BlockedPageState extends State<BlockedPage> {
  List<User>? _coaches;
  late Set<int> _selectedPks;
  String? _error;
  bool _loading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedPks = context.read<OrganiserCubit>().state.blocked.toSet();
    _loadCoaches();
  }

  Future<void> _loadCoaches() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final apiUsers = ApiUsers(client: context.read<AuthCubit>().apiClient);
      final allUsers = await apiUsers.getAllUsers();
      final coaches = allUsers.where((u) => u.isCoach).toList();

      if (mounted) {
        setState(() {
          _coaches = coaches;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExitGuard(
      title: 'Discard Changes?',
      content: 'Any unsaved changes to your blocked list will be lost.',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Blocked'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading || _isSaving) return const LoadingIndicator();

    if (_error != null) {
      return ErrorDisplay(message: _error!, onRetry: _loadCoaches);
    }

    final coaches = _coaches!;
    if (coaches.isEmpty) {
      return const Center(child: Text('No coaches found'));
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: coaches.length,
            itemBuilder: (context, index) {
              final coach = coaches[index];
              return CheckboxListTile(
                title: Text(coach.fullName),
                subtitle: Text(coach.username),
                secondary: coach.verified
                    ? const Icon(Icons.verified, color: AppTheme.primaryColor)
                    : null,
                value: _selectedPks.contains(coach.pk),
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      _selectedPks.add(coach.pk);
                    } else {
                      _selectedPks.remove(coach.pk);
                    }
                  });
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
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
          ),
        ),
      ],
    );
  }

  Future<void> _handleSave() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const ConfirmationDialog(title: 'Save blocked list?'),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isSaving = true);

    try {
      final apiOrganiser = ApiOrganiser(client: context.read<AuthCubit>().apiClient);
      final response = await apiOrganiser.updateBlocked(_selectedPks.toList());

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
