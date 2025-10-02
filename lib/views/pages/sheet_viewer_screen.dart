import 'package:flutter/material.dart';
import '../../models/character_sheet.dart';
import '../widgets/sheet_detail_card.dart';

class SheetViewerScreen extends StatefulWidget {
  final List<CharacterSheet> sheets;
  final int initialIndex;

  const SheetViewerScreen({
    super.key,
    required this.sheets,
    required this.initialIndex,
  });

  @override
  State<SheetViewerScreen> createState() => _SheetViewerScreenState();
}

class _SheetViewerScreenState extends State<SheetViewerScreen> {
  late final PageController _pageController;
  late String _currentCharacterName;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentCharacterName = widget.sheets[widget.initialIndex].characterName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentCharacterName),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.sheets.length,
        onPageChanged: (int index) {
          setState(() {
            _currentCharacterName = widget.sheets[index].characterName;
          });
        },
        itemBuilder: (context, index) {
          final sheet = widget.sheets[index];
          return SheetDetailCard(sheet: sheet);
        },
      ),
    );
  }
}