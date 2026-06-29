import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/tree_model.dart';
import '../services/storage_service.dart';
import '../widgets/trunk_widget.dart';
import '../widgets/branch_widget.dart';
import '../widgets/control_panel.dart';

class CanvasScreen extends StatefulWidget {
  final ProjectModel project;
  const CanvasScreen({super.key, required this.project});

  @override
  State<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends State<CanvasScreen> {
  late ProjectModel _project;
  double _scale = 1.0;
  double _prevScale = 1.0;
  Offset _offset = Offset.zero;
  Offset _prevOffset = Offset.zero;
  String? _selectedId;
  String? _selectedType;
  bool _showPanel = true;

  @override
  void initState() {
    super.initState();
    _project = widget.project;
  }

  void _addTrunk() {
    if (_project.trunk != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يمكن إضافة جذع واحد فقط لكل مشروع',
              style: TextStyle(fontFamily: 'Amiri')),
          backgroundColor: Color(0xFF5D4037),
        ),
      );
      return;
    }
    final size = MediaQuery.of(context).size;
    setState(() {
      _project.trunk = TrunkModel(
        id: const Uuid().v4(),
        x: size.width / 2,
        y: size.height * 0.7,
      );
    });
    _save();
  }

  void _addBranch() {
    if (_project.trunk == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أضف الجذع أولاً',
              style: TextStyle(fontFamily: 'Amiri')),
          backgroundColor: Color(0xFF5D4037),
        ),
      );
      return;
    }
    final trunk = _project.trunk!;
    setState(() {
      trunk.branches.add(BranchModel(
        id: const Uuid().v4(),
        name: 'غصن ${trunk.branches.length + 1}',
        x: trunk.x + (trunk.branches.length.isEven ? -80 : 80),
        y: trunk.y - trunk.height * 0.6,
        angle: trunk.branches.length.isEven ? -0.5 : 0.5,
      ));
    });
    _save();
  }

  void _addLeaf(String branchId) {
    final branch = _project.trunk?.branches
        .firstWhere((b) => b.id == branchId);
    if (branch == null) return;
    setState(() {
      branch.leaves.add(LeafModel(
        id: const Uuid().v4(),
        name: 'ورقة ${branch.leaves.length + 1}',
        x: branch.x + (branch.leaves.length * 30),
        y: branch.y - 60,
      ));
    });
    _save();
  }

  Future<void> _save() async {
    await StorageService.saveProject(_project);
  }

  void _selectElement(String id, String type) {
    setState(() {
      if (_selectedId == id) {
        _selectedId = null;
        _selectedType = null;
      } else {
        _selectedId = id;
        _selectedType = type;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        title: Text(_project.name,
            style: const TextStyle(fontFamily: 'Amiri', fontSize: 22)),
        backgroundColor: const Color(0xFF3E2723),
        foregroundColor: const Color(0xFFFFD54F),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: () async {
              await _save();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم الحفظ',
                        style: TextStyle(fontFamily: 'Amiri')),
                    backgroundColor: Color(0xFF388E3C),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // الكانفاس
          GestureDetector(
            onScaleStart: (d) {
              _prevScale = _scale;
              _prevOffset = _offset;
            },
            onScaleUpdate: (d) {
              setState(() {
                _scale = (_prevScale * d.scale).clamp(0.3, 3.0);
                _offset = _prevOffset + d.focalPointDelta;
              });
            },
            onTapDown: (_) {
              setState(() {
                _selectedId = null;
                _selectedType = null;
              });
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE8F5E9), Color(0xFFF5F0E8)],
                ),
              ),
              child: Transform(
                transform: Matrix4.identity()
                  ..translate(_offset.dx, _offset.dy)
                  ..scale(_scale),
                child: Stack(
                  children: [
                    if (_project.trunk != null) ...[
                      TrunkWidget(
                        trunk: _project.trunk!,
                        isSelected: _selectedId == _project.trunk!.id,
                        onSelect: () =>
                            _selectElement(_project.trunk!.id, 'trunk'),
                        onUpdate: (t) {
                          setState(() => _project.trunk = t);
                          _save();
                        },
                      ),
                      ..._project.trunk!.branches.map((branch) =>
                          BranchWidget(
                            branch: branch,
                            isSelected: _selectedId == branch.id,
                            onSelect: () =>
                                _selectElement(branch.id, 'branch'),
                            onUpdate: (b) {
                              setState(() {
                                final i = _project.trunk!.branches
                                    .indexWhere((x) => x.id == b.id);
                                if (i >= 0) _project.trunk!.branches[i] = b;
                              });
                              _save();
                            },
                          )),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // قائمة الإضافة
          Positioned(
            top: 16,
            right: 16,
            child: Column(
              children: [
                _buildAddButton('جذع', Icons.account_tree, _addTrunk),
                const SizedBox(height: 8),
                _buildAddButton('غصن', Icons.park, _addBranch),
                const SizedBox(height: 8),
                _buildAddButton(
                  'ورقة',
                  Icons.eco,
                  () {
                    if (_selectedType == 'branch' && _selectedId != null) {
                      _addLeaf(_selectedId!);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('اختر غصناً أولاً',
                              style: TextStyle(fontFamily: 'Amiri')),
                          backgroundColor: Color(0xFF5D4037),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          // لوحة التحكم
          if (_selectedId != null)
            Listener(
              onPointerDown: (_) => setState(() => _showPanel = false),
              onPointerUp: (_) => setState(() => _showPanel = true),
              child: AnimatedOpacity(
                opacity: _showPanel ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ControlPanel(
                    selectedId: _selectedId!,
                    selectedType: _selectedType!,
                    project: _project,
                    onUpdate: (p) {
                      setState(() => _project = p);
                      _save();
                    },
                    onAddLeaf: _selectedType == 'branch'
                        ? () => _addLeaf(_selectedId!)
                        : null,
                    onClose: () => setState(() {
                      _selectedId = null;
                      _selectedType = null;
                    }),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF5D4037),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    fontFamily: 'Amiri',
                    color: Colors.white,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
