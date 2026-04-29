<div align="center">

# 🎵 Music Player Pro

### Premium Offline Music Player for Android

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-21+-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://developer.android.com)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)](LICENSE)

*A beautifully crafted, feature-rich offline music player built with Flutter — featuring glassmorphism UI, dynamic color extraction, native equalizer, 5 home screen widgets, and more.*

---

</div>

## ✨ Features

### 🎧 Core Playback
- **Full Audio Playback** — Play local MP3, AAC, OGG, FLAC, WAV files with `just_audio`
- **Background Playback** — Continues playing with lock screen controls via `audio_service`
- **Queue Management** — Add, remove, reorder songs in the playback queue
- **Shuffle & Repeat** — Shuffle all, repeat one, repeat all modes
- **Playback Speed** — Adjustable speed from 0.5× to 2.0×
- **Seek Controls** — Scrub through songs with the seek bar or ±10s skip buttons

### 🎨 Premium UI & Themes
- **Glassmorphism Design** — Frosted glass containers with blur effects
- **Dynamic Color Extraction** — Automatically pulls dominant colors from album art using `palette_generator`
- **15+ Theme Presets** — Curated gradient themes (Neon Purple, Sunset, Ocean, Midnight, Forest, etc.)
- **Custom Themes** — Set your own background image or color
- **Staggered Animations** — Smooth list entrance animations with `flutter_staggered_animations`
- **Marquee Text** — Long song titles scroll automatically

### 🎛️ Native Equalizer
- **5-Band Equalizer** — 60Hz, 230Hz, 910Hz, 3.6kHz, 14kHz frequency control
- **14 Professional Presets** — Pop, Rock, Hip Hop, Dance, Classical, Jazz, R&B, Electronic, Vocal, Acoustic, Bass Heavy, Loudness, and more
- **Bass Boost** — Native Android bass enhancement (0–1000 strength)
- **Virtualizer** — 3D surround sound effect (0–1000 strength)
- **Native Android Implementation** — Uses Android's `Equalizer`, `BassBoost`, and `Virtualizer` APIs via platform channels for real audio processing

### 📱 5 Home Screen Widgets
| Widget | Size | Description |
|--------|------|-------------|
| **Mini Controls** | 4×1 | Compact strip with prev/play/next + song title |
| **Now Playing** | 4×2 | Album art, song info, and full controls |
| **Full Player** | 4×3 | Large album art, status indicator, all controls |
| **Quick Play** | 2×2 | Big play/pause button with song title |
| **Recent Playlist** | 4×2 | Last played song with play button |

### 📚 Library Management
- **Songs Tab** — All songs with sort by title, artist, album, duration, date, or size
- **Albums Tab** — Browse by album with artwork
- **Artists Tab** — Browse by artist
- **Folders Tab** — Browse by file system directory
- **Playlists** — Create, rename, delete custom playlists
- **Recently Played** — Auto-tracked horizontal scrollable cards
- **Most Played** — Top tracks ranked by play count
- **Hidden Music** — Hide specific songs or entire folders

### 🔍 Smart Search
- **Universal Search** — Search songs, albums, artists in one place
- **Tab Filtering** — Filter by category (All, Songs, Albums, Artists)
- **Recent Searches** — Quick access to previous queries

### 🛠️ Additional Features
- **Sleep Timer** — 5, 10, 15, 30, 60 min or custom duration with visual countdown
- **Tag Editor** — Edit song title, artist, album, genre metadata
- **Set as Ringtone** — Set any song as your phone ringtone
- **Lyrics** — Add and view lyrics for any song
- **Privacy Lock** — PIN protection for the app

---

## 🏗️ Architecture

