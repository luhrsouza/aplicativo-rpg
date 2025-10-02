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
}