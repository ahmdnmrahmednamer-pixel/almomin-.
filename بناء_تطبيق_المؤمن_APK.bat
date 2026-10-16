@echo off
chcp 65001 > nul
title بناء تطبيق المؤمن (Al-Momin) - حزم APK محسنة ومخففة
cd /d "%~dp0"
echo ======================================================================
echo 🕌 المؤسسة البرمجية المستقلة: خط أنابيب بناء حزم الأندرويد المحسنة (APK)
echo ======================================================================

set "JAVA_HOME=C:\Program Files\Android\Android Studio\jbr"
set "ANDROID_HOME=D:\Android\Sdk"
set "ANDROID_SDK_ROOT=D:\Android\Sdk"
set "PATH=D:\flutter\bin;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\cmdline-tools\latest\bin;%JAVA_HOME%\bin;%PATH%"

echo 🔍 فحص حالة Flutter SDK...
call flutter --version
if errorlevel 1 (
    echo ❌ فشل تشغيل Flutter SDK. يرجى التحقق من مسار D:\flutter
    pause
    exit /b 1
)

echo.
echo 📦 تثبيت حزم المشروع (pub get)...
cd app
call flutter pub get

echo.
echo 🔨 بناء حزم APK المحسنة والمخففة (Split-per-ABI)...
call flutter build apk --debug --split-per-abi --android-skip-build-dependency-validation
if errorlevel 1 (
    echo ❌ حدث خطأ أثناء تجميع الـ APK.
    pause
    exit /b 1
)

copy /y "build\app\outputs\flutter-apk\app-arm64-v8a-debug.apk" "..\المؤمن_AlMomin_v1.0.0_arm64.apk" > nul
copy /y "build\app\outputs\flutter-apk\app-armeabi-v7a-debug.apk" "..\المؤمن_AlMomin_v1.0.0_arm32.apk" > nul

echo.
echo ======================================================================
echo 🎉 اكتمل بناء حزم APK المحسنة بنجاح!
echo 📱 للهواتف الحديثة (64-bit): D:\برمجة\ططبيق المؤمن\المؤمن_AlMomin_v1.0.0_arm64.apk (حوالي 96 ميجابايت)
echo 📱 للهواتف القديمة (32-bit): D:\برمجة\ططبيق المؤمن\المؤمن_AlMomin_v1.0.0_arm32.apk (حوالي 76 ميجابايت)
echo ======================================================================
pause
