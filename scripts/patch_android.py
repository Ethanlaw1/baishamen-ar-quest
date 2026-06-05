from pathlib import Path

manifest = Path('android/app/src/main/AndroidManifest.xml')
text = manifest.read_text(encoding='utf-8')

permissions = '''
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-feature android:name="android.hardware.camera" android:required="false" />
    <uses-feature android:name="android.hardware.location.gps" android:required="false" />
'''

if 'android.permission.ACCESS_FINE_LOCATION' not in text:
    text = text.replace(
        '<manifest xmlns:android="http://schemas.android.com/apk/res/android">',
        '<manifest xmlns:android="http://schemas.android.com/apk/res/android">\n' + permissions,
    )

text = text.replace('android:label="baishamen_ar_quest"', 'android:label="白沙门AR寻宝"')
manifest.write_text(text, encoding='utf-8')

for gradle_name in ['android/app/build.gradle.kts', 'android/app/build.gradle']:
    p = Path(gradle_name)
    if not p.exists():
        continue
    s = p.read_text(encoding='utf-8')
    s = s.replace('minSdk = flutter.minSdkVersion', 'minSdk = 24')
    s = s.replace('minSdkVersion flutter.minSdkVersion', 'minSdkVersion 24')
    p.write_text(s, encoding='utf-8')

print('Android permissions and SDK patched.')
