import 'package:flutter/material.dart';
import '../../controllers/character_controller.dart';
import '../../models/character_sheet.dart';
import 'package:provider/provider.dart';

class EditSheetScreen extends StatefulWidget {
  final CharacterSheet sheet;

  const EditSheetScreen({super.key, required this.sheet});

  @override
  State<EditSheetScreen> createState() => _EditSheetScreenState();
}

class _EditSheetScreenState extends State<EditSheetScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _classController;
  late TextEditingController _levelController;
  String? _selectedSystem;
  String? _selectedClass;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.sheet.characterName);
    _levelController = TextEditingController(text: widget.sheet.level.toString());
    _selectedSystem = widget.sheet.system;
    _selectedClass = widget.sheet.className;

    Provider.of<CharacterController>(context, listen: false).loadClassesFromApi();
  }

  void _submitForm(CharacterController characterController) {
    if (_formKey.currentState?.validate() ?? false) {
      characterController.editSheet(
        sheetId: widget.sheet.id,
        newCharacterName: _nameController.text,
        newClassName: _selectedClass!,
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
    return Consumer<CharacterController>(
      builder: (context, characterController, child) {
        final dropdownValue = characterController.loadedClasses.contains(_selectedClass)
            ? _selectedClass
            : null;

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
                    decoration: const InputDecoration(
                      labelText: 'Nome do Personagem',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => (value?.isEmpty ?? true) ? 'O nome é obrigatório' : null,
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: dropdownValue,
                    decoration: const InputDecoration(
                      labelText: 'Classe (API D&D)',
                      border: OutlineInputBorder(),
                    ),
                    hint: characterController.loadedClasses.isEmpty
                        ? const Text('Carregando classes...')
                        : const Text('Selecione uma classe'),
                    items: characterController.loadedClasses.map((String className) {
                      return DropdownMenuItem<String>(
                        value: className,
                        child: Text(className),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedClass = newValue;
                      });
                    },
                    validator: (value) => value == null ? 'Selecione uma classe válida' : null,
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _selectedSystem,
                    decoration: const InputDecoration(
                      labelText: 'Sistema',
                      border: OutlineInputBorder(),
                    ),
                    items: characterController.availableSystems.map((String system) {
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
                    validator: (value) => value == null ? 'O sistema é obrigatório' : null,
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
                      if (value == null || value.isEmpty) return 'O nível é obrigatório';
                      if (int.tryParse(value) == null) return 'Insira um número válido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () => _submitForm(characterController),
                    child: const Text('SALVAR ALTERAÇÕES'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}