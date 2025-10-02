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
}