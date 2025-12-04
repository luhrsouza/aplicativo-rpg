import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class DiceRollerDialog extends StatefulWidget {
  const DiceRollerDialog({super.key});

  @override
  State<DiceRollerDialog> createState() => _DiceRollerDialogState();
}

class _DiceRollerDialogState extends State<DiceRollerDialog> {
  double x = 0, y = 0, z = 0;
  String _diceResult = '?';
  bool _isRolling = false;
  StreamSubscription? _accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  void _startListening() {
    _accelerometerSubscription = userAccelerometerEventStream().listen((UserAccelerometerEvent event) {
      if (!mounted) return;

      setState(() {
        x = event.x;
        y = event.y;
        z = event.z;
      });

      double acceleration = sqrt(x * x + y * y + z * z);

      if (acceleration > 15 && !_isRolling) {
        _rollDice();
      }
    });
  }

  void _rollDice() async {
    setState(() {
      _isRolling = true;
      _diceResult = '...';
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _diceResult = (Random().nextInt(20) + 1).toString();
        _isRolling = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rolar d20 🎲', textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Balance o celular para rolar!', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.deepPurple, width: 2),
            ),
            alignment: Alignment.center,
            child: _isRolling
                ? const CircularProgressIndicator()
                : Text(
              _diceResult,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _isRolling ? null : _rollDice,
            icon: const Icon(Icons.refresh),
            label: const Text('Rolar Manualmente'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}