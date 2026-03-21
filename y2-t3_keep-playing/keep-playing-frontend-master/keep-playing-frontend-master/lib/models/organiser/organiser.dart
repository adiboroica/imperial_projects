import 'package:keep_playing_frontend/models/user.dart';

import 'organiser_model.dart';

class Organiser {
  final List<int> favourites;
  final List<int> blocked;

  final String defaultSport;
  final String defaultRole;
  final String defaultLocation;
  final int? defaultPrice;

  Organiser._({
    required this.favourites,
    required this.blocked,
    required this.defaultSport,
    required this.defaultRole,
    required this.defaultLocation,
    required this.defaultPrice,
  });

  Organiser.fromModel({required OrganiserModel organiserModel})
      : this._(
          favourites: organiserModel.favourites,
          blocked: organiserModel.blocked,
          defaultSport: organiserModel.default_sport,
          defaultRole: organiserModel.default_role,
          defaultLocation: organiserModel.default_location,
          defaultPrice: organiserModel.default_price,
        );

  bool hasUserAsAFavourite(User user) {
    return favourites.contains(user.pk);
  }

  bool hasBlockedUser(User user) {
    return blocked.contains(user.pk);
  }
}
