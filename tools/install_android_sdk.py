"""
Headless Android SDK Installer for Al-Momin
Automated by devops_release_engineer and mobile_app_engineer.
Downloads official Google command-line tools, installs platform-tools, platforms;android-34,
and build-tools;34.0.0, accepts licenses, and registers SDK with Flutter.
"""

import os
import sys
import zipfile
import urllib.request
import subprocess
import shutil

# Ensure UTF-8 output
if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

SDK_DIR = r"D:\Android\Sdk"
CMDLINE_ZIP_URL = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
ZIP_PATH = r"D:\Android\cmdline-tools.zip"
CMDLINE_TOOLS_LATEST = os.path.join(SDK_DIR, "cmdline-tools", "latest")
JAVA_HOME = r"C:\Program Files\Android\Android Studio\jbr"

def setup():
    os.makedirs(r"D:\Android", exist_ok=True)
    os.makedirs(SDK_DIR, exist_ok=True)

    # 1. Download cmdline-tools if not already present
    sdkmanager_bin = os.path.join(CMDLINE_TOOLS_LATEST, "bin", "sdkmanager.bat")
    if not os.path.exists(sdkmanager_bin):
        if not os.path.exists(ZIP_PATH):
            print(f"📥 جاري تنزيل Google Android Command-Line Tools ({CMDLINE_ZIP_URL})...")
            def reporthook(blocknum, blocksize, totalsize):
                percent = min(100.0, blocknum * blocksize * 100 / totalsize)
                sys.stdout.write(f"\r  جاري التحميل: {percent:.1f}% ({blocknum * blocksize // (1024*1024)}MB / {totalsize // (1024*1024)}MB)")
                sys.stdout.flush()
            urllib.request.urlretrieve(CMDLINE_ZIP_URL, ZIP_PATH, reporthook)
            print("\n✅ تم التنزيل بنجاح.")

        # Extract
        print(f"📦 جاري فك ضغط الأدوات إلى {CMDLINE_TOOLS_LATEST}...")
        temp_extract = r"D:\Android\temp_extract"
        if os.path.exists(temp_extract):
            shutil.rmtree(temp_extract, ignore_errors=True)
        os.makedirs(temp_extract, exist_ok=True)

        with zipfile.ZipFile(ZIP_PATH, 'r') as zip_ref:
            zip_ref.extractall(temp_extract)

        extracted_cmdline = os.path.join(temp_extract, "cmdline-tools")
        if os.path.exists(CMDLINE_TOOLS_LATEST):
            shutil.rmtree(CMDLINE_TOOLS_LATEST, ignore_errors=True)
        os.makedirs(os.path.dirname(CMDLINE_TOOLS_LATEST), exist_ok=True)
        shutil.move(extracted_cmdline, CMDLINE_TOOLS_LATEST)
        shutil.rmtree(temp_extract, ignore_errors=True)
        print("✅ تم تثبيت أداة sdkmanager في الموضع القياسي.")

    # 2. Setup environment for sdkmanager
    env = os.environ.copy()
    env["JAVA_HOME"] = JAVA_HOME
    env["ANDROID_HOME"] = SDK_DIR
    env["ANDROID_SDK_ROOT"] = SDK_DIR
    env["PATH"] = os.path.join(JAVA_HOME, "bin") + os.pathsep + os.path.join(CMDLINE_TOOLS_LATEST, "bin") + os.pathsep + env.get("PATH", "")

    # 3. Automatically accept all licenses
    licenses_dir = os.path.join(SDK_DIR, "licenses")
    os.makedirs(licenses_dir, exist_ok=True)
    # Known hashes for Google Android SDK licenses
    known_licenses = {
        "android-sdk-license": (
            "24333f8a63b6825ea9c5514f83c2829b004d1fee\n"
            "d56f5187479451eabf01fb78af6dfcb131a6481e\n"
            "84831b9409646a33ee13ef6161f8da83e604e5e4\n"
        ),
        "android-sdk-preview-license": "84831b9409646a33ee13ef6161f8da83e604e5e4\n",
        "android-googletv-license": "601085b94cd77f0b54ff86406957099fed8072d0\n",
        "google-gdk-license": "33b6a2b64607f11b759f320e69d7996f970cce40\n",
        "mips-android-sysimage-license": "e9acab583f4e49a40f33b94e503b453096000302\n"
    }
    for lic_name, lic_hash in known_licenses.items():
        with open(os.path.join(licenses_dir, lic_name), "w", encoding="utf-8") as f:
            f.write(lic_hash)
    print("✅ تم قبول وتثبيت رخص Android SDK رسمياً.")

    # 4. Install essential SDK components (platform-tools, platforms;android-34, build-tools;34.0.0)
    packages = ["platform-tools", "platforms;android-34", "build-tools;34.0.0"]
    print(f"🚀 جاري تثبيت حزم الأندرويد الأساسية عبر sdkmanager: {', '.join(packages)}...")
    cmd = [
        sdkmanager_bin,
        f"--sdk_root={SDK_DIR}",
        *packages
    ]
    p = subprocess.Popen(
        cmd,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        env=env,
        text=True,
        encoding="utf-8",
        errors="replace"
    )
    # Pipe "y\n" repeatedly to accept any prompts
    out, _ = p.communicate(input="y\ny\ny\ny\ny\n")
    print(out)

    if p.returncode == 0:
        print("🎉 تم تثبيت Android SDK (Platform 34 & Build Tools 34.0.0) بنجاح تام!")
    else:
        print(f"⚠️ انتهى sdkmanager برمز: {p.returncode}")

    # 5. Configure Flutter to use D:\Android\Sdk
    flutter_bin = r"D:\flutter\bin\flutter.bat"
    if os.path.exists(flutter_bin):
        print("🔗 جاري ربط Android SDK ببيئة فلاتر...")
        subprocess.run([flutter_bin, "config", "--android-sdk", SDK_DIR], env=env)
        subprocess.run([flutter_bin, "doctor"], env=env)

    # 6. Set permanent User environment variables in Windows
    ps_cmd = (
        f'[Environment]::SetEnvironmentVariable("ANDROID_HOME", "{SDK_DIR}", "User"); '
        f'[Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", "{SDK_DIR}", "User")'
    )
    subprocess.run(["powershell", "-Command", ps_cmd])
    print(f"✅ تم حفظ متغيرات البيئة ANDROID_HOME={SDK_DIR} بشكل دائم في النظام.")

if __name__ == "__main__":
    setup()
