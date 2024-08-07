class DailyChallenge {
  final String id;
  final DateTime createdOn;
  final String challenge;
  final String dcContent;

  DailyChallenge(
      {required this.id,
      required this.createdOn,
      required this.challenge,
      required this.dcContent});

  factory DailyChallenge.fromJSON(Map<String, dynamic> data) {
    return DailyChallenge(
      id: data['id'] as String,
      createdOn: DateTime.parse(data['created_at']),
      challenge: data['challenge'] as String,
      dcContent: data['dc_content'] as String,
    );
  }
}
