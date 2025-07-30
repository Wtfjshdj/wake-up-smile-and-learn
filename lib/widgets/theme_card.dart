import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeCard extends StatelessWidget {
  final dynamic theme;
  final bool isSelected;
  final VoidCallback onSelect;

  const ThemeCard({
    Key? key,
    required this.theme,
    required this.isSelected,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Card(
      elevation: isSelected ? 8 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: isSelected 
            ? BorderSide(color: Theme.of(context).primaryColor, width: 3)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Color(theme.colors['primary'] as int).withValues(alpha: 0.1),
                Color(theme.colors['secondary'] as int).withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Preview del tema
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        Color(theme.colors['primary'] as int),
                        Color(theme.colors['secondary'] as int),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: <Widget>[
                      // Iconos decorativos
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Icon(
                          _getCategoryIcon(theme.category),
                          color: Colors.white.withValues(alpha: 0.8),
                          size: 20,
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Icon(
                          Icons.star,
                          color: Colors.white.withValues(alpha: 0.8),
                          size: 16,
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'GRATIS',
                            style: GoogleFonts.nunito(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Información del tema
              Text(
                theme.name,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(theme.colors['displayText'] as int),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              Text(
                theme.description,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: Color(theme.colors['bodyText'] as int).withValues(alpha: 0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),
              
              // Botón de selección
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onSelect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected 
                        ? Theme.of(context).primaryColor
                        : Color(theme.colors['primary'] as int),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    isSelected ? 'Seleccionado' : 'Seleccionar',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'boy':
        return Icons.sports_soccer;
      case 'girl':
        return Icons.favorite;
      case 'neutral':
        return Icons.eco;
      default:
        return Icons.palette;
    }
  }
} 