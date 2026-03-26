import 'user.dart';

class Organiser {
  final List<int> favourites;
  final List<int> blocked;
  final String defaultSport;
  final String defaultRole;
  final String defaultLocation;
  final int? defaultPrice;

  const Organiser({
    required this.favourites,
    required this.blocked,
    required this.defaultSport,
    required this.defaultRole,
    required this.defaultLocation,
    this.defaultPrice,
  });

  factory Organiser.fromJson(Map<String, dynamic> json) => Organiser(
        favourites: (json['favourites'] as List<dynamic>).map((e) => e as int).toList(),
        blocked: (json['blocked'] as List<dynamic>).map((e) => e as int).toList(),
        defaultSport: json['default_sport'] as String? ?? '',
        defaultRole: json['default_role'] as String? ?? '',
        defaultLocation: json['default_location'] as String? ?? '',
        defaultPrice: json['default_price'] as int?,
      );

  bool isFavourite(User user) => favourites.contains(user.pk);
  bool isBlocked(User user) => blocked.contains(user.pk);
}

class OrganiserDefaults {
  final String defaultSport;
  final String defaultRole;
  final String defaultLocation;
  final int? defaultPrice;

  const OrganiserDefaults({
    required this.defaultSport,
    required this.defaultRole,
    required this.defaultLocation,
    this.defaultPrice,
  });

  Map<String, dynamic> toJson() => {
        'default_sport': defaultSport,
        'default_role': defaultRole,
        'default_location': defaultLocation,
        'default_price': defaultPrice,
      };
}
