import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:keep_playing_frontend/utils.dart';
import 'package:keep_playing_frontend/widgets/app_theme.dart';
import 'package:keep_playing_frontend/widgets/sport_role_dropdowns.dart';

class EventFormData {
  String? sport;
  String? role;
  DateTime date;
  TimeOfDay startTime;
  TimeOfDay endTime;
  TimeOfDay flexibleStartTime;
  TimeOfDay flexibleEndTime;
  bool recurring;
  DateTime? recurringEndDate;

  final TextEditingController nameController;
  final TextEditingController locationController;
  final TextEditingController detailsController;
  final TextEditingController priceController;

  EventFormData({
    this.sport,
    this.role,
    required this.date,
    this.startTime = const TimeOfDay(hour: 9, minute: 0),
    this.endTime = const TimeOfDay(hour: 10, minute: 0),
    TimeOfDay? flexibleStartTime,
    TimeOfDay? flexibleEndTime,
    this.recurring = false,
    this.recurringEndDate,
    String name = '',
    String location = '',
    String details = '',
    String price = '',
  })  : flexibleStartTime = flexibleStartTime ?? const TimeOfDay(hour: 9, minute: 0),
        flexibleEndTime = flexibleEndTime ?? const TimeOfDay(hour: 10, minute: 0),
        nameController = TextEditingController(text: name),
        locationController = TextEditingController(text: location),
        detailsController = TextEditingController(text: details),
        priceController = TextEditingController(text: price);

  void dispose() {
    nameController.dispose();
    locationController.dispose();
    detailsController.dispose();
    priceController.dispose();
  }

  bool isEndTimeAfterStartTime() {
    return endTime.hour > startTime.hour ||
        (endTime.hour == startTime.hour && endTime.minute > startTime.minute);
  }
}

class EventFormFields extends StatelessWidget {
  final EventFormData data;
  final GlobalKey<FormState> formKey;
  final VoidCallback onChanged;

  const EventFormFields({
    super.key,
    required this.data,
    required this.formKey,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: data.nameController,
            decoration: const InputDecoration(
              labelText: 'Event Name',
              prefixIcon: Icon(Icons.title),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter an event name';
              return null;
            },
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          SportDropdown(
            value: data.sport,
            onChanged: (value) {
              data.sport = value;
              onChanged();
            },
          ),
          RoleDropdown(
            value: data.role,
            onChanged: (value) {
              data.role = value;
              onChanged();
            },
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          TextFormField(
            controller: data.locationController,
            decoration: const InputDecoration(
              labelText: 'Location',
              prefixIcon: Icon(Icons.location_on),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter a location';
              return null;
            },
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          TextFormField(
            controller: data.detailsController,
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
            title: Text('Date: ${DateFormat('MMMM dd, yyyy').format(data.date)}'),
            onTap: () => _pickDate(context),
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: Text('Start Time: ${formatTime(data.startTime)}'),
            onTap: () => _pickTime(context, isStart: true),
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: Text('End Time: ${formatTime(data.endTime)}'),
            onTap: () => _pickTime(context, isStart: false),
          ),
          SwitchListTile(
            title: const Text('Recurring'),
            secondary: const Icon(Icons.repeat),
            value: data.recurring,
            onChanged: (value) {
              data.recurring = value;
              onChanged();
            },
          ),
          if (data.recurring)
            ListTile(
              leading: const Icon(Icons.event_repeat),
              title: Text(data.recurringEndDate != null
                  ? 'Recurring until: ${DateFormat('MMMM dd, yyyy').format(data.recurringEndDate!)}'
                  : 'No end date (tap to set)'),
              onTap: () => _pickRecurringEndDate(context),
            ),
          const SizedBox(height: AppTheme.paddingMedium),
          TextFormField(
            controller: data.priceController,
            decoration: const InputDecoration(
              labelText: 'Price',
              prefixIcon: Icon(Icons.price_change),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter a price';
              if (int.tryParse(value) == null) return 'Please enter a valid number';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: data.date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      data.date = picked;
      onChanged();
    }
  }

  Future<void> _pickTime(BuildContext context, {required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? data.startTime : data.endTime,
    );
    if (picked != null) {
      if (isStart) {
        data.startTime = picked;
      } else {
        data.endTime = picked;
      }
      onChanged();
    }
  }

  Future<void> _pickRecurringEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: data.recurringEndDate ?? data.date.add(const Duration(days: 30)),
      firstDate: data.date,
      lastDate: data.date.add(const Duration(days: 365)),
    );
    if (picked != null) {
      data.recurringEndDate = picked;
      onChanged();
    }
  }
}
