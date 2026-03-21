import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:add_2_calendar/add_2_calendar.dart' as add2calendar;
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:keep_playing_frontend/api_manager/api.dart';
import 'package:keep_playing_frontend/constants.dart';
import 'package:keep_playing_frontend/models/event.dart' as sport_event;
import 'package:keep_playing_frontend/models/user.dart';
import 'package:keep_playing_frontend/models_widgets/user_widgets.dart';
import 'package:keep_playing_frontend/widgets/buttons.dart';
import 'package:keep_playing_frontend/widgets/cards.dart';
import 'package:keep_playing_frontend/widgets/dialogs.dart';
import 'package:keep_playing_frontend/widgets/icons.dart';
import 'package:keep_playing_frontend/widgets/loading_widgets.dart';

import '../../cubit/events_cubit.dart';

class ManageEventView extends StatefulWidget {
  static const String _title = 'Manage Event';

  final sport_event.Event event;

  const ManageEventView({super.key, required this.event});

  @override
  State<ManageEventView> createState() => _ManageEventView();
}

class _ManageEventView extends State<ManageEventView> {
  late String _name;
  late String _location;
  late String _details;
  late String _sport;
  late String _role;

  late DateTime _date;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  late bool _recurring;
  late int _price;

  late bool _coach;
  User? _sessionCoach;

  late TimeOfDay _flexibleStartTime;
  late TimeOfDay _flexibleEndTime;

  TextEditingController startTimeInput = TextEditingController();
  TextEditingController endTimeInput = TextEditingController();

  bool _initialValuesAreLoaded = false;

  @override
  void initState() {
    _setInitialValues();
    _retrieveCoachUser();

    super.initState();
  }

  void _setInitialValues() {
    _name = widget.event.name;
    _location = widget.event.location;
    _details = widget.event.details;

    _sport = widget.event.sport;
    _role = widget.event.role;

    _date = widget.event.date;
    _startTime = widget.event.startTime;
    _endTime = widget.event.endTime;
    _flexibleStartTime = widget.event.flexibleStartTime;
    _flexibleEndTime = widget.event.flexibleEndTime;

    _price = widget.event.price;
    _coach = widget.event.coach;

    _recurring = widget.event.recurring;

    startTimeInput.text = const DefaultMaterialLocalizations()
        .formatTimeOfDay(_startTime, alwaysUse24HourFormat: true);
    endTimeInput.text = const DefaultMaterialLocalizations()
        .formatTimeOfDay(_endTime, alwaysUse24HourFormat: true);

    setState(() {
      _initialValuesAreLoaded = true;
    });
  }

  void _retrieveCoachUser() async {
    User? coach = widget.event.coachPK == null
        ? null
        : await API.user.getUser(widget.event.coachPK!);

    setState(() {
      _sessionCoach = coach;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool initialValuesAreNotLoaded = !_initialValuesAreLoaded;
    final bool coachIsNotLoaded =
        widget.event.hasCoach() && _sessionCoach == null;

    if (initialValuesAreNotLoaded || coachIsNotLoaded) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(ManageEventView._title),
        ),
        body: LOADING_CIRCLE,
      );
    }

    final Widget coachInformationCard = _sessionCoach == null
        ? const SizedBox(height: 0, width: 0)
        : Card(
            margin: const EdgeInsets.all(CARD_PADDING),
            child: UserInfoListTile(
              user: _sessionCoach!,
              event: widget.event,
              userInfoType: UserInfoType.COACH,
            ),
          );

