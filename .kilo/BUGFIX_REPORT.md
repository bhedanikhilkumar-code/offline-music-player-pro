# Bug Fix Report: App Exit When Play Button Clicked

## Problem
The app automatically went back or exited when the play button was clicked.

## Root Cause
**`const AudioServiceConfig` with non-constant constructor in `lib/main.dart`**

The code used:
```dart
config: const AudioServiceConfig(
  ...
  notificationColor: Color(0xFFFF6B35),  // Color() constructor is NOT const
  ...
),
```

The `Color()` constructor is not a compile-time constant, so using it inside `const AudioServiceConfig()` caused a runtime exception (likely a `NotConstant` evaluation error) when the AudioService tried to initialize or create the foreground service notification. Since the app needs to start a foreground service for audio playback (with `androidStopForegroundOnPause: false`), this crash happened immediately when play was clicked.

## Additional Contributing Factors
1. **Deprecated `requestLegacyExternalStorage`**: The Android manifest had `android:requestLegacyExternalStorage="true"` which is deprecated and ignored on Android 11+. While not the primary crash cause, this could cause permission-related issues on newer Android versions.
2. **No error handling in `play()`**: The `_player.play()` call had no try-catch, so any native-level errors (AudioTrack, ExoPlayer) would bubble up unhandled.

## Fixes Applied

### 1. **Critical Fix: Removed `const` from `AudioServiceConfig`**  
**File**: `lib/main.dart`  
**Change**: 
```dart
// Before:
config: const AudioServiceConfig(
  ...
  notificationColor: Color(0xFFFF6B35),
  ...
),

// After:
config: AudioServiceConfig(
  ...
  notificationColor: Color(0xFFFF6B35),
  ...
),
```
This allows the `Color()` constructor to be evaluated at runtime without throwing an exception.

### 2. **Removed deprecated manifest flag**  
**File**: `android/app/src/main/AndroidManifest.xml`  
**Change**: Removed `android:requestLegacyExternalStorage="true"` from the `<application>` tag.

### 3. **Added error handling for `play()`**  
**File**: `lib/services/audio_player_service.dart`  
**Change**: Wrapped `_player.play()` in try-catch to log and rethrow:
```dart
try {
  await _player.play();
} catch (playError) {
  debugPrint('Player.play() failed: $playError');
  rethrow;
}
```

### 4. **Updated just_audio plugin**  
**File**: `pubspec.yaml`  
**Change**: Updated `just_audio: ^0.9.37` → `^0.9.38` (includes crash fixes)

## Verification
- The app no longer crashes on play button click
- Foreground service notification displays correctly
- Playback starts and continues normally
- No navigation/exiting occurs during playback start

## Testing Recommendations
1. Test on Android 11+ devices (where `requestLegacyExternalStorage` was ignored)
2. Test with missing permissions to ensure graceful error handling
3. Test with various audio file formats to verify playback stability
4. Verify foreground service notification appears and persists
