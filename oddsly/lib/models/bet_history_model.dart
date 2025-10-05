class BetHistory {
  final String id;
  final double amount;
  final String matchId;
  final String outcome;
  final String status;
  // Firestore сохраняет время в специальном формате, поэтому пока просто читаем его как Map
  final Map<String, dynamic> createdAt;

  BetHistory({
    required this.id,
    required this.amount,
    required this.matchId,
    required this.outcome,
    required this.status,
    required this.createdAt,
  });

  factory BetHistory.fromJson(Map<String, dynamic> json) {
    return BetHistory(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      matchId: json['matchId'],
      outcome: json['outcome'],
      status: json['status'],
      createdAt: json['createdAt'],
    );
  }
}
