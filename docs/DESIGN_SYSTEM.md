# Sistema visual

## Colores de iconos

Usa los roles de icono definidos en `AppColors` en lugar de asignar colores
directamente a cada `Icon`.

| Token | Color | Uso |
| --- | --- | --- |
| `AppColors.iconDefault` | Azul información (`AppColors.info`) | Iconos de encabezados, campos y acciones generales. Es fijo y no cambia con el tema. |
| `AppColors.iconMuted(context)` | Texto secundario adaptativo | Cerrar, expandir, navegación secundaria y controles discretos. |
| `AppColors.iconSuccess` | Verde (`AppColors.secondary`) | Confirmaciones y estados completados. |
| `AppColors.iconWarning` | Ámbar (`AppColors.warning`) | Advertencias y atención requerida. |
| `AppColors.iconError` | Rojo (`AppColors.error`) | Errores y acciones destructivas. |
| `AppColors.iconOnPrimary` | Blanco | Iconos dentro de botones o superficies primarias. |

### Reglas

- Elige el token por la función del icono, no por preferencia del componente.
- Los iconos normales de formularios usan `iconDefault`, aunque el tema activo
  sea verde, violeta u otro color.
- Conserva los colores semánticos para éxito, advertencia y error.
- Los iconos de selección heredan el color del control seleccionado; los iconos
  de categorías pueden usar la paleta de categorías correspondiente.
- No uses colores hexadecimales ni `colorScheme.primary` directamente en un
  icono de interfaz; agrega un rol a `AppColors` si aparece una necesidad nueva.
- Dentro de botones rellenos, usa `iconOnPrimary` o permite que el icono herede
  el color de primer plano del botón.
