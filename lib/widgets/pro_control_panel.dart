import 'package:flutter/material.dart';
import '../models/tree_model.dart';

class ProControlPanel extends StatefulWidget {
  final String selectedId;
  final String selectedType;
  final ProjectModel project;
  final void Function(ProjectModel) onUpdate;
  final VoidCallback? onAddLeaf;
  final VoidCallback onDelete;
  final VoidCallback onClose;

  const ProControlPanel({
    super.key,
    required this.selectedId,
    required this.selectedType,
    required this.project,
    required this.onUpdate,
    required this.onAddLeaf,
    required this.onDelete,
    required this.onClose,
  });

  @override
  State<ProControlPanel> createState() => _ProControlPanelState();
}

class _ProControlPanelState extends State<ProControlPanel> {
  late TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: _currentName);
  }

  @override
  void didUpdateWidget(ProControlPanel old) {
    super.didUpdateWidget(old);
    if (old.selectedId != widget.selectedId) {
      _nameCtrl.text = _currentName;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  String get _currentName {
    if (widget.selectedType == 'trunk') return widget.project.name;
    final b = widget.project.trunk?.branches
        .firstWhere((b) => b.id == widget.selectedId,
            orElse: () => BranchModel(id: '', name: '', x: 0, y: 0, angle: 0, curve: 0));
    return b?.name ?? '';
  }

  void _updateName(String val) {
    if (widget.selectedType == 'trunk') {
      widget.onUpdate(widget.project.copyWith(name: val));
    } else {
      final trunk = widget.project.trunk!;
      final list = trunk.branches.map((b) =>
        b.id == widget.selectedId ? b.copyWith(name: val) : b
      ).toList();
      widget.onUpdate(widget.project.copyWith(
          trunk: trunk.copyWith(branches: list)));
    }
  }

  void _updateColor(Color color) {
    if (widget.selectedType == 'trunk') {
      final trunk = widget.project.trunk!;
      widget.onUpdate(widget.project.copyWith(
          trunk: trunk.copyWith(color: color.value)));
    } else {
      final trunk = widget.project.trunk!;
      final list = trunk.branches.map((b) =>
        b.id == widget.selectedId ? b.copyWith(color: color.value) : b
      ).toList();
      widget.onUpdate(widget.project.copyWith(
          trunk: trunk.copyWith(branches: list)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final fg = isDark ? Colors.white : const Color(0xFF1C1C1C);
    final accent = const Color(0xFFD4A55A);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20, offset: const Offset(0, -4))],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Handle
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header row
            Row(children: [
              Icon(
                widget.selectedType == 'trunk'
                    ? Icons.forest_rounded
                    : Icons.call_split_rounded,
                color: accent, size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                widget.selectedType == 'trunk' ? 'تعديل الجذع' : 'تعديل الغصن',
                style: TextStyle(color: fg, fontFamily: 'Amiri',
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              // Add leaf button
              if (widget.onAddLeaf != null)
                _PanelBtn(
                  icon: Icons.eco_rounded,
                  label: 'ورقة',
                  onTap: widget.onAddLeaf!,
                  color: Colors.green.shade600,
                  isDark: isDark,
                ),
              const SizedBox(width: 8),
              // Delete button
              _PanelBtn(
                icon: Icons.delete_outline_rounded,
                label: 'حذف',
                onTap: widget.onDelete,
                color: Colors.red.shade400,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              // Close button
              GestureDetector(
                onTap: widget.onClose,
                child: Icon(Icons.close_rounded,
                    color: Colors.grey.shade600, size: 22),
              ),
            ]),

            const SizedBox(height: 16),

            // Name field
            TextField(
              controller: _nameCtrl,
              textDirection: TextDirection.rtl,
              style: TextStyle(color: fg, fontFamily: 'Amiri', fontSize: 14),
              decoration: InputDecoration(
                labelText: 'الاسم',
                labelStyle: TextStyle(
                    color: Colors.grey.shade600, fontFamily: 'Amiri'),
                filled: true,
                fillColor: isDark
                    ? const Color(0xFF242424)
                    : const Color(0xFFF5F0EA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: accent, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
              ),
              onChanged: _updateName,
            ),

            const SizedBox(height: 14),

            // Color palette
            Row(children: [
              Text('اللون:', style: TextStyle(
                  color: Colors.grey.shade600,
                  fontFamily: 'Amiri', fontSize: 13)),
              const SizedBox(width: 12),
              ..._colors.map((c) => GestureDetector(
                onTap: () => _updateColor(c),
                child: Container(
                  width: 28, height: 28,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3), width: 2),
                    boxShadow: [BoxShadow(
                        color: c.withOpacity(0.4), blurRadius: 6)],
                  ),
                ),
              )),
            ]),
          ]),
        ),
      ),
    );
  }

  static const _colors = [
    Color(0xFFD4A55A), // ذهبي
    Color(0xFF7CB88B), // أخضر
    Color(0xFF6B9FD4), // أزرق
    Color(0xFFD47B6B), // أحمر خفيف
    Color(0xFFB07DD4), // بنفسجي
    Color(0xFFD4C55A), // أصفر
  ];
}

class _PanelBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool isDark;
  const _PanelBtn({
    required this.icon, required this.label,
    required this.onTap, required this.color, required this.isDark,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(
          color: color, fontSize: 12, fontFamily: 'Amiri',
        )),
      ]),
    ),
  );
}
