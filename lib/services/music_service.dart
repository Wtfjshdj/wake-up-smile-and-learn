import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';

class MusicTrack {
  final String id;
  final String title;
  final String? artist;
  final String path;
  final bool isSystemMusic;
  final bool isFavorite;
  final Duration? duration;

  MusicTrack({
    required this.id,
    required this.title,
    this.artist,
    required this.path,
    this.isSystemMusic = false,
    this.isFavorite = false,
    this.duration,
  });

  Map<String, dynamic> toMap() => <String, dynamic>{
      'id': id,
      'title': title,
      'artist': artist,
      'path': path,
      'isSystemMusic': isSystemMusic,
      'isFavorite': isFavorite,
      'duration': duration?.inMilliseconds,
    };

  factory MusicTrack.fromMap(Map<String, dynamic> map) => MusicTrack(
      id: map['id'] as String,
      title: map['title'] as String,
      artist: map['artist'] as String?,
      path: map['path'] as String,
      isSystemMusic: map['isSystemMusic'] as bool? ?? false,
      isFavorite: map['isFavorite'] as bool? ?? false,
      duration: map['duration'] != null 
          ? Duration(milliseconds: map['duration'] as int)
          : null,
    );
}

class MusicService extends ChangeNotifier {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  MusicService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  List<MusicTrack> _musicTracks = <MusicTrack>[];
  MusicTrack? _currentTrack;
  bool _isPlaying = false;
  int _currentTrackIndex = -1;

  // Callbacks para la UI
  Function(MusicTrack)? onTrackChanged;
  Function(bool)? onPlaybackStateChanged;

  bool get isPlaying => _isPlaying;
  MusicTrack? get currentTrack => _currentTrack;
  List<MusicTrack> get musicTracks => List.unmodifiable(_musicTracks);
  List<MusicTrack> get favoriteTracks => _musicTracks.where((MusicTrack track) => track.isFavorite).toList();
  int get currentTrackIndex => _currentTrackIndex;

