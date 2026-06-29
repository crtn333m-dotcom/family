import 'package:flutter/material.dart';
import '../models/tree_model.dart';

class ProControlPanel extends StatefulWidget {
  final String selectedId, selectedType;
  final ProjectModel project;
  final Function(ProjectModel) onUpdate;
  final VoidCallback? onAddLeaf;
  final VoidCallback onDelete, onClose;

  const ProControlPanel({
    super.key,
    required this.selectedId, required this.selectedType,
    required this.project, required this.onUpdate,
    this.onAddLeaf,
    required this.onDelete, required this.onClose,
  });

  @override
  State<ProControlPanel> createState() => _ProControlPanelState();
}

class _ProControlPanelState extends State<ProControlPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _nameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() { _tab.dispose(); _nameCtrl.dispose(); super.dispose(); }

  TrunkModel? get _trunk => widget.project.trunk;
  BranchModel? get _branch => widget.project.trunk?.branches
      .where((b) => b.id == widget.selectedId).firstOrNull;
  bool get _isLocked => widget.selectedType == 'trunk'
      ? (_trunk?.isLocked ?? false) : (_branch?.isLocked ?? false);

  // ══ إصلاح القفل — copyWith دائماً ══
  void _toggleLock() {
    final p = widget.project;
    if (widget.selectedType == 'trunk' && p.trunk != null) {
      widget.onUpdate(p.copyWith(
          trunk: p.trunk!.copyWith(isLocked: !p.trunk!.isLocked)));
    } else if (_branch != null) {
      final trunk = p.trunk!;
      final idx = trunk.branches.indexWhere((x) => x.id == _branch!.id);
      if (idx < 0) return;
      final list = List<BranchModel>.from(trunk.branches);
      list[idx] = list[idx].copyWith(isLocked: !list[idx].isLocked);
      widget.onUpdate(p.copyWith(trunk: trunk.copyWith(branches: list)));
    }
  }

  void _updB(BranchModel b) {
    final trunk = widget.project.trunk!;
    final list = List<BranchModel>.from(trunk.branches);
    final i = list.indexWhere((x) => x.id == b.id);
    if (i >= 0) list[i] = b;
    widget.onUpdate(widget.project.copyWith(
        trunk: trunk.copyWith(branches: list)));
  }

  void _updT(TrunkModel t) =>
      widget.onUpdate(widget.project.copyWith(trunk: t));

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF141414) : Colors.white;
    final textC = isDark ? Colors.white : const Color(0xFF18120A);
    const accent = Color(0xFFD4A55A);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Container(
          margin: const EdgeInsets.only(top: 10),
          width: 36, height: 4,
          decoration: BoxDecoration(
            color: isDark ? Colors.white20 : Colors.black12,
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 14, 0),
          child: Row(children: [
            Icon(widget.selectedType == 'trunk'
                ? Icons.park_rounded : Icons.account_tree_rounded,
                color: accent, size: 20),
            const SizedBox(width: 8),
            Text(
              widget.selectedType == 'trunk' ? 'الجذع' : 'الغصن',
              style: TextStyle(fontFamily: 'Amiri', fontSize: 17,
                  fontWeight: FontWeight.bold, color: textC),
            ),
            const Spacer(),
            // Lock button — إصلاح هنا
            GestureDetector(
              onTap: _toggleLock,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _isLocked
                      ? Colors.red.withOpacity(0.12)
                      : Colors.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(_isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                      size: 16,
                      color: _isLocked ? Colors.red : Colors.green),
                  const SizedBox(width: 4),
                  Text(_isLocked ? 'مقفل' : 'مفتوح',
                      style: TextStyle(
                        fontFamily: 'Amiri', fontSize: 12,
                        color: _isLocked ? Colors.red : Colors.green,
                      )),
                ]),
              ),
            ),
            const SizedBox(width: 8),
            // Delete
            GestureDetector(
              onTap: widget.onDelete,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    size: 18, color: Colors.red),
              ),
            ),
            const SizedBox(width: 6),
            // Close
            GestureDetector(
              onTap: widget.onClose,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.close_rounded, size: 18,
                    color: isDark ? Colors.white54 : Colors.black54),
              ),
            ),
          ]),
        ),

        if (_isLocked)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.lock_rounded, color: Colors.red, size: 16),
              const SizedBox(width: 8),
              Text('العنصر مقفل — اضغط على زر القفل لفتحه',
                  style: TextStyle(fontFamily: 'Amiri',
                      color: textC.withOpacity(0.5), fontSize: 13)),
            ]),
          )
        else ...[
          TabBar(
            controller: _tab,
            labelColor: accent,
            unselectedLabelColor: isDark ? Colors.white30 : Colors.black30,
            indicatorColor: accent,
            indicatorWeight: 2,
            labelStyle: const TextStyle(fontFamily: 'Amiri', fontSize: 13),
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'الأسماء'),
              Tab(text: 'الحجم'),
              Tab(text: 'الشكل'),
              Tab(text: 'اللون'),
            ],
          ),
          SizedBox(
            height: 185,
            child: TabBarView(controller: _tab, children: [
              _namesTab(isDark, textC),
              _sizeTab(isDark),
              _styleTab(isDark),
              _colorTab(),
            ]),
          ),
        ],
        SizedBox(height: MediaQuery.of(context).padding.bottom + 6),
      ]),
    );
  }

  // ── Tab: الأسماء ─────────────────────
  Widget _namesTab(bool isDark, Color textC) {
    final fieldBg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF4F0EA);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Column(children: [
        Row(children: [
          Expanded(
            child: TextField(
              controller: _nameCtrl,
              textDirection: TextDirection.rtl,
              style: TextStyle(fontFamily: 'Amiri', color: textC),
              decoration: InputDecoration(
                hintText: widget.selectedType == 'trunk'
                    ? 'اسم في الجذع...' : 'اسم الغصن...',
                hintStyle: TextStyle(fontFamily: 'Amiri',
                    color: textC.withOpacity(0.38)),
                filled: true, fillColor: fieldBg,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 11),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _addName,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFD4A55A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        if (widget.selectedType == 'trunk' && _trunk != null &&
            _trunk!.names.isNotEmpty)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _trunk!.names.asMap().entries.map((e) =>
                  GestureDetector(
                    onTap: () => _removeName(e.key),
                    child: Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2A2A2A)
                            : const Color(0xFFF0E8D6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFFD4A55A).withOpacity(0.3)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(e.value, style: TextStyle(fontFamily: 'Amiri',
                            color: textC, fontSize: 13)),
                        const SizedBox(width: 6),
                        Icon(Icons.close_rounded, size: 13,
                            color: textC.withOpacity(0.45)),
                      ]),
                    ),
                  ),
                ).toList(),
              ),
            ),
          ),
        if (widget.selectedType == 'branch' && _branch != null &&
            _branch!.name.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0E8D6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('الاسم الحالي: ${_branch!.name}',
                style: TextStyle(fontFamily: 'Amiri', color: textC)),
          ),
        if (widget.onAddLeaf != null) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 11),
              ),
              onPressed: widget.onAddLeaf,
              icon: const Icon(Icons.eco_rounded, size: 17),
              label: const Text('إضافة ورقة',
                  style: TextStyle(fontFamily: 'Amiri', fontSize: 14)),
            ),
          ),
        ],
      ]),
    );
  }

  void _addName() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final p = widget.project;
    if (widget.selectedType == 'trunk' && p.trunk != null) {
      if (p.trunk!.names.length >= 20) {
        _snack('الحد الأقصى 20 اسماً'); return;
      }
      widget.onUpdate(p.copyWith(
          trunk: p.trunk!.copyWith(
              names: [...p.trunk!.names, name])));
    } else if (_branch != null) {
      _updB(_branch!.copyWith(name: name));
    }
    _nameCtrl.clear();
  }

  void _removeName(int idx) {
    final p = widget.project;
    if (p.trunk == null) return;
    final names = List<String>.from(p.trunk!.names)..removeAt(idx);
    widget.onUpdate(p.copyWith(trunk: p.trunk!.copyWith(names: names)));
  }

  // ── Tab: الحجم ───────────────────────
  Widget _sizeTab(bool isDark) {
    if (widget.selectedType == 'trunk' && _trunk != null) {
      return _sliderList([
        _SI('الطول', _trunk!.height, 80, 400,
            (v) => _updT(_trunk!.copyWith(height: v))),
        _SI('السُّمك', _trunk!.thickness, 10, 100,
            (v) => _updT(_trunk!.copyWith(thickness: v))),
      ], isDark);
    }
    if (_branch != null) {
      return _sliderList([
        _SI('الطول', _branch!.length, 40, 300,
            (v) => _updB(_branch!.copyWith(length: v))),
        _SI('السُّمك', _branch!.thickness, 4, 40,
            (v) => _updB(_branch!.copyWith(thickness: v))),
        _SI('الزاوية', _branch!.angle, -3.14, 3.14,
            (v) => _updB(_branch!.copyWith(angle: v))),
        _SI('الانحناء', _branch!.curve, -2, 2,
            (v) => _updB(_branch!.copyWith(curve: v))),
        _SI('حجم الدائرة', _branch!.headRadius, 8, 60,
            (v) => _updB(_branch!.copyWith(headRadius: v))),
      ], isDark);
    }
    return const SizedBox();
  }

  Widget _sliderList(List<_SI> items, bool isDark) => ListView(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    children: items.map((s) {
      final textC = isDark ? Colors.white60 : const Color(0xFF5A4A35);
      return Row(children: [
        SizedBox(width: 72, child: Text(s.label,
            style: TextStyle(fontFamily: 'Amiri',
                fontSize: 11, color: textC))),
        Expanded(child: Slider(
          value: s.value.clamp(s.min, s.max),
          min: s.min, max: s.max,
          onChanged: s.onChange,
        )),
        SizedBox(width: 34, child: Text(
          s.value.abs() < 10
              ? s.value.toStringAsFixed(2)
              : s.value.toStringAsFixed(0),
          style: TextStyle(fontFamily: 'Amiri',
              fontSize: 10, color: textC),
          textAlign: TextAlign.center,
        )),
      ]);
    }).toList(),
  );

  // ── Tab: الشكل ───────────────────────
  Widget _styleTab(bool isDark) {
    if (widget.selectedType == 'trunk' && _trunk != null) {
      return GridView.count(
        crossAxisCount: 4, padding: const EdgeInsets.all(10),
        crossAxisSpacing: 8, mainAxisSpacing: 8,
        children: TrunkStyle.values.map((s) => _StyleChip(
          label: ['كلاسيك', 'بوباب', 'نخلة', 'أرز'][s.index],
          icon: Icons.park_rounded,
          selected: _trunk!.style == s, isDark: isDark,
          onTap: () => _updT(_trunk!.copyWith(style: s)),
        )).toList(),
      );
    }
    if (_branch != null) {
      return GridView.count(
        crossAxisCount: 4, padding: const EdgeInsets.all(10),
        crossAxisSpacing: 8, mainAxisSpacing: 8,
        children: BranchStyle.values.map((s) => _StyleChip(
          label: ['منحنٍ', 'مستقيم', 'متعرج', 'كرمة'][s.index],
          icon: Icons.account_tree_rounded,
          selected: _branch!.style == s, isDark: isDark,
          onTap: () => _updB(_branch!.copyWith(style: s)),
        )).toList(),
      );
    }
    return const SizedBox();
  }

  // ── Tab: اللون ───────────────────────
  Widget _colorTab() {
    const colors = [
      0xFF5D4037, 0xFF795548, 0xFF8D6E63, 0xFF4E342E,
      0xFF3E2723, 0xFFA1887F, 0xFF6D4C41, 0xFFBCAAA4,
      0xFF1B5E20, 0xFF2E7D32, 0xFF388E3C, 0xFF43A047,
      0xFF66BB6A, 0xFF81C784, 0xFF827717, 0xFFF9A825,
      0xFFF57F17, 0xFFE65100, 0xFFBF360C, 0xFFD84315,
      0xFF37474F, 0xFF455A64, 0xFF4A148C, 0xFF6A1B9A,
    ];
    final current = widget.selectedType == 'trunk'
        ? (_trunk?.color ?? 0xFF5D4037)
        : (_branch?.color ?? 0xFF795548);

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8, crossAxisSpacing: 8, mainAxisSpacing: 8),
      itemCount: colors.length,
      itemBuilder: (_, i) {
        final c = colors[i];
        final sel = current == c;
        return GestureDetector(
          onTap: () {
            if (widget.selectedType == 'trunk' && _trunk != null) {
              _updT(_trunk!.copyWith(color: c));
            } else if (_branch != null) {
              _updB(_branch!.copyWith(color: c));
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: Color(c),
              shape: BoxShape.circle,
              border: Border.all(
                color: sel ? Colors.white : Colors.transparent,
                width: 3,
              ),
              boxShadow: sel ? [BoxShadow(
                  color: Color(c).withOpacity(0.6), blurRadius: 8)] : null,
            ),
          ),
        );
      },
    );
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg, style: const TextStyle(fontFamily: 'Amiri'))));
}

class _SI {
  final String label;
  final double value, min, max;
  final Function(double) onChange;
  _SI(this.label, this.value, this.min, this.max, this.onChange);
}

class _StyleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected, isDark;
  final VoidCallback onTap;
  const _StyleChip({required this.label, required this.icon,
      required this.selected, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFFD4A55A).withOpacity(0.18)
            : (isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF4F0EA)),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected ? const Color(0xFFD4A55A) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 20,
            color: selected ? const Color(0xFFD4A55A) : Colors.grey),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(
          fontFamily: 'Amiri', fontSize: 9,
          color: selected ? const Color(0xFFD4A55A) : Colors.grey,
        )),
      ]),
    ),
  );
}
