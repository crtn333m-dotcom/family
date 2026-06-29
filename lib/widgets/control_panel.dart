import 'package:flutter/material.dart';
import '../models/tree_model.dart';

class ControlPanel extends StatefulWidget {
  final String selectedId;
  final String selectedType;
  final ProjectModel project;
  final Function(ProjectModel) onUpdate;
  final VoidCallback? onAddLeaf;
  final VoidCallback onClose;

  const ControlPanel({
    super.key,
    required this.selectedId,
    required this.selectedType,
    required this.project,
    required this.onUpdate,
    this.onAddLeaf,
    required this.onClose,
  });

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  final _nameController = TextEditingController();

  TrunkModel? get _trunk => widget.project.trunk;

  BranchModel? get _branch => widget.project.trunk?.branches
      .where((b) => b.id == widget.selectedId)
      .firstOrNull;

  void _toggleLock() {
    final p = widget.project;
    if (widget.selectedType == 'trunk' && p.trunk != null) {
      final t = p.trunk!;
      p.trunk = TrunkModel(
        id: t.id, x: t.x, y: t.y, names: t.names,
        height: t.height, thickness: t.thickness,
        isLocked: !t.isLocked, branches: t.branches,
      );
      widget.onUpdate(p);
    } else if (widget.selectedType == 'branch' && _branch != null) {
      final b = _branch!;
      final updated = BranchModel(
        id: b.id, name: b.name, x: b.x, y: b.y,
        length: b.length, thickness: b.thickness,
        angle: b.angle, curve: b.curve,
        isLocked: !b.isLocked, leaves: b.leaves,
      );
      final i = p.trunk!.branches.indexWhere((x) => x.id == b.id);
      if (i >= 0) p.trunk!.branches[i] = updated;
      widget.onUpdate(p);
    }
  }