```
lib/
├── main.dart                    # App entry point with MultiProvider
├── app.dart                     # Initialization flow (permissions → providers)
├── constants/
│   ├── app_colors.dart          # Color palette & gradients
│   ├── app_constants.dart       # EQ presets, frequency labels
│   ├── app_strings.dart         # All UI strings (localization ready)
│   └── app_text_styles.dart     # Typography system
├── models/
│   ├── song_model.dart          # Song data model with computed properties
│   ├── equalizer_model.dart     # EQ state (bands, bass, virtualizer)
│   └── playlist_model.dart      # Playlist model
├── providers/
│   ├── audio_provider.dart      # Playback state management
│   ├── music_library_provider.dart  # Song scanning & library
│   ├── equalizer_provider.dart  # EQ state with native binding
│   ├── theme_provider.dart      # Dynamic theming & color extraction
│   ├── playlist_provider.dart   # Playlist CRUD
│   ├── search_provider.dart     # Search logic
│   ├── settings_provider.dart   # App settings
│   ├── sleep_timer_provider.dart # Timer countdown
│   └── lyrics_provider.dart     # Lyrics storage
├── services/
│   ├── audio_player_service.dart # just_audio wrapper (singleton)
│   ├── equalizer_service.dart   # Native EQ via MethodChannel
│   └── storage_service.dart     # SharedPreferences abstraction
├── screens/
│   ├── splash_screen.dart       # Animated launch screen
│   ├── permission_screen.dart   # Storage permission flow
│   ├── home_screen.dart         # Main tabbed interface (Songs/Playlists/Folders/Albums/Artists)
│   ├── player_screen.dart       # Full-screen player with album art
│   ├── equalizer_screen.dart    # 5-band EQ with presets
│   ├── search_screen.dart       # Universal search
│   ├── settings_screen.dart     # App preferences
│   ├── theme_screen.dart        # Theme customization
│   ├── widgets_screen.dart      # Home screen widget showcase
│   ├── sleep_timer_screen.dart  # Timer setup
│   ├── tag_editor_screen.dart   # Metadata editor
│   ├── lyrics_screen.dart       # Lyrics viewer
│   ├── hidden_music_screen.dart # Hidden songs manager
│   ├── album_detail_screen.dart # Album track list
│   ├── artist_detail_screen.dart # Artist track list
│   ├── folder_detail_screen.dart # Folder contents
│   └── playlist_detail_screen.dart # Playlist tracks
└── widgets/
    ├── mini_player.dart         # Bottom mini player bar
    ├── song_tile.dart           # Song list item with visualizer
    ├── drawer_menu.dart         # Navigation drawer
    ├── glass_container.dart     # Glassmorphism container
    ├── song_options_sheet.dart  # Song context menu
    ├── seek_bar.dart            # Audio seek bar
    ├── animated_play_button.dart # Animated play/pause
    ├── eq_slider.dart           # EQ frequency slider
    ├── album_tile.dart          # Album grid item
    ├── artist_tile.dart         # Artist list item
    ├── folder_tile.dart         # Folder list item
    └── playlist_tile.dart       # Playlist list item

android/app/src/main/
├── kotlin/.../
│   ├── MainActivity.kt          # Flutter engine + plugin registration
│   ├── equalizer/
│   │   └── EqualizerPlugin.kt   # Native EQ/BassBoost/Virtualizer
│   └── widgets/
│       ├── BaseMusicWidget.kt       # Widget base class
│       ├── WidgetActionReceiver.kt  # Media button broadcaster
│       ├── MiniControlsWidget.kt    # Widget 1: 4×1
│       ├── NowPlayingWidget.kt      # Widget 2: 4×2
│       ├── FullPlayerWidget.kt      # Widget 3: 4×3
│       ├── QuickPlayWidget.kt       # Widget 4: 2×2
│       └── RecentPlaylistWidget.kt  # Widget 5: 4×2
└── res/
    ├── layout/                  # Widget XML layouts
    ├── drawable/                 # Widget icons & backgrounds
    └── xml/                     # Widget provider configs
```

---

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `just_audio` | Core audio playback engine |
| `audio_service` | Background playback & media notification |
| `audio_session` | Audio session management |
| `on_audio_query` | Device music scanning |
| `provider` | State management |
| `shared_preferences` | Persistent storage |
| `palette_generator` | Album art color extraction |
| `google_fonts` | Premium typography |
| `flutter_staggered_animations` | List entrance animations |
| `marquee` | Scrolling text widget |
| `rxdart` | Reactive stream operators |
| `audiotags` | Metadata tag editing |
| `ringtone_set` | Set as ringtone API |
| `permission_handler` | Runtime permission management |
| `path_provider` | File system paths |
| `file_picker` | File selection |
| `image_picker` | Album art replacement |
| `intl` | Date/number formatting |
| `uuid` | Unique ID generation |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0
- Android SDK with API 21+ (Android 5.0+)
- Android Studio / VS Code with Flutter extension

### Installation

```bash
# Clone the repository
git clone https://github.com/bhedanikhilkumar-code/offline-music-player-pro.git

# Navigate to the project
cd offline-music-player-pro

# Install dependencies
flutter pub get

# Run in debug mode
flutter run

# Build release APK
flutter build apk --release
```

### Release APK Location

```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 📱 Screenshots

> Add your screenshots here

---

## 🔧 Technical Highlights

### Native Equalizer Integration
Unlike third-party packages, our equalizer uses Android's native audio effect APIs directly via Kotlin platform channels:
- `android.media.audiofx.Equalizer` — 5-band frequency control
- `android.media.audiofx.BassBoost` — Low-frequency enhancement
- `android.media.audiofx.Virtualizer` — 3D surround sound

The equalizer binds to `just_audio`'s actual Android audio session ID for real-time audio processing.

### Dynamic Theming
Album art colors are extracted in real-time using `palette_generator` and propagated through `ThemeProvider` to every screen — creating a cohesive, immersive visual experience that changes with each song.

### Home Screen Widgets
5 native Android `AppWidgetProvider` implementations communicate with the Flutter app through `SharedPreferences` and forward playback controls via `MediaSession` key events.

### State Management
The app uses Flutter's `Provider` pattern with `MultiProvider` at the root. Each provider manages a specific domain (audio, library, theme, EQ, etc.) and persists state through `StorageService`.

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Built with ❤️ using Flutter**

</div>
