import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:keep_playing_frontend/repositories/user_repository.dart';
import 'package:keep_playing_frontend/models/event.dart';
import 'package:keep_playing_frontend/models/user.dart';
import 'package:keep_playing_frontend/repositories/organiser_repository.dart';
import 'package:keep_playing_frontend/widgets/app_theme.dart';
import 'package:keep_playing_frontend/widgets/confirmation_dialog.dart';
import 'package:keep_playing_frontend/widgets/event_form.dart';
import 'package:keep_playing_frontend/widgets/exit_guard.dart';
import 'package:keep_playing_frontend/widgets/loading_indicator.dart';
import 'package:keep_playing_frontend/widgets/user_info_tiles.dart';

import 'package:keep_playing_frontend/pages/organiser/events/events_cubit.dart';

class ManageEventPage extends StatefulWidget {
  final Event event;
  final EventsCubit eventsCubit;

  const ManageEventPage({
    super.key,
    required this.event,
    required this.eventsCubit,
  });

  @override
  State<ManageEventPage> createState() => _ManageEventPageState();
}

class _ManageEventPageState extends State<ManageEventPage> {
  final _formKey = GlobalKey<FormState>();
  late final EventFormData _data;
  bool _isSubmitting = false;
  User? _coachUser;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _data = EventFormData(
      sport: e.sport.isNotEmpty ? e.sport : null,
      role: e.role.isNotEmpty ? e.role : null,
      date: e.date,
      startTime: e.startTime,
      endTime: e.endTime,
      flexibleStartTime: e.flexibleStartTime,
      flexibleEndTime: e.flexibleEndTime,
      recurring: e.recurring,
      recurringEndDate: e.recurringEndDate,
      name: e.name,
      location: e.location,
      details: e.details,
      price: e.price.toString(),
    );
    _loadCoach();
  }

  Future<void> _loadCoach() async {
    if (widget.event.coachPk == null) return;
    try {
      final userRepository = context.read<UserRepository>();
      final coach = await userRepository.getUser(widget.event.coachPk!);
      if (mounted) setState(() => _coachUser = coach);
    } catch (_) {
      // Coach info is optional display; ignore load failures.
    }
  }

  @override
  void dispose() {
    _data.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExitGuard(
      title: 'Discard Changes?',
      content: 'Any unsaved changes will be lost.',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Event'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: _isSubmitting
            ? const LoadingScreen()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_coachUser != null) ...[
                      UserInfoListTile(
                        user: _coachUser!,
                        event: widget.event,
                        type: UserInfoType.coach,
                      ),
                      const Divider(),
                    ],
                    EventFormFields(
                      data: _data,
                      formKey: _formKey,
                      onChanged: () => setState(() {}),
                    ),
                    const SizedBox(height: AppTheme.paddingLarge),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.calendar_today, color: Colors.white),
                      label: const Text(
                        'Add to Calendar',
                        style: TextStyle(
                          fontSize: AppTheme.buttonFontSize,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: _openGoogleCalendar,
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),
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
                    const SizedBox(height: AppTheme.paddingMedium),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.cancelColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _handleCancel,
                      child: const Text(
                        'Cancel Event',
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

  Future<void> _openGoogleCalendar() async {
    final start = DateTime(
      _data.date.year, _data.date.month, _data.date.day,
      _data.startTime.hour, _data.startTime.minute,
    );
    final end = DateTime(
      _data.date.year, _data.date.month, _data.date.day,
      _data.endTime.hour, _data.endTime.minute,
    );
    final dateFormat = DateFormat("yyyyMMdd'T'HHmmss");
    final url = 'https://www.google.com/calendar/render?action=TEMPLATE'
        '&text=${Uri.encodeComponent(widget.event.name)}'
        '&dates=${dateFormat.format(start)}/${dateFormat.format(end)}'
        '&location=${Uri.encodeComponent(_data.locationController.text)}'
        '&details=${Uri.encodeComponent(_data.detailsController.text)}';

    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_data.sport == null || _data.role == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select sport and role')),
      );
      return;
    }
    if (!_data.isEndTimeAfterStartTime()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const ConfirmationDialog(title: 'Save changes?'),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isSubmitting = true);

    final updatedEvent = NewEvent(
      name: _data.nameController.text.trim(),
      location: _data.locationController.text.trim(),
      details: _data.detailsController.text.trim(),
      sport: _data.sport!,
      role: _data.role!,
      date: _data.date,
      startTime: _data.startTime,
      endTime: _data.endTime,
      flexibleStartTime: _data.flexibleStartTime,
      flexibleEndTime: _data.flexibleEndTime,
      price: int.parse(_data.priceController.text.trim()),
      coach: widget.event.coach,
      recurring: _data.recurring,
      recurringEndDate: _data.recurringEndDate,
      creationStarted: widget.event.creationStarted,
      creationEnded: DateTime.now(),
    );

    try {
      final organiserRepository = context.read<OrganiserRepository>();
      await organiserRepository.updateEvent(
        event: widget.event,
        newEvent: updatedEvent,
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      await showDialog(
        context: context,
        builder: (_) => const RequestFailedDialog(),
      );
    }
  }

  Future<void> _handleCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const ConfirmationDialog(
        title: 'Cancel Event?',
        content: 'This action cannot be undone.',
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isSubmitting = true);

    try {
      final organiserRepository = context.read<OrganiserRepository>();
      await organiserRepository.deleteEvent(event: widget.event);

      if (!mounted) return;
      setState(() => _isSubmitting = false);
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      await showDialog(
        context: context,
        builder: (_) => const RequestFailedDialog(),
      );
    }
  }
}
