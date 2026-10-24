# android-debloat-log

Registro y respaldo del debloat de un dispositivo POCO (MIUI/HyperOS) vía
Shizuku/`rish`, incluyendo el incidente del error **UA599** de BancoEstado.

## Contenido

| Archivo | Descripción |
|---|---|
| `INCIDENTE-bancoestado-UA599.md` | Informe completo: cronología, apps quitadas, estado verificado, análisis e investigación web. |
| `4-fix-bancoestado-UA599.md` | Guía del fix. |
| `5-propuesta-qwen-UA599.md` | Propuesta de solución dada por **Qwen** (basada en este repo) + **su resultado: ✅ RESOLVIÓ**. La clave: apagar la **Depuración USB (ADB)**. |
| `backup_pkgs_20261023.txt` | Backup de paquetes **pre-debloat** |
| `estado_pkgs_20261023_post-debloat.txt` | Estado de paquetes **post-debloat** |
| `estado_pkgs_deshabilitados_20261023.txt` | Paquetes deshabilitados |
| `log_desinstalacion_*.txt` | Logs originales de cada corrida de debloat |
| `1-lista-objetivos.sh` | Inventario (solo lectura) |
| `2-desinstalar.sh` | Primer intento (sin rish) |
| `2-desinstalar-rish.sh` | Debloat conservador vía rish |
| `2b-desinstalar-pendientes-rish.sh` | Segundo debloat (pendientes) |
| `3-restaurar.sh` | Restauración reversible |
| `5-modo-banco.sh` | Apaga Depuración USB para usar **BancoEstado** (requiere rish activo) |
| `6-modo-shizuku.sh` | Pasos para reactivar **Shizuku** (encender Depuración USB) |

## TL;DR del incidente (RESUELTO ✅)

- App afectada: `net.veritran.becl.prod` (BancoEstado, plataforma Veritran/Microsite).
- Error exacto: **`UA599 (D1)`** (subcódigo interno de Veritran, no documentado).
- **CAUSA RAÍZ: la DEPURACIÓN USB (ADB) activa.**
  - Veritran valida el estado de **ADB**, que es **independiente** del interruptor
    de "Opciones de desarrollador".
  - **Modo Desarrollador ON + Depuración USB OFF → la app funciona.**
  - **Depuración USB ON → `UA599`.**
- **El debloat NO fue la causa.** Ninguna app quitada es dependencia de la banca.
- Sistema **limpio**: bootloader bloqueado, verified boot `green`, sin magisk/su,
  firmware oficial `release-keys`.
- Shizuku/F-Droid/Termux/ReVanced ya estaban ANTES (no es la causa).
- WebView canary `157.0.8103.14` -> bajada a estable `140.0.7339.207`.

## Fix que FUNCIONÓ (resumen)

1. **Apagar DEPURACIÓN USB y DEPURACIÓN INALÁMBRICA** (clave).
2. Detener **Shizuku** (vive de ADB).
3. Reiniciar el teléfono.
4. **Borrar DATOS** de BancoEstado (no solo caché).
5. Abrir la app → entra sin UA599.

> Detalle completo en `5-propuesta-qwen-UA599.md` y `4-fix-bancoestado-UA599.md`.

## Lecciones / propuestas probadas

- Apagar solo el interruptor de "Modo Desarrollador" (sin apagar la Depuración USB):
  **no bastó**.
- **Apagar Depuración USB + inalámbrica (+ Shizuku, datos, reinicio): ✅ resolvió**
  (`5-propuesta-qwen-UA599.md`).
- `pm clear` / `pm enable` / `install-existing` vía Shizuku sin root:
  fallan con `Failed transaction (2147483646)`.
- El interruptor "Opciones de desarrollador" y "Depuración USB" son **cosas
distintas**: Veritran mira **ADB**.

## Alternar entre BancoEstado y Shizuku

Veritran bloquea mientras la **Depuración USB (ADB)** esté encendida. Para alternar:

**Para usar el BANCO** (con rish aún activo):
```bash
bash ~/debloat/5-modo-banco.sh
# luego: borrar datos de BancoEstado + reiniciar
```

**Para volver a usar SHIZUKU** (a mano, porque ADB está OFF):
1. Ajustes > Opciones de desarrollador > **Depuración USB = ON** + **inalámbrica = ON**
2. Abrir Shizuku e inicialarlo.
3. (Con PC: `adb shell sh /storage/emulated/0/Android/data/moe.shizuku.privileged.api/start.sh`)

> Regla: **ADB ON = Shizuku funciona, banco bloqueado. ADB OFF = banco funciona, Shizuku detenido.**

## Restauración total

```bash
bash ~/debloat/3-restaurar.sh
```

> Nota: los comandos asumen Shizuku/`rish` activo. `pm uninstall --user 0` es
> reversible con `cmd package install-existing`.
