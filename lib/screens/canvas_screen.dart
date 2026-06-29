import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../models/tree_model.dart';
import '../services/storage_service.dart';
import '../widgets/trunk_widget.dart';
import '../widgets/branch_widget.dart';
import '../widgets/pro_control_panel.dart';
import '../widgets/side_panel.dart';
import '../main.dart';

class CanvasScreen extends StatefulWidget {
  final ProjectModel project;
  const CanvasScreen({super.key, required this.project});
  @override
  State<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends State<CanvasScreen> {
  late ProjectModel _project;

  // Transform
  double _scale = 1.0, _baseScale = 1.0;
  Offset _offset = Offset.zero;
  Offset _focalStart = Offset.zero, _offsetStart = Offset.zero;

  // Selection
  String? _selectedId, _selectedType;

  // Undo/Redo
  final List<String> _history = [];
  int _hIdx = -1;
  static const _maxH = 30;

  // Visibility
  final Set<String> _hidden = {};

  // Export
  final _exportKey = GlobalKey();

  // Panel
  bool _panelOpen = false;

  @override
  void initState() {
    super.initState();
    _project = widget.project;
    _pushH();
  }

  // ── History ──────────────────────────
  void _pushH() {
    if (_hIdx < _history.length - 1) {
      _history.removeRange(_hIdx + 1, _history.length);
    }
    _history.add(_project.toJson());
    if (_history.length > _maxH) _history.removeAt(0);
    _hIdx = _history.length - 1;
  }

  bool get _canUndo => _hIdx > 0;
  bool get _canRedo => _hIdx < _history.length - 1;

  void _undo() {
    if (!_canUndo) return;
    _hIdx--;
    setState(() => _project = ProjectModel.fromJson(_history[_hIdx]));
  }

  void _redo() {
    if (!_canRedo) return;
    _hIdx++;
    setState(() => _project = ProjectModel.fromJson(_history[_hIdx]));
  }

  // ── Update ───────────────────────────
  void _upd(ProjectModel p, {bool hist = true}) {
    setState(() => _project = p);
    if (hist) _pushH();
    StorageService.saveProject(p);
  }

  // ── Add ──────────────────────────────
  void _addTrunk() {
    if (_project.trunk != null) { _snack('يوجد جذع بالفعل'); return; }
    final sz = MediaQuery.of(context).size;
    _upd(_project.copyWith(trunk: TrunkModel(
      id: const Uuid().v4(),
      x: sz.width / 2, y: sz.height * 0.62,
    )));
  }

  void _addBranch() {
    if (_project.trunk == null) { _snack('أضف الجذع أولاً'); return; }
    final trunk = _project.trunk!;
    final idx = trunk.branches.length;
    final side = idx.isEven ? 1 : -1;
    final b = BranchModel(
      id: const Uuid().v4(),
      name: 'غصن ${idx + 1}',
      x: trunk.x + side * 58.0,
      y: trunk.y - trunk.height * (0.35 + (idx % 7) * 0.09),
      angle: side * (0.42 + (idx % 5) * 0.13),
      curve: side * 0.18,
    );
    _upd(_project.copyWith(
        trunk: trunk.copyWith(branches: [...trunk.branches, b])));
  }

  void _addLeaf(String branchId) {
    final trunk = _project.trunk;
    if (trunk == null) return;
    final bi = trunk.branches.indexWhere((b) => b.id == branchId);
    if (bi < 0) return;
    final branch = trunk.branches[bi];
    final count = branch.leaves.length;
    final side = count.isEven ? 1 : -1;
    final dist = 34.0 + (count ~/ 2) * 22;
    final leaf = LeafModel(
      id: const Uuid().v4(), name: 'ورقة ${count + 1}',
      x: dist * math.cos(branch.angle + side * (0.4 + (count ~/ 2) * 0.22)),
      y: -dist * math.sin(branch.angle + side * (0.4 + (count ~/ 2) * 0.22)),
    );
    final nb = branch.copyWith(leaves: [...branch.leaves, leaf]);
    final bList = List<BranchModel>.from(trunk.branches)..[bi] = nb;
    _upd(_project.copyWith(trunk: trunk.copyWith(branches: bList)));
  }

  void _delete(String id, String type) {
    if (type == 'trunk') {
      _upd(_project.copyWith(clearTrunk: true));
    } else {
      final trunk = _project.trunk!;
      _upd(_project.copyWith(trunk: trunk.copyWith(
          branches: trunk.branches.where((b) => b.id != id).toList())));
    }
    setState(() { _selectedId = null; _selectedType = null; });
  }

  void _toggleVis(String id) =>
      setState(() => _hidden.contains(id) ? _hidden.remove(id) : _hidden.add(id));

  // ── Export ───────────────────────────
  Future<void> _export() async {
    _snack('جارٍ التصدير...');
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      final rb = _exportKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (rb == null) { _snack('خطأ في التصدير'); return; }
      final img = await rb.toImage(pixelRatio: 3.0);
      final bd = await img.toByteData(format: ui.ImageByteFormat.png);
      if (bd == null) return;
      final dir = await getTemporaryDirectory();
      final f = File(
          '${dir.path}/salati_${DateTime.now().millisecondsSinceEpoch}.png');
      await f.writeAsBytes(bd.buffer.asUint8List());
      await Share.shareXFiles([XFile(f.path)],
          text: '🌳 شجرة: ${_project.name}\nتطبيق سلالتي');
    } catch (e) {
      _snack('فشل التصدير');
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Amiri')),
      backgroundColor: const Color(0xFF1C1C1C),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ),
  );

