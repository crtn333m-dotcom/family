import 'package:shared_preferences/shared_preferences.dart';
import '../models/tree_model.dart';

class StorageService {
  static const _key = 'salati_projects_v3';

  static Future<List<ProjectModel>> loadProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map((s) {
      try { return ProjectModel.fromJson(s); }
      catch (_) { return null; }
    }).whereType<ProjectModel>().toList();
  }

  static Future<void> saveProject(ProjectModel project) async {
    final projects = await loadProjects();
    final idx = projects.indexWhere((p) => p.id == project.id);
    if (idx >= 0) projects[idx] = project; else projects.add(project);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, projects.map((p) => p.toJson()).toList());
  }

  static Future<void> deleteProject(String id) async {
    final projects = await loadProjects();
    projects.removeWhere((p) => p.id == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, projects.map((p) => p.toJson()).toList());
  }
}
