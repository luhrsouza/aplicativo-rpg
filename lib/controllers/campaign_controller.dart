import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/campaign.dart';
import 'dart:math';
import '../models/session.dart';
import 'auth_controller.dart';

class CampaignController extends ChangeNotifier {
  static final CampaignController _instance = CampaignController._internal();
  factory CampaignController() {
    return _instance;
  }
  CampaignController._internal();

  final AuthController _authController = AuthController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _campaignsCollection => _firestore.collection('campaigns');
  CollectionReference get _sessionsCollection => _firestore.collection('sessions');

  Future<void> createCampaign({
    required String name,
    required String description,
  }) async {
    final currentUser = _authController.currentUser;
    if (currentUser == null) return;

    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final campaignCode = String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(random.nextInt(chars.length))));

    final newCampaign = Campaign(
      id: '',
      name: name,
      description: description,
      masterUserId: currentUser.id,
      campaignCode: campaignCode,
      playerUserIds: [currentUser.id],
      sessions: [],
    );

    await _campaignsCollection.add(newCampaign.toJson());
  }

  Stream<List<Campaign>> getCampaignsStream() {
    final currentUser = _authController.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _campaignsCollection
        .where('playerUserIds', arrayContains: currentUser.id)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Campaign.fromSnapshot(doc)).toList();
    });
  }

  Stream<Campaign> getCampaignStream(String campaignId) {
    return _campaignsCollection
        .doc(campaignId)
        .snapshots()
        .map((doc) => Campaign.fromSnapshot(doc));
  }

  Stream<List<Session>> getSessionsStream(String campaignId) {
    return _sessionsCollection
        .where('campaignId', isEqualTo: campaignId)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Session.fromJson(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<String?> joinCampaignByCode(String code) async {
    final currentUser = _authController.currentUser;
    if (currentUser == null) return "Usuário não logado";

    try {
      final query = await _campaignsCollection
          .where('campaignCode', isEqualTo: code.trim().toUpperCase())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return "Código de campanha não encontrado.";
      }

      final campaignDoc = query.docs.first;

      await campaignDoc.reference.update({
        'playerUserIds': FieldValue.arrayUnion([currentUser.id])
      });
      return null; // Sucesso
    } catch (e) {
      return "Erro ao entrar na campanha: ${e.toString()}";
    }
  }

  Future<void> removePlayer(String campaignId, String playerId) async {
    final campaignRef = _campaignsCollection.doc(campaignId);

    final doc = await campaignRef.get();
    final data = doc.data() as Map<String, dynamic>;
    final masterId = data['masterUserId'] as String;

    if (playerId == masterId) {
      print("Não é permitido remover o mestre da campanha.");
      return;
    }

    await campaignRef.update({
      'playerUserIds': FieldValue.arrayRemove([playerId])
    });
  }

  Future<void> scheduleSession(String campaignId, DateTime dateTime, String description) async {
    final campaignDoc = await _campaignsCollection.doc(campaignId).get();
    if (!campaignDoc.exists) return;

    final campaign = Campaign.fromSnapshot(campaignDoc);

    final attendanceMap = <String, AttendanceStatus>{};
    for (var playerId in campaign.playerUserIds) {
      attendanceMap[playerId] = AttendanceStatus.pending;
    }

    final newSession = Session(
      id: '',
      campaignId: campaignId,
      dateTime: dateTime,
      description: description,
      attendance: attendanceMap,
    );

    await _sessionsCollection.add(newSession.toJson());
  }

  Future<void> respondToSession(String sessionId, AttendanceStatus status) async {
    final currentUser = _authController.currentUser;
    if (currentUser == null) return;

    await _sessionsCollection.doc(sessionId).update({
      'attendance.${currentUser.id}': status.name,
    });
  }
}