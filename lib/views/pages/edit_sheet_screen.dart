import 'package:flutter/material.dart';
import '../../controllers/character_controller.dart';
import '../../models/character_sheet.dart';

class EditSheetScreen extends StatefulWidget {
  final CharacterSheet sheet;

  const EditSheetScreen({super.key, required this.sheet});

  @override
  State<EditSheetScreen> createState() => _EditSheetScreenState();
}

class _EditSheetScreenState extends State<EditSheetScreen> {
  final CharacterController _characterController = CharacterController();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _classController;
  late TextEditingController _levelController;
  String? _selectedSystem;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.sheet.characterName);
    _classController = TextEditingController(text: widget.sheet.className);
    _levelController = TextEditingController(text: widget.sheet.level.toString());
    _selectedSystem = widget.sheet.system;
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      _characterController.editSheet(
        sheetId: widget.sheet.id,
        newCharacterName: _nameController.text,
        newClassName: _classController.text,
        newLevel: int.tryParse(_levelController.text) ?? 1,
        newSystem: _selectedSystem!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ficha atualizada com sucesso!')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Ficha'),
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
                decoration: const InputDecoration(labelText: 'Nome do Personagem'),
                validator: (value) => (value?.isEmpty ?? true) ? 'O nome é obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _classController,
                decoration: const InputDecoration(labelText: 'Classe'),
                validator: (value) => (value?.isEmpty ?? true) ? 'A classe é obrigatória' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _levelController,
                decoration: const InputDecoration(labelText: 'Nível'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'O nível é obrigatório';
                  if (int.tryParse(value) == null) return 'Insira um número válido';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('SALVAR ALTERAÇÕES'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}