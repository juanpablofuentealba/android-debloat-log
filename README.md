# android-debloat-log

Registro y respaldo del debloat de un dispositivo POCO (MIUI/HyperOS) vía
Shizuku/`rish`, incluyendo el incidente del error **UA599** de BancoEstado.

## Contenido

| Archivo | Descripción |
|---|---|
| `INCIDENTE-bancoestado-UA599.md` | Informe completo: cronología, apps quitadas, estado verificado, análisis, **investigación web** y plan de recuperación |
| `4-fix-bancoestado-UA599.md` | **Guía definitiva del fix**: causa raíz = Modo Desarrollador/Depuración |
| `backup_pkgs_20261023.txt` | Backup de paquetes **pre-debloat** |
| `estado_pkgs_20261023_post-debloat.txt` | Estado de paquetes **post-debloat** |
| `estado_pkgs_deshabilitados_20261023.txt` | Paquetes deshabilitados |
| `log_desinstalacion_*.txt` | Logs originales de cada corrida de debloat |
| `1-lista-objetivos.sh` | Inventario (solo lectura) |
| `2-desinstalar.sh` | Primer intento (sin rish) |
| `2-desinstalar-rish.sh` | Debloat conservador vía rish |
| `2b-desinstalar-pendientes-rish.sh` | Segundo debloat (pendientes) |
| `3-restaurar.sh` | Restauración reversible |

## TL;DR del incidente

- App afectada: `net.veritran.becl.prod` (BancoEstado, plataforma Veritran/Microsite).
- **CAUSA RAÍZ CONFIRMADA: Modo Desarrollador / Depuración USB activos.**
  - Veritran lanza UA599 al detectar entorno de desarrollo/superusuario.
  - Confirmado por bytepeaker.com, doncomo.com, notesread.com y Reclamos.cl
    ("Banco Estado te Bloquea Rut Pay si tienes modo Desarrollador Activo").
- **El debloat NO fue la causa.** Ninguna app quitada es dependencia de la banca.
- Sin root. Se usa **Shizuku** (requiere dev mode); al apagar dev mode, Shizuku se detiene.
- Morphe/ReVanced GMS descartado (estaba antes del 1er debloat).
- WebView canary `157.0.8103.14` -> bajada a estable `140.0.7339.207`.
- WebView, GMS, GSF, Play Store y Security **intactos**.

## Fix (resumen)

1. Apagar Modo Desarrollador + Depuración USB/inalámbrica.
2. Detener Shizuku por completo.
3. **Borrar DATOS** de BancoEstado (no solo caché) — la app cachea la detección.
4. Si falla: reinstalar la app.
5. Si aún falla: probar en otro teléfono (bloqueo del lado del banco).

> Detalle completo en `4-fix-bancoestado-UA599.md`.

## Restauración total

```bash
bash ~/debloat/3-restaurar.sh
```

> Nota: los comandos asumen Shizuku/`rish` activo. `pm uninstall --user 0` es
> reversible con `cmd package install-existing`.
