import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:keep_playing_frontend/models/user.dart';
import 'package:keep_playing_frontend/stored_data.dart';
import 'package:keep_playing_frontend/widgets/icons.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User currentUser = StoredData.getCurrentUser();

    final Widget usernameForm = ListTile(
      title: TextFormField(
        initialValue: currentUser.username,
        readOnly: true,
        decoration: const InputDecoration(
          icon: UserIcons.USERNAME_ICON,
          hintText: 'Enter your username',
          labelText: 'Username',
        ),
      ),
    );

    final Widget emailForm = ListTile(
      title: TextFormField(
        initialValue: currentUser.email,
        readOnly: false,
        decoration: const InputDecoration(
          icon: UserIcons.EMAIL_ICON,
          hintText: 'Enter your Email',
          labelText: 'Email',
        ),
      ),
    );

    final Widget firstNameForm = ListTile(
      title: TextFormField(
        initialValue: currentUser.firstName,
        readOnly: true,
        decoration: const InputDecoration(
          icon: UserIcons.FIRST_NAME_ICON,
          hintText: 'Enter your first name',
          labelText: 'First Name',
        ),
      ),
    );

    final Widget lastNameForm = ListTile(
      title: TextFormField(
        initialValue: currentUser.lastName,
        readOnly: true,
        decoration: const InputDecoration(
          icon: UserIcons.LAST_NAME_ICON,
          hintText: 'Enter your last name',
          labelText: 'Last Name',
        ),
      ),
    );

    final Widget locationForm = ListTile(
      title: TextFormField(
        initialValue: currentUser.location,
        readOnly: false,
        decoration: const InputDecoration(
          icon: UserIcons.LOCATION_ICON,
          hintText: 'Enter your location',
          labelText: 'Location',
        ),
      ),
    );

    final Widget phoneNumberForm = ListTile(
      title: InternationalPhoneNumberInput(
        initialValue: PhoneNumber(isoCode: 'GB', phoneNumber: '07951273003'),
        hintText: 'Phone Number',
        errorMessage: 'Invalid Phone Number',
        onInputChanged: (PhoneNumber number) {},
        maxLength: 15,
        spaceBetweenSelectorAndTextField: 8,
        autoValidateMode: AutovalidateMode.always,
        keyboardType: TextInputType.number,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
      ),
      body: Center(
        child: ListView(
          children: [
            usernameForm,
            emailForm,
            firstNameForm,
            lastNameForm,
            locationForm,
            phoneNumberForm,
          ],
        ),
      ),
    );
  }
}
