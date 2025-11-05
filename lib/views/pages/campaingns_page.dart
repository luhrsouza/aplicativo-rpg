import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/campaign_controller.dart';
import '../../models/campaign.dart';
import 'campaign_details_screen.dart';

class CampaignsPage extends StatelessWidget {
  const CampaignsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final campaignController = Provider.of<CampaignController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suas Campanhas'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<Campaign>>(
        stream: campaignController.getCampaignsStream(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print(snapshot.error);
            return const Center(child: Text('Erro ao carregar campanhas.'));
          }

          final campaigns = snapshot.data ?? [];
          if (campaigns.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Você ainda não participa de nenhuma campanha :(',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: campaigns.length,
            itemBuilder: (context, index) {
              final campaign = campaigns[index];
              return Card(
                child: ListTile(
                  title: Text(campaign.name),
                  subtitle: Text(campaign.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CampaignDetailsScreen(campaignId: campaign.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}