# BLKWDS Manager Build Configuration

This document describes how to build BLKWDS Manager for different environments.

## Environment Configuration

BLKWDS Manager supports three environments:

1. **Development** - Used during active development
2. **Testing** - Used for testing and QA
3. **Production** - Used for production releases

The environment is determined at build time using the `--dart-define=ENVIRONMENT` flag.

## Build and Run Commands

### Development Environment

```bash
# Build and run in development mode (recommended for development)
flutter run --debug --dart-define=ENVIRONMENT=development

# Build for Windows in development mode
flutter build windows --debug --dart-define=ENVIRONMENT=development

# Build for Android in development mode
flutter build apk --debug --dart-define=ENVIRONMENT=development

# Build for iOS in development mode
flutter build ios --debug --dart-define=ENVIRONMENT=development
```

### Testing Environment

```bash
# Build and run in testing mode
flutter run --profile --dart-define=ENVIRONMENT=testing

# Build for Windows in testing mode
flutter build windows --profile --dart-define=ENVIRONMENT=testing

# Build for Android in testing mode
flutter build apk --profile --dart-define=ENVIRONMENT=testing

# Build for iOS in testing mode
flutter build ios --profile --dart-define=ENVIRONMENT=testing
```

### Production Environment

```bash
# Build and run in production mode
flutter run --release --dart-define=ENVIRONMENT=production

# Build for Windows in production mode
flutter build windows --release --dart-define=ENVIRONMENT=production

# Build for Android in production mode
flutter build apk --release --dart-define=ENVIRONMENT=production

# Build for iOS in production mode
flutter build ios --release --dart-define=ENVIRONMENT=production
```

### Running After Build

If you've built the app but need to run it:

```bash
# For Windows, navigate to the build directory and run the executable
cd build\windows\runner\Debug
.\blkwds_manager.exe

# For Android, install the APK
adb install build/app/outputs/flutter-apk/app-debug.apk

# For iOS, open the Xcode project and run from there
open build/ios/Runner.xcworkspace
```

## Environment-Specific Behavior

The application behavior changes based on the environment:

### Development Mode Behavior

- Data seeding is enabled by default
- Debug features are available
- Detailed logging is enabled
- Database reseeding is allowed

### Testing Mode Behavior

- Data seeding is enabled by default
- Debug features are available
- Detailed logging is enabled
- Database reseeding is allowed

### Production Mode Behavior

- Data seeding is disabled
- Debug features are hidden (except when explicitly enabled)
- Minimal logging
- Database reseeding is disabled

## Default Environment Detection

If no environment is specified during build, the application will:

- Use **Development** environment for debug builds
- Use **Production** environment for release builds

## Overriding Environment at Runtime

For testing purposes, you can override the environment at runtime by setting the `ENVIRONMENT` environment variable before launching the application.

```bash
# Windows
set ENVIRONMENT=development
flutter run

# macOS/Linux
export ENVIRONMENT=development
flutter run
```

This is useful for testing production behavior in a development build.

## Troubleshooting

### App Builds Successfully But Doesn't Launch

If the app builds successfully but doesn't launch, try the following:

1. **Use `flutter run` instead of `flutter build`**
   ```bash
   flutter run --debug --dart-define=ENVIRONMENT=development
   ```

2. **Check the build directory**
   Navigate to the build directory and run the executable directly:
   ```bash
   cd build\windows\runner\Debug
   .\blkwds_manager.exe
   ```

3. **Clean the build**
   ```bash
   flutter clean
   flutter pub get
   flutter run --debug --dart-define=ENVIRONMENT=development
   ```

4. **Check for errors in the console**
   Look for any error messages in the console output during build or launch.

5. **Verify environment variable**
   Make sure the environment variable is being passed correctly. Try using a simpler approach:
   ```bash
   flutter run
   ```
   Then check the logs to see what environment was detected.

### Environment Not Detected Correctly

If the environment is not being detected correctly:

1. **Check the logs**
   Look for the "Running in X environment" message in the logs.

2. **Try a different syntax**
   Some shells may require different syntax for passing dart-define:
   ```bash
   flutter run --dart-define="ENVIRONMENT=development"
   ```

3. **Use environment variables**
   Set the environment variable before running:
   ```bash
   set ENVIRONMENT=development
   flutter run
   ```
