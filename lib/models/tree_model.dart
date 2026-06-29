import 'dart:convert';

class LeafModel {
  String id;
  String name;
  double x;
  double y;
  double width;
  double height;
  bool isLocked;

  LeafModel({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
    this.width = 60,
    this.height = 40,
    this.isLocked = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'x': x, 'y': y,
    'width': width, 'height': height, 'isLocked': isLocked,
  };

  factory LeafModel.fromMap(Map<String, dynamic> m) => LeafModel(
    id: m['id'], name: m['name'], x: m['x'], y: m['y'],
    width: m['width'] ?? 60, height: m['height'] ?? 40,
    isLocked: m['isLocked'] ?? false,
  );
}

class BranchModel {
  String id;
  String name;
  double x;
  double y;
  double length;
  double thickness;
  double angle;
  double curve;
  bool isLocked;
  List<LeafModel> leaves;

  BranchModel({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
    this.length = 120,
    this.thickness = 14,
    this.angle = 0,
    this.curve = 0.3,
    this.isLocked = false,
    List<LeafModel>? leaves,
  }) : leaves = leaves ?? [];

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'x': x, 'y': y,
    'length': length, 'thickness': thickness,
    'angle': angle, 'curve': curve,
    'isLocked': isLocked,
    'leaves': leaves.map((l) => l.toMap()).toList(),
  };

  factory BranchModel.fromMap(Map<String, dynamic> m) => BranchModel(
    id: m['id'], name: m['name'], x: m['x'], y: m['y'],
    length: m['length'] ?? 120, thickness: m['thickness'] ?? 14,
    angle: m['angle'] ?? 0, curve: m['curve'] ?? 0.3,
    isLocked: m['isLocked'] ?? false,
    leaves: (m['leaves'] as List? ?? [])
        .map((l) => LeafModel.fromMap(l)).toList(),
  );
}

class TrunkModel {
  String id;
  List<String> names;
  double x;
  double y;
  double height;
  double thickness;
  bool isLocked;
  List<BranchModel> branches;

  TrunkModel({
    required this.id,
    required this.x,
    required this.y,
    List<String>? names,
    this.height = 200,
    this.thickness = 40,
    this.isLocked = false,
    List<BranchModel>? branches,
  }) : names = names ?? [], branches = branches ?? [];

  Map<String, dynamic> toMap() => {
    'id': id, 'names': names, 'x': x, 'y': y,
    'height': height, 'thickness': thickness,
    'isLocked': isLocked,
    'branches': branches.map((b) => b.toMap()).toList(),
  };

  factory TrunkModel.fromMap(Map<String, dynamic> m) => TrunkModel(
    id: m['id'], x: m['x'], y: m['y'],
    names: List<String>.from(m['names'] ?? []),
    height: m['height'] ?? 200, thickness: m['thickness'] ?? 40,
    isLocked: m['isLocked'] ?? false,
    branches: (m['branches'] as List? ?? [])
        .map((b) => BranchModel.fromMap(b)).toList(),
  );
}

class ProjectModel {
  String id;
  String name;
  DateTime createdAt;
  TrunkModel? trunk;

  ProjectModel({
    required this.id,
    required this.name,
    required this.createdAt,
    this.trunk,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name,
    'createdAt': createdAt.toIso8601String(),
    'trunk': trunk?.toMap(),
  };

  factory ProjectModel.fromMap(Map<String, dynamic> m) => ProjectModel(
    id: m['id'], name: m['name'],
    createdAt: DateTime.parse(m['createdAt']),
    trunk: m['trunk'] != null ? TrunkModel.fromMap(m['trunk']) : null,
  );

  String toJson() => jsonEncode(toMap());
  factory ProjectModel.fromJson(String s) =>
      ProjectModel.fromMap(jsonDecode(s));
}
