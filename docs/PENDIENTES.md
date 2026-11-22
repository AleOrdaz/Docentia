# Pendientes

## Certificados con Canva

Generar y editar certificados desde la vista actual usando Canva Connect, sin incrustar el editor en Flutter.

- Plantilla de marca apaisada con campos: alumno, curso, título, fecha, docente y folio.
- Autocompletado por alumno (`POST /rest/v1/autofills`) y exportación a PDF (`POST /rest/v1/exports`). El enlace de Canva caduca a las 24 horas; el PDF se guarda en Docentia.
- La edición abre la URL del diseño en Canva (`url_launcher`) y, al volver, se vuelve a exportar.
- El token y el secreto de OAuth van en Cloud Functions. Hace falta Canva Pro, Education, Teams o Enterprise, y red.
- El folio, la selección de alumnos y el historial siguen en `CertificateService`. Canva sustituye el dibujo de `CertificateDiploma` y la generación de `CertificatePdfService`.
