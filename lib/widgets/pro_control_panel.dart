import 'dart:math' as math;
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

class _ProControlPanelState extends State<ProControlPanel>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nameCtrl;
  late TabController _tabCtrl;
  int _leafIdx = 0; // الورقة المحددة حالياً

  static const _accent = Color(0xFFD4A55A);
  static const _red = Color(0xFFE57373);
  static const _green = Color(0xFF81C784);

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: _currentName);
    _tabCtrl = TabController(length: widget.selectedType == 'trunk' ? 2 : 3, vsync: this);
  }

  @override
  void didUpdateWidget(ProControlPanel old) {
    super.didUpdateWidget(old);
    if (old.selectedId != widget.selectedId) {
      _nameCtrl.text = _currentName;
      _leafIdx = 0;
      _tabCtrl.dispose();
      _tabCtrl = TabController(length: widget.selectedType == 'trunk' ? 2 : 3, vsync: this);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  // ═══ Getters ═══

  String get _currentName {
    if (widget.selectedType == 'trunk') return widget.project.name;
    return _branch?.name ?? '';
  }

  TrunkModel? get _trunk => widget.project.trunk;

  BranchModel? get _branch => _trunk?.branches
      .where((b) => b.id == widget.selectedId)
      .firstOrNull;

  List<LeafModel> get _leaves => _branch?.leaves ?? [];

  LeafModel? get _selectedLeaf =>
      (_leafIdx < _leaves.length) ? _leaves[_leafIdx] : null;

  // ═══ Update helpers ═══

  void _updTrunk(TrunkModel t) =>
      widget.onUpdate(widget.project.copyWith(trunk: t));

  void _updBranch(BranchModel b) {
    final trunk = _trunk!;
    final list = trunk.branches.map((x) => x.id == b.id ? b : x).toList();
    _updTrunk(trunk.copyWith(branches: list));
  }

  void _updLeaf(LeafModel l) {
    final branch = _branch!;
    final list = branch.leaves.map((x) => x.id == l.id ? x.copyWith(
      name: l.name, x: l.x, y: l.y, width: l.width, height: l.height,
      rotation: l.rotation, scaleX: l.scaleX,
      isLocked: l.isLocked, style: l.style, color: l.color,
    ) : x).toList();
    _updBranch(branch.copyWith(leaves: list));
  }

  // ═══ Build ═══

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final fg = isDark ? Colors.white : const Color(0xFF1C1C1C);
    final sub = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F0EA);

    return Container(
      constraints: const BoxConstraints(maxHeight: 320),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 20, offset: const Offset(0, -4),
        )],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // ── Handle + Header ──
        _buildHeader(fg, sub, isDark),

        // ── Tabs ──
        TabBar(
          controller: _tabCtrl,
          indicatorColor: _accent,
          labelColor: _accent,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontFamily: 'Amiri', fontSize: 12),
          tabs: [
            const Tab(text: 'الشكل'),
            const Tab(text: 'الألوان'),
            if (widget.selectedType == 'branch') const Tab(text: 'الأوراق'),
          ],
        ),

        // ── Tab Content ──
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: [
              _buildShapeTab(fg, sub, isDark),
              _buildColorTab(fg, sub, isDark),
              if (widget.selectedType == 'branch') _buildLeavesTab(fg, sub, isDark),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildHeader(Color fg, Color sub, bool isDark) => Container(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      // Handle
      Container(width: 40, height: 4, decoration: BoxDecoration(
        color: Colors.grey.shade600, borderRadius: BorderRadius.circular(2),
      )),
      const SizedBox(height: 10),
      Row(children: [
        Icon(widget.selectedType == 'trunk'
            ? Icons.forest_rounded : Icons.call_split_rounded,
            color: _accent, size: 18),
        const SizedBox(width: 8),
        // اسم قابل للتعديل
        Expanded(
          child: TextField(
            controller: _nameCtrl,
            textDirection: TextDirection.rtl,
            style: TextStyle(fontFamily: 'Amiri', fontSize: 14, color: fg),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              filled: true, fillColor: sub,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _accent, width: 1.5),
              ),
            ),
            onChanged: (v) {
              if (widget.selectedType == 'trunk') {
                widget.onUpdate(widget.project.copyWith(name: v));
              } else if (_branch != null) {
                _updBranch(_branch!.copyWith(name: v));
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        // أضف ورقة
        if (widget.selectedType == 'branch' && widget.onAddLeaf != null)
          _HeaderBtn(icon: Icons.eco_rounded, color: _green, onTap: widget.onAddLeaf!),
        const SizedBox(width: 6),
        // حذف
        _HeaderBtn(icon: Icons.delete_outline_rounded, color: _red, onTap: widget.onDelete),
        const SizedBox(width: 6),
        // إغلاق
        GestureDetector(
          onTap: widget.onClose,
          child: Icon(Icons.close_rounded, color: Colors.grey.shade500, size: 20),
        ),
      ]),
    ]),
  );

  // ══════════════════════════════════════
  //  تبويب الشكل
  // ══════════════════════════════════════
  Widget _buildShapeTab(Color fg, Color sub, bool isDark) {
    if (widget.selectedType == 'trunk' && _trunk != null) {
      return _trunkShapeTab(fg, sub, isDark);
    } else if (_branch != null) {
      return _branchShapeTab(fg, sub, isDark);
    }
    return const SizedBox();
  }

  Widget _trunkShapeTab(Color fg, Color sub, bool isDark) {
    final t = _trunk!;
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 8), children: [
      // نوع الجذع
      _SectionLabel('نوع الجذع', fg),
      _StylePicker<TrunkStyle>(
        values: TrunkStyle.values,
        selected: t.style,
        labels: const ['كلاسيك', 'بوباب', 'نخيل', 'أرز', 'صفصاف', 'صنوبر'],
        icons: const ['🌳', '🌴', '🌴', '🌲', '🎋', '🎄'],
        onSelect: (s) => _updTrunk(t.copyWith(style: s)),
        isDark: isDark,
      ),
      const SizedBox(height: 10),
      _Slider2('الارتفاع', t.height, 80, 500, fg, (v) => _updTrunk(t.copyWith(height: v))),
      _Slider2('السُّمك', t.thickness, 10, 100, fg, (v) => _updTrunk(t.copyWith(thickness: v))),
      _Slider2('الدوران', t.rotation, -math.pi / 3, math.pi / 3, fg,
          (v) => _updTrunk(t.copyWith(rotation: v)), fmt: (v) => '${(v * 180 / math.pi).round()}°'),
      _Slider2('الانحناء', t.bend, -1, 1, fg, (v) => _updTrunk(t.copyWith(bend: v))),
      _Slider2('التمدد الأفقي', t.scaleX, 0.3, 2.5, fg, (v) => _updTrunk(t.copyWith(scaleX: v))),
    ]);
  }

  Widget _branchShapeTab(Color fg, Color sub, bool isDark) {
    final b = _branch!;
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 8), children: [
      // نوع الغصن
      _SectionLabel('نوع الغصن', fg),
      _StylePicker<BranchStyle>(
        values: BranchStyle.values,
        selected: b.style,
        labels: const ['منحنٍ', 'مستقيم', 'متعرج', 'كرمة', 'متدلٍّ'],
        icons: const ['🌿', '📏', '⚡', '🍇', '🌊'],
        onSelect: (s) => _updBranch(b.copyWith(style: s)),
        isDark: isDark,
      ),
      const SizedBox(height: 10),
      _Slider2('الطول', b.length, 40, 300, fg, (v) => _updBranch(b.copyWith(length: v))),
      _Slider2('السُّمك', b.thickness, 2, 40, fg, (v) => _updBranch(b.copyWith(thickness: v))),
      _Slider2('الزاوية', b.angle, -math.pi, math.pi, fg,
          (v) => _updBranch(b.copyWith(angle: v)),
          fmt: (v) => '${(v * 180 / math.pi).round()}°'),
      _Slider2('الالتواء', b.curve, -1.5, 1.5, fg, (v) => _updBranch(b.copyWith(curve: v))),
      _Slider2('الدوران', b.rotation, -math.pi, math.pi, fg,
          (v) => _updBranch(b.copyWith(rotation: v)),
          fmt: (v) => '${(v * 180 / math.pi).round()}°'),
      _Slider2('القلب الأفقي', b.scaleX, -1.0, 1.0, fg, (v) => _updBranch(b.copyWith(scaleX: v))),
      _Slider2('حجم الرأس', b.headRadius, 6, 60, fg, (v) => _updBranch(b.copyWith(headRadius: v))),
    ]);
  }

  // ══════════════════════════════════════
  //  تبويب الألوان
  // ══════════════════════════════════════
  Widget _buildColorTab(Color fg, Color sub, bool isDark) {
    final currentColor = widget.selectedType == 'trunk'
        ? Color(_trunk!.color)
        : Color(_branch?.color ?? 0xFF795548);

    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 8), children: [
      _SectionLabel('لون مخصص', fg),
      _ColorGrid(
        selected: currentColor,
        onSelect: (c) {
          if (widget.selectedType == 'trunk') {
            _updTrunk(_trunk!.copyWith(color: c.value));
          } else if (_branch != null) {
            _updBranch(_branch!.copyWith(color: c.value));
          }
        },
      ),
    ]);
  }

  // ══════════════════════════════════════
  //  تبويب الأوراق
  // ══════════════════════════════════════
  Widget _buildLeavesTab(Color fg, Color sub, bool isDark) {
    final leaves = _leaves;
    if (leaves.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.eco_outlined, size: 36, color: Colors.grey.shade600),
          const SizedBox(height: 8),
          Text('لا توجد أوراق — اضغط + لإضافة',
              style: TextStyle(fontFamily: 'Amiri', color: Colors.grey.shade600)),
        ]),
      );
    }

    final leaf = _selectedLeaf;
    return Column(children: [
      // شريط اختيار الورقة
      SizedBox(
        height: 36,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: leaves.length,
          itemBuilder: (_, i) => GestureDetector(
            onTap: () => setState(() => _leafIdx = i),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _leafIdx == i ? _accent : sub,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(leaves[i].name.isNotEmpty ? leaves[i].name : 'ورقة ${i + 1}',
                  style: TextStyle(
                    fontFamily: 'Amiri', fontSize: 11,
                    color: _leafIdx == i ? Colors.white : fg,
                  )),
            ),
          ),
        ),
      ),

      if (leaf != null) Expanded(
        child: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 8), children: [
          // نوع الورقة
          _SectionLabel('نوع الورقة', fg),
          _StylePicker<LeafStyle>(
            values: LeafStyle.values,
            selected: leaf.style,
            labels: const ['بيضاوي', 'مدبب', 'مستدير', 'قلب', 'صنوبر', 'قيقب', 'نخيل', 'ريشة'],
            icons: const ['🍃', '🌿', '⭕', '💚', '🌲', '🍁', '🌴', '🪶'],
            onSelect: (s) => _updLeaf(leaf.copyWith(style: s)),
            isDark: isDark,
          ),
          const SizedBox(height: 6),
          _Slider2('العرض', leaf.width, 10, 120, fg, (v) => _updLeaf(leaf.copyWith(width: v))),
          _Slider2('الارتفاع', leaf.height, 10, 160, fg, (v) => _updLeaf(leaf.copyWith(height: v))),
          _Slider2('الدوران', leaf.rotation, -math.pi, math.pi, fg,
              (v) => _updLeaf(leaf.copyWith(rotation: v)),
              fmt: (v) => '${(v * 180 / math.pi).round()}°'),
          _Slider2('القلب الأفقي', leaf.scaleX, -1.0, 1.0, fg, (v) => _updLeaf(leaf.copyWith(scaleX: v))),
          _Slider2('الموضع X', leaf.x, -150, 150, fg, (v) => _updLeaf(leaf.copyWith(x: v))),
          _Slider2('الموضع Y', leaf.y, -150, 150, fg, (v) => _updLeaf(leaf.copyWith(y: v))),
          _SectionLabel('لون الورقة', fg),
          _ColorGrid(
            selected: Color(leaf.color),
            isLeaf: true,
            onSelect: (c) => _updLeaf(leaf.copyWith(color: c.value)),
          ),
        ]),
      ),
    ]);
  }
}

