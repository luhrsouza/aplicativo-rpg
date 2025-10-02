import 'package:flutter/material.dart';
import '../../controllers/character_controller.dart';
import '../../models/character_sheet.dart';
import 'create_sheet_screen.dart';
import 'sheet_viewer_screen.dart';

class CharacterLibraryScreen extends StatefulWidget {
  const CharacterLibraryScreen({super.key});

  @override
  State<CharacterLibraryScreen> createState() => _CharacterLibraryScreenState();
}

class _CharacterLibraryScreenState extends State<CharacterLibraryScreen> {
  final CharacterController _characterController = CharacterController();
  late List<CharacterSheet> _sheets;
  bool _isSelectionMode = false;
  final Set<String> _selectedSheetIds = {};

  @override
  void initState() {
    super.initState();
    _sheets = _characterController.getSheetsForCurrentUser();
  }

  void _navigateToCreateSheet() {
    print('Navegar para a tela de criar ficha');
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CreateSheetScreen()),
    ).then((_) {
      setState(() {
        _sheets = _characterController.getSheetsForCurrentUser();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: _isSelectionMode
          ? Text('${_selectedSheetIds.length} selecionada(s)')
          : const Text('Minhas Fichas'),
      leading: _isSelectionMode
          ? IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          setState(() {
            _isSelectionMode = false;
            _selectedSheetIds.clear();
          });
        },
      )
          : null,
      actions: _isSelectionMode
          ? [
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            _characterController.deleteSheets(_selectedSheetIds.toList());
            setState(() {
              _sheets = _characterController.getSheetsForCurrentUser();
              _isSelectionMode = false;
              _selectedSheetIds.clear();
            });
          },
        ),
      ]
          : [],
    );

    return Scaffold(
      appBar: appBar,
      body: _sheets.isEmpty
          ? const Center(
        child: Text(
          'Você ainda não criou nenhuma ficha.\nClique no botão "+" para começar!',
          textAlign: TextAlign.center,
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _sheets.length,
        itemBuilder: (context, index) {
          final sheet = _sheets[index];
          final isSelected = _selectedSheetIds.contains(sheet.id);

          return Card(
            color: isSelected ? Colors.deepPurple.withOpacity(0.5) : null,
            child: ListTile(
              onLongPress: () {
                setState(() {
                  _isSelectionMode = true;
                  _selectedSheetIds.add(sheet.id);
                });
              },
              onTap: () {
                if (_isSelectionMode) {
                  setState(() {
                    if (isSelected) {
                      _selectedSheetIds.remove(sheet.id);
                      if (_selectedSheetIds.isEmpty) {
                        _isSelectionMode = false;
                      }
                    } else {
                      _selectedSheetIds.add(sheet.id);
                    }
                  });
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          SheetViewerScreen(
                            sheets: _sheets,
                            initialIndex: index,
                          ),
                    ),
                  ).then((_) {
                    setState(() {
                      _sheets = _characterController.getSheetsForCurrentUser();
                    });
                  });
                }
              },
              leading: CircleAvatar(
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white)
                    : Text(sheet.level.toString()),
              ),
              title: Text(sheet.characterName),
              subtitle: Text(sheet.className),
            ),
          );
        },
      ),
      floatingActionButton: _isSelectionMode
          ? null
          : FloatingActionButton(
        onPressed: _navigateToCreateSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}