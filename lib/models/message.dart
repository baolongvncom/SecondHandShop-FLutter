import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderUID;
  final String senderEmail;
  final String receiverEmail;
  final String message;
  final Timestamp time;

  Message({
    required this.senderUID,
    required this.senderEmail,
    required this.receiverEmail,
    required this.message,
    required this.time,
  });

  // convert message to map
  Map<String, dynamic> toMap() {
    return {
      'senderUID': senderUID,
      'senderEmail': senderEmail,
      'receiverEmail': receiverEmail,
      'message': message,
      'time': time,
    };
  }
}
