import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../data/treasures.dart';
import '../services/storage_service.dart';

class Puzzle15Page extends StatefulWidget {
  final Treasure treasure;
  const Puzzle15Page({super.key, required this.treasure});
  @override
  State<Puzzle15Page> createState() => _Puzzle15PageState();
}

class _Puzzle15PageState extends State<Puzzle15Page> {
  List<int> board = List.generate(16, (i) => (i + 1) % 16);

  @override
  void initState() {
    super.initState();
    _shuffle();
  }

  void _shuffle() {
    final rng = math.Random();
    // 简单打乱：从已解状态做 80 次合法移动
    board = List.generate(16, (i) => (i + 1) % 16);
    for (int i = 0; i < 80; i++) {
      final empty = board.indexOf(0);
      final neighbors = <int>[];
      if (empty % 4 > 0) neighbors.add(empty - 1);
      if (empty % 4 < 3) neighbors.add(empty + 1);
      if (empty >= 4) neighbors.add(empty - 4);
      if (empty < 12) neighbors.add(empty + 4);
      final pick = neighbors[rng.nextInt(neighbors.length)];
      board[empty] = board[pick];
      board[pick] = 0;
    }
    setState(() {});
  }

  void _tap(int i) async {
    final empty = board.indexOf(0);
    final sameRow = (empty ~/ 4) == (i ~/ 4);
    final sameCol = (empty % 4) == (i % 4);
    final adjacent = (sameRow && (empty - i).abs() == 1) || (sameCol && (empty - i).abs() == 4);
    if (!adjacent) return;
    setState(() {
      board[empty] = board[i];
      board[i] = 0;
    });
    if (_isWin()) {
      await StorageService.markCompleted(widget.treasure.id);
      if (!mounted) return;
      showDialog(context: context, builder: (_) => AlertDialog(
        title: const Text('🎉 完成华容道！'),
        content: const Text('观海长廊的数字归位，下一站去风车广场迎接终极挑战！'),
        actions: [TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('继续'))],
      ));
    }
  }

  bool _isWin() {
    for (int i = 0; i < 15; i++) {
      if (board[i] != i + 1) return false;
    }
    return board[15] == 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('观海华容道'), actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _shuffle),
      ]),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('🧩 把数字 1-15 按顺序排好', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, mainAxisSpacing: 6, crossAxisSpacing: 6,
                ),
                itemCount: 16,
                itemBuilder: (ctx, i) {
                  final v = board[i];
                  if (v == 0) return Container(color: Colors.transparent);
                  return GestureDetector(
                    onTap: () => _tap(i),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.cyan.shade700,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text('$v', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
