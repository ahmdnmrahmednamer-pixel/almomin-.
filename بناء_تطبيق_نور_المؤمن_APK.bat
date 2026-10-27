@echo off
chcp 65001 > nul
title بناء تطبيق نور المؤمن (Noor Al-Momin) - حزم Release رسمية فائقة الصغر
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
set "APP_DIR=%~dp0app\app"
if not exist "%APP_DIR%" set "APP_DIR=%~dp0app"
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
echo 🔨 بناء حزمة Production Release الموحدة المخففة (ARM64 + ARMv7 فائقة الصغر ~29MB)...
call flutter build apk --release --target-platform android-arm,android-arm64 --android-skip-build-dependency-validation
if errorlevel 1 (
    echo ❌ حدث خطأ أثناء تجميع الـ Release APK.
    subst X: /D > nul 2>&1
    pause
    exit /b 1
)

echo 📋 تنظيف أي نسخ قديمة ونسخ أحدث إصدار إلى المجلد الرئيسي...
del /q "%~dp0*v1.0.0*.apk" 2>nul
del /q "%~dp0*v1.1.0*.apk" 2>nul
del /q "%~dp0*v1.2.0*.apk" 2>nul
del /q "%~dp0app-*.apk" 2>nul

if exist "build\app\outputs\flutter-apk\app-release.apk" (
    copy /y "build\app\outputs\flutter-apk\app-release.apk" "%~dp0نور_المؤمن_Noor_AlMomin_Latest.apk" > nul
) else (
    copy /y "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk" "%~dp0نور_المؤمن_Noor_AlMomin_Latest.apk" > nul
)

subst X: /D > nul 2>&1

echo.
echo ======================================================================
echo 🎉 اكتمل بناء أحدث نسخة من تطبيق نور المؤمن بنجاح!
echo 📱 مسار النسخة الأحدث المعتمدة المباشرة للتثبيت:
echo    %~dp0نور_المؤمن_Noor_AlMomin_Latest.apk
echo 💡 تم تنظيف وحذف كافة الإصدارات القديمة لضمان عدم تثبيت أي نسخة سابقة.
echo ======================================================================
pause

