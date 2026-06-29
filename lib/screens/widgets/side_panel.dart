import 'package:flutter/material.dart';
import '../models/tree_model.dart';

class SidePanel extends StatefulWidget {
  final bool isOpen;
  final VoidCallback onToggle;
  final ProjectModel project;
  final Set<String> hidden;
  final VoidCallback onAddTrunk, onAddBranch;
  final VoidCallback? onAddLeaf;
  final Function(String) onToggleVisibility;
  final Function(String, String) onDeleteElement;
  final Function(int, int) onReorderBranches;
  final VoidCallback onExport;
  final bool isDark;
  final String? selectedId;
  final Function(String, String) onSelectElement;

  const SidePanel({
    super.key,
    required this.isOpen, required this.onToggle,
    required this.project, required this.hidden,
    required this.onAddTrunk, required this.onAddBranch,
    this.onAddLeaf,
    required this.onToggleVisibility,
    required this.onDeleteElement,
    required this.onReorderBranches,
    required this.onExport,
    required this.isDark,
    this.selectedId,
    required this.onSelectElement,
  });

  @override
  State<SidePanel> createState() => _SidePanelState();
}

class _SidePanelState extends State<SidePanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  int _section = 0;

  static const _w = 270.0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 280));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void didUpdateWidget(SidePanel old) {
    super.didUpdateWidget(old);
    widget.isOpen ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? const Color(0xFF111111) : Colors.white;
    final border = widget.isDark
        ? const Color(0xFF252525) : const Color(0xFFE4D9CC);

    return Stack(children: [
      // Overlay
      AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => _anim.value > 0
            ? GestureDetector(
                onTap: widget.onToggle,
                child: Container(
                  color: Colors.black.withOpacity(0.35 * _anim.value)),
              )
            : const SizedBox.shrink(),
      ),

      // Panel
      AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => Positioned(
          top: 0, bottom: 0,
          right: -_w * (1 - _anim.value),
          child: Container(
            width: _w,
            decoration: BoxDecoration(
              color: bg,
              border: Border(left: BorderSide(color: border, width: 0.5)),
              boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 24, offset: const Offset(-6, 0),
              )],
            ),
            child: SafeArea(child: Column(children: [
              _header(border),
              _tabs(),
              const SizedBox(height: 6),
              Expanded(child: _body()),
            ])),
          ),
        ),
      ),

      // زر الفتح
      AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => Positioned(
          top: 72,
          right: _w * _anim.value,
          child: GestureDetector(
            onTap: widget.onToggle,
            child: Container(
              width: 34, height: 52,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12)),
                border: Border.all(color: border, width: 0.5),
                boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.15), blurRadius: 8)],
              ),
              child: Icon(
                widget.isOpen
                    ? Icons.chevron_right_rounded
                    : Icons.menu_rounded,
                color: const Color(0xFFD4A55A), size: 20,
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _header(Color border) {
    final textC = widget.isDark ? Colors.white : const Color(0xFF18120A);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: border, width: 0.5))),
      child: Row(children: [
        const Text('🌳', style: TextStyle(fontSize: 22)),
        const SizedBox(width: 10),
        Text('سلالتي',
            style: TextStyle(fontFamily: 'Amiri', fontSize: 18,
                fontWeight: FontWeight.bold, color: textC)),
        const Spacer(),
        GestureDetector(
          onTap: widget.onToggle,
          child: Icon(Icons.close_rounded, size: 20,
              color: textC.withOpacity(0.35)),
        ),
      ]),
    );
  }

  Widget _tabs() {
    final labels = ['أدوات', 'طبقات', 'مشروع'];
    final icons = [Icons.construction_rounded, Icons.layers_rounded,
      Icons.info_outline_rounded];
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF1C1C1C) : const Color(0xFFF0EBE3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: List.generate(3, (i) {
          final active = _section == i;
          return Expanded(child: GestureDetector(
            onTap: () => setState(() => _section = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color: active ? const Color(0xFFD4A55A) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(icons[i], size: 15,
                    color: active ? Colors.white
                        : (widget.isDark ? Colors.white38 : Colors.black38)),
                const SizedBox(height: 2),
                Text(labels[i],
                    style: TextStyle(fontFamily: 'Amiri', fontSize: 10,
                        color: active ? Colors.white
                            : (widget.isDark ? Colors.white38 : Colors.black38))),
              ]),
            ),
          ));
        })),
      ),
    );
  }

  Widget _body() {
    switch (_section) {
      case 0: return _tools();
      case 1: return _layers();
      case 2: return _info();
      default: return const SizedBox();
    }
  }

  // ── أدوات ────────────────────────────
  Widget _tools() => ListView(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    children: [
      _label('إضافة عنصر'),
      _toolTile(Icons.park_rounded, 'جذع الشجرة', 'جذع واحد لكل مشروع',
          const Color(0xFF8D6E63), widget.onAddTrunk),
      _toolTile(Icons.account_tree_rounded, 'غصن / فرع', 'يتفرع من الجذع',
          const Color(0xFF795548), widget.onAddBranch),
      _toolTile(Icons.eco_rounded, 'ورقة',
          widget.onAddLeaf != null ? 'تُضاف للغصن المحدد' : 'اختر غصناً أولاً',
          const Color(0xFF388E3C), widget.onAddLeaf ?? () {}),
      const SizedBox(height: 14),
      _label('تصدير ومشاركة'),
      _toolTile(Icons.image_rounded, 'تصدير PNG', 'حفظ ومشاركة الشجرة',
          const Color(0xFFD4A55A), widget.onExport),
    ],
  );

  Widget _toolTile(IconData icon, String title, String sub,
      Color color, VoidCallback? onTap) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.4,
        duration: const Duration(milliseconds: 200),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: widget.isDark
                ? const Color(0xFF1C1C1C) : const Color(0xFFF7F3EE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: widget.isDark
                    ? const Color(0xFF272727) : const Color(0xFFE4D9CC)),
          ),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(9)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(
                fontFamily: 'Amiri', fontSize: 14, fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : const Color(0xFF18120A),
              )),
              Text(sub, style: TextStyle(
                fontFamily: 'Amiri', fontSize: 10,
                color: widget.isDark ? Colors.white38 : Colors.black38,
              )),
            ])),
            Icon(Icons.add_circle_outline_rounded,
                color: color.withOpacity(0.6), size: 18),
          ]),
        ),
      ),
    );
  }

  // ── طبقات ────────────────────────────
  Widget _layers() {
    final trunk = widget.project.trunk;
    if (trunk == null) {
      return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('🌱', style: TextStyle(fontSize: 40)),
        const SizedBox(height: 12),
        Text('لا يوجد جذع بعد',
            style: TextStyle(fontFamily: 'Amiri', fontSize: 14,
                color: widget.isDark ? Colors.white38 : Colors.black38)),
      ]));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
        child: _label('الطبقات'),
      ),
      // الجذع
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: _layerTile(
          id: trunk.id, label: 'الجذع', type: 'trunk',
          icon: Icons.park_rounded, color: Color(trunk.color),
          isLocked: trunk.isLocked, showDrag: false,
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
        child: _label('الأغصان'),
      ),
      Expanded(
        child: ReorderableListView(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          onReorder: widget.onReorderBranches,
          children: trunk.branches.asMap().entries.map((e) =>
            _layerTile(
              key: ValueKey(e.value.id),
              id: e.value.id,
              label: e.value.name.isEmpty ? 'غصن ${e.key + 1}' : e.value.name,
              type: 'branch',
              icon: Icons.account_tree_rounded,
              color: Color(e.value.color),
              isLocked: e.value.isLocked,
              showDrag: true,
            ),
          ).toList(),
        ),
      ),
    ]);
  }

  Widget _layerTile({
    Key? key,
    required String id, required String label, required String type,
    required IconData icon, required Color color,
    required bool isLocked, required bool showDrag,
  }) {
    final isVis = !widget.hidden.contains(id);
    final isSel = widget.selectedId == id;
    final textC = widget.isDark ? Colors.white : const Color(0xFF18120A);
    final selBg = const Color(0xFFD4A55A).withOpacity(0.12);
    final bg = widget.isDark ? const Color(0xFF1C1C1C) : const Color(0xFFF7F3EE);

    return GestureDetector(
      key: key,
      onTap: () => widget.onSelectElement(id, type),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSel ? selBg : bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSel
                ? const Color(0xFFD4A55A).withOpacity(0.4)
                : (widget.isDark ? const Color(0xFF272727) : const Color(0xFFE4D9CC)),
            width: isSel ? 1.5 : 0.8,
          ),
        ),
        child: Row(children: [
          if (showDrag)
            Icon(Icons.drag_handle_rounded, size: 16,
                color: widget.isDark ? Colors.white20 : Colors.black20),
          const SizedBox(width: 4),
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(7)),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: TextStyle(
            fontFamily: 'Amiri', fontSize: 13, color: textC,
          ))),
          if (isLocked)
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(Icons.lock_rounded, size: 12, color: Colors.orange),
            ),
          GestureDetector(
            onTap: () => widget.onToggleVisibility(id),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                isVis ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                size: 16,
                color: isVis
                    ? const Color(0xFFD4A55A)
                    : (widget.isDark ? Colors.white24 : Colors.black24),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _confirmDelete(id, type, label),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.delete_outline_rounded,
                  size: 16, color: Colors.red.withOpacity(0.7)),
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _confirmDelete(String id, String type, String label) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.isDark ? const Color(0xFF1C1C1C) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('حذف العنصر', textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Amiri', color: Colors.red)),
        content: Text('حذف "$label"؟', textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Amiri',
                color: widget.isDark ? Colors.white70 : Colors.black87)),
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
    if (ok == true) widget.onDeleteElement(id, type);
  }

  // ── معلومات المشروع ───────────────────
  Widget _info() {
    final p = widget.project;
    final textC = widget.isDark ? Colors.white : const Color(0xFF18120A);
    final subC = widget.isDark ? Colors.white38 : Colors.black38;
    final branchCount = p.trunk?.branches.length ?? 0;
    final leafCount = p.trunk?.branches
        .fold(0, (s, b) => s + b.leaves.length) ?? 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _label('معلومات المشروع'),
        _infoRow('الاسم', p.name, textC, subC),
        _infoRow('الإنشاء',
            '${p.createdAt.year}/${p.createdAt.month}/${p.createdAt.day}',
            textC, subC),
        _infoRow('الأغصان', '$branchCount غصن', textC, subC),
        _infoRow('الأوراق', '$leafCount ورقة', textC, subC),
        if (p.trunk != null)
          _infoRow('الأسماء', '${p.trunk!.names.length} اسم', textC, subC),
        const SizedBox(height: 16),
        _label('الإصدار'),
        _infoRow('التطبيق', 'سلالتي v3.2', textC, subC),
      ],
    );
  }

  Widget _infoRow(String k, String v, Color tc, Color sc) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(children: [
      Text(k, style: TextStyle(fontFamily: 'Amiri', fontSize: 13, color: sc)),
      const Spacer(),
      Text(v, style: TextStyle(
          fontFamily: 'Amiri', fontSize: 13,
          fontWeight: FontWeight.bold, color: tc)),
    ]),
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: TextStyle(
      fontFamily: 'Amiri', fontSize: 11, fontWeight: FontWeight.bold,
      color: widget.isDark ? Colors.white38 : Colors.black38,
      letterSpacing: 0.3,
    )),
  );
}
