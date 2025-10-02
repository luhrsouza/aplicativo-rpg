// lib/views/pages/campaign_details_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/campaign_controller.dart';
import '../../models/campaign.dart';
import '../../models/session.dart';

class CampaignDetailsScreen extends StatefulWidget {
  final Campaign campaign;

  const CampaignDetailsScreen({super.key, required this.campaign});

  @override
  State<CampaignDetailsScreen> createState() => _CampaignDetailsScreenState();
}

class _CampaignDetailsScreenState extends State<CampaignDetailsScreen> {
  final AuthController _authController = AuthController();
  final CampaignController _campaignController = CampaignController();

  late Campaign _campaign;
  late bool _isMaster;

  @override
  void initState() {
    super.initState();
    _campaign = widget.campaign;
    _isMaster = _authController.currentUser?.id == widget.campaign.masterUserId;
  }

  void _refreshCampaign() {
    final updatedCampaign = _campaignController.getCampaignById(_campaign.id);
    if (updatedCampaign != null) {
      setState(() {
        _campaign = updatedCampaign;
      });
    }
  }

  void _showInviteCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Código de Convite'),
        content: SelectableText(
          widget.campaign.campaignCode,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _scheduleSession() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final finalDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        _campaignController.scheduleSession(_campaign.id, finalDateTime, 'Próxima aventura!');
        _refreshCampaign();

        setState(() {
          _campaignController.scheduleSession(widget.campaign.id, finalDateTime, 'Próxima aventura!');
        });
      }
    }
  }

  void _confirmRemovePlayer(String playerId, String playerName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja remover o jogador "$playerName" da campanha?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
              onPressed: () {
                _campaignController.removePlayer(_campaign.id, playerId);
                Navigator.of(context).pop();
                _refreshCampaign();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final latestSession = _campaign.sessions.isNotEmpty ? _campaign.sessions.last : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.campaign.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Código de Convite'),
                subtitle: Text(widget.campaign.campaignCode),
                onTap: _showInviteCode,
              ),
            ),
            const SizedBox(height: 24),

            Text('Próxima Sessão', style: Theme.of(context).textTheme.headlineSmall),
            const Divider(),
            if (latestSession != null)
              _buildSessionInfo(latestSession)
            else
              const Text('Nenhuma sessão agendada.'),

            if (_isMaster)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ElevatedButton.icon(
                  onPressed: _scheduleSession,
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Agendar Sessão'),
                ),
              ),

            const SizedBox(height: 24),

            Text('Jogadores', style: Theme.of(context).textTheme.headlineSmall),
            const Divider(),
            if (widget.campaign.playerUserIds.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text('Nenhum jogador entrou na campanha ainda :('),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.campaign.playerUserIds.length,
                itemBuilder: (context, index) {
                  final playerId = widget.campaign.playerUserIds[index];
                  final player = _authController.getUserById(playerId);

                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(player?.name.substring(0, 1).toUpperCase() ?? '?'),
                    ),
                    title: Text(player?.name ?? 'Usuário desconhecido'),
                    trailing: _isMaster
                        ? IconButton(
                      icon: Icon(Icons.remove_circle_outline, color: Colors.red.shade400),
                      onPressed: () {
                        _confirmRemovePlayer(playerId, player?.name ?? 'Jogador desconhecido');
                      },
                    )
                        : null,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionInfo(Session session) {
    final formattedDate = DateFormat('dd/MM/yyyy \'às\' HH:mm').format(session.dateTime);
    final status = session.attendance[_authController.currentUser?.id] ?? AttendanceStatus.pending;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(formattedDate, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),

        if (!_isMaster) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: status == AttendanceStatus.confirmed ? null : () {
                  _campaignController.respondToSession(session.id, AttendanceStatus.confirmed);
                  _refreshCampaign();
                },
                icon: const Icon(Icons.check),
                label: const Text('Confirmar'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              ),
              ElevatedButton.icon(
                onPressed: status == AttendanceStatus.denied ? null : () {
                  _campaignController.respondToSession(session.id, AttendanceStatus.denied);
                  _refreshCampaign();
                },
                icon: const Icon(Icons.close),
                label: const Text('Negar'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Center(child: Text('Seu status: ${status.name}')),
          )
        ],

        if (_isMaster) ...[
          const Text('Status dos Jogadores:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (session.attendance.isEmpty)
            const Text('Nenhum jogador na campanha para convidar.')
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: session.attendance.length,
              itemBuilder: (context, index) {
                final playerId = session.attendance.keys.elementAt(index);
                final playerStatus = session.attendance.values.elementAt(index);
                final player = _authController.getUserById(playerId);

                Icon statusIcon;
                switch (playerStatus) {
                  case AttendanceStatus.confirmed:
                    statusIcon = const Icon(Icons.check_circle, color: Colors.deepPurple);
                    break;
                  case AttendanceStatus.denied:
                    statusIcon = const Icon(Icons.cancel, color: Colors.red);
                    break;
                  case AttendanceStatus.pending:
                    statusIcon = const Icon(Icons.hourglass_empty, color: Colors.grey);
                }

                return ListTile(
                  leading: statusIcon,
                  title: Text(player?.name ?? 'Jogador desconhecido'),
                  subtitle: Text('Status: ${playerStatus.name}'),
                );
              },
            )
        ]
      ],
    );
  }
}