    final Widget addToCalendarButton = Container(
      padding: const EdgeInsets.fromLTRB(BUTTON_PADDING, 0, BUTTON_PADDING, 0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: APP_COLOR,
          textStyle: const TextStyle(fontSize: BUTTON_FONT_SIZE),
        ),
        onPressed: () {
          final add2calendar.Event event = add2calendar.Event(
            title: widget.event.name,
            description: widget.event.details,
            location: widget.event.location,
            startDate: widget.event.getStartTimestamp(),
            endDate: widget.event.getEndTimestamp(),
          );
          Add2Calendar.addEvent2Cal(event);
        },
        child: const Text('Add to calendar'),
      ),
    );

    final Widget nameForm = ListTile(
      title: TextFormField(
        initialValue: _name,
        readOnly: false,
        decoration: const InputDecoration(
          icon: EventIcons.NAME_ICON,
          hintText: 'Enter the name',
          labelText: 'Name',
        ),
        onChanged: (text) {
          _name = text;
        },
      ),
    );

    final Widget sportForm = ListTile(
      leading: EventIcons.SPORT_ICON,
      title: DropdownButton<String>(
        value: _sport == "" ? null : _sport,
        items: SPORTS.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _sport = newValue!;
          });
        },
      ),
    );

    final Widget roleForm = ListTile(
      leading: EventIcons.ROLE_ICON,
      title: DropdownButton<String>(
        value: _role == "" ? null : _role,
        items: ROLES.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _role = newValue!;
          });
        },
      ),
    );

    final Widget locationForm = ListTile(
      title: TextFormField(
        initialValue: _location,
        decoration: const InputDecoration(
          icon: EventIcons.LOCATION_ICON,
          hintText: 'Enter location of event',
          labelText: 'Location',
        ),
        onChanged: (text) {
          _location = text;
        },
      ),
    );

    final Widget detailsForm = ListTile(
      title: TextFormField(
        initialValue: _details,
        decoration: const InputDecoration(
          icon: EventIcons.DETAILS_ICON,
          hintText: 'Enter details about the session',
          labelText: 'Details',
        ),
        onChanged: (text) {
          _details = text;
        },
      ),
    );

    final Widget dateForm = ListTile(
      title: DateTimeField(
        initialValue: _date,
        decoration: const InputDecoration(
          icon: EventIcons.DATE_ICON,
          hintText: 'Enter the date',
          labelText: 'Date',
        ),
        format: DateFormat("dd-MMMM-yyyy"),
        onShowPicker: (context, currentValue) {
          return showDatePicker(
              context: context,
              firstDate: DateTime.now(),
              initialDate: currentValue ?? DateTime.now(),
              lastDate: DateTime(2100));
        },
        onChanged: (date) {
          _date = date!;
        },
      ),
    );

    final Widget startTimeForm = ListTile(
      title: TextField(
        controller: startTimeInput,
        decoration: const InputDecoration(
          icon: EventIcons.START_TIME_ICON,
          labelText: "Start Time",
        ),
        readOnly: true,
        onTap: () async {
          final TimeOfDay? newTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
            initialEntryMode: TimePickerEntryMode.input,
          );
          if (newTime != null) {
            setState(() {
              _startTime = newTime;
              startTimeInput.text =
                  const DefaultMaterialLocalizations().formatTimeOfDay(
                _startTime,
                alwaysUse24HourFormat: true,
              );
            });
          }
        },
      ),
    );

    final Widget endTimeForm = ListTile(
      title: TextField(
        controller: endTimeInput,
        decoration: const InputDecoration(
          icon: EventIcons.END_TIME_ICON,
          labelText: "End Time",
        ),
        readOnly: true,
        onTap: () async {
          final TimeOfDay? newTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
            initialEntryMode: TimePickerEntryMode.input,
          );
          if (newTime != null) {
            setState(() {
              _endTime = newTime;
              endTimeInput.text =
                  const DefaultMaterialLocalizations().formatTimeOfDay(
                _endTime,
                alwaysUse24HourFormat: true,
              );
            });
          }
        },
      ),
    );

    final Widget recurringForm = CheckboxListTile(
      value: _recurring,
      onChanged: (bool? value) => {
        setState(() {
          _recurring = value!;
        })
      },
      title: const Text('Is the event weekly?'),
    );

    final Widget priceForm = ListTile(
      title: TextFormField(
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        initialValue: _price.toString(),
        decoration: const InputDecoration(
          icon: EventIcons.PRICE_ICON,
          hintText: 'Enter the fee',
          labelText: 'Fee per event',
        ),
        onChanged: (text) {
          // TODO: Remove this cast.
          _price = int.parse(text);
        },
      ),
    );

    void onCancelButtonPressed() {
      const Widget cancelEventDialog = ConfirmationDialog(
        title: 'Are you sure that you want to cancel this event?',
      );

      showDialog(
        context: context,
        builder: (_) => cancelEventDialog,
      ).then(
        (value) async {
          if (value) {
            showLoadingDialog(context);

            NavigatorState navigator = Navigator.of(context);
            final EventsCubit eventsCubit =
                BlocProvider.of<EventsCubit>(context);

            final Response response =
                await API.organiser.cancelEvent(event: widget.event);
            if (response.statusCode == HTTP_200_OK) {
              await eventsCubit.retrieveEvents();
              navigator.pop();
              navigator.pop();
            } else {
              navigator.pop();
              showDialog(
                context: context,
                builder: (_) => const RequestFailedDialog(),
                barrierDismissible: false,
              );
            }
          }
        },
      );
    }

    final Widget cancelEventButton = Container(
      padding: const EdgeInsets.fromLTRB(
          BUTTON_PADDING, BUTTON_PADDING, 0, BUTTON_PADDING),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: CANCEL_BUTTON_COLOR,
          textStyle: const TextStyle(fontSize: BUTTON_FONT_SIZE),
        ),
        onPressed: onCancelButtonPressed,
        child: const Text('Cancel Event'),
      ),
    );

    void onSaveButtonPressed() {
      const Widget saveChangesDialog = ConfirmationDialog(
        title: 'Are you sure that you want to save your changes?',
      );

      showDialog(
        context: context,
        builder: (_) => saveChangesDialog,
      ).then(
        (value) async {
          if (value) {
            showLoadingDialog(context);

            NavigatorState navigator = Navigator.of(context);
            final EventsCubit eventsCubit =
                BlocProvider.of<EventsCubit>(context);

            sport_event.NewEvent newEvent = sport_event.NewEvent(
              name: _name,
              location: _location,
              details: _details,
              sport: _sport,
              role: _role,
              date: _date,
              startTime: _startTime,
              endTime: _endTime,
              flexibleStartTime: _flexibleStartTime,
              flexibleEndTime: _flexibleEndTime,
              price: _price,
              coach: _coach,
              recurring: _recurring,
              creationStarted: widget.event.creationStarted,
              creationEnded: widget.event.creationEnded,
            );

            Response response = await API.organiser.changeEvent(
              event: widget.event,
              newEvent: newEvent,
            );
            if (response.statusCode == HTTP_202_ACCEPTED) {
              await eventsCubit.retrieveEvents();
              navigator.pop();
              navigator.pop();
            } else {
              navigator.pop();
              showDialog(
                context: context,
                builder: (_) => const RequestFailedDialog(),
                barrierDismissible: false,
              );
            }
          }
        },
      );
    }

    final Widget saveChangesButton = Container(
      padding: const EdgeInsets.fromLTRB(
          0, BUTTON_PADDING, BUTTON_PADDING, BUTTON_PADDING),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: APP_COLOR,
          textStyle: const TextStyle(fontSize: BUTTON_FONT_SIZE),
        ),
        onPressed: onSaveButtonPressed,
        child: const Text('Save Changes'),
      ),
    );

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(ManageEventView._title),
        ),
        body: ListView(
          children: [
            coachInformationCard,
            addToCalendarButton,
            nameForm,
            sportForm,
            roleForm,
            locationForm,
            detailsForm,
            dateForm,
            startTimeForm,
            endTimeForm,
            recurringForm,
            priceForm,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [cancelEventButton, saveChangesButton],
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (_) => const ExitDialog(
            title: 'Are you sure that you want to exit?',
            text: 'You haven\'t finished editing the event',
          ),
        )) ??
        false;
  }
}