// ══════════════════════════════════════
//  Widgets مساعدة
// ══════════════════════════════════════

class _HeaderBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _HeaderBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Icon(icon, size: 17, color: color),
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final Color fg;
  const _SectionLabel(this.text, this.fg);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: TextStyle(
      fontFamily: 'Amiri', fontSize: 12,
      color: fg.withOpacity(0.6), fontWeight: FontWeight.bold,
    )),
  );
}

class _Slider2 extends StatelessWidget {
  final String label;
  final double value;
  final double min, max;
  final Color fg;
  final void Function(double) onChanged;
  final String Function(double)? fmt;

  const _Slider2(this.label, this.value, this.min, this.max, this.fg,
      this.onChanged, {this.fmt});

  @override
  Widget build(BuildContext context) {
    final display = fmt != null ? fmt!(value) : value.toStringAsFixed(1);
    return Row(children: [
      SizedBox(
        width: 80,
        child: Text(label, style: TextStyle(
            fontFamily: 'Amiri', fontSize: 11, color: fg.withOpacity(0.75))),
      ),
      Expanded(
        child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 2.5,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            activeTrackColor: const Color(0xFFD4A55A),
            inactiveTrackColor: const Color(0xFFD4A55A).withOpacity(0.2),
            thumbColor: const Color(0xFFD4A55A),
            overlayColor: const Color(0xFFD4A55A).withOpacity(0.15),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min, max: max,
            onChanged: onChanged,
          ),
        ),
      ),
      SizedBox(
        width: 38,
        child: Text(display, style: TextStyle(
            fontFamily: 'Amiri', fontSize: 10, color: const Color(0xFFD4A55A))),
      ),
    ]);
  }
}

