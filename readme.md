# 白沙门 AR 寻宝 · BaiShaMen AR Quest

海口市白沙门公园 5 关 AR 互动寻宝游戏。

## 玩法

5 个宝藏点：
1. **南门广场** - AR 海螺怪兽战斗
2. **椰林步道** - 文字谜题
3. **海边沙滩** - 收集 5 颗贝壳
4. **观海长廊** - 数字华容道
5. **风车广场** - 终极水母 BOSS

走到宝藏点 20 米内即可开始挑战。

## 编译方式

### 方法 1：GitHub Actions 云端自动编译（推荐）

push 代码到 main 分支后，GitHub Actions 会自动编译 APK。

1. 打开仓库的 **Actions** 标签页
2. 等待 **Build APK** 任务完成（10-15 分钟）
3. 点进任务详情，下载底部的 **baishamen-ar-quest-apk** artifact
4. 解压后将 `app-release.apk` 传到 OPPO Reno 6 安装

### 方法 2：本机编译

```bash
flutter pub get
flutter build apk --release
```

输出在 `build/app/outputs/flutter-apk/app-release.apk`

## 手机安装

1. 把 APK 通过微信 / QQ / 数据线传到手机
2. 安卓设置 → 安全 → 允许安装未知来源应用
3. 点击 APK 文件安装

## 坐标调整

打开 `lib/data/treasures.dart`，修改每个宝藏点的 `lat` / `lng` 经纬度即可。
建议到现场用高德地图长按某个位置，获取真实坐标后填入。

## 权限说明

App 需要：
- 📍 定位权限（GPS）
- 📷 摄像头权限（AR 关卡）
- 🧭 罗盘传感器（自动）
