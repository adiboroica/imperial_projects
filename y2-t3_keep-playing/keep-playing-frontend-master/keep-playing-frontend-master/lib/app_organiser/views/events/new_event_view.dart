import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:keep_playing_frontend/api_manager/api.dart';
import 'package:keep_playing_frontend/app_organiser/cubit/events_cubit.dart';
import 'package:keep_playing_frontend/app_organiser/cubit/organiser_cubit.dart';
import 'package:keep_playing_frontend/constants.dart';
import 'package:keep_playing_frontend/models/event.dart';
import 'package:keep_playing_frontend/widgets/buttons.dart';
import 'package:keep_playing_frontend/widgets/dialogs.dart';
import 'package:keep_playing_frontend/widgets/icons.dart';
import 'package:keep_playing_frontend/widgets/loading_widgets.dart';

class NewEventView extends StatefulWidget {
  static const String _title = 'New Event';

  final DateTime? date;

  const NewEventView({Key? key, this.date}) : super(key: key);

  @override
  State<NewEventView> createState() => _NewEventViewState();
}

class _NewEventViewState extends State<NewEventView> {
  String _name = '';
  String _location = '';
  String _details = '';
  String _sport = '';
  String _role = '';

  late DateTime _date;
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();

  bool _recurring = false;
  int? _price;

  final DateTime _creationStarted = DateTime.now();

  final TimeOfDay _flexibleStartTime = const TimeOfDay(hour: 0, minute: 0);
  final TimeOfDay _flexibleEndTime = const TimeOfDay(hour: 0, minute: 0);

  TextEditingController startTimeInput = TextEditingController();
  TextEditingController endTimeInput = TextEditingController();

  bool _defaultValuesAreLoaded = false;
  bool _initialValuesAreLoaded = false;

  @override
  void initState() {
    _setInitialValues();

    super.initState();
  }

  void _setInitialValues() {
    _date = widget.date == null ? DateTime.now() : widget.date!;

    startTimeInput.text = "";
    endTimeInput.text = "";

    setState(() {
      _initialValuesAreLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool initialValuesAreNotLoaded = !_initialValuesAreLoaded;

    if (!_defaultValuesAreLoaded) {
      _sport = BlocProvider.of<OrganiserCubit>(context).state.defaultSport;
      _role = BlocProvider.of<OrganiserCubit>(context).state.defaultRole;
      _location =
          BlocProvider.of<OrganiserCubit>(context).state.defaultLocation;
      _price = BlocProvider.of<OrganiserCubit>(context).state.defaultPrice;

      _defaultValuesAreLoaded = true;
    }

    if (initialValuesAreNotLoaded) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(NewEventView._title),
        ),
        body: LOADING_CIRCLE,
      );
    }

    final Widget nameForm = ListTile(
      title: TextFormField(
        initialValue: _name,
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
        hint: const Text('Enter sport'),
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
        hint: const Text('Enter role'),
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
            initialTime: _startTime,
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
              if (endTimeInput.text == '') {
                _endTime = newTime;
                endTimeInput.text =
                    const DefaultMaterialLocalizations().formatTimeOfDay(
                  _endTime,
                  alwaysUse24HourFormat: true,
                );
              }
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
            initialTime: _endTime,
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
        initialValue: _price?.toString(),
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

    void onSubmitButtonPressed() {
      const Widget submitJobDialog = ConfirmationDialog(
        title: 'Are you sure that you want to post this event?',
      );

      showDialog(
        context: context,
        builder: (_) => submitJobDialog,
      ).then(
        (value) async {
          if (value) {
            showLoadingDialog(context);

            NavigatorState navigator = Navigator.of(context);
            final EventsCubit eventsCubit =
                BlocProvider.of<EventsCubit>(context);

            NewEvent newEvent = NewEvent(
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
              price: _price == null ? 0 : _price!,
              coach: false,
              recurring: _recurring,
              creationStarted: _creationStarted,
              creationEnded: DateTime.now(),
            );

            Response response =
                await API.organiser.addNewEvent(newEvent: newEvent);
            if (response.statusCode == HTTP_201_CREATED) {
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

    final Widget submitButton = Container(
      padding: const EdgeInsets.all(BUTTON_PADDING),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: APP_COLOR,
          textStyle: const TextStyle(fontSize: BUTTON_FONT_SIZE),
        ),
        onPressed: onSubmitButtonPressed,
        child: const Text('Submit'),
      ),
    );

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(NewEventView._title),
        ),
        body: ListView(
          children: [
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
            Center(child: submitButton),
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
            text: 'You haven\'t finished editing the new event',
          ),
        )) ??
        false;
  }
}
