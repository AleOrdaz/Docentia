# Páginas legales Docentia

HTML listo para publicar en HTTPS (requisito App Store / Play Store).

## Archivos

| Archivo | Uso |
|---|---|
| `index.html` | Índice |
| `privacy.html` | Política de Privacidad |
| `terms.html` | Términos de Uso (EULA) |
| `support.html` | Soporte |
| `account-deletion.html` | Borrado de cuenta (Play) |
| `styles.css` | Estilos compartidos |

## Cómo publicar (elige una)

### Opción A — GitHub Pages
1. Sube la carpeta `legal/` a un repo (o usa este mismo).
2. Activa Pages (Settings → Pages → Deploy from branch / folder).
3. Tu base quedará tipo: `https://TU_USUARIO.github.io/TU_REPO/`
4. Actualiza en la app:

```dart
// lib/core/constants/legal_urls.dart
static const String siteBase = 'https://TU_USUARIO.github.io/TU_REPO';
```

### Opción B — Netlify / Cloudflare Pages / Firebase Hosting
Arrastra la carpeta `legal/` o conecta el repo. Apunta `siteBase` al dominio.

## Después de publicar
1. Cambia `privacidad@docentia.app` / `soporte@docentia.app` por tus correos reales en los HTML.
2. Pega las URLs en App Store Connect y Play Console.
3. Verifica que abren desde el celular sin login.
