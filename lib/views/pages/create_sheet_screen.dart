import 'package:flutter/material.dart';
import '../../controllers/character_controller.dart';

class CreateSheetScreen extends StatefulWidget {
  const CreateSheetScreen({super.key});

  @override
  State<CreateSheetScreen> createState() => _CreateSheetScreenState();
}

class _CreateSheetScreenState extends State<CreateSheetScreen> {
  final CharacterController _characterController = CharacterController();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _classController = TextEditingController();
  final _levelController = TextEditingController();
  String? _selectedSystem;
  bool _isLoading = false;

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      _characterController.createSheet(
        characterName: _nameController.text,
        className: _classController.text,
        level: int.tryParse(_levelController.text) ?? 1,
        system: _selectedSystem!,
      );

      Future.delayed(const Duration(milliseconds: 500)).then((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ficha criada com sucesso!')),
          );
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableSystems = _characterController.availableSystems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Nova Ficha'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Personagem',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value?.isEmpty ?? true) ? 'O nome é obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _classController,
                decoration: const InputDecoration(
                  labelText: 'Classe (ex: Guerreiro, Mago)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value?.isEmpty ?? true) ? 'A classe é obrigatória' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _levelController,
                decoration: const InputDecoration(
                  labelText: 'Nível',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'O nível é obrigatório';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Por favor, insira um número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedSystem,
                decoration: const InputDecoration(
                  labelText: 'Sistema',
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Selecione o sistema de RPG'),
                items: availableSystems.map((String system) {
                  return DropdownMenuItem<String>(
                    value: system,
                    child: Text(system),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSystem = newValue;
                  });
                },
                validator: (value) => value == null ? 'Selecione um sistema' : null,
              ),

              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('CRIAR FICHA'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}