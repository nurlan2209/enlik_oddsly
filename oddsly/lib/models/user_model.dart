class UserModel {
  final String email;
  final double balance;

  UserModel({required this.email, required this.balance});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'],
      // Приводим balance к double, так как из Firestore он может прийти как int
      balance: (json['balance'] as num).toDouble(),
    );
  }
}
