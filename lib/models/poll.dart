import 'user.dart';

class PollOption {
  final String id;
  final String text;

  PollOption({required this.id, required this.text});

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(
      id: json['id'],
      text: json['text'],
    );
  }
}

class PollVote {
  final String id;
  final User? user;
  final String optionId;

  PollVote({required this.id, this.user, required this.optionId});

  factory PollVote.fromJson(Map<String, dynamic> json) {
    return PollVote(
      id: json['id'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      optionId: json['option'] != null ? json['option']['id'] : null,
    );
  }
}

class Poll {
  final String id;
  final String question;
  final DateTime expiresAt;
  final List<PollOption> options;
  final List<PollVote> votes;

  Poll({
    required this.id,
    required this.question,
    required this.expiresAt,
    required this.options,
    required this.votes,
  });

  factory Poll.fromJson(Map<String, dynamic> json) {
    var optionsList = json['options'] as List? ?? [];
    var votesList = json['votes'] as List? ?? [];

    return Poll(
      id: json['id'],
      question: json['question'],
      expiresAt: DateTime.parse(json['expiresAt']),
      options: optionsList.map((o) => PollOption.fromJson(o)).toList(),
      votes: votesList.map((v) => PollVote.fromJson(v)).toList(),
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  int get totalVotes => votes.length;

  int getVotesForOption(String optionId) {
    return votes.where((v) => v.optionId == optionId).length;
  }

  double getPercentageForOption(String optionId) {
    if (totalVotes == 0) return 0.0;
    return getVotesForOption(optionId) / totalVotes;
  }

  bool hasVoted(String userId) {
    return votes.any((v) => v.user?.id == userId);
  }
}