  void _addName() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final p = widget.project;
    if (widget.selectedType == 'trunk' && p.trunk != null) {
      if (p.trunk!.names.length >= 20) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('الحد الأقصى 20 اسم',
                style: TextStyle(fontFamily: 'Amiri')),
          ),
        );
        return;
      }
      p.trunk!.names.add(name);
      widget.onUpdate(p);
      _nameController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = widget.selectedType == 'trunk'
        ? (_trunk?.isLocked ?? false)
        : (_branch?.isLocked ?? false);

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF3E2723).withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // شريط العنوان
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.selectedType == 'trunk' ? 'تعديل الجذع' : 'تعديل الغصن',
                  style: const TextStyle(
                      fontFamily: 'Amiri',
                      color: Color(0xFFFFD54F),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isLocked ? Icons.lock : Icons.lock_open,
                        color: isLocked ? Colors.red : Colors.green,
                      ),
                      onPressed: _toggleLock,
                      tooltip: isLocked ? 'فك القفل' : 'قفل',
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: widget.onClose,
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (!isLocked) ...[
            const Divider(color: Colors.white24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // الحجم
                  _buildSlider(
                    label: 'الطول',
                    value: widget.selectedType == 'trunk'
                        ? (_trunk?.height ?? 200)
                        : (_branch?.length ?? 120),
                    min: 60,
                    max: 400,
                    onChanged: (v) {
                      final p = widget.project;
                      if (widget.selectedType == 'trunk' && p.trunk != null) {
                        final t = p.trunk!;
                        p.trunk = TrunkModel(
                          id: t.id, x: t.x, y: t.y, names: t.names,
                          height: v, thickness: t.thickness,
                          isLocked: t.isLocked, branches: t.branches,
                        );
                      } else if (_branch != null) {
                        final b = _branch!;
                        final updated = BranchModel(
                          id: b.id, name: b.name, x: b.x, y: b.y,
                          length: v, thickness: b.thickness,
                          angle: b.angle, curve: b.curve,
                          isLocked: b.isLocked, leaves: b.leaves,
                        );
                        final i = p.trunk!.branches
                            .indexWhere((x) => x.id == b.id);
                        if (i >= 0) p.trunk!.branches[i] = updated;
                      }
                      widget.onUpdate(p);
                    },
                  ),

                  _buildSlider(
                    label: 'السُّمك',
                    value: widget.selectedType == 'trunk'
                        ? (_trunk?.thickness ?? 40)
                        : (_branch?.thickness ?? 14),
                    min: 4,
                    max: 80,
                    onChanged: (v) {
                      final p = widget.project;
                      if (widget.selectedType == 'trunk' && p.trunk != null) {
                        final t = p.trunk!;
                        p.trunk = TrunkModel(
                          id: t.id, x: t.x, y: t.y, names: t.names,
                          height: t.height, thickness: v,
                          isLocked: t.isLocked, branches: t.branches,
                        );
                      } else if (_branch != null) {
                        final b = _branch!;
                        final updated = BranchModel(
                          id: b.id, name: b.name, x: b.x, y: b.y,
                          length: b.length, thickness: v,
                          angle: b.angle, curve: b.curve,
                          isLocked: b.isLocked, leaves: b.leaves,
                        );
                        final i = p.trunk!.branches
                            .indexWhere((x) => x.id == b.id);
                        if (i >= 0) p.trunk!.branches[i] = updated;
                      }
                      widget.onUpdate(p);
                    },
                  ),

                  if (widget.selectedType == 'branch')
                    _buildSlider(
                      label: 'الالتواء',
                      value: _branch?.curve ?? 0.3,
                      min: -2,
                      max: 2,
                      onChanged: (v) {
                        final p = widget.project;
                        if (_branch != null) {
                          final b = _branch!;
                          final updated = BranchModel(
                            id: b.id, name: b.name, x: b.x, y: b.y,
                            length: b.length, thickness: b.thickness,
                            angle: b.angle, curve: v,
                            isLocked: b.isLocked, leaves: b.leaves,
                          );
                          final i = p.trunk!.branches
                              .indexWhere((x) => x.id == b.id);
                          if (i >= 0) p.trunk!.branches[i] = updated;
                        }
                        widget.onUpdate(p);
                      },
                    ),

                  if (widget.selectedType == 'branch')
                    _buildSlider(
                      label: 'الزاوية',
                      value: _branch?.angle ?? 0,
                      min: -3.14,
                      max: 3.14,
                      onChanged: (v) {
                        final p = widget.project;
                        if (_branch != null) {
                          final b = _branch!;
                          final updated = BranchModel(
                            id: b.id, name: b.name, x: b.x, y: b.y,
                            length: b.length, thickness: b.thickness,
                            angle: v, curve: b.curve,
                            isLocked: b.isLocked, leaves: b.leaves,
                          );
                          final i = p.trunk!.branches
                              .indexWhere((x) => x.id == b.id);
                          if (i >= 0) p.trunk!.branches[i] = updated;
                        }
                        widget.onUpdate(p);
                      },
                    ),

                  // إضافة اسم
                  if (widget.selectedType == 'trunk') ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nameController,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                fontFamily: 'Amiri', color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'أضف اسماً للجذع',
                              hintStyle: TextStyle(
                                  fontFamily: 'Amiri', color: Colors.white38),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white24)),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white24)),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFD54F),
                              foregroundColor: const Color(0xFF3E2723)),
                          onPressed: _addName,
                          child: const Text('إضافة',
                              style: TextStyle(fontFamily: 'Amiri')),
                        ),
                      ],
                    ),
                    if (_trunk != null && _trunk!.names.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 36,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: _trunk!.names
                              .map((n) => Container(
                                    margin: const EdgeInsets.only(left: 6),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF5D4037),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(n,
                                        style: const TextStyle(
                                            fontFamily: 'Amiri',
                                            color: Colors.white,
                                            fontSize: 12)),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ],

                  if (widget.selectedType == 'branch' && widget.onAddLeaf != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF388E3C)),
                          onPressed: widget.onAddLeaf,
                          icon: const Icon(Icons.eco, color: Colors.white),
                          label: const Text('إضافة ورقة',
                              style: TextStyle(
                                  fontFamily: 'Amiri', color: Colors.white)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ] else
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '🔒 العنصر مقفل — اضغط على القفل لفتحه',
                style: TextStyle(
                    fontFamily: 'Amiri', color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontFamily: 'Amiri', color: Colors.white70, fontSize: 13)),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFFFFD54F),
            inactiveTrackColor: Colors.white24,
            thumbColor: const Color(0xFFFFD54F),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
