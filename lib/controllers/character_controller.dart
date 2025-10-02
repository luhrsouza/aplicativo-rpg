import '../models/character_sheet.dart';
import 'auth_controller.dart';

class CharacterController {
  static final CharacterController _instance = CharacterController._internal();
  factory CharacterController() {
    return _instance;
  }
  CharacterController._internal();

  final AuthController _authController = AuthController();

  final List<CharacterSheet> _sheets = [];

  final List<String> availableSystems = [
    'D&D 5e',
    'Ordem Paranormal',
    'Tormenta20',
    'Call of Cthulhu',
    'Outro',
  ];

  void createSheet({
    required String characterName,
    required String className,
    required int level,
    required String system,
  }) {
    final currentUser = _authController.currentUser;
    if (currentUser == null) return;

    final newSheet = CharacterSheet(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      ownerUserId: currentUser.id,
      characterName: characterName,
      className: className,
      level: level,
      system: system,
    );

    _sheets.add(newSheet);
    print('Ficha criada: ${newSheet.characterName} para o usuário ${currentUser.name}');
  }

  List<CharacterSheet> getSheetsForCurrentUser() {
    final currentUser = _authController.currentUser;
    if (currentUser == null) return [];

    return _sheets.where((sheet) => sheet.ownerUserId == currentUser.id).toList();
  }

  void editSheet({
    required String sheetId,
    required String newCharacterName,
    required String newClassName,
    required int newLevel,
    required String newSystem,
  }) {
    try {
      final sheetToEdit = _sheets.firstWhere((sheet) => sheet.id == sheetId);

      sheetToEdit.characterName = newCharacterName;
      sheetToEdit.className = newClassName;
      sheetToEdit.level = newLevel;
      sheetToEdit.system = newSystem;

      print('Ficha editada com sucesso: ${sheetToEdit.characterName}');
    } catch (e) {
      print('Erro ao editar ficha: Ficha com ID $sheetId não encontrada.');
    }
  }

  void deleteSheets(List<String> sheetIds) {
    _sheets.removeWhere((sheet) => sheetIds.contains(sheet.id));
    print('Fichas deletadas com sucesso: $sheetIds');
  }
}