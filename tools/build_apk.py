"""
Automated Android APK Build Pipeline for Noor Al-Momin (نور المؤمن)
Orchestrated by the Global Autonomous Software Conglomerate
(mobile_app_engineer, devops_release_engineer, and lead_architect).
"""

import os
import sys
import subprocess
import shutil

# Ensure UTF-8 output
if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

PROJECT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
APP_DIR = os.path.join(PROJECT_DIR, "app")
ANDROID_DIR = os.path.join(APP_DIR, "android")

def find_java_home():
    # 1. Existing env var
    if os.environ.get("JAVA_HOME") and os.path.exists(os.environ.get("JAVA_HOME")):
        return os.environ.get("JAVA_HOME")
    
    # 2. Bundled JBR in Android Studio
    studio_jbr = r"C:\Program Files\Android\Android Studio\jbr"
    if os.path.exists(studio_jbr):
        return studio_jbr
    
    # 3. Common Java paths
    java_paths = [
        r"C:\Program Files\Java\jdk-21",
        r"C:\Program Files\Java\jdk-17",
        r"C:\Program Files\Eclipse Adoptium\jdk-17",
    ]
    for p in java_paths:
        if os.path.exists(p):
            return p
    return None

def find_flutter_bin():
    # 1. On PATH
    which_flutter = shutil.which("flutter")
    if which_flutter:
        return which_flutter
    
    # 2. D:\flutter\bin\flutter.bat
    candidates = [
        r"D:\flutter\bin\flutter.bat",
        r"C:\flutter\bin\flutter.bat",
        r"C:\src\flutter\bin\flutter.bat",
        os.path.expanduser(r"~\flutter\bin\flutter.bat"),
    ]
    for c in candidates:
        if os.path.exists(c):
            return c
    return None

def find_android_sdk():
    # 1. ANDROID_HOME or ANDROID_SDK_ROOT
    for var in ["ANDROID_HOME", "ANDROID_SDK_ROOT"]:
        val = os.environ.get(var)
        if val and os.path.exists(val):
            return val
    
    # 2. Standard location
    local_sdk = os.path.expandvars(r"%LOCALAPPDATA%\Android\Sdk")
    if os.path.exists(local_sdk):
        return local_sdk
    
    custom_paths = [r"D:\Android\Sdk", r"C:\Android\Sdk"]
    for p in custom_paths:
        if os.path.exists(p):
            return p
    return None

def main():
    print("=" * 70)
    print("🕌 خط أنابيب بناء حزمة الأندرويد (APK) لتطبيق نور المؤمن")
    print("=" * 70)

    # 1. Java check
    java_home = find_java_home()
    if java_home:
        os.environ["JAVA_HOME"] = java_home
        os.environ["PATH"] = os.path.join(java_home, "bin") + os.pathsep + os.environ.get("PATH", "")
        print(f"✅ تم اكتشاف بيئة جافا (Java JDK): {java_home}")
    else:
        print("⚠️ لم يتم العثور على مسار جافا، يرجى تثبيت JDK 17 أو تشغيل Android Studio.")

    # 2. Flutter check
    flutter_bin = find_flutter_bin()
    if not flutter_bin:
        print("❌ لم يتم العثور على Flutter SDK في النظام أو في D:\\flutter.")
        print("   💡 جاري تنزيل فلاتر في الخلفية، أو يمكنك تثبيته بالأمر: git clone -b stable https://github.com/flutter/flutter.git D:\\flutter")
        sys.exit(1)
    
    flutter_dir = os.path.dirname(os.path.dirname(flutter_bin))
    print(f"✅ تم اكتشاف Flutter SDK: {flutter_dir}")

    # Add flutter to PATH
    os.environ["PATH"] = os.path.join(flutter_dir, "bin") + os.pathsep + os.environ.get("PATH", "")

    # 3. Android SDK check
    sdk_dir = find_android_sdk()
    if sdk_dir:
        print(f"✅ تم اكتشاف Android SDK: {sdk_dir}")
        # Write local.properties
        local_props_path = os.path.join(ANDROID_DIR, "local.properties")
        with open(local_props_path, "w", encoding="utf-8") as f:
            f.write(f"sdk.dir={sdk_dir.replace(chr(92), '/')}\n")
            f.write(f"flutter.sdk={flutter_dir.replace(chr(92), '/')}\n")
        print("✅ تم تحديث ملف android/local.properties بنجاح.")
    else:
        print("⚠️ تحذير: لم يتم العثور على Android SDK مكتمل على المسار الافتراضي.")
        print("   💡 افتح Android Studio وقم بإكمال معالج التثبيت السريع لتحميل SDK Platforms (Android 34).")

    # 4. Run flutter pub get
    print("\n📦 جاري تحميل حزم ومكتبات المشروع (flutter pub get)...")
    res_pub = subprocess.run([flutter_bin, "pub", "get"], cwd=APP_DIR)
    if res_pub.returncode != 0:
        print("❌ فشل تحميل الحزم، يرجى مراجعة الاتصال بالإنترنت.")
        sys.exit(res_pub.returncode)

    # 5. Build APK
    print("\n🔨 جاري تجميع وبناء ملف APK (النسخة التجريبية الأولى)...")
    build_cmd = [flutter_bin, "build", "apk", "--debug"]
    res_build = subprocess.run(build_cmd, cwd=APP_DIR)
    
    if res_build.returncode == 0:
        apk_output = os.path.join(APP_DIR, "build", "app", "outputs", "flutter-apk", "app-debug.apk")
        print("\n" + "=" * 70)
        print(f"🎉 تم بناء أول نسخة APK بنجاح!")
        print(f"📍 مسار الملف: {apk_output}")
        print("=" * 70)
    else:
        print(f"❌ انتهى البناء مع رمز خطأ: {res_build.returncode}")
        sys.exit(res_build.returncode)

if __name__ == "__main__":
    main()
