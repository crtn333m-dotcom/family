import 'package:shared_preferences/shared_preferences.dart';
import '../models/tree_model.dart';

class StorageService {
  static const _key = 'projects';

  static Future<List<ProjectModel>> loadProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map((s) => ProjectModel.fromJson(s)).toList();
  }

  static Future<void> saveProjects(List<ProjectModel> projects) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, projects.map((p) => p.toJson()).toList());
  }

  static Future<void> saveProject(ProjectModel project) async {
    final projects = await loadProjects();
    final index = projects.indexWhere((p) => p.id == project.id);
    if (index >= 0) {
      projects[index] = project;
    } else {
      projects.add(project);
    }
    await saveProjects(projects);
  }

  static Future<void> deleteProject(String id) async {
    final projects = await loadProjects();
    projects.removeWhere((p) => p.id == id);
    await saveProjects(projects);
  }
}
