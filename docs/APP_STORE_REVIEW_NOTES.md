# Notas para App Review — Docentia

Documento listo para pegar (parcial o completo) en **App Store Connect → App Review Information → Notes**.  
Idioma: español (México). Versión de referencia del proyecto: `1.0.0+11` · Bundle ID iOS: `com.docentia.docentia`.

---

## 2. Propósito de la aplicación y público objetivo

**Docentia** es una aplicación móvil para **docentes independientes, academias pequeñas y centros educativos** que necesitan organizar su operación diaria en un solo lugar.

**Problema que resuelve:** muchos profesores gestionan alumnos, asistencia, cobros y comunicación con tutores en hojas de cálculo, chats y papel. Eso genera errores, pérdida de tiempo y poca visibilidad financiera.

**Valor que aporta:**
- Crear y administrar **cursos** y **alumnos**.
- Pasar **lista de asistencia** y consultar estadísticas de sesión.
- Registrar **pagos / cuotas** y llevar un **balance financiero** (ingresos, gastos, márgenes).
- Generar **certificados e informes en PDF** (plan Pro).
- Contactar a **tutores** por **WhatsApp** o preparar un correo (el docente inicia la comunicación).
- Plan **Free** (hasta 2 cursos y 20 alumnos) y plan **Pro** por suscripción vía App Store (`docentia_pro_monthly` / `docentia_pro_yearly`).

La app está dirigida a **adultos docentes**. Los datos de alumnos (incluidos menores) los captura el docente bajo su responsabilidad educativa; **los menores no crean cuentas propias** en Docentia.

---

## 3. Instrucciones de configuración y acceso a funciones principales

### Requisitos previos
1. Dispositivo iOS con la build de revisión instalada (TestFlight o build enviada a App Review).
2. Conexión a Internet (necesaria para **Sign in with Apple** / Google vía Firebase Auth).
3. Para probar compras: Apple ID de **Sandbox** (si se revisa IAP) con los productos de suscripción creados en App Store Connect.

### Inicio de sesión
La app **no usa correo/contraseña propios**. El acceso es únicamente con:

1. Abrir Docentia.
2. En la pantalla de login, elegir **Continuar con Apple** (recomendado para revisión en iOS) o **Continuar con Google**.
3. Completar el flujo nativo del proveedor.
4. Si es la primera vez, completar el **perfil del docente** (nombre y datos opcionales).

### Flujo principal a revisar
1. **Home / Cursos:** crear un curso (Free permite hasta 2).
2. **Alumnos:** agregar alumnos al curso (Free permite hasta 20 en total); opcionalmente usar el selector de contactos solo para rellenar el teléfono del tutor.
3. **Asistencia:** abrir el curso → pasar lista del día.
4. **Pagos:** registrar cuotas / estados de pago desde la ficha del alumno o módulo de pagos.
5. **Finanzas:** consultar ingresos/gastos (funciones avanzadas y PDF requieren Pro).
6. **Certificados / informes PDF:** disponibles en plan Pro (paywall si el usuario está en Free).
7. **WhatsApp a tutores:** desde la ficha del alumno se abre `wa.me` / WhatsApp con un mensaje preparado (deep link; no hay API de WhatsApp Business).
8. **Suscripción Pro:** Perfil → Mejorar a Pro → comprar o restaurar compras; gestionar/cancelar vía enlace a suscripciones de Apple.
9. **Eliminar cuenta:** Perfil → Eliminar cuenta (requisito 5.1.1(v)); también hay página web de borrado.

### Credenciales de demostración para App Review

> **TODO — completar antes de enviar a revisión.**  
> En el repositorio **no hay** cuenta demo fija ni login con usuario/contraseña. Hay que preparar una de estas opciones y pegar los datos abajo y en App Store Connect → **Sign-in required** / Notes.

**Opción A (recomendada) — Cuenta Apple de prueba ya creada en Firebase:**

```
Método: Sign in with Apple
Apple ID de revisión: [TODO: email Apple ID Sandbox o de prueba]
Contraseña: [TODO: contraseña del Apple ID de prueba]
Notas: La cuenta ya debe existir en Firebase Auth del proyecto Docentia y tener datos de ejemplo (1–2 cursos, algunos alumnos).
```

**Opción B — Cuenta Google de prueba:**

```
Método: Continuar con Google
Correo: [TODO: cuenta Google de prueba]
Contraseña: [TODO]
Notas: En iOS Apple exige Sign in with Apple si se ofrece Google; el revisor puede usar Apple. Preparar también Opción A.
```

**Opción C — Si el revisor crea su propia sesión:**

```
Puede iniciar sesión con su propio Sign in with Apple.
Tras el login verá la app vacía (plan Free) y podrá crear cursos/alumnos de prueba.
Para Pro/IAP usar Sandbox Apple ID.
```

**Datos de ejemplo sugeridos (si siembran la cuenta demo):**
- 1–2 cursos activos con nombres ficticios.
- 5–10 alumnos con teléfonos de tutores ficticios (no reales).
- Al menos un pago y una sesión de asistencia registrados.

---

## 4. Servicios, herramientas y plataformas externas

Docentia utiliza los siguientes servicios externos para su funcionalidad principal:

