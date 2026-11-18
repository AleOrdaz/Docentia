# Códigos promocionales

La app canjea códigos mediante la callable `redeemPromoCode`. Firebase Authentication identifica al usuario y una transacción de Firestore valida el código, registra el canje único por cuenta y limita los usos totales. Un canje concede acceso Pro por tres meses calendario.

## Preparar Firebase

1. Instala Firebase CLI y ejecuta `firebase login`.
2. Crea la base de datos de Firestore predeterminada en el proyecto `docentia-809b0` si aún no existe.
3. Habilita el plan Blaze para desplegar Cloud Functions.
4. Desde la raíz del proyecto, instala dependencias con `cd functions && npm install`.
5. Despliega reglas y función con `firebase deploy --project docentia-809b0 --only firestore:rules,functions:redeemPromoCode`.
6. En Firestore, crea una colección `promoCodes`. Cada código normalizado en mayúsculas debe ser el ID del documento. Por ejemplo, para `DOCENTIA2026`, crea `promoCodes/DOCENTIA2026` con:

```json
{
  "active": true,
  "maxRedemptions": 100,
  "redemptionCount": 0
}
```

`maxRedemptions: 0` significa usos ilimitados. Opcionalmente agrega `expiresAt` como fecha/hora de Firestore. Para detener un código, cambia `active` a `false`. Los documentos de `promoCodes` y `promoRedemptions` quedan inaccesibles desde clientes; la función usa el Admin SDK.

Cada cuenta autenticada puede canjear un código promocional una sola vez. La marca de canje vive en `promoRedemptions/{uid}` y no se elimina al cerrar sesión o reinstalar la app.
