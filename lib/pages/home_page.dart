import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../data/treasures.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';
import 'treasure_detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position? _position;
  Set<String> _completed = {};

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final ok = await LocationService.ensurePermission();
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请授予位置权限')),
      );
    }
    _completed = await StorageService.getCompleted();
    LocationService.positionStream().listen((p) {
      if (mounted) setState(() => _position = p);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('白沙门 AR 寻宝'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '重置进度',
            onPressed: () async {
              await StorageService.reset();
              _completed = {};
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusCard(),
          Expanded(
            child: ListView.builder(
              itemCount: treasures.length,
              itemBuilder: (ctx, i) {
                final t = treasures[i];
                final done = _completed.contains(t.id);
                double? distance;
                if (_position != null) {
                  distance = LocationService.distanceMeters(
                    _position!.latitude, _position!.longitude,
                    t.lat, t.lng,
                  );
                }
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Text(t.icon, style: const TextStyle(fontSize: 36)),
                    title: Text('${i + 1}. ${t.name}'),
                    subtitle: Text('${t.area}${distance != null ? ' · ${distance.toStringAsFixed(0)} 米' : ''}'),
                    trailing: done
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.chevron_right),
                    onTap: () async {
                      await Navigator.push(context, MaterialPageRoute(
                        builder: (_) => TreasureDetailPage(treasure: t),
                      ));
                      _completed = await StorageService.getCompleted();
                      setState(() {});
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final done = _completed.length;
    final total = treasures.length;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1976D2), Color(0xFF00ACC1)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🏝 白沙门海岛传说', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 6),
          Text('进度：$done / $total', style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 6),
          Text(
            _position == null
                ? '正在定位...'
                : '当前位置：${_position!.latitude.toStringAsFixed(5)}, ${_position!.longitude.toStringAsFixed(5)} · 精度 ${_position!.accuracy.toStringAsFixed(0)} 米',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
