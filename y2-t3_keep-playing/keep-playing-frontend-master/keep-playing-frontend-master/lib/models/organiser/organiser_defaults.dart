class OrganiserDefaults {
  final String defaultSport;
  final String defaultRole;
  final String defaultLocation;
  final int? defaultPrice;

  OrganiserDefaults({
    required this.defaultSport,
    required this.defaultRole,
    required this.defaultLocation,
    required this.defaultPrice,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'default_sport': defaultSport,
        'default_role': defaultRole,
        'default_location': defaultLocation,
        'default_price': defaultPrice,
      };
}
