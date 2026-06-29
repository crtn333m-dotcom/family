import 'dart:math' as math;
import 'package:uuid/uuid.dart';
import '../models/tree_model.dart';

class TemplatesService {
  static const _uuid = Uuid();

  static List<ProjectModel> get all => [
    _familyTree(), _tribeTree(), _orgChart(), _ancestorTree(),
  ];

  // ── شجرة عائلية بسيطة ───────────────
  static ProjectModel _familyTree() {
    const cx = 200.0, cy = 520.0;
    final trunk = TrunkModel(
      id: _uuid.v4(), x: cx, y: cy,
      names: ['الجد محمد', 'الجدة فاطمة'],
      height: 240, thickness: 44,
    );
    final data = [
      ('الأب عمر',    -1,  0, -0.85),
      ('العم أحمد',    1,  1, -0.70),
      ('الأب الثاني',  -1, 2, -0.55),
      ('العمة سارة',   1,  3, -0.40),
      ('الأخ خالد',   -1,  4, -0.25),
      ('الأخت نور',    1,  5, -0.15),
    ];
    for (final (name, side, idx, angleMod) in data) {
      final b = BranchModel(
        id: _uuid.v4(), name: name,
        x: cx + side * 55, y: cy - 90 - idx * 28,
        angle: side * (0.45 + idx * 0.07),
        length: 105 + idx * 6, headRadius: 26,
      );
      for (int j = 0; j < 2; j++) {
        b.leaves.add(LeafModel(
          id: _uuid.v4(), name: 'فرد ${j + 1}',
          x: side * (28.0 + j * 20), y: -35 - j * 15,
        ));
      }
      trunk.branches.add(b);
    }
    return ProjectModel(
      id: _uuid.v4(), name: '🌳 شجرة العائلة',
      createdAt: DateTime.now(), trunk: trunk,
    );
  }

  // ── شجرة قبيلة ──────────────────────
  static ProjectModel _tribeTree() {
    const cx = 200.0, cy = 530.0;
    final trunk = TrunkModel(
      id: _uuid.v4(), x: cx, y: cy,
      names: ['القبيلة', 'الجد الأكبر', 'الأصل'],
      height: 270, thickness: 52,
      style: TrunkStyle.baobab, color: 0xFF4E342E,
    );
    final forks = [
      ('الفرع الأول',  -1, 0),
      ('الفرع الثاني',  1, 1),
      ('الفرع الثالث', -1, 2),
      ('الفرع الرابع',  1, 3),
      ('الفرع الخامس', -1, 4),
    ];
    for (final (name, side, idx) in forks) {
      final b = BranchModel(
        id: _uuid.v4(), name: name,
        x: cx + side * 60, y: cy - 110 - idx * 36,
        angle: side * (0.5 + idx * 0.08),
        length: 125, thickness: 15, headRadius: 30,
        style: BranchStyle.curved, color: 0xFF6D4C41,
      );
      b.leaves.add(LeafModel(
        id: _uuid.v4(), name: 'عائلة',
        x: side * 30, y: -38,
      ));
      trunk.branches.add(b);
    }
    return ProjectModel(
      id: _uuid.v4(), name: '🏕️ شجرة القبيلة',
      createdAt: DateTime.now(), trunk: trunk,
    );
  }

  // ── هيكل تنظيمي ─────────────────────
  static ProjectModel _orgChart() {
    const cx = 200.0, cy = 490.0;
    final trunk = TrunkModel(
      id: _uuid.v4(), x: cx, y: cy,
      names: ['المدير العام'],
      height: 200, thickness: 36,
      style: TrunkStyle.cedar, color: 0xFF37474F,
    );
    final depts = [
      ('التقنية',   -1, 0, 0xFF1565C0),
      ('المالية',    1, 1, 0xFF2E7D32),
      ('التسويق',   -1, 2, 0xFF6A1B9A),
      ('الموارد',    1, 3, 0xFFC62828),
      ('العمليات',  -1, 4, 0xFFE65100),
    ];
    for (final (name, side, idx, c) in depts) {
      final b = BranchModel(
        id: _uuid.v4(), name: name,
        x: cx + side * 52, y: cy - 80 - idx * 30,
        angle: side * 0.6, length: 100,
        headRadius: 28, color: c,
        style: BranchStyle.straight,
      );
      b.leaves.add(LeafModel(
        id: _uuid.v4(), name: 'موظف',
        x: side * 32, y: -34,
        color: c,
      ));
      trunk.branches.add(b);
    }
    return ProjectModel(
      id: _uuid.v4(), name: '🏢 الهيكل التنظيمي',
      createdAt: DateTime.now(), trunk: trunk,
    );
  }

  // ── شجرة أجداد ──────────────────────
  static ProjectModel _ancestorTree() {
    const cx = 200.0, cy = 540.0;
    final trunk = TrunkModel(
      id: _uuid.v4(), x: cx, y: cy,
      names: ['آدم', 'حواء'],
      height: 300, thickness: 56,
      style: TrunkStyle.palm, color: 0xFF3E2723,
    );
    for (int gen = 0; gen < 3; gen++) {
      for (int side in [-1, 1]) {
        final b = BranchModel(
          id: _uuid.v4(),
          name: 'الجيل ${gen + 1}',
          x: cx + side * (45 + gen * 15),
          y: cy - 120 - gen * 55,
          angle: side * (0.4 + gen * 0.12),
          length: 90 + gen * 10,
          headRadius: 24 + gen * 2,
          thickness: (14 - gen).toDouble(), // ✅ تم التصحيح
        );
        b.leaves.add(LeafModel(
          id: _uuid.v4(), name: 'سلف',
          x: side * 28, y: -36,
        ));
        trunk.branches.add(b);
      }
    }
    return ProjectModel(
      id: _uuid.v4(), name: '📜 شجرة الأجداد',
      createdAt: DateTime.now(), trunk: trunk,
    );
  }
}
