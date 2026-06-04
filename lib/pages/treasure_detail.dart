import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../data/treasures.dart';
import '../services/location_service.dart';
import '../widgets/compass_arrow.dart';
import 'monster_battle.dart';
import 'puzzle_page.dart';
import 'collect_shells.dart';
import 'puzzle_15.dart';
import 'final_boss.dart';

class TreasureDetailPage extends StatefulWidget {
  final Treasure treasure;
  const TreasureDetailPage({super.key, required this.treasure});

  @override
  State<TreasureDetailPage> createState() => _TreasureDetailPageState();
}

class _TreasureDetailPageState extends State<TreasureDetailPage> {
  Position? _pos;
  double _heading = 0;

  @override
  void initState() {
    super.initState();
    LocationService.positionStream().listen((p) {
      if (mounted) setState(() => _pos = p);
    });
    LocationService.headingStream().listen((h) {
      if (mounted && h != null) setState(() => _heading = h);
    });
  }

  void _startGame() {
    final t = widget.treasure;
    Widget? page;
    switch (t.gameType) {
      case 'monster': page = MonsterBattlePage(treasure: t); break;
      case 'puzzle': page = PuzzlePage(treasure: t); break;
      case 'collect': page = CollectShellsPage(treasure: t); break;
      case 'puzzle15': page = Puzzle15Page(treasure: t); break;
      case 'boss': page = FinalBossPage(treasure: t); break;
    }
    if (page != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.treasure;
    double? distance;
    double bearing = 0;
    if (_pos != null) {
      distance = LocationService.distanceMeters(_pos!.latitude, _pos!.longitude, t.lat, t.lng);
      bearing = LocationService.bearingDegrees(_pos!.latitude, _pos!.longitude, t.lat, t.lng);
    }
    final canStart = distance != null && distance < 20;

    return Scaffold(
      appBar: AppBar(title: Text('${t.icon} ${t.name}')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(t.area, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(t.description, style: const TextStyle(fontSize: 16, color: Colors.white70)),
            const SizedBox(height: 24),
            Center(child: CompassArrow(targetBearing: bearing, currentHeading: _heading)),
            const SizedBox(height: 24),
            Center(
              child: Text(
                distance == null ? '定位中...' : '距离：${distance.toStringAsFixed(0)} 米',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                canStart ? '✅ 已抵达，可以开始挑战！' : '走到 20 米内才能开始挑战',
                style: TextStyle(color: canStart ? Colors.greenAccent : Colors.orangeAccent),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: canStart ? _startGame : null,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('开始挑战', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () { Navigator.pop(context); },
              child: const Text('返回'),
            ),
          ],
        ),
      ),
    );
  }
}
