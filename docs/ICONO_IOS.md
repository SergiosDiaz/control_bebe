# Icono de la app en iOS

El icono del launcher en iOS se ve pixelado porque la imagen actual (**673×702 px**) es menor que el tamaño mínimo requerido.

## Requisitos de Apple para el icono iOS

| Formato | Tamaño mínimo | Notas |
|---------|---------------|-------|
| 1024×1024 px | Obligatorio | Base para generar todos los tamaños |
| PNG | Sin transparencia | iOS usa fondo sólido si hay transparencia |
| Cuadrado | Sin bordes redondeados | iOS aplica la máscara automáticamente |

## Cómo solucionarlo

### Opción 1: Nueva imagen 1024×1024 (recomendado)

1. Crea o exporta tu icono en **1024×1024 píxeles**.
2. Formato PNG, sin transparencia (o con fondo sólido #F8F9FA).
3. Sustituye `assets/images/app_icon.png` por tu nueva imagen.
4. Ejecuta:
   ```bash
   dart run flutter_launcher_icons
   ```
5. Reinstala la app en el dispositivo iOS.

### Opción 2: Icono específico para iOS

Si tienes una imagen de alta resolución solo para iOS:

1. Guarda el archivo como `assets/images/app_icon_ios.png` (1024×1024 px).
2. Añade en `pubspec.yaml` dentro de `flutter_launcher_icons`:
   ```yaml
   image_path_ios: "assets/images/app_icon_ios.png"
   ```
3. Ejecuta `dart run flutter_launcher_icons`.

### Herramientas para redimensionar

- **Figma / Canva**: exportar a 1024×1024.
- **Photoshop / GIMP**: Image → Image Size.
- **Online**: [resizeimage.net](https://resizeimage.net) (asegúrate de no perder calidad).

### Si solo tienes la imagen actual

Si no tienes el archivo original en mayor resolución, tendrás que rediseñar el icono en 1024×1024 o usar una herramienta de upscaling (como [Real-ESRGAN](https://github.com/xinntao/Real-ESRGAN)) que puede mejorar algo la calidad, aunque no será perfecta.
