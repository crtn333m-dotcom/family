import 'dart:convert';

enum TrunkStyle { classic, baobab, palm, cedar, willow, pine }
enum BranchStyle { curved, straight, zigzag, vine, drooping }
enum LeafStyle { oval, pointed, round, heart, pine, maple, palm, feather }

// ════════════════════════════════════════
class LeafModel {
  final String id;
  String name;
  double x, y, width, height, rotation, scaleX;
  bool isLocked;
  LeafStyle style;
  int color;

  LeafModel({
    required this.id,
    this.name = '',
    this.x = 0,
    this.y = -40,
    this.width = 44,
    this.height = 64,
    this.rotation = 0,
    this.scaleX = 1.0,
    this.isLocked = false,
    this.style = LeafStyle.oval,
    this.color = 0xFF4CAF50,
  });

  LeafModel copyWith({
    String? id, String? name,
    double? x, double? y, double? width, double? height,
    double? rotation, double? scaleX,
    bool? isLocked, LeafStyle? style, int? color,
  }) => LeafModel(
    id: id ?? this.id, name: name ?? this.name,
    x: x ?? this.x, y: y ?? this.y,
    width: width ?? this.width, height: height ?? this.height,
    rotation: rotation ?? this.rotation,
    scaleX: scaleX ?? this.scaleX,
    isLocked: isLocked ?? this.isLocked,
    style: style ?? this.style, color: color ?? this.color,
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'x': x, 'y': y,
    'width': width, 'height': height,
    'rotation': rotation, 'scaleX': scaleX,
    'isLocked': isLocked, 'style': style.index, 'color': color,
  };

  factory LeafModel.fromMap(Map<String, dynamic> m) => LeafModel(
    id: m['id'], name: m['name'] ?? '',
    x: (m['x'] as num).toDouble(), y: (m['y'] as num).toDouble(),
    width: (m['width'] as num?)?.toDouble() ?? 44,
    height: (m['height'] as num?)?.toDouble() ?? 64,
    rotation: (m['rotation'] as num?)?.toDouble() ?? 0,
    scaleX: (m['scaleX'] as num?)?.toDouble() ?? 1.0,
    isLocked: m['isLocked'] ?? false,
    style: LeafStyle.values[m['style'] ?? 0],
    color: m['color'] ?? 0xFF4CAF50,
  );
}

// ════════════════════════════════════════
class BranchModel {
  final String id;
  String name;
  double x, y, length, thickness, angle, curve, headRadius, rotation, scaleX;
  bool isLocked;
  List<LeafModel> leaves;
  BranchStyle style;
  int color;

  BranchModel({
    required this.id,
    this.name = '',
    required this.x, required this.y,
    this.length = 120, this.thickness = 14,
    this.angle = 1.0, this.curve = 0.3,
    this.headRadius = 26,
    this.rotation = 0,
    this.scaleX = 1.0,
    this.isLocked = false,
    List<LeafModel>? leaves,
    this.style = BranchStyle.curved,
    this.color = 0xFF795548,
  }) : leaves = leaves ?? [];

  BranchModel copyWith({
    String? id, String? name,
    double? x, double? y,
    double? length, double? thickness,
    double? angle, double? curve, double? headRadius,
    double? rotation, double? scaleX,
    bool? isLocked, List<LeafModel>? leaves,
    BranchStyle? style, int? color,
  }) => BranchModel(
    id: id ?? this.id, name: name ?? this.name,
    x: x ?? this.x, y: y ?? this.y,
    length: length ?? this.length, thickness: thickness ?? this.thickness,
    angle: angle ?? this.angle, curve: curve ?? this.curve,
    headRadius: headRadius ?? this.headRadius,
    rotation: rotation ?? this.rotation,
    scaleX: scaleX ?? this.scaleX,
    isLocked: isLocked ?? this.isLocked,
    leaves: leaves ?? List<LeafModel>.from(this.leaves),
    style: style ?? this.style, color: color ?? this.color,
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'x': x, 'y': y,
    'length': length, 'thickness': thickness,
    'angle': angle, 'curve': curve, 'headRadius': headRadius,
    'rotation': rotation, 'scaleX': scaleX,
    'isLocked': isLocked,
    'leaves': leaves.map((l) => l.toMap()).toList(),
    'style': style.index, 'color': color,
  };

