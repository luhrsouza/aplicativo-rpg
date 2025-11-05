import 'package:cloud_firestore/cloud_firestore.dart';
import 'session.dart';

class Campaign {
  final String id;
  final String name;
  final String description;
  final String masterUserId;
  final String campaignCode;
  final List<String> playerUserIds;
  List<Session> sessions;

  Campaign({
    required this.id,
    required this.name,
    required this.description,
    required this.masterUserId,
    required this.campaignCode,
    this.playerUserIds = const [],
    this.sessions = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'masterUserId': masterUserId,
      'campaignCode': campaignCode,
      'playerUserIds': playerUserIds,
    };
  }

  factory Campaign.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Campaign(
      id: doc.id,
      name: data['name'] as String,
      description: data['description'] as String,
      masterUserId: data['masterUserId'] as String,
      campaignCode: data['campaignCode'] as String,
      playerUserIds: List<String>.from(data['playerUserIds'] ?? []),
      sessions: [],
    );
  }
}