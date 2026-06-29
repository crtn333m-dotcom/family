import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../models/tree_model.dart';
import '../services/storage_service.dart';
import 'canvas_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<ProjectModel> _projects = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final projects = await StorageService.loadProjects();
    setState(() {
      _projects = projects;
      _loading = false;
    });
  }

  Future<void> _createProject() async {
    final nameController = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFF8E1),
        title: const Text(
          'مشروع جديد',
          style: TextStyle(fontFamily: 'Amiri', color: Color(0xFF3E2723)),
          textAlign: TextAlign.center,
        ),
        content: TextField(
          controller: nameController,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            hintText: 'اسم المشروع',
            hintStyle: TextStyle(fontFamily: 'Amiri'),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF5D4037)),
            ),
          ),
          style: const TextStyle(fontFamily: 'Amiri', fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء',
                style: TextStyle(fontFamily: 'Amiri', color: Color(0xFF5D4037))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5D4037)),
            onPressed: () => Navigator.pop(ctx, nameController.text.trim()),
            child: const Text('إنشاء',
                style: TextStyle(fontFamily: 'Amiri', color: Colors.white)),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      final project = ProjectModel(
        id: const Uuid().v4(),
        name: name,
        createdAt: DateTime.now(),
      );
      await StorageService.saveProject(project);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CanvasScreen(project: project),
          ),
        ).then((_) => _load());
      }
    }
  }

  Future<void> _deleteProject(ProjectModel project) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFF8E1),
        title: const Text('حذف المشروع',
            style: TextStyle(fontFamily: 'Amiri', color: Color(0xFF3E2723)),
            textAlign: TextAlign.center),
        content: Text('هل تريد حذف "${project.name}"؟',
            style: const TextStyle(fontFamily: 'Amiri'),
            textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء',
                style: TextStyle(fontFamily: 'Amiri', color: Color(0xFF5D4037))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف',
                style: TextStyle(fontFamily: 'Amiri', color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await StorageService.deleteProject(project.id);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text('سلالتي',
            style: TextStyle(fontFamily: 'Amiri', fontSize: 26)),
        backgroundColor: const Color(0xFF3E2723),
        foregroundColor: const Color(0xFFFFD54F),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF5D4037)))
          : _projects.isEmpty
              ? _buildEmpty()
              : _buildList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createProject,
        backgroundColor: const Color(0xFF5D4037),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('مشروع جديد',
            style: TextStyle(fontFamily: 'Amiri', fontSize: 16)),
      ).animate().fadeIn(delay: 300.ms).slideY(begin: 1),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌱', style: TextStyle(fontSize: 80))
              .animate().scale(duration: 600.ms),
          const SizedBox(height: 24),
          const Text('لا توجد مشاريع بعد',
              style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 24,
                  color: Color(0xFF5D4037))),
          const SizedBox(height: 8),
          const Text('ابدأ بإنشاء شجرتك الأولى',
              style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 16,
                  color: Color(0xFF8D6E63))),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _projects.length,
      itemBuilder: (context, index) {
        final project = _projects[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: const Color(0xFFFFF3E0),
          elevation: 2,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 12),
            leading: const Text('🌳', style: TextStyle(fontSize: 36)),
            title: Text(project.name,
                style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 20,
                    color: Color(0xFF3E2723),
                    fontWeight: FontWeight.bold)),
            subtitle: Text(
              '${project.createdAt.year}/${project.createdAt.month}/${project.createdAt.day}',
              style: const TextStyle(
                  fontFamily: 'Amiri', color: Color(0xFF8D6E63)),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deleteProject(project),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => CanvasScreen(project: project)),
            ).then((_) => _load()),
          ),
        ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.2);
      },
    );
  }
}
