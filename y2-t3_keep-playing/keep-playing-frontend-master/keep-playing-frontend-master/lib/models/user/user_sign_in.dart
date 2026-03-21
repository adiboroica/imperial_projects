import 'dart:io';

class CoachSignUp {
  final String username;
  final String password;
  final File? qualificationFile;

  CoachSignUp({
    required this.username,
    required this.password,
    required this.qualificationFile,
  });
}

class OrganiserSignUp {
  final String username;
  final String password;

  OrganiserSignUp({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        "username": username,
        "password": password,
      };
}
