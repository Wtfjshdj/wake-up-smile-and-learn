import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../services/music_service.dart';
import '../widgets/music_track_card.dart';
import '../services/local_storage_service.dart';
import '../models/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({Key? key}) : super(key: key);

  @override
  MusicScreenState createState() => MusicScreenState();
}

class MusicScreenState extends State<MusicScreen> {
  final MusicService _musicService = MusicService();
  List<MusicTrack> _musicTracks = <MusicTrack>[];
  bool _isLoading = true;
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadMusicTracks();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await LocalStorageService().getActiveProfile();
    setState(() {
      _userProfile = profile;
    });
  }

  Future<void> _loadMusicTracks() async {
    await _musicService.initialize();
    setState(() {
      _musicTracks = _musicService.musicTracks;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        'Mi Música',
        style: GoogleFonts.nunito(
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    body: _isLoading 
        ? _buildLoadingState() 
        : _musicTracks.isEmpty 
            ? _buildEmptyState() 
            : _buildMusicList(),
    floatingActionButton: FloatingActionButton(
      onPressed: _showAddMusicDialog,
      backgroundColor: Theme.of(context).primaryColor,
      child: const Icon(Icons.add, color: Colors.white),
    ),
  );

  Widget _buildLoadingState() => const Center(
    child: CircularProgressIndicator(),
  );

  Widget _buildEmptyState() => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Lottie.asset(
            'assets/animations/welcome.json',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 20),
          Text(
            '¡No tienes música configurada!',
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Toca el botón + para agregar tu música favorita',
            style: GoogleFonts.nunito(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _showAddMusicDialog,
            icon: const Icon(Icons.add),
            label: const Text('Agregar Música'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
          ),
        ],
      ),
    );

  Widget _buildMusicList() => ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _musicTracks.length,
      itemBuilder: (BuildContext context, int index) {
        final MusicTrack track = _musicTracks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: MusicTrackCard(
            track: track,
            onPlay: () => _playTrack(track),
            onToggleFavorite: () => _toggleFavorite(track.id),
            onDelete: track.isSystemMusic ? null : () => _deleteTrack(track.id),
          ),
        );
      },
    );

  void _showAddMusicDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          'Agregar Música',
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.music_note, color: Colors.blue),
              title: const Text('Seleccionar archivos de música'),
              subtitle: const Text('Buscar en tu dispositivo'),
              onTap: () {
                Navigator.of(context).pop();
                _addFromFiles();
              },
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }



  Future<void> _addFromFiles() async {
    try {
      // Agregar música desde archivos del dispositivo
      await _musicService.addMusicFromGallery(context);
      await _loadMusicTracks();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Música agregada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al agregar música: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _playTrack(MusicTrack track) async {
    await _musicService.playTrack(track);
  }

  Future<void> _toggleFavorite(String trackId) async {
    await _musicService.toggleFavorite(trackId);
    await _loadMusicTracks();
  }

  Future<void> _deleteTrack(String trackId) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Eliminar Música'),
        content: const Text('¿Estás seguro de que quieres eliminar esta música?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await _musicService.deleteTrack(trackId);
      await _loadMusicTracks();
    }
  }
} 