  void _select(String id, String type) => setState(() {
    if (_selectedId == id) { _selectedId = null; _selectedType = null; }
    else { _selectedId = id; _selectedType = type; }
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final panelH = _selectedId != null ? 300.0 : 0.0;

    return Scaffold(
      appBar: _appBar(isDark),
      body: Stack(children: [
        // ═══ Canvas ═══════════════════
        RepaintBoundary(
          key: _exportKey,
          child: GestureDetector(
            onScaleStart: (d) {
              _baseScale = _scale;
              _focalStart = d.focalPoint;
              _offsetStart = _offset;
            },
            onScaleUpdate: (d) => setState(() {
              _scale = (_baseScale * d.scale).clamp(0.12, 5.0);
              _offset = _offsetStart + (d.focalPoint - _focalStart);
            }),
            onTap: () => setState(() {
              _selectedId = null; _selectedType = null;
            }),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [const Color(0xFF0C0C0C), const Color(0xFF111111)]
                      : [const Color(0xFFF4F0EA), const Color(0xFFEDE8E0)],
                ),
              ),
              child: CustomPaint(
                painter: _GridPainter(isDark: isDark),
                child: Transform(
                  transform: Matrix4.identity()
                    ..translate(_offset.dx, _offset.dy)
                    ..scale(_scale),
                  alignment: Alignment.topLeft,
                  child: Stack(children: [
                    if (_project.trunk != null) ...[
                      if (!_hidden.contains(_project.trunk!.id))
                        TrunkWidget(
                          trunk: _project.trunk!,
                          isSelected: _selectedId == _project.trunk!.id,
                          onSelect: () => _select(_project.trunk!.id, 'trunk'),
                          onUpdate: (t) => _upd(
                              _project.copyWith(trunk: t), hist: false),
                        ),
                      ..._project.trunk!.branches
                          .where((b) => !_hidden.contains(b.id))
                          .map((b) => BranchWidget(
                            branch: b,
                            isSelected: _selectedId == b.id,
                            onSelect: () => _select(b.id, 'branch'),
                            onUpdate: (nb) {
                              final trunk = _project.trunk!;
                              final list = List<BranchModel>.from(trunk.branches);
                              final i = list.indexWhere((x) => x.id == nb.id);
                              if (i >= 0) list[i] = nb;
                              _upd(_project.copyWith(
                                  trunk: trunk.copyWith(branches: list)),
                                  hist: false);
                            },
                          )),
                    ],
                  ]),
                ),
              ),
            ),
          ),
        ),

        // ═══ Side Panel ═══════════════
        SidePanel(
          isOpen: _panelOpen,
          onToggle: () => setState(() => _panelOpen = !_panelOpen),
          project: _project,
          hidden: _hidden,
          onAddTrunk: () { setState(() => _panelOpen = false); _addTrunk(); },
          onAddBranch: () { setState(() => _panelOpen = false); _addBranch(); },
          onAddLeaf: _selectedType == 'branch' && _selectedId != null
              ? () { setState(() => _panelOpen = false); _addLeaf(_selectedId!); }
              : null,
          onToggleVisibility: _toggleVis,
          onDeleteElement: _delete,
          onReorderBranches: (o, n) {
            final trunk = _project.trunk!;
            final list = List<BranchModel>.from(trunk.branches);
            final item = list.removeAt(o);
            list.insert(n > o ? n - 1 : n, item);
            _upd(_project.copyWith(trunk: trunk.copyWith(branches: list)));
          },
          onExport: _export,
          isDark: isDark,
          selectedId: _selectedId,
          onSelectElement: _select,
        ),

        // ═══ Float Controls ═══════════
        Positioned(
          bottom: panelH + 16, left: 16,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _Fab(Icons.undo_rounded, _canUndo ? _undo : null, isDark),
            const SizedBox(height: 6),
            _Fab(Icons.redo_rounded, _canRedo ? _redo : null, isDark),
            const SizedBox(height: 14),
            _Fab(Icons.add_rounded,
                () => setState(() => _scale = (_scale * 1.3).clamp(0.12, 5.0)), isDark),
            const SizedBox(height: 6),
            _Fab(Icons.crop_free_rounded,
                () => setState(() { _scale = 1.0; _offset = Offset.zero; }), isDark),
            const SizedBox(height: 6),
            _Fab(Icons.remove_rounded,
                () => setState(() => _scale = (_scale / 1.3).clamp(0.12, 5.0)), isDark),
          ]),
        ),

