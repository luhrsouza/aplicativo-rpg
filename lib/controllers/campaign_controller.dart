import 'dart:math';
import '../models/campaign.dart';
import 'auth_controller.dart';
import '../models/session.dart';
import 'package:flutter/material.dart';

class CampaignController extends ChangeNotifier {
  static final CampaignController _instance = CampaignController._internal();
  factory CampaignController() {
    return _instance;
  }
  CampaignController._internal();

  final AuthController _authController = AuthController();

  final List<Campaign> _campaigns = [];

  void createCampaign({
    required String name,
    required String description,
  }) {
    final currentUser = _authController.currentUser;
    if (currentUser == null) {
      print('Erro: Nenhum usuário logado para criar a campanha.');
      return;
    }

    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final random = Random();
    final campaignCode = String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(random.nextInt(chars.length))));

    final newCampaign = Campaign(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      masterUserId: currentUser.id,
      campaignCode: campaignCode,
      playerUserIds: [],
    );

    _campaigns.add(newCampaign);
    print('Campanha criada: ${newCampaign.name} com o código: ${newCampaign.campaignCode}');
  }

  List<Campaign> getCampaignsForCurrentUser() {
    final currentUser = _authController.currentUser;
    if (currentUser == null) {
      return [];
    }

    return _campaigns.where((campaign) {
      final isMaster = campaign.masterUserId == currentUser.id;
      final isPlayer = campaign.playerUserIds.contains(currentUser.id);
      return isMaster || isPlayer;
    }).toList();
  }

  Future<bool> joinCampaignByCode(String code) async {
    final currentUser = _authController.currentUser;
    if (currentUser == null) return false;

    try {
      final campaign = _campaigns.firstWhere((c) => c.campaignCode == code);

      if (campaign.masterUserId != currentUser.id && !campaign.playerUserIds.contains(currentUser.id)) {
        campaign.playerUserIds.add(currentUser.id);
        print('Usuário ${currentUser.name} entrou na campanha ${campaign.name}');
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void removePlayer(String campaignId, String playerId) {
    try {
      final campaign = _campaigns.firstWhere((c) => c.id == campaignId);
      campaign.playerUserIds.remove(playerId);
      print('Jogador $playerId removido da campanha ${campaign.name}');
    } catch (e) {
      print('Erro ao remover jogador: campanha não encontrada.');
    }
  }

  void scheduleSession(String campaignId, DateTime dateTime, String description) {
    try {
      final campaignIndex = _campaigns.indexWhere((c) => c.id == campaignId);

      if (campaignIndex != -1) {
        final oldCampaign = _campaigns[campaignIndex];

        final attendanceMap = <String, AttendanceStatus>{};
        for (var playerId in oldCampaign.playerUserIds) {
          attendanceMap[playerId] = AttendanceStatus.pending;
        }

        final newSession = Session(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          campaignId: campaignId,
          dateTime: dateTime,
          description: description,
          attendance: attendanceMap,
        );

        final updatedSessions = List<Session>.from(oldCampaign.sessions)..add(newSession);

        final updatedCampaign = Campaign(
          id: oldCampaign.id,
          name: oldCampaign.name,
          description: oldCampaign.description,
          masterUserId: oldCampaign.masterUserId,
          campaignCode: oldCampaign.campaignCode,
          playerUserIds: oldCampaign.playerUserIds,
          sessions: updatedSessions,
        );
        _campaigns[campaignIndex] = updatedCampaign;

      } else {
        print('Erro ao agendar sessão: campanha não encontrada (indexWhere falhou).');
      }
    } catch (e) {
      print('Ocorreu um erro inesperado em scheduleSession: $e');
    }
  }

  void respondToSession(String sessionId, AttendanceStatus status) {
    final currentUser = _authController.currentUser;
    if (currentUser == null) return;

    for (var campaign in _campaigns) {
      for (var session in campaign.sessions) {
        if (session.id == sessionId) {
          session.attendance[currentUser.id] = status;

          print('>>> ATUALIZAÇÃO: Status do usuário ${currentUser.name} alterado para ${status.name} <<<');
          return;
        }
      }
    }
  }

  Campaign? getCampaignById(String campaignId) {
    try {
      return _campaigns.firstWhere((c) => c.id.trim() == campaignId.trim());
    } catch (e) {
      return null;
    }
  }
}