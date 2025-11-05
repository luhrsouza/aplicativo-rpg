import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/campaign_controller.dart';
import '../../models/campaign.dart';
import '../../models/session.dart';
import '../../models/user.dart' as app_user;

class CampaignDetailsScreen extends StatefulWidget {
  final String campaignId;

  const CampaignDetailsScreen({super.key, required this.campaignId});

  @override
  State<CampaignDetailsScreen> createState() => _CampaignDetailsScreenState();
}

class _CampaignDetailsScreenState extends State<CampaignDetailsScreen> {
  late final AuthController _authController;
  late final CampaignController _campaignController;
  bool _isMaster = false;

  @override
  void initState() {
    super.initState();
    _authController = Provider.of<AuthController>(context, listen: false);
    _campaignController = Provider.of<CampaignController>(context, listen: false);
  }

  void _showInviteCode(String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Código de Convite'),
        content: SelectableText(
          code,
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

  Future<void> _scheduleSession(String campaignId) async {
    try {
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

          await _campaignController.scheduleSession(campaignId, finalDateTime, 'Próxima aventura!');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Erro ao agendar sessão: ${e.toString()}'),
          ),
        );
      }
    }
  }

  void _confirmRemovePlayer(Campaign campaign, String playerId, String playerName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja remover o jogador "$playerName" da campanha?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
              onPressed: () {
                _campaignController.removePlayer(campaign.id, playerId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Campaign>(
      stream: _campaignController.getCampaignStream(widget.campaignId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(appBar: AppBar(), body: const Center(child: Text('Erro ao carregar campanha.')));
        }

        final campaign = snapshot.data!;
        _isMaster = _authController.currentUser?.id == campaign.masterUserId;

        return Scaffold(
          appBar: AppBar(
            title: Text(campaign.name),
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
                    subtitle: Text(campaign.campaignCode),
                    onTap: () => _showInviteCode(campaign.campaignCode),
                  ),
                ),
                const SizedBox(height: 24),

                Text('Próxima Sessão', style: Theme.of(context).textTheme.headlineSmall),
                const Divider(),
                _buildSessionsList(campaign.id),

                if (_isMaster)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ElevatedButton.icon(
                      onPressed: () => _scheduleSession(campaign.id),
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Agendar Sessão'),
                    ),
                  ),

                const SizedBox(height: 24),

                Text('Jogadores', style: Theme.of(context).textTheme.headlineSmall),
                const Divider(),
                if (campaign.playerUserIds.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text('Nenhum jogador entrou na campanha ainda :('),
                  )
                else
                  _buildPlayersList(campaign),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayersList(Campaign campaign) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: campaign.playerUserIds.length,
      itemBuilder: (context, index) {
        final playerId = campaign.playerUserIds[index];

        if (_isMaster && playerId == _authController.currentUser?.id) {
          return Container();
        }

        return FutureBuilder<app_user.User?>(
          future: _authController.getUserById(playerId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ListTile(title: Text('Carregando jogador...'));
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return ListTile(title: Text('Usuário desconhecido ($playerId)'));
            }

            final player = snapshot.data!;

            return ListTile(
              leading: CircleAvatar(
                child: Text(player.name.substring(0, 1).toUpperCase()),
              ),
              title: Text(player.name),
              trailing: _isMaster
                  ? IconButton(
                icon: Icon(Icons.remove_circle_outline, color: Colors.red.shade400),
                onPressed: () => _confirmRemovePlayer(campaign, playerId, player.name),
              )
                  : null,
            );
          },
        );
      },
    );
  }

  Widget _buildSessionsList(String campaignId) {
    return StreamBuilder<List<Session>>(
      stream: _campaignController.getSessionsStream(campaignId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Carregando sessões...'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('Nenhuma sessão agendada.');
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final session = snapshot.data![index];
            return _buildSessionInfo(session);
          },
        );
      },
    );
  }

  Widget _buildSessionInfo(Session session) {
    final formattedDate = DateFormat('dd/MM/yyyy \'às\' HH:mm').format(session.dateTime);
    final status = session.attendance[_authController.currentUser?.id] ?? AttendanceStatus.pending;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formattedDate, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 16),
            if (!_isMaster) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: status == AttendanceStatus.confirmed ? null : () {
                      _campaignController.respondToSession(session.id, AttendanceStatus.confirmed);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Confirmar'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                  ElevatedButton.icon(
                    onPressed: status == AttendanceStatus.denied ? null : () {
                      _campaignController.respondToSession(session.id, AttendanceStatus.denied);
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

                    if (playerId == _authController.currentUser?.id) {
                      return Container();
                    }

                    return FutureBuilder<app_user.User?>(
                      future: _authController.getUserById(playerId),
                      builder: (context, snapshot) {
                        final playerName = snapshot.data?.name ?? 'Carregando...';

                        Icon statusIcon;
                        switch (playerStatus) {
                          case AttendanceStatus.confirmed:
                            statusIcon = const Icon(Icons.check_circle, color: Colors.green);
                            break;
                          case AttendanceStatus.denied:
                            statusIcon = const Icon(Icons.cancel, color: Colors.red);
                            break;
                          case AttendanceStatus.pending:
                            statusIcon = const Icon(Icons.hourglass_empty, color: Colors.grey);
                        }

                        return ListTile(
                          leading: statusIcon,
                          title: Text(playerName),
                          subtitle: Text('Status: ${playerStatus.name}'),
                        );
                      },
                    );
                  },
                )
            ]
          ],
        ),
      ),
    );
  }
}