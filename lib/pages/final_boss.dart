import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import '../data/treasures.dart';
import '../services/storage_service.dart';

class FinalBossPage extends StatefulWidget {
  final Treasure treasure;
  const FinalBossPage({super.key, required this.treasure});
  @override
  State<FinalBossPage> createState() => _FinalBossPageState();
}

class _FinalBossPageState extends State<FinalBossPage> with SingleTickerProviderStateMixin {
  int hp = 100;
  int timeLeft = 30;
  Timer? timer;
  double offsetX = 0, offsetY = 0;
  final rng = math.Random();
  bool ended = false;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        timeLeft--;
        if (timeLeft <= 0) _end(false);
      });
    });
  }

  @override
  void dispose() { timer?.cancel(); super.dispose(); }

  void _hit() {
    if (ended) return;
    setState(() {
      hp -= 2;
      offsetX = (rng.nextDouble() - 0.5) * 80;
      offsetY = (rng.nextDouble() - 0.5) * 80;
    });
    if (hp <= 0) _end(true);
  }

  Future<void> _end(bool win) async {
    if (ended) return;
    ended = true;
    timer?.cancel();
    if (win) await StorageService.markCompleted(widget.treasure.id);
    if (!mounted) return;
    showDialog(context: context, barrierDismissible: false, builder: (_) => AlertDialog(
      title: Text(win ? '🎉 通关！' : '😵 BOSS 逃跑了'),
      content: Text(win
          ? '你击败了风车广场水母 BOSS，完成了白沙门海岛传说全部 5 关！'
          : '再来一次吧，多点几下！'),
      actions: [TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('返回'))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('终极 BOSS'), backgroundColor: Colors.transparent),
      body: GestureDetector(
        onTap: _hit,
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(colors: [Color(0xFF4A148C), Colors.black], radius: 1.2),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 150),
              left: MediaQuery.of(context).size.width / 2 - 100 + offsetX,
              top: MediaQuery.of(context).size.height / 2 - 100 + offsetY,
              child: const Text('👾', style: TextStyle(fontSize: 180)),
            ),
            Positioned(
              top: 80, left: 20, right: 20,
              child: Column(
                children: [
                  const Text('疯狂点击击败 BOSS！', style: TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: hp / 100,
                    backgroundColor: Colors.white24,
                    color: Colors.redAccent,
                    minHeight: 12,
                  ),
                  const SizedBox(height: 6),
                  Text('BOSS 血量：$hp / 100', style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 8),
                  Text('倒计时：$timeLeft 秒', style: TextStyle(color: timeLeft < 10 ? Colors.redAccent : Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
