# 🎵 SOUNDSONG

**SOUNDSONG** is a music search application built with Flutter and Dart. The application uses the iTunes Search API to retrieve song information and provides a simple interface for discovering music.

## ✨ Features

- **Home:** Main page of the application.
- **Search:** Search for songs and retrieve music information from the iTunes Search API.
- **Library:** View saved favorite songs.
- **Audio Preview:** Play available song previews.
- **Navigation:** Navigate between Home, Search, and Library pages.

## 🛠️ Technologies

- Flutter
- Dart
- iTunes Search API
- HTTP requests for retrieving data
- `just_audio` for audio preview playback

## 🌐 API

SOUNDSONG uses the iTunes Search API to retrieve song information.

API endpoint:

`https://itunes.apple.com/search`

The application sends search parameters, processes the response, and displays the retrieved song information in the user interface.

## 📂 Project Structure

```text
lib/
├── main.dart
├── app_theme.dart
├── models/
│   └── song.dart
├── services/
│   └── music_service.dart
└── widgets/
    └── page_header.dart
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Visual Studio Code or another Flutter-compatible IDE
- An Android emulator or a physical device

### Installation

1. Clone this repository:

   ```bash
   git clone https://github.com/250605110073-commits/SOUND-SONG.git
   ```

2. Open the project directory:

   ```bash
   cd SOUND-SONG
   ```

3. Install the dependencies:

   ```bash
   flutter pub get
   ```

4. Run the application:

   ```bash
   flutter run
   ```

## 👨‍💻 Developer

**Alvian Deswendi**  

## 📄 License

This project was developed for educational purposes.
