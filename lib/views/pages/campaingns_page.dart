import 'package:flutter/material.dart';
import '../../controllers/campaign_controller.dart';
import '../../models/campaign.dart';
import 'campaign_details_screen.dart';

class CampaignsPage extends StatefulWidget {
  const CampaignsPage({super.key});

  @override
  State<CampaignsPage> createState() => _CampaignsPageState();
}

class _CampaignsPageState extends State<CampaignsPage> {
  final CampaignController _campaignController = CampaignController();
  late List<Campaign> _userCampaigns;

  @override
  void initState() {
    super.initState();
    _userCampaigns = _campaignController.getCampaignsForCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suas Campanhas'),
        automaticallyImplyLeading: false,
      ),
      body: _userCampaigns.isEmpty
          ? const Center(
        child: Text('Você ainda não participa de nenhuma campanha :('),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _userCampaigns.length,
        itemBuilder: (context, index) {
          final campaign = _userCampaigns[index];
          return Card(
            child: ListTile(
              title: Text(campaign.name),
              subtitle: Text(campaign.description),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CampaignDetailsScreen(campaign: campaign),
                  ),
                ).then((_) => setState(() {}));
              },
            ),
          );
        },
      ),
    );
  }
}