import 'package:cloud_firestore/cloud_firestore.dart';

class ReportService {
  final CollectionReference<Map<String, dynamic>> _userRef = FirebaseFirestore
      .instance
      .collection('reports');

  Future<void> reportUser({required Map<String, dynamic> data}) async {
    await _userRef.add(data);
  }
}
