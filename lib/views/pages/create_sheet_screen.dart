import 'package:flutter/material.dart';
import '../../controllers/character_controller.dart';
import 'package:provider/provider.dart';

class CreateSheetScreen extends StatefulWidget {
  const CreateSheetScreen({super.key});

  @override
  State<CreateSheetScreen> createState() => _CreateSheetScreenState();
}

class _CreateSheetScreenState extends State<CreateSheetScreen> {
  late CharacterController _characterController = CharacterController();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _classController = TextEditingController();
  final _levelController = TextEditingController();
  String? _selectedSystem;
  String? _selectedClass;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _characterController = Provider.of<CharacterController>(context, listen: false);
    _characterController.loadClassesFromApi();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      _characterController.createSheet(
        characterName: _nameController.text,
          className: _selectedClass!,
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
    return Consumer<CharacterController>(
      builder: (context, controller, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Criar Nova Ficha')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nome do Personagem', border: OutlineInputBorder()),
                    validator: (value) => (value?.isEmpty ?? true) ? 'O nome é obrigatório' : null,
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _selectedClass,
                    decoration: const InputDecoration(
                      labelText: 'Classe (vinda da API)',
                      border: OutlineInputBorder(),
                    ),
                    hint: controller.loadedClasses.isEmpty
                        ? const Text('Carregando classes...')
                        : const Text('Selecione uma classe'),
                    items: controller.loadedClasses.isEmpty
                        ? []
                        : controller.loadedClasses.map((String className) {
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
                    validator: (value) => value == null ? 'Selecione uma classe' : null,
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _selectedSystem,
                    decoration: const InputDecoration(labelText: 'Sistema', border: OutlineInputBorder()),
                    items: controller.availableSystems.map((String system) {
                      return DropdownMenuItem<String>(value: system, child: Text(system));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedSystem = val),
                    validator: (value) => value == null ? 'Selecione um sistema' : null,
                  ),

                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _levelController,
                    decoration: const InputDecoration(labelText: 'Nível', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (value) => (value?.isEmpty ?? true) ? 'Obrigatório' : null,
                  ),
                  const SizedBox(height: 24),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('CRIAR FICHA'),
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