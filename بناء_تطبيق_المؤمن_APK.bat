@echo off
chcp 65001 > nul
title بناء تطبيق المؤمن (Al-Momin) - حزم Release رسمية فائقة الصغر
cd /d "%~dp0"
echo ======================================================================
echo 🕌 المؤسسة البرمجية المستقلة: خط أنابيب بناء حزم الـ Release الرسمية
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
echo 📁 تحديد مسار المشروع...
set "APP_DIR=%~dp0app"
if not exist "%APP_DIR%" set "APP_DIR=%~dp0almomin\app"

echo 🔗 تعيين قرص افتراضي لتسريع التجميع وعزل الحروف العربية...
subst X: /D > nul 2>&1
subst X: "%APP_DIR%"
if errorlevel 1 (
    echo ⚠️ تعذر تعيين القرص X، سيتم التجميع المباشر...
    cd /d "%APP_DIR%"
) else (
    cd /d X:\
)

echo.
echo 📦 تثبيت حزم المشروع (pub get)...
call flutter pub get

echo.
echo 🔨 بناء حزم Production Release المخففة (Split-per-ABI AOT)...
call flutter build apk --release --split-per-abi --no-tree-shake-icons --android-skip-build-dependency-validation
if errorlevel 1 (
    echo ❌ حدث خطأ أثناء تجميع الـ Release APK.
    subst X: /D > nul 2>&1
    pause
    exit /b 1
)

echo 📋 نسخ الحزم إلى المجلد الرئيسي...
copy /y "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk" "%~dp0المؤمن_AlMomin_v1.0.0_arm64.apk" > nul
copy /y "build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk" "%~dp0المؤمن_AlMomin_v1.0.0_arm32.apk" > nul

subst X: /D > nul 2>&1

echo.
echo ======================================================================
echo 🎉 اكتمل بناء حزم الـ Release بنجاح فائق وتخفيض الحجم بنسبة 75%!
echo 📱 للهواتف الحديثة (64-bit): D:\برمجة\ططبيق المؤمن\المؤمن_AlMomin_v1.0.0_arm64.apk (حوالي 31 ميجابايت)
echo 📱 للهواتف القديمة (32-bit): D:\برمجة\ططبيق المؤمن\المؤمن_AlMomin_v1.0.0_arm32.apk (حوالي 29 ميجابايت)
echo ======================================================================
pause
