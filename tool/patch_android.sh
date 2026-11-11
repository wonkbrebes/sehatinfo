#!/usr/bin/env bash
# Menambah izin notifikasi, receiver alarm, dan desugaring untuk flutter_local_notifications.
# Jalankan setelah `flutter create --platforms=android .`
set -e
python3 - <<'PY'
import re, pathlib
m = pathlib.Path('android/app/src/main/AndroidManifest.xml')
t = m.read_text()
if 'POST_NOTIFICATIONS' not in t:
    t = t.replace('<application', '<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>\n    <application', 1)
if 'ScheduledNotificationReceiver' not in t:
    t = t.replace('</application>', '    <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />\n    </application>', 1)
m.write_text(t)
for name in ('build.gradle.kts', 'build.gradle'):
    g = pathlib.Path('android/app') / name
    if not g.exists():
        continue
    s = g.read_text()
    kts = name.endswith('.kts')
    if 'oreLibraryDesugaringEnabled' not in s:
        flag = 'isCoreLibraryDesugaringEnabled = true' if kts else 'coreLibraryDesugaringEnabled true'
        s = re.sub(r'(compileOptions\s*\{)', lambda x: x.group(1) + '\n        ' + flag, s, count=1)
    if 'desugar_jdk_libs' not in s:
        dep = 'coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")' if kts else "coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.0.4'"
        if re.search(r'^dependencies\s*\{', s, re.M):
            s = re.sub(r'^(dependencies\s*\{)', lambda x: x.group(1) + '\n    ' + dep, s, count=1, flags=re.M)
        else:
            s += '\ndependencies {\n    ' + dep + '\n}\n'
    g.write_text(s)
    break
print('patch_android: selesai')
PY
