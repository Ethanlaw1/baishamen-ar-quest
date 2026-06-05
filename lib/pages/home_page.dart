import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

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
  final MapController _mapController = MapController();
  Position? _position;
  double _heading = 0;
  Set<String> _completed = {};
  Treasure? _selected;
  String _status = '正在检查定位权限...';
  bool _permissionOk = false;
  StreamSubscription<Position>? _posSub;
  StreamSubscription<double?>? _headingSub;

  static const LatLng _baishamenCenter = LatLng(20.0635, 110.3225);

  @override
  void initState() {
    super.initState();
    _selected = treasures.first;
    _init();
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _headingSub?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    _completed = await StorageService.getCompleted();
    final result = await LocationService.ensurePermission();
    if (!mounted) return;
    setState(() {
      _permissionOk = result.ok;
      _status = result.message;
    });

    if (!result.ok) return;

    final current = await LocationService.currentPosition();
    if (current != null && mounted) {
      setState(() => _position = current);
      _moveMapToUser(current);
    }

    _posSub = LocationService.positionStream().listen((p) {
      if (!mounted) return;
      setState(() {
        _position = p;
        _status = '定位中 · 精度 ${p.accuracy.toStringAsFixed(0)} 米';
      });
    }, onError: (e) {
      if (!mounted) return;
      setState(() => _status = '定位失败：$e');
    });

    _headingSub = LocationService.headingStream().listen((h) {
      if (!mounted || h == null) return;
      setState(() => _heading = h);
    });
  }

  void _moveMapToUser(Position p) {
    _mapController.move(LatLng(p.latitude, p.longitude), 17);
  }

  double? _distanceTo(Treasure t) {
    final p = _position;
    if (p == null) return null;
    return LocationService.distanceMeters(p.latitude, p.longitude, t.lat, t.lng);
  }

  double? _bearingTo(Treasure t) {
    final p = _position;
    if (p == null) return null;
    return LocationService.bearingDegrees(p.latitude, p.longitude, t.lat, t.lng);
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected ?? treasures.first;
    final distance = _distanceTo(selected);
    final bearing = _bearingTo(selected) ?? 0;
    final arrowAngle = ((bearing - _heading) * math.pi / 180);

    return Scaffold(
      appBar: AppBar(
        title: const Text('白沙门 AR 寻宝'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: '回到我的位置',
            onPressed: _position == null ? null : () => _moveMapToUser(_position!),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '重新请求定位',
            onPressed: _init,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
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
          _buildStatusCard(selected, distance, arrowAngle),
          Expanded(child: _buildMap()),
          _buildTreasureStrip(),
        ],
      ),
    );
  }

  Widget _buildStatusCard(Treasure selected, double? distance, double arrowAngle) {
    final done = _completed.length;
    final total = treasures.length;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF00838F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '🏝 白沙门海岛传说 · $done/$total',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              Transform.rotate(
                angle: arrowAngle,
                child: const Icon(Icons.navigation, color: Colors.redAccent, size: 34),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '当前目标：${selected.icon} ${selected.name} · ${selected.area}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            distance == null ? '距离：等待定位...' : '距离：${distance.toStringAsFixed(0)} 米 · 方位：${(_bearingTo(selected) ?? 0).toStringAsFixed(0)}°',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            _position == null
                ? _status
                : '我的位置：${_position!.latitude.toStringAsFixed(5)}, ${_position!.longitude.toStringAsFixed(5)} · $_status',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          if (!_permissionOk) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: LocationService.openAppSettings,
                  icon: const Icon(Icons.settings),
                  label: const Text('打开应用权限设置'),
                ),
                OutlinedButton.icon(
                  onPressed: LocationService.openLocationSettings,
                  icon: const Icon(Icons.location_on),
                  label: const Text('打开系统定位'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMap() {
    final userLatLng = _position == null ? null : LatLng(_position!.latitude, _position!.longitude);
    final markers = <Marker>[
      for (final t in treasures)
        Marker(
          width: 64,
          height: 64,
          point: LatLng(t.lat, t.lng),
          child: GestureDetector(
            onTap: () => setState(() => _selected = t),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _completed.contains(t.id) ? Colors.green : Colors.redAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 6)],
                  ),
                  child: Text(t.icon, style: const TextStyle(fontSize: 20)),
                ),
                Text(t.area, style: const TextStyle(fontSize: 9, color: Colors.black, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      if (userLatLng != null)
        Marker(
          width: 56,
          height: 56,
          point: userLatLng,
          child: Transform.rotate(
            angle: _heading * math.pi / 180,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 8)],
              ),
              child: const Icon(Icons.navigation, color: Colors.white, size: 26),
            ),
          ),
        ),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(16)),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: userLatLng ?? _baishamenCenter,
            initialZoom: 16,
            minZoom: 3,
            maxZoom: 19,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.baishamen_ar_quest',
            ),
            if (_position != null && _selected != null)
              PolylineLayer(polylines: [
                Polyline(
                  points: [LatLng(_position!.latitude, _position!.longitude), LatLng(_selected!.lat, _selected!.lng)],
                  color: Colors.redAccent,
                  strokeWidth: 4,
                ),
              ]),
            MarkerLayer(markers: markers),
          ],
        ),
      ),
    );
  }

  Widget _buildTreasureStrip() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(10),
        itemCount: treasures.length,
        itemBuilder: (ctx, i) {
          final t = treasures[i];
          final done = _completed.contains(t.id);
          final selected = _selected?.id == t.id;
          final distance = _distanceTo(t);
          return GestureDetector(
            onTap: () => setState(() {
              _selected = t;
              _mapController.move(LatLng(t.lat, t.lng), 17);
            }),
            onDoubleTap: () => _openTreasure(t),
            child: Container(
              width: 170,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selected ? Colors.blueGrey.shade700 : Colors.blueGrey.shade900,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: done ? Colors.greenAccent : (selected ? Colors.cyanAccent : Colors.white12), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(t.icon, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 6),
                    Expanded(child: Text(t.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold))),
                    if (done) const Icon(Icons.check_circle, color: Colors.greenAccent, size: 18),
                  ]),
                  Text(t.area, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  const Spacer(),
                  Text(distance == null ? '等待定位' : '${distance.toStringAsFixed(0)} 米', style: const TextStyle(color: Colors.amber)),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(onPressed: () => _openTreasure(t), child: const Text('进入')),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openTreasure(Treasure t) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => TreasureDetailPage(treasure: t)));
    _completed = await StorageService.getCompleted();
    setState(() {});
  }
}
