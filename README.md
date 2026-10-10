# Docentia - Aplicación Móvil Flutter (Google Stitch)

Proyecto nativo Flutter y Dart completo para Android e iOS, fiel al diseño de Google Stitch.

## 📋 Requisitos
- Flutter SDK 3.19.0 o superior (compatible con Flutter 3.24+)
- Dart 3.3.0 o superior
- Android Studio / VS Code con plugins oficiales de Flutter y Dart
- Xcode 15+ (para compilar en iOS / macOS)
- CocoaPods 1.13+ (para iOS)

## 🚀 Inicio Rápido

1. Abre tu terminal y navega hasta esta carpeta:
   ```bash
   cd docentia
   ```

2. Descarga todas las dependencias del proyecto:
   ```bash
   flutter pub get
   ```

3. Analiza el código con el linter:
   ```bash
   flutter analyze
   ```

4. Ejecuta las pruebas unitarias:
   ```bash
   flutter test
   ```

5. Ejecuta la aplicación en tu emulador o dispositivo físico:
   ```bash
   flutter run
   ```

## 📱 Compilación para Producción

### Android
- Generar APK para pruebas o distribución directa:
  ```bash
  flutter build apk --release
  ```
- Generar App Bundle para Google Play Store:
  ```bash
  flutter build appbundle --release
  ```

### iOS
- Preparar pods y abrir en Xcode:
  ```bash
  cd ios && pod install && cd ..
  open ios/Runner.xcworkspace
  ```
- O compilar desde terminal:
  ```bash
  flutter build ios --release
  ```

## 🏗️ Arquitectura del Proyecto

```text
lib/
├── main.dart                       # Entrada principal (ProviderScope)
├── app/
│   ├── app.dart                   # MaterialApp.router configurado
│   ├── router/
│   │   └── app_router.dart        # Rutas declarativas GoRouter (/login, /home, /course/:id, etc.)
│   └── theme/
│       ├── app_colors.dart        # Tokens hexadecimales oficiales de Google Stitch
│       └── app_theme.dart         # ThemeData con Material 3 e Inter Font
├── core/
│   ├── constants/
│   ├── services/
│   │   ├── whatsapp_service.dart  # Integración nativa deep link wa.me
│   │   └── storage_service.dart   # Persistencia local con SharedPreferences
│   └── widgets/
└── features/
    ├── auth/                      # Login con Google y Apple
    ├── courses/                   # Home, lista de cursos y diálogo de creación
    ├── students/                  # Registro de alumnos, ficha y WhatsApp a tutores
    ├── attendance/                # Control de asistencia diaria y estadísticas de sesión
    ├── payments/                  # Gestión de cuotas, mensualidades y estados
    ├── finance/                   # Balance, ingresos, gastos y márgenes
    └── profile/                   # Perfil docente y credenciales
```

## 💬 Integración WhatsApp
El botón de WhatsApp de la ficha de alumno utiliza `url_launcher` para abrir enlaces directos con el formato:
`https://wa.me/<telefono_sanitizado>?text=<mensaje_preparado>`

## 🔥 Integración con Firebase (Cloud Firestore y Auth)
Para conectar con tu proyecto real de Firebase:
1. Registra tu app en [Firebase Console](https://console.firebase.google.com).
2. Descarga `google-services.json` y colócalo en `android/app/google-services.json`.
3. Descarga `GoogleService-Info.plist` y colócalo en `ios/Runner/GoogleService-Info.plist`.
4. El proyecto cuenta con arquitectura desacoplada mediante Repositorios (`MockRepository` actual intercambiable por `FirestoreRepository`).
