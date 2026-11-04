# Checklist App Store + Google Play — Docentia

Auditoría de requisitos para publicar y operar cuentas de desarrollador / listados.
Fecha: 2 nov 2026.

Leyenda: ✅ listo en el proyecto · ⚠️ parcial / pendiente de tienda o contenido · ❌ bloqueante

---

## Veredicto

**Casi listo en código; falta publicar y configurar tiendas.**  
Ya hay IAP con `in_app_purchase`, páginas legales en `/legal`, eliminar cuenta, restore, Privacy Manifest y permisos. Falta: hostear las páginas HTTPS, crear productos en ASC/Play, firma release y metadatos de consola.

---

## 1. Cuentas de desarrollador (fuera del código)

| Requisito | Apple | Google | Estado |
|---|---|---|---|
| Cuenta Apple Developer ($99/año) | Sí | — | ⚠️ Tú |
| Cuenta Play Console (cuota única) | — | Sí | ⚠️ Tú |
| Identidad / D-U-N-S si aplica (organización) | Sí | Sí | ⚠️ Tú |
| Acuerdos fiscales / banking | Paid Apps Agreement | Perfil de pagos | ⚠️ Tú |
| Aceptar Paid Applications Agreement (IAP) | Obligatorio para suscripciones | — | ⚠️ Tú |

---

## 2. Identidad de la app

| Ítem | Valor actual | Estado |
|---|---|---|
| Android `applicationId` | `com.docentia.app` | ✅ |
| iOS Bundle ID | `com.docentia.docentia` | ⚠️ Distinto de Android (válido, pero unifica si puedes) |
| Nombre visible | Docentia | ✅ |
| Version name / code | `1.0.0+11` en `pubspec.yaml` | ✅ |
| Iconos launcher | Existen mipmap / AppIcon | ⚠️ Revisa calidad 1024×1024 marketing |
| Splash / launch | Presente | ✅ |
| Firma Android release | Usa `signingConfigs.debug` | ❌ Necesitas keystore de release |
| Certificados iOS / provisioning | En Xcode / ASC | ⚠️ Tú |

---

## 3. Privacidad y legal (bloqueante en ambas tiendas)

| Requisito | Estado | Notas |
|---|---|---|
| Política de privacidad **pública HTTPS** | ⚠️ | HTML listo en `legal/privacy.html` — **hostéala** y apunta `LegalUrls.siteBase` |
| Términos de uso / EULA públicos | ⚠️ | HTML listo en `legal/terms.html` |
| Enlace privacidad **dentro de la app** | ✅ | Login + Perfil + Paywall |
| Enlace términos **dentro de la app** | ✅ | Login + Perfil + Paywall |
| URL privacidad en App Store Connect / Play Console | ⚠️ | Pegar la URL al crear el listado |
| Privacy Nutrition Labels (ASC) | ⚠️ | Declarar email, nombre, teléfono, fotos, contactos, User ID (ver `PrivacyInfo.xcprivacy`) |
| Data safety form (Play) | ⚠️ | Misma data + si se comparte con Firebase |
| Privacy Manifest iOS | ✅ | `ios/Runner/PrivacyInfo.xcprivacy` |
| `ITSAppUsesNonExemptEncryption` | ✅ | `false` en Info.plist (export compliance simplificado) |
| Soporte / contacto | ⚠️ | `LegalUrls.support` — página o email real |

**La política debe cubrir:** datos recolectados, usos, terceros (Firebase Auth / Google / Apple), retención, cómo borrar datos, contacto de privacidad.

---

## 4. Cuentas de usuario

| Requisito | Estado | Notas |
|---|---|---|
| Login Google | ✅ | Firebase Auth |
| Login Apple (obligatorio si ofreces Google en iOS) | ✅ | Entitlement Sign in with Apple |
| Eliminar cuenta **in-app** (Apple 5.1.1v + Play) | ✅ | Perfil → Eliminar cuenta |
| Recurso **web** de borrado (Play) | ⚠️ | `LegalUrls.accountDeletion` — página real obligatoria |
| Borrado borra datos asociados | ✅ parcial | Limpia local + Firebase Auth user; si luego usas Firestore, borrar también ahí |

---

## 5. Suscripciones / IAP (crítico para Pro)

