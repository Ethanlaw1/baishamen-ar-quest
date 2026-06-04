import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../data/treasures.dart';
import '../services/storage_service.dart';

class MonsterBattlePage extends StatefulWidget {
  final Treasure treasure;
  const MonsterBattlePage({super.key, required this.treasure});
  @override
  State<MonsterBattlePage> createState() => _MonsterBattlePageState();
}

class _MonsterBattlePageState extends State<MonsterBattlePage> with SingleTickerProviderStateMixin {
  int hp = 30;
  double offsetX = 0;
  double offsetY = 0;
  final rng = math.Random();

  void _hit() {
    setState(() {
      hp--;
      offsetX = (rng.nextDouble() - 0.5) * 40;
      offsetY = (rng.nextDouble() - 0.5) * 40;
    });
    if (hp <= 0) _win();
  }

  Future<void> _win() async {
    await StorageService.markCompleted(widget.treasure.id);
    if (!mounted) return;
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('🎉 击败海螺怪兽！'),
      content: const Text('你解锁了下一关线索：椰林深处藏着古老的谜语。'),
      actions: [TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('继续'))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('AR 怪兽战斗'), backgroundColor: Colors.transparent),
      body: GestureDetector(
        onTap: _hit,
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(colors: [Color(0xFF003344), Colors.black], radius: 1.2),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              left: MediaQuery.of(context).size.width / 2 - 80 + offsetX,
              top: MediaQuery.of(context).size.height / 2 - 80 + offsetY,
              child: const Text('🐚', style: TextStyle(fontSize: 140)),
            ),
            Positioned(
              top: 80, left: 20, right: 20,
              child: Column(
                children: [
                  const Text('点击屏幕攻击！', style: TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: hp / 30,
                    backgroundColor: Colors.white24,
                    color: Colors.redAccent,
                    minHeight: 10,
                  ),
                  const SizedBox(height: 4),
                  Text('剩余血量：$hp', style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
