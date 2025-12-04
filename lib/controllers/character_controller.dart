import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/character_sheet.dart';
import 'auth_controller.dart';
import '../service/dnd_api_service.dart';

class CharacterController extends ChangeNotifier {
  static final CharacterController _instance = CharacterController._internal();
  factory CharacterController() {
    return _instance;
  }
  CharacterController._internal();

  final AuthController _authController = AuthController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _sheetsCollection => _firestore.collection('sheets');

  final List<String> availableSystems = [
    'D&D 5e',
  ];
  final DndApiService _apiService = DndApiService();
  List<String> loadedClasses = [];

  Future<void> loadClassesFromApi() async {
    if (loadedClasses.isNotEmpty) return;

    print('Buscando classes na API de D&D...');
    try {
      final classes = await _apiService.fetchClasses();
      loadedClasses = classes;
      notifyListeners();
      print('Classes carregadas: $loadedClasses');
    } catch (e) {
      print('Erro no controller ao buscar classes: $e');
    }
  }

  Future<void> createSheet({
    required String characterName,
    required String className,
    required int level,
    required String system,
  }) async {
    final currentUser = _authController.currentUser;
    if (currentUser == null) return;

    final newSheet = CharacterSheet(
      id: '',
      ownerUserId: currentUser.id,
      characterName: characterName,
      className: className,
      level: level,
      system: system,
    );

    await _sheetsCollection.add(newSheet.toJson());
  }

  Stream<List<CharacterSheet>> getSheetsStreamForCurrentUser() {
    final currentUser = _authController.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    // Cria uma consulta no Firestore
    return _sheetsCollection
        .where('ownerUserId', isEqualTo: currentUser.id)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CharacterSheet.fromSnapshot(doc)).toList();
    });
  }

  Future<void> editSheet({
    required String sheetId,
    required String newCharacterName,
    required String newClassName,
    required int newLevel,
    required String newSystem,
  }) async {
    final updates = {
      'characterName': newCharacterName,
      'className': newClassName,
      'level': newLevel,
      'system': newSystem,
    };

    await _sheetsCollection.doc(sheetId).update(updates);
  }

  Future<void> deleteSheets(List<String> sheetIds) async {
    // Para deletar múltiplos itens, usamos um "batch write"
    final batch = _firestore.batch();

    for (final id in sheetIds) {
      batch.delete(_sheetsCollection.doc(id));
    }

    await batch.commit();
  }
}