import 'user_model.dart';

class User {
  final int pk;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String location;

  final bool isCoach;
  final bool isOrganiser;

  final bool verified;

  User._({
    required this.pk,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.location,
    required this.isCoach,
    required this.isOrganiser,
    required this.verified,
  });

  User.fromModel({required UserModel userModel})
      : this._(
          pk: userModel.pk,
          username: userModel.username,
          email: userModel.email,
          firstName: userModel.first_name,
          lastName: userModel.last_name,
          location: userModel.location,
          isCoach: userModel.is_coach,
          isOrganiser: userModel.is_organiser,
          verified: userModel.verified,
        );

  String getFullName() {
    return '$firstName $lastName';
  }

  bool isCoachUser() {
    return isCoach;
  }

  bool isOrganiserUser() {
    return isOrganiser;
  }

  bool isVerified() {
    return verified;
  }
}
