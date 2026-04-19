import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:keep_playing_frontend/models/event.dart';
import 'package:keep_playing_frontend/models/organiser.dart';
import 'package:keep_playing_frontend/repositories/organiser_repository.dart';
import 'package:keep_playing_frontend/widgets/app_theme.dart';
import 'package:keep_playing_frontend/widgets/confirmation_dialog.dart';
import 'package:keep_playing_frontend/widgets/event_form.dart';
import 'package:keep_playing_frontend/widgets/exit_guard.dart';
import 'package:keep_playing_frontend/widgets/loading_indicator.dart';

import 'package:keep_playing_frontend/pages/organiser/events/events_cubit.dart';

class NewEventPage extends StatefulWidget {
  final EventsCubit eventsCubit;
  final Organiser organiser;
  final DateTime? initialDate;

  const NewEventPage({
    super.key,
    required this.eventsCubit,
    required this.organiser,
    this.initialDate,
  });

  @override
  State<NewEventPage> createState() => _NewEventPageState();
}

class _NewEventPageState extends State<NewEventPage> {
  final _formKey = GlobalKey<FormState>();
  late final EventFormData _data;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final org = widget.organiser;
    final today = DateUtils.dateOnly(DateTime.now());
    final initial = widget.initialDate ?? today;
    _data = EventFormData(
      sport: org.defaultSport.isNotEmpty ? org.defaultSport : null,
      role: org.defaultRole.isNotEmpty ? org.defaultRole : null,
      date: initial.isBefore(today) ? today : initial,
      location: org.defaultLocation,
      price: org.defaultPrice?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _data.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExitGuard(
      title: 'Discard New Event?',
      content: 'Any information entered will be lost.',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('New Event'),
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
                    EventFormFields(
                      data: _data,
                      formKey: _formKey,
                      onChanged: () => setState(() {}),
                    ),
                    const SizedBox(height: AppTheme.paddingLarge),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _handleSubmit,
                      child: const Text(
                        'Create Event',
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

  Future<void> _handleSubmit() async {
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
      builder: (_) => const ConfirmationDialog(title: 'Create this event?'),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isSubmitting = true);

    final now = DateTime.now();
    final newEvent = NewEvent(
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
      coach: false,
      recurring: _data.recurring,
      recurringEndDate: _data.recurringEndDate,
      creationStarted: now,
      creationEnded: now,
    );

    try {
      final organiserRepository = context.read<OrganiserRepository>();
      await organiserRepository.addEvent(newEvent: newEvent);

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
