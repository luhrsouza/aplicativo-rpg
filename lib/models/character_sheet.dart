import 'package:cloud_firestore/cloud_firestore.dart';

class CharacterSheet {
  final String id;
  final String ownerUserId;
  String characterName;
  String className;
  int level;
  String system;

  CharacterSheet({
    required this.id,
    required this.ownerUserId,
    required this.characterName,
    required this.className,
    required this.level,
    required this.system,
  });

  Map<String, dynamic> toJson() {
    return {
      'ownerUserId': ownerUserId,
      'characterName': characterName,
      'className': className,
      'level': level,
      'system': system,
    };
  }

  factory CharacterSheet.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CharacterSheet(
      id: doc.id,
      ownerUserId: data['ownerUserId'] as String,
      characterName: data['characterName'] as String,
      className: data['className'] as String,
      level: data['level'] as int,
      system: data['system'] as String,
    );
  }
}