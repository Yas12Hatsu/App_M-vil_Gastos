import 'package:cloud_firestore/cloud_firestore.dart';

class Budget {
  String id;
  DateTime startDate;
  DateTime endDate;
  double amount;
  String category;

  Budget({required this.id, required this.startDate, required this.endDate, required this.amount, required this.category});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startDate': startDate,
      'endDate': endDate,
      'amount': amount,
      'category': category,
    };
  }

  static Budget fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      amount: map['amount'],
      category: map['category'],
    );
  }
}
