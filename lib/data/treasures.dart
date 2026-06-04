class Treasure {
  final String id;
  final String name;
  final String area;
  final double lat;
  final double lng;
  final String gameType;
  final String description;
  final String icon;

  const Treasure({
    required this.id,
    required this.name,
    required this.area,
    required this.lat,
    required this.lng,
    required this.gameType,
    required this.description,
    required this.icon,
  });
}

const List<Treasure> treasures = [
  Treasure(
    id: 't1',
    name: '海螺怪兽',
    area: '南门广场',
    lat: 20.0610,
    lng: 110.3210,
    gameType: 'monster',
    description: '南门广场出现了一只巨大的海螺怪兽，连点屏幕将它击败！',
    icon: '🐚',
  ),
  Treasure(
    id: 't2',
    name: '白沙之谜',
    area: '椰林步道',
    lat: 20.0625,
    lng: 110.3220,
    gameType: 'puzzle',
    description: '椰林深处传来声音：「白浪沙白岛屿白，何物却是黑黄白？」',
    icon: '🌴',
  ),
  Treasure(
    id: 't3',
    name: '收集贝壳',
    area: '海边沙滩',
    lat: 20.0650,
    lng: 110.3225,
    gameType: 'collect',
    description: '沙滩上散落 5 颗贝壳，全部找到即可通关。',
    icon: '🐚',
  ),
  Treasure(
    id: 't4',
    name: '观海数字',
    area: '观海长廊',
    lat: 20.0640,
    lng: 110.3235,
    gameType: 'puzzle15',
    description: '完成数字华容道，让数字 1-15 归位。',
    icon: '🧩',
  ),
  Treasure(
    id: 't5',
    name: '风车 BOSS',
    area: '风车广场',
    lat: 20.0660,
    lng: 110.3240,
    gameType: 'boss',
    description: '终极水母 BOSS 出现！血量 100，连点击败它！',
    icon: '👾',
  ),
];
