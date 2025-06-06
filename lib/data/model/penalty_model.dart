class Penalty {
  final String description;
  final List<String> userIds;

  Penalty({required this.description, required this.userIds});

  factory Penalty.fromJson(Map<String, dynamic> json) => Penalty(
    description: json['description'],
    userIds: List<String>.from(json['userIds']),
  );

  Map<String, dynamic> toJson() => {
    'description': description,
    'userIds': userIds,
  };
}
