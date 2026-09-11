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

## 💻 Cómo correrla localmente (opcional, si instalás Flutter)
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
