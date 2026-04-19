import 'package:image_picker/image_picker.dart';

/// Authenticated user with profile info and role flags (coach/organiser).
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

  const User({
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

  factory User.fromJson(Map<String, dynamic> json) => User(
        pk: json['pk'] as int,
        username: json['username'] as String,
        email: json['email'] as String? ?? '',
        firstName: json['first_name'] as String? ?? '',
        lastName: json['last_name'] as String? ?? '',
        location: json['location'] as String? ?? '',
        isCoach: json['is_coach'] as bool? ?? false,
        isOrganiser: json['is_organiser'] as bool? ?? false,
        verified: json['verified'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'pk': pk,
        'username': username,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'location': location,
        'is_coach': isCoach,
        'is_organiser': isOrganiser,
        'verified': verified,
      };

  String get fullName => '$firstName $lastName';
}

/// Credentials payload for logging in.
class UserLogin {
  final String username;
  final String password;

  const UserLogin({required this.username, required this.password});

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
      };
}

/// Registration payload for a new coach, including optional qualification file.
class CoachSignUp {
  final String username;
  final String password;
  final String email;
  final String firstName;
  final String lastName;
  final XFile? qualificationFile;

  const CoachSignUp({
    required this.username,
    required this.password,
    this.email = '',
    this.firstName = '',
    this.lastName = '',
    this.qualificationFile,
  });
}

/// Registration payload for a new organiser.
class OrganiserSignUp {
  final String username;
  final String password;
  final String email;
  final String firstName;
  final String lastName;

  const OrganiserSignUp({
    required this.username,
    required this.password,
    this.email = '',
    this.firstName = '',
    this.lastName = '',
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
      };
}
