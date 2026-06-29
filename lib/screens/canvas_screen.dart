// ═══════════════════════════════════════════════════════════
//  استبدل دالة _addLeaf في canvas_screen.dart بهذه النسخة
// ═══════════════════════════════════════════════════════════

void _addLeaf(String branchId) {
  final trunk = _project.trunk;
  if (trunk == null) return;
  final bi = trunk.branches.indexWhere((b) => b.id == branchId);
  if (bi < 0) return;
  final branch = trunk.branches[bi];
  final count = branch.leaves.length;

  // حساب نقطة نهاية الغصن (الموضع المطلق)
  final endX = branch.length * math.cos(branch.angle);
  final endY = -branch.length * math.sin(branch.angle);

  // توزيع الأوراق حول نهاية الغصن بمواضع مطلقة
  final side = count.isEven ? 1.0 : -1.0;
  final spread = 28.0 + (count ~/ 2) * 20.0;
  final angOffset = 0.5 + (count ~/ 2) * 0.3;

  final leaf = LeafModel(
    id: const Uuid().v4(),
    name: 'ورقة ${count + 1}',
    // الموضع بالنسبة لأصل الغصن (branch.x, branch.y) وليس نهايته
    x: endX + spread * math.cos(branch.angle + side * angOffset),
    y: endY - spread * math.sin(branch.angle + side * angOffset),
    rotation: branch.angle + side * angOffset - math.pi / 2,
  );

  final nb = branch.copyWith(leaves: [...branch.leaves, leaf]);
  final bList = List<BranchModel>.from(trunk.branches)..[bi] = nb;
  _upd(_project.copyWith(trunk: trunk.copyWith(branches: bList)));
}
