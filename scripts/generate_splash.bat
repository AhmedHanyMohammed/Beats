@echo off
echo Running flutter pub get...
flutter pub get || goto :err

echo Generating launcher icons...
dart run flutter_launcher_icons || goto :err

echo Generating native splash...
dart run flutter_native_splash:create || goto :err

echo Cleaning build...
flutter clean

echo Done. Rebuild with: flutter run
exit /b 0

:err
echo.
echo Failed. Check network/DNS or version constraints.
exit /b 1