  factory BranchModel.fromMap(Map<String, dynamic> m) => BranchModel(
    id: m['id'], name: m['name'] ?? '',
    x: (m['x'] as num).toDouble(), y: (m['y'] as num).toDouble(),
    length: (m['length'] as num?)?.toDouble() ?? 120,
    thickness: (m['thickness'] as num?)?.toDouble() ?? 14,
    angle: (m['angle'] as num?)?.toDouble() ?? 1.0,
    curve: (m['curve'] as num?)?.toDouble() ?? 0.3,
    headRadius: (m['headRadius'] as num?)?.toDouble() ?? 26,
    rotation: (m['rotation'] as num?)?.toDouble() ?? 0,
    scaleX: (m['scaleX'] as num?)?.toDouble() ?? 1.0,
    isLocked: m['isLocked'] ?? false,
    leaves: (m['leaves'] as List?)
        ?.map((l) => LeafModel.fromMap(l)).toList() ?? [],
    style: BranchStyle.values[m['style'] ?? 0],
    color: m['color'] ?? 0xFF795548,
  );
}

// ════════════════════════════════════════
class TrunkModel {
  final String id;
  double x, y, height, thickness, rotation, scaleX, bend;
  List<String> names;
  bool isLocked;
  List<BranchModel> branches;
  TrunkStyle style;
  int color;

  TrunkModel({
    required this.id, required this.x, required this.y,
    List<String>? names,
    this.height = 220, this.thickness = 40,
    this.rotation = 0, this.scaleX = 1.0, this.bend = 0.0,
    this.isLocked = false,
    List<BranchModel>? branches,
    this.style = TrunkStyle.classic,
    this.color = 0xFF5D4037,
  }) : names = names ?? [],
       branches = branches ?? [];

  TrunkModel copyWith({
    String? id, double? x, double? y,
    List<String>? names,
    double? height, double? thickness,
    double? rotation, double? scaleX, double? bend,
    bool? isLocked, List<BranchModel>? branches,
    TrunkStyle? style, int? color,
  }) => TrunkModel(
    id: id ?? this.id, x: x ?? this.x, y: y ?? this.y,
    names: names ?? List<String>.from(this.names),
    height: height ?? this.height, thickness: thickness ?? this.thickness,
    rotation: rotation ?? this.rotation,
    scaleX: scaleX ?? this.scaleX,
    bend: bend ?? this.bend,
    isLocked: isLocked ?? this.isLocked,
    branches: branches ?? List<BranchModel>.from(this.branches),
    style: style ?? this.style, color: color ?? this.color,
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'x': x, 'y': y, 'names': names,
    'height': height, 'thickness': thickness,
    'rotation': rotation, 'scaleX': scaleX, 'bend': bend,
    'isLocked': isLocked,
    'branches': branches.map((b) => b.toMap()).toList(),
    'style': style.index, 'color': color,
  };

  factory TrunkModel.fromMap(Map<String, dynamic> m) => TrunkModel(
    id: m['id'],
    x: (m['x'] as num).toDouble(), y: (m['y'] as num).toDouble(),
    names: List<String>.from(m['names'] ?? []),
    height: (m['height'] as num?)?.toDouble() ?? 220,
    thickness: (m['thickness'] as num?)?.toDouble() ?? 40,
    rotation: (m['rotation'] as num?)?.toDouble() ?? 0,
    scaleX: (m['scaleX'] as num?)?.toDouble() ?? 1.0,
    bend: (m['bend'] as num?)?.toDouble() ?? 0.0,
    isLocked: m['isLocked'] ?? false,
    branches: (m['branches'] as List?)
        ?.map((b) => BranchModel.fromMap(b)).toList() ?? [],
    style: TrunkStyle.values[m['style'] ?? 0],
    color: m['color'] ?? 0xFF5D4037,
  );
}

// ════════════════════════════════════════
class ProjectModel {
  final String id;
  String name;
  final DateTime createdAt;
  TrunkModel? trunk;

  ProjectModel({
    required this.id, required this.name,
    required this.createdAt, this.trunk,
  });

  ProjectModel copyWith({
    String? id, String? name,
    DateTime? createdAt, TrunkModel? trunk,
    bool clearTrunk = false,
  }) => ProjectModel(
    id: id ?? this.id, name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    trunk: clearTrunk ? null : (trunk ?? this.trunk),
  );

  String toJson() => jsonEncode({
    'id': id, 'name': name,
    'createdAt': createdAt.toIso8601String(),
    'trunk': trunk?.toMap(),
  });

  factory ProjectModel.fromJson(String s) {
    final m = jsonDecode(s);
    return ProjectModel(
      id: m['id'], name: m['name'],
      createdAt: DateTime.parse(m['createdAt']),
      trunk: m['trunk'] != null ? TrunkModel.fromMap(m['trunk']) : null,
    );
  }
}