  Future<void> initialize() async {
    try {
      debugPrint('Inicializando MusicService...');
      
      // Verificar permisos necesarios para Android 13+
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final int androidVersion = androidInfo.version.sdkInt;
        debugPrint('📱 Versión de Android detectada: $androidVersion');
        
        if (androidVersion >= 33) {
          debugPrint('📱 Verificando permisos para Android 13+...');
          await _requestNotificationPermission();
          await _requestAudioPermission();
        }
      }
      
      // Verificar que audioplayers funciona
      await _audioPlayer.setVolume(1);
      debugPrint('AudioPlayer inicializado correctamente');
      
      await _loadMusicTracks();
      await _loadSystemMusic();
      
      // Verificar que al menos un asset se puede cargar
      if (_musicTracks.isNotEmpty) {
        final MusicTrack testTrack = _musicTracks.first;
        debugPrint('Probando carga de asset: ${testTrack.path}');
        
        try {
          if (testTrack.path.startsWith('assets/')) {
            final String assetPath = testTrack.path.replaceFirst('assets/', '');
            await _audioPlayer.play(AssetSource(assetPath));
            await _audioPlayer.stop();
            debugPrint('✅ Asset cargado correctamente: $assetPath');
          }
        } catch (e) {
          debugPrint('❌ Error cargando asset: ${testTrack.path} - $e');
        }
      }
      
      // Configurar listener para cambios de estado
      _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
        final bool wasPlaying = _isPlaying;
        _isPlaying = state == PlayerState.playing;
        
        if (wasPlaying != _isPlaying) {
          onPlaybackStateChanged?.call(_isPlaying);
        }
      });
      
      debugPrint('MusicService inicializado correctamente');
    } catch (e) {
      debugPrint('Error inicializando MusicService: $e');
    }
  }

  Future<void> _loadMusicTracks() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> tracksJson = prefs.getStringList('music_tracks') ?? <String>[];
    
    _musicTracks = tracksJson
        .map((String json) => MusicTrack.fromMap(jsonDecode(json)))
        .toList();
  }

  Future<void> _saveMusicTracks() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> tracksJson = _musicTracks
        .map((MusicTrack track) => jsonEncode(track.toMap()))
        .toList();
    
    await prefs.setStringList('music_tracks', tracksJson);
  }

  Future<void> _loadSystemMusic() async {
    // Agregar música del sistema por defecto
    final List<MusicTrack> defaultTracks = <MusicTrack>[
      MusicTrack(
        id: 'default_1',
        title: 'Melodía Matutina',
        artist: 'Sistema',
        path: 'assets/music/morning_melody.mp3',
        isSystemMusic: true,
        isFavorite: false,
      ),
      MusicTrack(
        id: 'default_2',
        title: 'Despertar Feliz',
        artist: 'Sistema',
        path: 'assets/music/happy_wakeup.mp3',
        isSystemMusic: true,
        isFavorite: false,
      ),
      MusicTrack(
        id: 'default_3',
        title: 'Sonido Natural',
        artist: 'Sistema',
        path: 'assets/music/nature_sounds.mp3',
        isSystemMusic: true,
        isFavorite: false,
      ),
    ];

    // Solo agregar si no existen
    for (final MusicTrack track in defaultTracks) {
      if (!_musicTracks.any((MusicTrack t) => t.id == track.id)) {
        _musicTracks.add(track);
      }
    }

    await _saveMusicTracks();
  }

  Future<bool> _requestNotificationPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final int androidVersion = androidInfo.version.sdkInt;
      
      if (androidVersion >= 33) {
        // Android 13+ requiere permiso explícito para notificaciones
        debugPrint('📱 Android 13+ detectado, verificando permisos de notificación...');
        
        if (await Permission.notification.isGranted) {
          debugPrint('✅ Permisos de notificación ya concedidos');
          return true;
        } else {
          debugPrint('📱 Solicitando permisos de notificación...');
          final status = await Permission.notification.request();
          debugPrint('📱 Estado del permiso de notificación: $status');
          return status.isGranted;
        }
      }
    }
    
    return true; // Para versiones anteriores o iOS
  }

  Future<bool> _requestAudioPermission() async {
    if (Platform.isAndroid) {
      debugPrint('📱 Solicitando permisos de audio en Android...');
      
      // Verificar la versión de Android
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final int androidVersion = androidInfo.version.sdkInt;
      debugPrint('📱 Versión de Android: $androidVersion');
      
      bool hasPermission = false;
      
      if (androidVersion >= 33) {
        // Android 13+ (API 33+): usar READ_MEDIA_AUDIO
        debugPrint('📱 Android 13+ detectado, usando READ_MEDIA_AUDIO');
        
        if (await Permission.audio.isGranted) {
          debugPrint('✅ Permisos de audio ya concedidos');
          hasPermission = true;
        } else {
          debugPrint('📱 Solicitando permisos de audio...');
          final status = await Permission.audio.request();
          debugPrint('📱 Estado del permiso de audio: $status');
          hasPermission = status.isGranted;
        }
      } else {
        // Android 12 y anteriores: usar READ_EXTERNAL_STORAGE
        debugPrint('📱 Android 12 o anterior detectado, usando READ_EXTERNAL_STORAGE');
        
        if (await Permission.storage.isGranted) {
          debugPrint('✅ Permisos de almacenamiento ya concedidos');
          hasPermission = true;
        } else {
          debugPrint('📱 Solicitando permisos de almacenamiento...');
          final status = await Permission.storage.request();
          debugPrint('📱 Estado del permiso de almacenamiento: $status');
          hasPermission = status.isGranted;
        }
      }
      
      if (hasPermission) {
        debugPrint('✅ Permisos concedidos');
        return true;
      } else {
        debugPrint('❌ Permisos denegados');
        return false;
      }
    }
    
    // Para iOS u otros, puedes ajustar según sea necesario
    debugPrint('📱 No es Android, saltando verificación de permisos');
    return true;
  }

  Future<void> addMusicFromGallery(BuildContext context) async {
    try {
      debugPrint('🔄 Iniciando proceso de agregar música...');
      
      // Verificar la versión de Android
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final int androidVersion = androidInfo.version.sdkInt;
      debugPrint('📱 Versión de Android: $androidVersion');
      
      bool needsPermission = false;
      
      if (Platform.isAndroid) {
        if (androidVersion >= 33) {
          // Android 13+: file_picker maneja los permisos automáticamente
          // Solo verificar si ya tenemos permisos de audio
          if (await Permission.audio.isDenied) {
            debugPrint('📱 Android 13+: verificando permisos de audio...');
            final bool hasPermission = await _requestAudioPermission();
            if (!hasPermission) {
              debugPrint('❌ Permisos de audio no concedidos');
              _showPermissionDialog(context, isAndroid13Plus: true);
              return;
            }
          }
        } else {
          // Android 12 y anteriores: verificar permisos de almacenamiento
          if (await Permission.storage.isDenied) {
            needsPermission = true;
          }
        }
      }
      
      if (needsPermission) {
        debugPrint('📱 Solicitando permisos manualmente...');
        final bool hasPermission = await _requestAudioPermission();
        debugPrint('📱 Estado de permisos: $hasPermission');
        
        if (!hasPermission) {
          debugPrint('❌ Permisos no concedidos');
          _showPermissionDialog(context, isAndroid13Plus: false);
          return;
        }
      }

      debugPrint('✅ Abriendo selector de archivos...');

      // Usar file_picker para seleccionar archivos de música
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );

      if (result != null) {
        debugPrint('📁 Archivos seleccionados: ${result.files.length}');
        
        for (final PlatformFile file in result.files) {
          if (file.path != null) {
            debugPrint('📁 Procesando archivo: ${file.path}');
            
            final File audioFile = File(file.path!);
            
            // Verificar que el archivo existe y es accesible
            if (await audioFile.exists()) {
              try {
                // Verificar que se puede leer el archivo
                await audioFile.open(mode: FileMode.read);
                
                final String fileName = file.name;
                final String title = fileName.replaceAll(RegExp(r'\.(mp3|wav|m4a|aac|ogg)$'), '');
                
                final MusicTrack track = MusicTrack(
                  id: DateTime.now().millisecondsSinceEpoch.toString() + '_${file.name.hashCode}',
                  title: title,
                  artist: 'Usuario',
                  path: file.path!,
                  isSystemMusic: false,
                  isFavorite: false,
                );

                debugPrint('✅ Archivo procesado correctamente: $title');
                _musicTracks.add(track);
                notifyListeners();
                
              } catch (e) {
                debugPrint('❌ Error al procesar archivo ${file.path}: $e');
              }
            } else {
              debugPrint('❌ Archivo no encontrado: ${file.path}');
            }
          }
        }
        
        await _saveMusicTracks();
        debugPrint('✅ Proceso completado. Total de tracks: ${_musicTracks.length}');
      } else {
        debugPrint('❌ No se seleccionaron archivos');
      }
    } catch (e) {
      debugPrint('❌ Error en addMusicFromGallery: $e');
    }
  }

  Future<void> addMusicFromFile(String filePath) async {
    try {
      final File file = File(filePath);
      if (!await file.exists()) {
        debugPrint('Archivo no encontrado: $filePath');
        return;
      }

      final String fileName = file.path.split('/').last;
      final String title = fileName.replaceAll(RegExp(r'\.(mp3|wav|m4a|aac|ogg)$'), '');
      
      final MusicTrack track = MusicTrack(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_${fileName.hashCode}',
        title: title,
        artist: 'Usuario',
        path: filePath,
        isSystemMusic: false,
        isFavorite: false,
      );

      _musicTracks.add(track);
      await _saveMusicTracks();
      debugPrint('Música agregada: $title desde $filePath');
    } catch (e) {
      debugPrint('Error adding music file: $e');
    }
  }

  Future<void> playTrack(MusicTrack track, {bool loop = false}) async {
    try {
      debugPrint('🎵 Reproduciendo: ${track.title}');
      
      // Detener cualquier reproducción actual
      await _audioPlayer.stop();
      
      // Configurar modo de reproducción
      if (loop) {
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      } else {
        await _audioPlayer.setReleaseMode(ReleaseMode.release);
      }
      
      if (track.path.startsWith('assets/')) {
        final String assetPath = track.path.replaceFirst('assets/', '');
        debugPrint('Cargando asset: $assetPath');
        await _audioPlayer.play(AssetSource(assetPath));
      } else {
        // Verificar que el archivo existe antes de intentar reproducirlo
        final File file = File(track.path);
        if (await file.exists()) {
          debugPrint('Cargando archivo del dispositivo: ${track.path}');
          await _audioPlayer.play(DeviceFileSource(track.path));
        } else {
          debugPrint('❌ Archivo no encontrado: ${track.path}');
          // Reproducir sonido de fallback
          await _audioPlayer.play(AssetSource('sounds/default_alarm.mp3'));
          debugPrint('Reproduciendo sonido de fallback');
        }
      }
      
      _currentTrack = track;
      onTrackChanged?.call(track);
      
    } catch (e) {
      debugPrint('Error playing track: $e');
      // Intentar reproducir sonido de fallback
      try {
        await _audioPlayer.play(AssetSource('sounds/default_alarm.mp3'));
        debugPrint('Reproduciendo sonido de fallback');
      } catch (fallbackError) {
        debugPrint('Error con sonido de fallback: $fallbackError');
      }
    }
  }

  Future<void> playAlarm(String path, {bool loop = true}) async {
    try {
      debugPrint('🔔 Reproduciendo alarma: $path');
      
      // Detener cualquier reproducción actual
      await _audioPlayer.stop();
      
      // Configurar modo de reproducción
      if (loop) {
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      } else {
        await _audioPlayer.setReleaseMode(ReleaseMode.release);
      }
      
      if (path.startsWith('assets/')) {
        final String assetPath = path.replaceFirst('assets/', '');
        debugPrint('🔔 Cargando alarma desde asset: $assetPath');
        await _audioPlayer.play(AssetSource(assetPath));
      } else {
        final File file = File(path);
        if (await file.exists()) {
          debugPrint('🔔 Cargando alarma desde archivo: $path');
          await _audioPlayer.play(DeviceFileSource(path));
        } else {
          debugPrint('❌ Archivo de alarma no encontrado: $path');
          await _audioPlayer.play(AssetSource('sounds/default_alarm.mp3'));
        }
      }
      
      debugPrint('✅ Alarma iniciada correctamente');
      
    } catch (e) {
      debugPrint('❌ Error reproduciendo alarma: $e');
      // Intentar reproducir sonido de fallback
      try {
        await _audioPlayer.play(AssetSource('sounds/default_alarm.mp3'));
        debugPrint('Reproduciendo sonido de fallback');
      } catch (fallbackError) {
        debugPrint('Error con sonido de fallback: $fallbackError');
      }
    }
  }

  Future<void> play() async {
    await _audioPlayer.resume();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> stop() async {
    // Asegurarse de que el modo de bucle se desactive al parar.
    await _audioPlayer.setReleaseMode(ReleaseMode.release);
    await _audioPlayer.stop();
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  Future<void> toggleFavorite(String trackId) async {
    final int index = _musicTracks.indexWhere((MusicTrack track) => track.id == trackId);
    if (index != -1) {
      final MusicTrack track = _musicTracks[index];
      final MusicTrack updatedTrack = MusicTrack(
        id: track.id,
        title: track.title,
        artist: track.artist,
        path: track.path,
        isSystemMusic: track.isSystemMusic,
        isFavorite: !track.isFavorite,
        duration: track.duration,
      );
      
      _musicTracks[index] = updatedTrack;
      await _saveMusicTracks();
    }
  }

  Future<void> deleteTrack(String trackId) async {
    final MusicTrack track = _musicTracks.firstWhere((MusicTrack t) => t.id == trackId);
    
    // No permitir eliminar música del sistema
    if (track.isSystemMusic) return;
    
    _musicTracks.removeWhere((MusicTrack t) => t.id == trackId);
    await _saveMusicTracks();
  }

  Future<void> previewTrack(MusicTrack track) async {
    try {
      if (track.path.startsWith('assets/')) {
        final String assetPath = track.path.replaceFirst('assets/', '');
        await _audioPlayer.play(AssetSource(assetPath));
      } else {
        await _audioPlayer.play(DeviceFileSource(track.path));
      }
      
      // Detener después de 5 segundos
      Future.delayed(const Duration(seconds: 5), _audioPlayer.stop);
    } catch (e) {
      debugPrint('Error previewing track: $e');
    }
  }

  Future<Duration?> getTrackDuration(String path) async {
    try {
      // audioplayers no permite obtener duración directamente sin reproducir
      // Por ahora retornamos null, pero podríamos implementar una solución alternativa
      debugPrint('getTrackDuration no implementado para audioplayers');
      return null;
    } catch (e) {
      debugPrint('Error getting track duration: $e');
      return null;
    }
  }

  // Método específico para detener alarmas
  Future<void> stopAlarm() async {
    try {
      debugPrint('🔔 Deteniendo alarma...');
      await _audioPlayer.stop();
      await _audioPlayer.setReleaseMode(ReleaseMode.release);
      debugPrint('✅ Alarma detenida');
    } catch (e) {
      debugPrint('❌ Error deteniendo alarma: $e');
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }

  void _showPermissionDialog(BuildContext context, {bool isAndroid13Plus = false}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permisos Requeridos'),
          content: Text(
            isAndroid13Plus 
              ? 'Para acceder a archivos de audio en Android 13+, necesitamos el permiso "Acceso a archivos de audio". '
                'Este permiso permite que la app acceda a tus archivos de música.'
              : 'Para agregar música desde tu dispositivo, necesitamos acceso a tus archivos de audio. '
                'Por favor, concede el permiso cuando se te solicite.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Ir a Configuración'),
            ),
          ],
        );
      },
    );
  }
} 