| Requisito | Estado | Notas |
|---|---|---|
| StoreKit / Play Billing real | ✅ código | Plugin `in_app_purchase` + `SubscriptionBillingService`. Ver `docs/IAP_SETUP.md` |
| Productos en ASC / Play Console | ⚠️ | Crear: `docentia_pro_monthly`, `docentia_pro_yearly` |
| Precio, duración, trial visibles en paywall | ✅ | $129/mes, $899/año, 14 días |
| Texto auto-renovación | ✅ | Paywall |
| Links Términos + Privacidad en paywall | ✅ | |
| **Restore Purchases** | ✅ | `restorePurchases()` vía tienda |
| Gestionar / cancelar suscripción | ✅ | Abre ASC / Play Subscription Center |
| Suscripción disponible en todos los devices del usuario | ⚠️ | Restore en cada dispositivo; ideal validar recibos en backend |
| No dirigir a pago externo (digital goods) | ✅ | No hay enlaces de pago web |

**No envíes a revisión** hasta crear los productos IAP en las consolas y hostear las URLs legales.

---

## 6. Permisos y purpose strings

| Permiso | iOS | Android | Estado |
|---|---|---|---|
| Cámara (foto perfil) | `NSCameraUsageDescription` | `CAMERA` | ✅ |
| Fotos | Photo Library strings | vía `image_picker` | ✅ |
| Contactos (tutores) | `NSContactsUsageDescription` | `READ_CONTACTS` | ✅ |
| Internet | — | `INTERNET` | ✅ |
| mailto / WhatsApp queries | — | queries en manifest | ✅ |
| Tracking / ATT | No tracking | — | ✅ `NSPrivacyTracking=false` |

---

## 7. Metadatos de listado (consolas)

Completar en App Store Connect y Play Console (no están en el repo):

- [ ] Descripción corta / larga (ES + EN recomendado)
- [ ] Keywords / categoría (Educación / Productividad)
- [ ] Capturas de pantalla (iPhone 6.7", 6.5"; iPad si soportas; phones Android)
- [ ] Feature graphic Play (1024×500)
- [ ] Icono 512 / 1024
- [ ] Clasificación de edad / cuestionario de contenido
- [ ] Política de privacidad URL
- [ ] Categoría de anuncios (si aplica; Docentia no tiene ads hoy)
- [ ] Notas de revisión + cuenta demo (Google/Apple de prueba)
- [ ] ¿App usa cifrado? (Apple: Non-exempt = No con la flag actual)

---

## 8. Contenido y revisión

| Ítem | Estado |
|---|---|
| App usable sin crash en flujo principal | ⚠️ Probar release build |
| Cuenta demo para reviewers | ⚠️ Preparar usuario de prueba |
| Datos de alumnos / menores | ⚠️ En age rating declara si hay datos de niños; política debe ser clara (COPPA/LFPDPPP) |
| WhatsApp / email a tutores | ✅ Uso legítimo; no scrapea contactos en masa |

---

## 9. Lo que ya quedó en código (esta pasada)

- Links legales clickeables (login, perfil, paywall)
- Eliminar cuenta + enlace web de borrado
- Restore purchases (UI) + gestionar suscripción
- Disclosure de auto-renovación
- `PrivacyInfo.xcprivacy` + encryption flag
- Purpose string de contactos + `READ_CONTACTS`
- Constantes centralizadas: `lib/core/constants/legal_urls.dart`

---

## 10. Orden recomendado antes de submit

1. Publicar sitio con Privacy, Terms, Support, Account deletion (HTTPS).  
2. Actualizar `LegalUrls.siteBase` al dominio real.  
3. Integrar **In-App Purchases** (StoreKit 2 + Play Billing) y quitar simulación.  
4. Crear productos de suscripción en ambas consolas.  
5. Keystore release Android + firma iOS Distribution.  
6. Completar Privacy Labels + Data safety.  
7. Subir build TestFlight / Internal testing → revisión.

---

## Referencias

- [Apple Subscriptions](https://developer.apple.com/app-store/subscriptions/)
- [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Account deletion (Apple)](https://developer.apple.com/help/app-review/guideline-reference/5-1-1-account-deletion/)
- [Play Subscriptions](https://support.google.com/googleplay/android-developer/answer/9900533)
- [Play User Data / account deletion](https://support.google.com/googleplay/android-developer/answer/10144311)
