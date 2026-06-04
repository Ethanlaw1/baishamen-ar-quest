import 'package:flutter/material.dart';
import '../data/treasures.dart';
import '../services/storage_service.dart';

class PuzzlePage extends StatefulWidget {
  final Treasure treasure;
  const PuzzlePage({super.key, required this.treasure});
  @override
  State<PuzzlePage> createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> {
  final controller = TextEditingController();
  String? hint;

  void _check() async {
    final ans = controller.text.trim();
    final ok = ans.contains('海鸥') || ans.toLowerCase().contains('seagull');
    if (ok) {
      await StorageService.markCompleted(widget.treasure.id);
      if (!mounted) return;
      showDialog(context: context, builder: (_) => AlertDialog(
        title: const Text('🎉 答对了！'),
        content: const Text('「海鸥」正是椰林之外、海浪之上、白沙之间最灵动的存在。'),
        actions: [TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('继续'))],
      ));
    } else {
      setState(() => hint = '再想想：黑黄白三色，常在海上飞翔的小生灵...');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('白沙之谜')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('🌴 椰林之谜', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '「白浪沙白岛屿白，何物却是黑黄白？」',
                style: TextStyle(fontSize: 20, height: 1.6),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: '输入你的答案',
                border: OutlineInputBorder(),
              ),
            ),
            if (hint != null) ...[
              const SizedBox(height: 12),
              Text('💡 $hint', style: const TextStyle(color: Colors.amber)),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _check,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('提交答案', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
