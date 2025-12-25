import 'package:flutter/material.dart';

class WorkerDashboard extends StatelessWidget {
  const WorkerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Panel Trabajador'),
        backgroundColor: const Color(0xFF37474F),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Dashboard Trabajador',
          style: TextStyle(fontSize: 24, color: Color(0xFF2C2C2C)),
        ),
      ),
    );
  }
}