        // ═══ Control Panel ════════════
        if (_selectedId != null)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: ProControlPanel(
              selectedId: _selectedId!,
              selectedType: _selectedType!,
              project: _project,
              onUpdate: (p) => _upd(p),
              onAddLeaf: _selectedType == 'branch'
                  ? () => _addLeaf(_selectedId!)
                  : null,
              onDelete: () => _delete(_selectedId!, _selectedType!),
              onClose: () => setState(
                  () { _selectedId = null; _selectedType = null; }),
            ),
          ),
      ]),
    );
  }

  PreferredSizeWidget _appBar(bool isDark) => AppBar(
    title: Text(_project.name),
    actions: [
      IconButton(
        icon: Icon(Icons.undo_rounded,
            color: _canUndo ? const Color(0xFFD4A55A) : Colors.grey.shade700),
        onPressed: _canUndo ? _undo : null,
      ),
      IconButton(
        icon: Icon(Icons.redo_rounded,
            color: _canRedo ? const Color(0xFFD4A55A) : Colors.grey.shade700),
        onPressed: _canRedo ? _redo : null,
      ),
      IconButton(
        icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: const Color(0xFFD4A55A)),
        onPressed: () => SalatiApp.of(context)?.toggleTheme(),
      ),
      IconButton(
        icon: const Icon(Icons.ios_share_rounded, color: Color(0xFFD4A55A)),
        onPressed: _export,
      ),
      const SizedBox(width: 4),
    ],
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(height: 1,
          color: isDark ? const Color(0xFF272727) : const Color(0xFFE4D9CC)),
    ),
  );
}

class _Fab extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDark;
  const _Fab(this.icon, this.onTap, this.isDark);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.18), blurRadius: 8)],
      ),
      child: Icon(icon, size: 20,
          color: onTap != null
              ? const Color(0xFFD4A55A)
              : Colors.grey.shade600),
    ),
  );
}

class _GridPainter extends CustomPainter {
  final bool isDark;
  const _GridPainter({required this.isDark});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFDDD5C5)
      ..strokeWidth = 0.5;
    const s = 40.0;
    for (double x = 0; x < size.width; x += s)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    for (double y = 0; y < size.height; y += s)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
  }
  @override bool shouldRepaint(_) => false;
}
