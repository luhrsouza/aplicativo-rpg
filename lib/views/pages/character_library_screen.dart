import 'package:flutter/material.dart';
import '../../controllers/character_controller.dart';
import '../../models/character_sheet.dart';
import 'create_sheet_screen.dart';
import 'edit_sheet_screen.dart';
import 'sheet_viewer_screen.dart';

class CharacterLibraryScreen extends StatefulWidget {
  const CharacterLibraryScreen({super.key});

  @override
  State<CharacterLibraryScreen> createState() => _CharacterLibraryScreenState();
}

class _CharacterLibraryScreenState extends State<CharacterLibraryScreen> {
  final CharacterController _characterController = CharacterController();

  bool _isSelectionMode = false;
  final Set<String> _selectedSheetIds = {};


  void _navigateToCreateSheet() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CreateSheetScreen()),
    );
  }

  void _onTap(bool isSelected, CharacterSheet sheet, List<CharacterSheet> allSheets, int index) {
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
          builder: (context) => SheetViewerScreen(
            sheets: allSheets,
            initialIndex: index,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              // Chama o novo método async do controller
              _characterController.deleteSheets(_selectedSheetIds.toList());
              setState(() {
                _isSelectionMode = false;
                _selectedSheetIds.clear();
              });
            },
          ),
        ]
            : [],
      ),
      body: StreamBuilder<List<CharacterSheet>>(
        stream: _characterController.getSheetsStreamForCurrentUser(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar fichas.'));
          }

          final sheets = snapshot.data ?? [];
          if (sheets.isEmpty) {
            return const Center(
              child: Text(
                'Você ainda não criou nenhuma ficha.\nClique no botão "+" para começar!',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: sheets.length,
            itemBuilder: (context, index) {
              final sheet = sheets[index];
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
                  onTap: () => _onTap(isSelected, sheet, sheets, index),
                  leading: CircleAvatar(
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : Text(sheet.level.toString()),
                  ),
                  title: Text(sheet.characterName),
                  subtitle: Text('${sheet.className} | ${sheet.system}'),
                  trailing: _isSelectionMode ? null : const Icon(Icons.edit),
                ),
              );
            },
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