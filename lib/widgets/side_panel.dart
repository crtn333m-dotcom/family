import 'package:flutter/material.dart';
import '../models/tree_model.dart';

class SidePanel extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onToggle;
  final ProjectModel project;
  final Set<String> hidden;
  final VoidCallback onAddTrunk;
  final VoidCallback onAddBranch;
  final VoidCallback? onAddLeaf;
  final void Function(String id) onToggleVisibility;
  final void Function(String id, String type) onDeleteElement;
  final void Function(int oldIndex, int newIndex) onReorderBranches;
  final VoidCallback onExport;
  final bool isDark;
  final String? selectedId;
  final void Function(String id, String type) onSelectElement;

  const SidePanel({
    super.key,
    required this.isOpen,
    required this.onToggle,
    required this.project,
    required this.hidden,
    required this.onAddTrunk,
    required this.onAddBranch,
    required this.onAddLeaf,
    required this.onToggleVisibility,
    required this.onDeleteElement,
    required this.onReorderBranches,
    required this.onExport,
    required this.isDark,
    required this.selectedId,
    required this.onSelectElement,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final fg = isDark ? Colors.white : const Color(0xFF1C1C1C);
    final accent = const Color(0xFFD4A55A);

    return Stack(children: [
      // ── Toggle Button ──────────────
      Positioned(
        top: 80,
        right: isOpen ? 260 : 0,
        child: GestureDetector(
          onTap: onToggle,
          child: Container(
            width: 28,
            height: 56,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8)],
            ),
            child: Icon(
              isOpen ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
              color: accent, size: 20,
            ),
          ),
        ),
      ),

      // ── Drawer ────────────────────
      AnimatedPositioned(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        top: 0, bottom: 0,
        right: isOpen ? 0 : -260,
        width: 260,
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 16)],
          ),
          child: SafeArea(
            child: Column(children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(children: [
                  Icon(Icons.account_tree_rounded, color: accent, size: 20),
                  const SizedBox(width: 8),
                  Text('الشجرة', style: TextStyle(
                    color: fg, fontFamily: 'Amiri',
                    fontSize: 18, fontWeight: FontWeight.bold,
                  )),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.ios_share_rounded, color: accent, size: 20),
                    onPressed: onExport,
                    tooltip: 'تصدير',
                  ),
                ]),
              ),

              Divider(color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEEE8DE), height: 1),

              // Actions
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  _ActionBtn(
                    icon: Icons.forest_rounded,
                    label: 'جذع',
                    onTap: onAddTrunk,
                    isDark: isDark,
                    enabled: project.trunk == null,
                  ),
                  const SizedBox(width: 8),
                  _ActionBtn(
                    icon: Icons.call_split_rounded,
                    label: 'غصن',
                    onTap: onAddBranch,
                    isDark: isDark,
                    enabled: project.trunk != null,
                  ),
                  const SizedBox(width: 8),
                  _ActionBtn(
                    icon: Icons.eco_rounded,
                    label: 'ورقة',
                    onTap: onAddLeaf ?? () {},
                    isDark: isDark,
                    enabled: onAddLeaf != null,
                  ),
                ]),
              ),

              Divider(color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEEE8DE), height: 1),

              // Tree list
              Expanded(
                child: project.trunk == null
                    ? Center(
                        child: Text('لا يوجد جذع بعد',
                          style: TextStyle(color: Colors.grey.shade600,
                            fontFamily: 'Amiri', fontSize: 14),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        children: [
                          // Trunk item
                          _TreeItem(
                            id: project.trunk!.id,
                            label: 'الجذع',
                            icon: Icons.forest_rounded,
                            isSelected: selectedId == project.trunk!.id,
                            isHidden: hidden.contains(project.trunk!.id),
                            onTap: () => onSelectElement(project.trunk!.id, 'trunk'),
                            onToggleVis: () => onToggleVisibility(project.trunk!.id),
                            onDelete: () => onDeleteElement(project.trunk!.id, 'trunk'),
                            isDark: isDark,
                            indent: 0,
                          ),

                          // Branches
                          ReorderableListView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            onReorder: onReorderBranches,
                            children: project.trunk!.branches.map((b) =>
                              _TreeItem(
                                key: ValueKey(b.id),
                                id: b.id,
                                label: b.name,
                                icon: Icons.call_split_rounded,
                                isSelected: selectedId == b.id,
                                isHidden: hidden.contains(b.id),
                                onTap: () => onSelectElement(b.id, 'branch'),
                                onToggleVis: () => onToggleVisibility(b.id),
                                onDelete: () => onDeleteElement(b.id, 'branch'),
                                isDark: isDark,
                                indent: 16,
                              ),
                            ).toList(),
                          ),
                        ],
                      ),
              ),
            ]),
          ),
        ),
      ),
    ]);
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark, enabled;
  const _ActionBtn({
    required this.icon, required this.label,
    required this.onTap, required this.isDark, required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFFD4A55A);
    return Expanded(
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: enabled
                ? accent.withOpacity(0.12)
                : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F0EA)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: enabled ? accent.withOpacity(0.4) : Colors.transparent,
            ),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 18,
                color: enabled ? accent : Colors.grey.shade600),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(
              fontSize: 11, fontFamily: 'Amiri',
              color: enabled ? accent : Colors.grey.shade600,
            )),
          ]),
        ),
      ),
    );
  }
}

class _TreeItem extends StatelessWidget {
  final String id, label;
  final IconData icon;
  final bool isSelected, isHidden, isDark;
  final VoidCallback onTap, onToggleVis, onDelete;
  final double indent;

  const _TreeItem({
    super.key,
    required this.id, required this.label, required this.icon,
    required this.isSelected, required this.isHidden, required this.isDark,
    required this.onTap, required this.onToggleVis, required this.onDelete,
    required this.indent,
  });

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFFD4A55A);
    final fg = isDark ? Colors.white : const Color(0xFF1C1C1C);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(left: indent, right: 8, bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? accent.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: accent.withOpacity(0.4))
              : null,
        ),
        child: Row(children: [
          Icon(icon, size: 16,
              color: isSelected ? accent : Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: TextStyle(
              color: isHidden ? Colors.grey : fg,
              fontFamily: 'Amiri', fontSize: 13,
              decoration: isHidden ? TextDecoration.lineThrough : null,
            )),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            icon: Icon(
              isHidden ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              size: 16, color: Colors.grey.shade600,
            ),
            onPressed: onToggleVis,
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            icon: Icon(Icons.delete_outline_rounded,
                size: 16, color: Colors.red.shade400),
            onPressed: onDelete,
          ),
        ]),
      ),
    );
  }
}
