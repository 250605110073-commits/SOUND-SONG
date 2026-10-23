import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'app_theme.dart';
import 'models/song.dart';
import 'services/music_service.dart';
import 'widgets/page_header.dart';

void main() {
  runApp(const SoundWaveApp());
}

class SoundWaveApp extends StatefulWidget {
  const SoundWaveApp({super.key});

  @override
  State<SoundWaveApp> createState() => _SoundWaveAppState();
}

class _SoundWaveAppState extends State<SoundWaveApp> {
  bool isDarkMode = true;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOUNDSONG',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: HomePage(
        isDarkMode: isDarkMode,
        onToggleTheme: toggleTheme,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const HomePage({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController = TextEditingController();
  final AudioPlayer audioPlayer = AudioPlayer();
  final MusicService musicService = MusicService();

  final Map<int, Song> favoriteSongs = {};

  List<Song> homeSongs = [];
  List<Song> searchResults = [];

  bool isHomeLoading = true;
  bool isSearchLoading = false;

  String? homeError;
  String? searchError;
  String lastSearchTerm = '';

  int currentIndex = 0;
  int? playingSongId;
  Song? currentSong;

  Color get accent => Theme.of(context).colorScheme.primary;

  Color get card => Theme.of(context).cardColor;

  Color get secondaryText =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65);

  Color get favoriteRed => AppTheme.favoriteRed;

  @override
  void initState() {
    super.initState();
    fetchHomeSongs();
  }

  Future<List<Song>> requestSongs(String term) {
    return musicService.requestSongs(term);
  }

  Future<void> fetchHomeSongs() async {
    if (!mounted) return;

    setState(() {
      isHomeLoading = true;
      homeError = null;
    });

    try {
      final songs = await requestSongs('pop music');

      if (!mounted) return;

      setState(() {
        homeSongs = songs;
        isHomeLoading = false;

        if (songs.isEmpty) {
          homeError = 'Lagu belum ditemukan. Coba muat ulang.';
        }
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isHomeLoading = false;
        homeError = 'Gagal mengambil lagu. Periksa koneksi internet.';
      });
    }
  }

  Future<void> searchSongs() async {
    final term = searchController.text.trim();

    if (term.isEmpty) {
      setState(() {
        searchResults = [];
        lastSearchTerm = '';
        searchError = 'Ketik judul lagu atau nama artis terlebih dahulu.';
      });
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      lastSearchTerm = term;
      isSearchLoading = true;
      searchError = null;
    });

    try {
      final results = await requestSongs(term);

      if (!mounted) return;

      setState(() {
        searchResults = results;
        isSearchLoading = false;

        if (results.isEmpty) {
          searchError = 'Tidak ada lagu yang cocok dengan "$term".';
        }
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isSearchLoading = false;
        searchError = 'Pencarian gagal. Periksa koneksi internet.';
      });
    }
  }

