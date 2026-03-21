class CoachNewRating {
  final int experience;
  final int flexibility;
  final int reliability;

  CoachNewRating({
    required this.experience,
    required this.flexibility,
    required this.reliability,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'experience': experience,
        'flexibility': flexibility,
        'reliability': reliability,
      };
}
