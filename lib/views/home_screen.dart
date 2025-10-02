import 'package:flutter/material.dart';
import 'pages/campaingns_page.dart';
import 'pages/profile_page.dart';
import 'pages/create_campaign_screen.dart';
import 'pages/join_campaign_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    CampaignsPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAddCampaignDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('O que você deseja fazer?'),
          actions: <Widget>[
            TextButton(
              child: const Text('ENTRAR COM CÓDIGO'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const JoinCampaignScreen(),
                  ),
                ).then((_) => setState(() {}));
              },
            ),
            ElevatedButton(
              child: const Text('CRIAR CAMPANHA'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateCampaignScreen(),
                  ),
                ).then((_) {
                  setState(() {
                    //força a se resconstruir.
                  });
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.elementAt(_selectedIndex),

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCampaignDialog,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home, color: _selectedIndex == 0 ? Colors.deepPurple : Colors.grey),
              onPressed: () => _onItemTapped(0),
            ),
            const SizedBox(width: 48),
            IconButton(
              icon: Icon(Icons.person, color: _selectedIndex == 1 ? Colors.deepPurple : Colors.grey),
              onPressed: () => _onItemTapped(1),
            ),
          ],
        ),
      ),
    );
  }
}