# android-debloat-log

Registro y respaldo del debloat de un dispositivo POCO (MIUI/HyperOS) vía
Shizuku/`rish`, incluyendo el incidente del error **UA599** de BancoEstado.

## Contenido

| Archivo | Descripción |
|---|---|
| `INCIDENTE-bancoestado-UA599.md` | Informe completo: cronología, apps quitadas, estado verificado, análisis y plan de recuperación |
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
- **Ninguna app quitada por el debloat es dependencia directa de la banca.**
- Único sospechoso plausible: `com.android.stk` (SIM Toolkit).
- El UA599 apunta a **WebView / integridad / fecha-hora**, no al debloat.
- WebView, GMS, GSF, Play Store y Security **intactos**.

## Restauración total

```bash
bash ~/debloat/3-restaurar.sh
```

> Nota: los comandos asumen Shizuku/`rish` activo. `pm uninstall --user 0` es
> reversible con `cmd package install-existing`.
