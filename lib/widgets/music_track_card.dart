import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/music_service.dart';
import 'dart:async';

class MusicTrackCard extends StatefulWidget {
  final dynamic track;
  final VoidCallback onPlay;
  final VoidCallback onToggleFavorite;
  final VoidCallback? onDelete;

  const MusicTrackCard({
    Key? key,
    required this.track,
    required this.onPlay,
    required this.onToggleFavorite,
    this.onDelete,
  }) : super(key: key);

  @override
  State<MusicTrackCard> createState() => _MusicTrackCardState();
}

class _MusicTrackCardState extends State<MusicTrackCard> {
  final MusicService _musicService = MusicService();
  bool _isPlaying = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkPlayingState();
    
    // Verificar el estado cada 100ms para asegurar sincronización
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        _checkPlayingState();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(MusicTrackCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.track.id != widget.track.id) {
      _checkPlayingState();
    }
  }

  void _checkPlayingState() {
    final bool newPlayingState = _musicService.isPlaying && 
                   _musicService.currentTrack?.id == widget.track.id;
    
    if (newPlayingState != _isPlaying) {
      debugPrint('MusicTrackCard ${widget.track.title}: _isPlaying cambió de $_isPlaying a $newPlayingState');
      debugPrint('  - _musicService.isPlaying: ${_musicService.isPlaying}');
      debugPrint('  - _musicService.currentTrack?.id: ${_musicService.currentTrack?.id}');
      debugPrint('  - widget.track.id: ${widget.track.id}');
      
      setState(() {
        _isPlaying = newPlayingState;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              _isPlaying 
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
                  : Theme.of(context).primaryColor.withValues(alpha: 0.1),
              _isPlaying 
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                  : Theme.of(context).primaryColor.withValues(alpha: 0.05),
            ],
          ),
          border: _isPlaying 
              ? Border.all(color: Theme.of(context).primaryColor, width: 2)
              : null,
        ),
        child: Row(
          children: <Widget>[
            // Icono de música con indicador de reproducción
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _isPlaying 
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).primaryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _isPlaying ? Icons.music_note : Icons.music_note,
                color: _isPlaying ? Colors.white : Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
            // Información de la canción
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.track.title,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _isPlaying 
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).primaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.track.artist != null) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(
                      widget.track.artist,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      if (_isPlaying) ...<Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.play_arrow,
                                size: 12,
                                color: Colors.green[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Reproduciendo',
                                style: GoogleFonts.nunito(
                                  fontSize: 10,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (widget.track.isSystemMusic)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Sistema',
                            style: GoogleFonts.nunito(
                              fontSize: 10,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (widget.track.isFavorite) ...<Widget>[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Favorita',
                            style: GoogleFonts.nunito(
                              fontSize: 10,
                              color: Colors.amber[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            // Botones de acción
            Column(
              children: <Widget>[
                // Botón de Play/Stop
                IconButton(
                  onPressed: _isPlaying ? _stopTrack : widget.onPlay,
                  icon: Icon(
                    _isPlaying ? Icons.stop : Icons.play_arrow,
                    color: _isPlaying ? Colors.red : Theme.of(context).primaryColor,
                    size: 24,
                  ),
                  tooltip: _isPlaying ? 'Detener' : 'Reproducir',
                ),
                // Botón de Pause/Resume (solo si está reproduciendo)
                if (_isPlaying)
                  IconButton(
                    onPressed: _pauseResumeTrack,
                    icon: Icon(
                      _musicService.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                    tooltip: _musicService.isPlaying ? 'Pausar' : 'Reanudar',
                  ),
                IconButton(
                  onPressed: widget.onToggleFavorite,
                  icon: Icon(
                    widget.track.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: widget.track.isFavorite ? Colors.red : Colors.grey[600],
                    size: 20,
                  ),
                  tooltip: widget.track.isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
                ),
                if (widget.onDelete != null)
                  IconButton(
                    onPressed: widget.onDelete,
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red[400],
                      size: 20,
                    ),
                    tooltip: 'Eliminar',
                  ),
              ],
            ),
          ],
        ),
      ),
    );

  void _stopTrack() async {
    await _musicService.stop();
    setState(() {
      _isPlaying = false;
    });
  }

  void _pauseResumeTrack() async {
    if (_musicService.isPlaying) {
      await _musicService.pause();
    } else {
      await _musicService.play();
    }
  }
} 