  Future<void> playSong(Song song) async {
    final url = song.previewUrl;

    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preview audio lagu ini tidak tersedia.'),
        ),
      );
      return;
    }

    try {
      if (playingSongId == song.id && audioPlayer.playing) {
        await audioPlayer.pause();
        return;
      }

      await audioPlayer.setUrl(url);

      if (!mounted) return;

      setState(() {
        currentSong = song;
        playingSongId = song.id;
      });

      unawaited(audioPlayer.play());
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Audio gagal diputar. Silakan coba lagu lain.'),
        ),
      );
    }
  }

  void toggleFavorite(Song song) {
    final wasFavorite = favoriteSongs.containsKey(song.id);

    setState(() {
      if (wasFavorite) {
        favoriteSongs.remove(song.id);
      } else {
        favoriteSongs[song.id] = song;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasFavorite
              ? 'Lagu dihapus dari Library.'
              : 'Lagu ditambahkan ke Library.',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void selectTab(int index) {
    FocusScope.of(context).unfocus();

    setState(() {
      currentIndex = index;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  Widget artworkImage(Song song, {double size = 56}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: song.artwork.isEmpty
          ? Container(
              width: size,
              height: size,
              color: card,
              child: Icon(
                Icons.music_note,
                color: secondaryText,
              ),
            )
          : Image.network(
              song.artwork,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  width: size,
                  height: size,
                  color: card,
                  child: Icon(
                    Icons.music_note,
                    color: secondaryText,
                  ),
                );
              },
            ),
    );
  }

  Widget songTile(Song song) {
    final isFavorite = favoriteSongs.containsKey(song.id);
    final isCurrentSong = playingSongId == song.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 5,
        ),
        leading: artworkImage(song),
        title: Text(
          song.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          song.artist,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: secondaryText,
            fontSize: 12,
          ),
        ),
        trailing: SizedBox(
          width: 94,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                tooltip: isFavorite
                    ? 'Hapus dari Library'
                    : 'Tambah ke Library',
                visualDensity: VisualDensity.compact,
                onPressed: () => toggleFavorite(song),
                icon: Icon(
                  isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: isFavorite ? favoriteRed : secondaryText,
                  size: 21,
                ),
              ),
              IconButton(
                tooltip: 'Putar preview',
                visualDensity: VisualDensity.compact,
                onPressed: () => playSong(song),
                icon: Icon(
                  isCurrentSong && audioPlayer.playing
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill,
                  color: accent,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
        onTap: () => playSong(song),
      ),
    );
  }

  Widget loadingOrError({
    required bool loading,
    required String? error,
    required VoidCallback retry,
  }) {
    if (loading) {
      return Padding(
        padding: const EdgeInsets.all(42),
        child: Center(
          child: CircularProgressIndicator(
            color: accent,
          ),
        ),
      );
    }

    if (error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 36,
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.music_off,
                color: secondaryText,
                size: 42,
              ),
              const SizedBox(height: 12),
              Text(
                error,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: retry,
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget buildHomePage() {
    return RefreshIndicator(
      color: accent,
      onRefresh: fetchHomeSongs,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.graphic_eq,
                  color: Colors.black,
                  size: 29,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SOUNDSONG',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Music for every moment',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: widget.isDarkMode
                    ? 'Aktifkan mode terang'
                    : 'Aktifkan mode gelap',
                onPressed: widget.onToggleTheme,
                icon: Icon(
                  widget.isDarkMode
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  color: accent,
                  size: 27,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'Temukan musikmu',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Temukan lagu baru untuk menemani harimu.',
            style: TextStyle(color: secondaryText),
          ),
          const SizedBox(height: 22),
          InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () => selectTab(1),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: secondaryText,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Cari judul lagu atau artis...',
                      style: TextStyle(color: secondaryText),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 15,
                    color: accent,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Lagu pilihan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 13),
          if (isHomeLoading || homeError != null)
            loadingOrError(
              loading: isHomeLoading,
              error: homeError,
              retry: fetchHomeSongs,
            )
          else ...[
            Text(
              '${homeSongs.length} lagu dari iTunes',
              style: TextStyle(
                color: secondaryText,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
            ...homeSongs.map(songTile),
          ],
        ],
      ),
    );
  }

  Widget buildSearchPage() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
      children: [
        const PageHeader(
          title: 'Search',
          subtitle: 'Cari lagu dan artis favoritmu',
          icon: Icons.search,
        ),
        TextField(
          controller: searchController,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => searchSongs(),
          decoration: InputDecoration(
            hintText: 'Judul lagu atau nama artis...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              tooltip: 'Cari',
              onPressed: searchSongs,
              icon: Icon(
                Icons.arrow_forward,
                color: accent,
              ),
            ),
            filled: true,
            fillColor: card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          lastSearchTerm.isEmpty
              ? 'Mulai pencarian'
              : 'Hasil untuk "$lastSearchTerm"',
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (lastSearchTerm.isEmpty &&
            !isSearchLoading &&
            searchError == null)
          Padding(
            padding: const EdgeInsets.only(top: 28),
            child: Column(
              children: [
                Icon(
                  Icons.travel_explore,
                  size: 55,
                  color: accent,
                ),
                const SizedBox(height: 12),
                Text(
                  'Cari musik berdasarkan judul lagu atau nama artis.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryText),
                ),
              ],
            ),
          )
        else if (isSearchLoading || searchError != null)
          loadingOrError(
            loading: isSearchLoading,
            error: searchError,
            retry: searchSongs,
          )
        else
          ...searchResults.map(songTile),
      ],
    );
  }

  Widget buildLibraryPage() {
    final favorites = favoriteSongs.values.toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
      children: [
        const PageHeader(
          title: 'Library',
          subtitle: 'Kumpulan lagu yang kamu sukai',
          icon: Icons.library_music,
        ),
        if (favorites.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 55),
            child: Column(
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 64,
                  color: favoriteRed,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Library kamu masih kosong',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tekan ikon hati pada lagu untuk menyimpannya di sini.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryText),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => selectTab(0),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Jelajahi lagu'),
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          )
        else ...[
          Text(
            '${favorites.length} lagu favorit',
            style: TextStyle(
              color: secondaryText,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          ...favorites.map(songTile),
        ],
      ],
    );
  }

  Widget buildMiniPlayer() {
    return StreamBuilder<bool>(
      stream: audioPlayer.playingStream,
      initialData: audioPlayer.playing,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data ?? false;
        final song = currentSong;

        if (song == null) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 8),
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Theme.of(context)
                  .dividerColor
                  .withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              artworkImage(song, size: 42),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      song.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      'Preview iTunes - sekitar 30 detik',
                      style: TextStyle(
                        color: accent,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: isPlaying ? 'Jeda' : 'Putar',
                onPressed: () async {
                  if (isPlaying) {
                    await audioPlayer.pause();
                  } else {
                    unawaited(audioPlayer.play());
                  }
                },
                icon: Icon(
                  isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: accent,
                  size: 30,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      buildHomePage(),
      buildSearchPage(),
      buildLibraryPage(),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: currentIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildMiniPlayer(),
          NavigationBar(
            height: 66,
            selectedIndex: currentIndex,
            onDestinationSelected: selectTab,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: Icon(
                  Icons.home_rounded,
                  color: accent,
                ),
                label: 'Home',
              ),
              NavigationDestination(
                icon: const Icon(Icons.search_rounded),
                selectedIcon: Icon(
                  Icons.search_rounded,
                  color: accent,
                ),
                label: 'Search',
              ),
              NavigationDestination(
                icon: const Icon(Icons.library_music_outlined),
                selectedIcon: Icon(
                  Icons.library_music_rounded,
                  color: accent,
                ),
                label: 'Library',
              ),
            ],
          ),
        ],
      ),
    );
  }
}