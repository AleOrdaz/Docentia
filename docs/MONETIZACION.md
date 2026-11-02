# Monetización Docentia — Free / Pro

Documento de referencia del modelo comercial acordado e implementado en la app.
Última actualización: 2 nov 2026.

---

## Resumen ejecutivo

| | Free | Pro |
|---|---|---|
| Objetivo | Enganche diario (asistencia, cursos básicos) | Escala + documentos + dinero |
| Precio | $0 | **$129 MXN/mes** o **$899 MXN/año** |
| Modalidad | — | Suscripción (mensual + anual). Sin compra permanente |
| Trial | — | **14 días** desde el paywall |

No ofrecemos plan lifetime al inicio: complica updates, baja el LTV y fija un precio difícil de subir.

---

## Límites Free

| Recurso | Límite |
|---|---|
| Cursos activos | **2** |
| Alumnos activos (total) | **20** |

Constantes en código: `lib/features/subscription/models/subscription_config.dart`.

---

## Qué es Free vs Pro

### Free (hábito + retención)

- Login / perfil / tema / idioma
- Crear hasta 2 cursos
- Hasta 20 alumnos
- Pasar lista (asistencia)
- Calendario de clases y eventos (crear/ver)
- Ficha de alumno
- WhatsApp puntual al tutor (progreso / un pago desde detalle)
- Ver y registrar pagos básicos
- Ver informe del curso **en pantalla** (sin exportar PDF)

### Pro (pago)

- Cursos y alumnos **ilimitados**
- Certificados PDF (estilos, folio, compartir)
- Exportar informe de curso a PDF
- Reportes financieros (pantalla + PDF)
- Gastos y utilidad real
- Lista de recordatorios de cobro
- Avisar tutores de un evento por correo (BCC)

---

## Precios y modalidad

| Plan | Precio | Nota |
|---|---|---|
| Pro mensual | **$129 MXN** | Entrada fácil |
| Pro anual | **$899 MXN** | ~2 meses gratis / mejor valor (ahorro vs 12× mensual) |

**Recomendación de empaque:** un solo plan de pago (“Pro”), dos cadencias de cobro.

Orden de paywall pensado para conversión:

1. Límite de cursos / alumnos  
2. Certificados  
3. PDFs / reportes financieros  
4. Gastos y recordatorios  

---

## Cómo está implementado hoy

| Pieza | Ubicación |
|---|---|
| Config (límites/precios/trial) | `lib/features/subscription/models/subscription_config.dart` |
| Estado Free/Pro | `lib/features/subscription/models/subscription_status.dart` |
| Provider + persistencia local | `lib/features/subscription/providers/subscription_provider.dart` |
| Paywall UI | `lib/features/subscription/widgets/paywall_sheet.dart` |
| Gates | `lib/features/subscription/utils/subscription_gate.dart` |
| Perfil → plan | `lib/features/profile/screens/teacher_profile_screen.dart` |
| Storage key | `docentia_subscription` en `StorageService` |

### Billing

La app usa **`in_app_purchase`** (StoreKit / Play Billing). Guía: [`IAP_SETUP.md`](IAP_SETUP.md).

- Productos: `docentia_pro_monthly` · `docentia_pro_yearly`
- En **debug** sin tienda/productos, puede simular Pro para desarrollo
- En **release**, requiere productos creados en las consolas
- Pendiente recomendado: validación de recibos en backend

### Probar en la app

1. Perfil → **Mejorar a Pro** (o chocar un límite Free).  
2. Elegir mensual/anual o **Probar 14 días gratis**.  
3. Para volver a Free: Perfil → **Volver a Free**.

---

## Principios de producto (no olvidar)

1. **No gates el hábito diario** (pasar lista, primer curso, alumnos básicos).  
2. **Cobra escala y profesionalización** (ilimitado, PDFs, finanzas avanzadas).  
3. Preferir **trial al chocar el límite**, no trial ciego al registrarse.  
4. Un plan de pago claro; el anual debe verse como mejor valor.  
5. Lifetime solo como oferta futura excepcional, no como default.

---

## Próximos pasos comerciales / técnicos

- [ ] Integrar In-App Purchases (StoreKit 2 + Play Billing).  
- [ ] Product IDs sugeridos: `docentia_pro_monthly`, `docentia_pro_yearly`.  
- [ ] Analytics de paywall (feature que disparó, plan elegido, trial → pago).  
- [ ] Plan **Centro** futuro (multi-docente / sync nube) a ~$249–349 MXN/mes cuando exista nube.
