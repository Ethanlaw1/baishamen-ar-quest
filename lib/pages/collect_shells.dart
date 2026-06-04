import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../data/treasures.dart';
import '../services/storage_service.dart';

class CollectShellsPage extends StatefulWidget {
  final Treasure treasure;
  const CollectShellsPage({super.key, required this.treasure});
  @override
  State<CollectShellsPage> createState() => _CollectShellsPageState();
}

class _CollectShellsPageState extends State<CollectShellsPage> {
  final rng = math.Random();
  List<Offset> shells = [];
  int collected = 0;
  late Size screen;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      screen = MediaQuery.of(context).size;
      _spawn();
    });
  }

  void _spawn() {
    shells = List.generate(5, (_) => Offset(
      80 + rng.nextDouble() * (screen.width - 160),
      150 + rng.nextDouble() * (screen.height - 300),
    ));
    setState(() {});
  }

  void _collect(int i) async {
    setState(() {
      shells.removeAt(i);
      collected++;
    });
    if (collected >= 5) {
      await StorageService.markCompleted(widget.treasure.id);
      if (!mounted) return;
      showDialog(context: context, builder: (_) => AlertDialog(
        title: const Text('🎉 全部收集！'),
        content: const Text('你收集到了 5 颗白沙门特产贝壳。'),
        actions: [TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('继续'))],
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDE7C2),
      appBar: AppBar(title: Text('收集贝壳 ($collected/5)'), backgroundColor: Colors.transparent),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFDE7C2), Color(0xFFFFE0B2)],
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
              ),
            ),
          ),
          ...List.generate(shells.length, (i) {
            return Positioned(
              left: shells[i].dx, top: shells[i].dy,
              child: GestureDetector(
                onTap: () => _collect(i),
                child: const Text('🐚', style: TextStyle(fontSize: 56)),
              ),
            );
          }),
          if (shells.isEmpty && collected < 5)
            Center(child: ElevatedButton(onPressed: _spawn, child: const Text('再来一批'))),
          Positioned(
            top: 80, left: 20, right: 20,
            child: Text(
              '在沙滩上点击贝壳来收集！',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.brown.shade800, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
