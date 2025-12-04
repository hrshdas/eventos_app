# EVENTOS App - Flutter HomeScreen

## Prerequisites

1. **Install Flutter**
   - Visit: https://flutter.dev/docs/get-started/install/linux
   - Or install via snap: `sudo snap install flutter --classic`
   - Verify installation: `flutter doctor`

2. **Install Android Studio / VS Code** (for running on emulator/device)
   - Android Studio: https://developer.android.com/studio
   - VS Code: Install Flutter extension

## Running the App

### Step 1: Install Flutter Dependencies
```bash
flutter pub get
```

### Step 2: Check Available Devices
```bash
flutter devices
```

### Step 3: Run the App

**Option A: Run on connected device/emulator**
```bash
flutter run
```

**Option B: Run on Chrome (Web)**
```bash
flutter run -d chrome
```

**Option C: Run on specific device**
```bash
flutter run -d <device-id>
```

## Quick Setup Commands

```bash
# Navigate to project directory
cd "/home/hrshdas/BETA/beta frontend"

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Troubleshooting

- **Flutter not found**: Install Flutter first (see Prerequisites)
- **No devices found**: Start an Android emulator or connect a physical device
- **Dependencies error**: Run `flutter pub get` again
- **SDK version error**: Ensure Flutter SDK version >= 3.0.0

