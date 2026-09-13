# 📖 Recetario y Costos

App Flutter en español para gestionar recetas de cocina (postres, comidas y bebidas) y calcular automáticamente costos, márgenes y precios de venta sugeridos.

## Funcionalidades
- Fichas técnicas completas: ingredientes con costo proporcional automático, pasos, tiempos, porciones e imagen (galería o URL).
- Lista de compras generada desde las recetas, con checkboxes.
- Panel de Finanzas con costos indirectos y margen de ganancia configurables, precio de venta sugerido y gráfico de inversión vs. ganancia.
- Datos guardados localmente con `sqflite` (persisten al cerrar la app).

## 🚀 Cómo obtener el APK sin instalar Flutter en tu computadora

Este repo está preparado para que **GitHub Actions compile el APK automáticamente** cada vez que subís cambios a la rama `main`. Pasos:

1. Creá un repositorio nuevo en GitHub (público o privado).
2. Subí todo el contenido de esta carpeta a ese repositorio:
   ```bash
   git init
   git add .
   git commit -m "App inicial"
   git branch -M main
   git remote add origin https://github.com/TU_USUARIO/TU_REPO.git
   git push -u origin main
   ```
3. En GitHub, andá a la pestaña **Actions** de tu repositorio. Vas a ver el workflow "Compilar APK" ejecutándose automáticamente (tarda unos 5-8 minutos).
4. Cuando termine (ícono verde ✅), entrá a esa ejecución y bajá hasta **Artifacts**. Ahí vas a encontrar `recetas-app-apk` para descargar — es un .zip que contiene `app-release.apk`.
5. Pasá el APK a tu celular Android e instalalo (puede que tengas que habilitar "instalar apps de fuentes desconocidas").

Si querés forzar una compilación manual sin hacer push, podés ir a **Actions → Compilar APK → Run workflow**.

## 🔐 Prueba gratis y activación

La app tiene **3 días de prueba gratis**, contados desde la fecha real de instalación en Android (`firstInstallTime`, vía el plugin `install_time_plugin`). Mientras la prueba está activa (o si ya venció y no se activó):

- Se ve un cartel en Inicio con los días restantes (o el aviso de prueba vencida).
- "Moneda" en Ajustes queda bloqueada con un candado.
- "Galería" y "Pegar URL de imagen" al crear/editar receta quedan bloqueadas con candado.
- En "Nuevo ingrediente", el campo "Precio" no muestra el valor numérico que se escribe (queda oculto, aunque sigue funcionando para los cálculos de costo).

Para activar la app de forma permanente, la pantalla "Activar app" (accesible desde el cartel de Inicio o desde cualquier función bloqueada) muestra un **identificador único del dispositivo**. El cliente envía ese identificador a quien le vendió la app, quien genera un **código de activación atado a ese dispositivo puntual** (firma RSA-SHA256 sobre el identificador). Un código generado para un celular no sirve en otro. La clave pública vive en el código de la app; la clave privada se guarda fuera del proyecto (no se sube a GitHub). Los detalles y el script para generar códigos se entregan aparte de este repositorio.

Una vez activada, todos los bloqueos y el cartel de prueba desaparecen automáticamente, sin reiniciar la app.


```bash
flutter pub get
flutter run
```

## 🗂 Estructura del proyecto
```
lib/
 ├─ main.dart
 ├─ theme/          # colores y estilo visual
 ├─ models/         # Receta, Ingrediente, ItemCompra
 ├─ db/             # persistencia local (sqflite)
 ├─ providers/      # estado global (Provider)
 ├─ screens/        # las 6 pantallas de la app
 └─ widgets/        # componentes reutilizables
```
