import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:keep_playing_frontend/api/organiser.dart';
import 'package:keep_playing_frontend/models/event.dart';
import 'package:keep_playing_frontend/models/organiser.dart';
import 'package:keep_playing_frontend/state/auth_cubit.dart';
import 'package:keep_playing_frontend/widgets/app_theme.dart';
import 'package:keep_playing_frontend/widgets/confirmation_dialog.dart';
import 'package:keep_playing_frontend/widgets/exit_guard.dart';
import 'package:keep_playing_frontend/widgets/loading_indicator.dart';
import 'package:keep_playing_frontend/widgets/sport_role_dropdowns.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'events_cubit.dart';

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
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _detailsController = TextEditingController();
  final _priceController = TextEditingController();

  late String? _sport;
  late String? _role;
  late DateTime _date;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  bool _recurring = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final org = widget.organiser;
    _sport = org.defaultSport.isNotEmpty ? org.defaultSport : null;
    _role = org.defaultRole.isNotEmpty ? org.defaultRole : null;
    _locationController.text = org.defaultLocation;
    if (org.defaultPrice != null) {
      _priceController.text = org.defaultPrice.toString();
    }
    _date = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _detailsController.dispose();
    _priceController.dispose();
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Event Name',
                          prefixIcon: Icon(Icons.title),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an event name';
                          }
                          return null;
                        },
                      ),
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
                          labelText: 'Location',
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a location';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),
                      TextFormField(
                        controller: _detailsController,
                        decoration: const InputDecoration(
                          labelText: 'Details',
                          prefixIcon: Icon(Icons.details),
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),
                      ListTile(
                        leading: const Icon(Icons.date_range),
                        title: Text('Date: ${DateFormat('MMMM dd, yyyy').format(_date)}'),
                        onTap: _pickDate,
                      ),
                      ListTile(
                        leading: const Icon(Icons.access_time),
                        title: Text('Start Time: ${_formatTime(_startTime)}'),
                        onTap: () => _pickTime(isStart: true),
                      ),
                      ListTile(
                        leading: const Icon(Icons.access_time),
                        title: Text('End Time: ${_formatTime(_endTime)}'),
                        onTap: () => _pickTime(isStart: false),
                      ),
                      SwitchListTile(
                        title: const Text('Recurring'),
                        secondary: const Icon(Icons.repeat),
                        value: _recurring,
                        onChanged: (value) => setState(() => _recurring = value),
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price',
                          prefixIcon: Icon(Icons.price_change),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a price';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
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
      ),
    );
  }

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_sport == null || _role == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select sport and role')),
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
      name: _nameController.text.trim(),
      location: _locationController.text.trim(),
      details: _detailsController.text.trim(),
      sport: _sport!,
      role: _role!,
      date: _date,
      startTime: _startTime,
      endTime: _endTime,
      flexibleStartTime: _startTime,
      flexibleEndTime: _endTime,
      price: int.parse(_priceController.text.trim()),
      coach: false,
      recurring: _recurring,
      creationStarted: now,
      creationEnded: now,
    );

    try {
      final apiOrganiser = ApiOrganiser(client: context.read<AuthCubit>().apiClient);
      final response = await apiOrganiser.addEvent(newEvent: newEvent);

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.of(context).pop(true);
      } else {
        await showDialog(
          context: context,
          builder: (_) => const RequestFailedDialog(),
        );
      }
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