class _StylePicker<T> extends StatelessWidget {
  final List<T> values;
  final T selected;
  final List<String> labels;
  final List<String> icons;
  final void Function(T) onSelect;
  final bool isDark;

  const _StylePicker({
    required this.values, required this.selected,
    required this.labels, required this.icons,
    required this.onSelect, required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: values.length,
        itemBuilder: (_, i) {
          final isSelected = values[i] == selected;
          return GestureDetector(
            onTap: () => onSelect(values[i]),
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFD4A55A).withOpacity(0.2)
                    : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F0EA)),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFD4A55A)
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(icons[i], style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 2),
                Text(labels[i], style: TextStyle(
                  fontFamily: 'Amiri', fontSize: 9,
                  color: isSelected
                      ? const Color(0xFFD4A55A)
                      : Colors.grey.shade500,
                ), textAlign: TextAlign.center),
              ]),
            ),
          );
        },
      ),
    );
  }
}

class _ColorGrid extends StatelessWidget {
  final Color selected;
  final bool isLeaf;
  final void Function(Color) onSelect;

  const _ColorGrid({required this.selected, required this.onSelect, this.isLeaf = false});

  static const _treeColors = [
    Color(0xFF5D4037), Color(0xFF4E342E), Color(0xFF6D4C41),
    Color(0xFF795548), Color(0xFF8D6E63), Color(0xFFA1887F),
    Color(0xFF3E2723), Color(0xFF9E7B4D), Color(0xFFB8860B),
    Color(0xFF37474F), Color(0xFF263238), Color(0xFF546E7A),
  ];

  static const _leafColors = [
    Color(0xFF4CAF50), Color(0xFF2E7D32), Color(0xFF66BB6A),
    Color(0xFF81C784), Color(0xFF1B5E20), Color(0xFF8BC34A),
    Color(0xFFCDDC39), Color(0xFFF9A825), Color(0xFFFF7043),
    Color(0xFFE53935), Color(0xFF8D6E63), Color(0xFFFFEB3B),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = isLeaf ? _leafColors : _treeColors;
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: colors.map((c) {
        final isSel = c.value == selected.value;
        return GestureDetector(
          onTap: () => onSelect(c),
          child: Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSel ? Colors.white : Colors.transparent,
                width: 2.5,
              ),
              boxShadow: [
                if (isSel) BoxShadow(color: c.withOpacity(0.6), blurRadius: 6),
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 3),
              ],
            ),
            child: isSel
                ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                : null,
          ),
        );
      }).toList(),
    );
  }
}
