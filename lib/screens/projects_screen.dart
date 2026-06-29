import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../models/tree_model.dart';
import '../services/storage_service.dart';
import '../services/templates_service.dart';
import '../main.dart';
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
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    var projects = await StorageService.loadProjects();
    if (projects.isEmpty) {
      for (final t in TemplatesService.all) {
        await StorageService.saveProject(t);
      }
      projects = TemplatesService.all;
    }
    if (mounted) setState(() { _projects = projects; _loading = false; });
  }

  Future<void> _create() async {
    final ctrl = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('مشروع جديد',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Amiri', fontSize: 20,
                color: isDark ? Colors.white : const Color(0xFF18120A))),
        content: TextField(
          controller: ctrl,
          textDirection: TextDirection.rtl,
          autofocus: true,
          style: TextStyle(fontFamily: 'Amiri',
              color: isDark ? Colors.white : const Color(0xFF18120A)),
          decoration: InputDecoration(
            hintText: 'اسم الشجرة...',
            hintStyle: TextStyle(fontFamily: 'Amiri',
                color: isDark ? Colors.white38 : Colors.black38),
            filled: true,
            fillColor: isDark ? const Color(0xFF272727) : const Color(0xFFF4F0EA),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء',
                style: TextStyle(fontFamily: 'Amiri', color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4A55A),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('إنشاء',
                style: TextStyle(fontFamily: 'Amiri', color: Colors.white)),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    final p = ProjectModel(
      id: const Uuid().v4(), name: name,
      createdAt: DateTime.now(),
    );
    await StorageService.saveProject(p);
    if (mounted) {
      await Navigator.push(context,
          MaterialPageRoute(builder: (_) => CanvasScreen(project: p)));
      _load();
    }
  }

  Future<void> _delete(ProjectModel p) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('حذف المشروع',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Amiri', color: Colors.red)),
        content: Text('هل تريد حذف "${p.name}"؟',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Amiri',
                color: isDark ? Colors.white70 : Colors.black87)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء',
                  style: TextStyle(fontFamily: 'Amiri', color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف',
                style: TextStyle(fontFamily: 'Amiri', color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true) { await StorageService.deleteProject(p.id); _load(); }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = SalatiApp.of(context)?.isDark ?? true;
    final accent = const Color(0xFFD4A55A);

    return Scaffold(
      appBar: AppBar(
        title: const Text('سلالتي'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: accent),
            onPressed: () => SalatiApp.of(context)?.toggleTheme(),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1,
              color: isDark ? const Color(0xFF272727) : const Color(0xFFE4D9CC)),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(
              color: Color(0xFFD4A55A)))
          : _projects.isEmpty
              ? _buildEmpty(isDark)
              : _buildList(isDark),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _create,
        backgroundColor: accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('مشروع جديد',
            style: TextStyle(fontFamily: 'Amiri', fontSize: 15)),
      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.5),
    );
  }

  Widget _buildEmpty(bool isDark) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('🌱', style: TextStyle(fontSize: 72))
          .animate().scale(duration: 500.ms),
      const SizedBox(height: 20),
      Text('لا توجد مشاريع',
          style: TextStyle(fontFamily: 'Amiri', fontSize: 22,
              color: isDark ? Colors.white : const Color(0xFF18120A))),
      const SizedBox(height: 8),
      Text('اضغط + لإنشاء شجرتك الأولى',
          style: TextStyle(fontFamily: 'Amiri', fontSize: 14,
              color: isDark ? Colors.white38 : Colors.black38)),
    ]),
  );

  Widget _buildList(bool isDark) => ListView.builder(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
    itemCount: _projects.length,
    itemBuilder: (_, i) {
      final p = _projects[i];
      final branchCount = p.trunk?.branches.length ?? 0;
      return GestureDetector(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => CanvasScreen(project: p)))
            .then((_) => _load()),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isDark ? const Color(0xFF272727) : const Color(0xFFE4D9CC)),
            boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 10, offset: const Offset(0, 4),
            )],
          ),
          child: Row(children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFD4A55A).withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text('🌳', style: TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: TextStyle(
                  fontFamily: 'Amiri', fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF18120A),
                )),
                const SizedBox(height: 3),
                Text(
                  '$branchCount غصن  •  ${p.createdAt.year}/${p.createdAt.month}/${p.createdAt.day}',
                  style: TextStyle(fontFamily: 'Amiri', fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.black38),
                ),
              ],
            )),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Colors.red, size: 22),
              onPressed: () => _delete(p),
            ),
          ]),
        ).animate().fadeIn(delay: (i * 60).ms).slideX(begin: 0.1),
      );
    },
  );
}
