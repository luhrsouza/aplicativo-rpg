import 'package:flutter/material.dart';
import '../../controllers/campaign_controller.dart';

class JoinCampaignScreen extends StatefulWidget {
  const JoinCampaignScreen({super.key});

  @override
  State<JoinCampaignScreen> createState() => _JoinCampaignScreenState();
}

class _JoinCampaignScreenState extends State<JoinCampaignScreen> {
  final CampaignController _campaignController = CampaignController();
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final success = await _campaignController.joinCampaignByCode(_codeController.text.toUpperCase());

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Você entrou na campanha!')),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Código inválido ou você já está na campanha.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrar em uma Campanha'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Código da Campanha',
                  border: OutlineInputBorder(),
                  hintText: 'ABCDEF',
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) => (value?.isEmpty ?? true) ? 'O código é obrigatório' : null,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _submitForm,
                child: const Text('ENTRAR'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}