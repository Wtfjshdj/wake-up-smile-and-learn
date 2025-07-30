# Wake Up Smile and Learn 🌅😊📚

## Descripción
"Wake Up Smile and Learn" es una aplicación educativa diseñada para niños que combina diversión y aprendizaje. La app ayuda a los niños a despertarse con una sonrisa mientras aprenden de manera interactiva y personalizada.

## ✨ Características Principales

### 👥 Sistema de Múltiples Perfiles
- **Perfiles personalizados** para cada niño
- **Configuración individual** de edad, intereses y preferencias
- **Cambio fácil** entre perfiles de hermanos o amigos

### 🎵 Experiencia Personalizada
- **Música de despertar** personalizada según preferencias
- **Sonidos de alarma** suaves y amigables para niños
- **Temas visuales** adaptados a diferentes edades

### 🎮 Aprendizaje Interactivo
- **Sistema de logros** y recompensas
- **Metas diarias** personalizadas
- **Progreso visual** del aprendizaje
- **Actividades educativas** según edad e intereses

### 🔒 Modo Padre
- **PIN de seguridad** para configuraciones avanzadas
- **Control parental** de contenido y configuraciones
- **Monitoreo** del progreso del niño

## 🚀 Instalación y Configuración

### Prerrequisitos
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (versión 3.0 o superior)
- [Dart SDK](https://dart.dev/get-dart)
- [Android Studio](https://developer.android.com/studio) o [VS Code](https://code.visualstudio.com/)
- Dispositivo Android/iOS o emulador

### Pasos de Instalación

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/TU-USUARIO/wake-up-smile-and-learn.git
   cd wake-up-smile-and-learn
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Verificar la configuración**
   ```bash
   flutter doctor
   ```

4. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

## 📱 Uso de la Aplicación

### Primer Uso
1. **Crear perfil**: Configura el perfil del niño con nombre, edad e intereses
2. **Personalizar**: Selecciona música, sonidos y temas preferidos
3. **Configurar alarma**: Establece horarios de despertar
4. **¡Comenzar a aprender!**: La app está lista para usar

### Gestión de Perfiles
- **Añadir perfil**: Toca "+ Nuevo perfil" en la pantalla principal
- **Cambiar perfil**: Selecciona el perfil deseado desde la pantalla de inicio
- **Eliminar perfil**: Mantén presionado el perfil y selecciona "Eliminar"

### Modo Padre
- **Acceder**: Toca el ícono de candado en la esquina superior derecha
- **Configurar PIN**: Establece un PIN de 4 dígitos para acceso seguro
- **Gestionar**: Configura opciones avanzadas y monitorea progreso

## 🛠️ Tecnologías Utilizadas

- **Framework**: Flutter 3.x
- **Lenguaje**: Dart
- **Almacenamiento**: SharedPreferences, Hive
- **Autenticación**: Firebase Auth (opcional)
- **Base de datos**: Cloud Firestore (opcional)
- **Notificaciones**: Flutter Local Notifications
- **Audio**: AudioPlayers, Flutter TTS
- **UI/UX**: Material Design, Lottie Animations

## 📁 Estructura del Proyecto

```
wake_up_smile_and_learn/
├── lib/
│   ├── main.dart                 # Punto de entrada de la aplicación
│   ├── screens/                  # Pantallas de la aplicación
│   │   ├── auth_screen.dart      # Selección de perfiles
│   │   ├── home_screen.dart      # Pantalla principal
│   │   ├── onboarding_screen.dart # Configuración inicial
│   │   └── ...
│   ├── models/                   # Modelos de datos
│   │   ├── user_profile.dart     # Modelo de perfil de usuario
│   │   └── ...
│   ├── services/                 # Servicios y lógica de negocio
│   │   ├── local_storage_service.dart # Almacenamiento local
│   │   ├── alarm_service.dart    # Servicio de alarmas
│   │   └── ...
│   ├── widgets/                  # Widgets reutilizables
│   └── providers/                # Gestión de estado
├── assets/                       # Recursos (imágenes, sonidos, etc.)
├── android/                      # Configuración específica de Android
├── ios/                         # Configuración específica de iOS
└── pubspec.yaml                 # Dependencias del proyecto
```

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Para contribuir:

1. **Fork** el proyecto
2. **Crea** una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. **Commit** tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. **Push** a la rama (`git push origin feature/AmazingFeature`)
5. **Abre** un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 🆘 Soporte

Si tienes problemas o preguntas:

1. **Revisa** la documentación de Flutter
2. **Busca** en los issues existentes
3. **Crea** un nuevo issue con detalles del problema

## 📞 Contacto

- **Desarrollador**: [Tu Nombre]
- **Email**: [tu-email@ejemplo.com]
- **GitHub**: [@tu-usuario]

---

⭐ **¡No olvides darle una estrella al proyecto si te gusta!** ⭐