import 'package:flutter/material.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text(
          'سلالتي',
          style: TextStyle(fontFamily: 'Amiri', fontSize: 24),
        ),
        backgroundColor: const Color(0xFF5D4037),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'قريباً...',
          style: TextStyle(fontFamily: 'Amiri', fontSize: 24),
        ),
      ),
    );
  }
}
