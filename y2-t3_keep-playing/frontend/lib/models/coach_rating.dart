class CoachRating {
  final int pk;
  final int votes;
  final int experience;
  final int flexibility;
  final int reliability;

  const CoachRating({
    required this.pk,
    required this.votes,
    required this.experience,
    required this.flexibility,
    required this.reliability,
  });

  factory CoachRating.fromJson(Map<String, dynamic> json) => CoachRating(
        pk: json['pk'] as int,
        votes: json['votes'] as int,
        experience: json['experience'] as int,
        flexibility: json['flexibility'] as int,
        reliability: json['reliability'] as int,
      );

  double get experienceAverage => votes == 0 ? 0 : experience / votes;
  double get flexibilityAverage => votes == 0 ? 0 : flexibility / votes;
  double get reliabilityAverage => votes == 0 ? 0 : reliability / votes;
}

class CoachNewRating {
  final int experience;
  final int flexibility;
  final int reliability;

  const CoachNewRating({
    required this.experience,
    required this.flexibility,
    required this.reliability,
  });

  Map<String, dynamic> toJson() => {
        'experience': experience,
        'flexibility': flexibility,
        'reliability': reliability,
      };
}