| Servicio / plataforma | Uso en la app |
|---|---|
| **Firebase Authentication (Google)** | Inicio de sesión con Google y Sign in with Apple; identidad del docente. |
| **Sign in with Apple** | Autenticación en iOS (entitlement activo). |
| **Google Sign-In / Google Identity** | Alternativa de login (mismo backend Firebase Auth). |
| **App Store / StoreKit (`in_app_purchase`)** | Suscripciones Docentia Pro (`docentia_pro_monthly`, `docentia_pro_yearly`), restore y gestión de suscripción. |
| **WhatsApp (deep link `wa.me` / esquema nativo)** | Abrir chat con mensaje prellenado hacia el tutor; el docente confirma el envío en WhatsApp. No hay WhatsApp Business API ni envío automático. |
| **Cliente de correo del dispositivo (`mailto`)** | Preparar avisos a tutores (p. ej. eventos) con copia oculta (BCC); el docente envía desde su app de correo. |
| **Google Fonts** | Tipografías de la interfaz. |
| **Firebase Hosting (páginas legales)** | Política de privacidad, términos, soporte y borrado de cuenta en `https://docentia-809b0.web.app`. |

**Almacenamiento de datos académicos:** cursos, alumnos, asistencia, pagos, etc. se guardan **principalmente en el dispositivo** (`SharedPreferences` / almacenamiento local). Firebase Auth mantiene la cuenta del docente. El README menciona arquitectura preparada para Firestore, pero **la operación actual revisada no depende de un backend de datos académicos en la nube**.

**No utiliza:** publicidad de terceros, tracking entre apps (ATT), analítica de terceros documentada, procesadores de pago distintos de Apple IAP para bienes digitales, ni servicios de IA externos.

**Permisos iOS (purpose strings):** cámara y fotos (foto de perfil); contactos (solo para rellenar teléfono del tutor al agregar un alumno). `NSPrivacyTracking = false`. `ITSAppUsesNonExemptEncryption = false`.

---

## 5. Diferencias regionales

**La aplicación funciona de manera uniforme en todas las regiones** disponibles en App Store: las mismas funciones de cursos, asistencia, pagos, finanzas, certificados (Pro) y comunicación con tutores.

**Matices (no son restricciones de función por país):**
- **Idiomas de interfaz:** español (preferido / plantilla) e inglés (`es`, `en` en localizaciones).
- **Precios de referencia Pro** documentados en MXN ($129/mes · $899/año · trial 14 días). El precio final mostrado al usuario es el de **App Store Connect / StoreKit** según tienda y país del Apple ID.
- Textos legales y de privacidad contemplan el marco mexicano (LFPDPPP) y, cuando corresponda, RGPD; el producto no cambia de features por región.

No hay contenido geobloqueado, catálogos regionales ni partners locales distintos por país.

---

## 6. Sector regulado y material de terceros

**No aplica documentación de licencia sectorial específica** (la app no es un servicio bancario, sanitario, de apuestas ni de transporte regulado).

Docentia es una herramienta de **productividad educativa** para docentes. El docente es responsable de los datos de alumnos/tutores que captura en el marco de su labor. La política de privacidad aclara que la app **no está diseñada para que menores creen cuentas**.

**Material de terceros:**
- No se redistribuyen currículos, bancos de preguntas u obras protegidas de terceros como contenido propio de la app.
- Los **certificados PDF** los genera el docente con los datos que él captura; no hay partnership editorial ni licencia de marca educativa de terceros que deba acreditarse ante App Review.
- Identidad y facturación dependen de **Apple** y **Google** bajo sus propios términos (Sign in with Apple, Firebase Auth, IAP).

Si en el futuro se integran contenidos licenciados o se opera bajo un marco regulado adicional, se actualizará esta sección y se adjuntarán las credenciales correspondientes.

**URLs legales (ya hosteadas):**
- Privacidad: https://docentia-809b0.web.app/privacy.html
- Términos: https://docentia-809b0.web.app/terms.html
- Soporte: https://docentia-809b0.web.app/support.html
- Borrado de cuenta: https://docentia-809b0.web.app/account-deletion.html

---

## Checklist para Antonio / el equipo (antes de submit)

Completar o verificar lo siguiente; lo marcado **TODO** bloquea o debilita la revisión:

- [ ] **TODO:** Credenciales demo (sección 3) pegadas en App Store Connect → App Review Information.
- [ ] **TODO:** Sembrar datos de ejemplo en la cuenta demo (cursos/alumnos/asistencia/pagos).
- [ ] Productos IAP creados y listos en App Store Connect: `docentia_pro_monthly`, `docentia_pro_yearly` (grupo de suscripción + trial 14 días).
- [ ] Paid Apps Agreement + banking/tax aceptados.
- [ ] Privacy Nutrition Labels alineados con `PrivacyInfo.xcprivacy` (email, nombre, teléfono, fotos, contactos, User ID).
- [ ] URLs legales públicas verificadas en el celular (ya apuntan a `https://docentia-809b0.web.app`).
- [ ] **Confirmar con el equipo:** correos `privacidad@docentia.app` / `soporte@docentia.app` activos o reemplazados en las páginas legales.
- [ ] **Confirmar con el equipo:** age rating / datos de niños declarado de forma coherente con la política (docentes capturan datos de alumnos).
- [ ] Build release / TestFlight estable del flujo principal sin crash.
- [ ] Capturas y metadatos del listado (ES; EN recomendado).

---

*Generado a partir del estado del repositorio AleOrdaz/Docentia (README, docs/MONETIZACION.md, docs/IAP_SETUP.md, docs/STORE_CHECKLIST.md, legal/, auth Firebase, suscripciones, Privacy Manifest). No inventar partners ni licencias: actualizar este archivo si cambia el producto.*
