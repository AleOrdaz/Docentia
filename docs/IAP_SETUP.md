# Configurar compras in-app (Docentia Pro)

La app ya usa el plugin oficial `in_app_purchase` con estos product IDs:

| Periodo | Product ID |
|---|---|
| Mensual | `docentia_pro_monthly` |
| Anual | `docentia_pro_yearly` |

Precios de referencia: **$129 MXN/mes** · **$899 MXN/año** · trial **14 días** (oferta introductoria en la tienda).

---

## App Store Connect

1. Acepta el **Paid Apps Agreement** + banking/tax.
2. Crea un **Subscription Group** (p. ej. `Docentia Pro`).
3. Crea dos Auto-Renewable Subscriptions con los IDs exactos de arriba.
4. Localiza precios (MXN y demás).
5. Configura **Introductory Offer**: free trial 14 días (una vez por usuario Apple ID).
6. Metadata: nombre “Docentia Pro”, descripción de beneficios.
7. Envía los productos a revisión junto con un build que los use.
8. Prueba con **Sandbox** Apple ID.

## Google Play Console

1. Completa perfil de pagos / merchant.
2. Monetizar → Suscripciones → crea productos con los mismos IDs (o un subscription con base plans `monthly` / `yearly` según la consola actual; los IDs expuestos a la app deben coincidir con `SubscriptionConfig`).
3. Añade base plans + oferta gratuita de 14 días.
4. Activa y prueba con licencia de prueba / track interno.

## Comportamiento en la app

- Paywall llama a `purchasePro` → sheet nativo de la tienda.
- “Probar 14 días” abre la misma compra (la tienda aplica el trial si está configurado).
- “Restaurar compras” usa `restorePurchases`.
- Si la tienda no está disponible **en debug**, la app simula Pro para desarrollo.
- En release sin productos configurados, muestra error claro (`paywallProductMissing`).

## Pendiente recomendado (producción seria)

- Validación de recibos en **backend** (App Store Server API / Google Play Developer API).
- Webhooks de renovación/cancelación para no depender solo del cache local.

## Código clave

- IDs: `lib/features/subscription/models/subscription_config.dart`
- Billing: `lib/features/subscription/services/subscription_billing_service.dart`
- Estado: `lib/features/subscription/providers/subscription_provider.dart`
