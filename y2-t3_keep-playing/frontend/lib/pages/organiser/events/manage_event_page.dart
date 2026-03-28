import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:keep_playing_frontend/api/organiser.dart';
import 'package:keep_playing_frontend/api/users.dart';
import 'package:keep_playing_frontend/models/event.dart';
import 'package:keep_playing_frontend/models/user.dart';
import 'package:keep_playing_frontend/state/auth_cubit.dart';
import 'package:keep_playing_frontend/utils.dart';
import 'package:keep_playing_frontend/widgets/app_theme.dart';
import 'package:keep_playing_frontend/widgets/confirmation_dialog.dart';
import 'package:keep_playing_frontend/widgets/exit_guard.dart';
import 'package:keep_playing_frontend/widgets/loading_indicator.dart';
import 'package:keep_playing_frontend/widgets/sport_role_dropdowns.dart';
import 'package:keep_playing_frontend/widgets/user_info_tiles.dart';

import 'events_cubit.dart';

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
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _detailsController;
  late final TextEditingController _priceController;

  late String? _sport;
  late String? _role;
  late DateTime _date;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late bool _recurring;
  bool _isSubmitting = false;

  User? _coachUser;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _nameController = TextEditingController(text: e.name);
    _locationController = TextEditingController(text: e.location);
    _detailsController = TextEditingController(text: e.details);
    _priceController = TextEditingController(text: e.price.toString());
    _sport = e.sport.isNotEmpty ? e.sport : null;
    _role = e.role.isNotEmpty ? e.role : null;
    _date = e.date;
    _startTime = e.startTime;
    _endTime = e.endTime;
    _recurring = e.recurring;
    _loadCoach();
  }

  Future<void> _loadCoach() async {
    if (widget.event.coachPk == null) return;
    try {
      final apiUsers = ApiUsers(client: context.read<AuthCubit>().apiClient);
      final coach = await apiUsers.getUser(widget.event.coachPk!);
      if (mounted) setState(() => _coachUser = coach);
    } catch (_) {
      // Coach info is optional display; ignore load failures.
    }
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
                child: Form(
                  key: _formKey,
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
                        title: Text('Start Time: ${formatTime(_startTime)}'),
                        onTap: () => _pickTime(isStart: true),
                      ),
                      ListTile(
                        leading: const Icon(Icons.access_time),
                        title: Text('End Time: ${formatTime(_endTime)}'),
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
      ),
    );
  }

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

  Future<void> _openGoogleCalendar() async {
    final event = widget.event;
    final start = DateTime(
      _date.year, _date.month, _date.day,
      _startTime.hour, _startTime.minute,
    );
    final end = DateTime(
      _date.year, _date.month, _date.day,
      _endTime.hour, _endTime.minute,
    );
    final dateFormat = DateFormat("yyyyMMdd'T'HHmmss");
    final url = 'https://www.google.com/calendar/render?action=TEMPLATE'
        '&text=${Uri.encodeComponent(event.name)}'
        '&dates=${dateFormat.format(start)}/${dateFormat.format(end)}'
        '&location=${Uri.encodeComponent(_locationController.text)}'
        '&details=${Uri.encodeComponent(_detailsController.text)}';

    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_sport == null || _role == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select sport and role')),
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
      coach: widget.event.coach,
      recurring: _recurring,
      creationStarted: widget.event.creationStarted,
      creationEnded: DateTime.now(),
    );

    try {
      final apiOrganiser = ApiOrganiser(client: context.read<AuthCubit>().apiClient);
      await apiOrganiser.updateEvent(
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
      final apiOrganiser = ApiOrganiser(client: context.read<AuthCubit>().apiClient);
      await apiOrganiser.deleteEvent(event: widget.event);

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
