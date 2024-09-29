# Pokemon App

Este repositorio contiene el código para una aplicación de Pokemon, donde los usuarios pueden:

- Visualizar una lista de Pokemon
- Visualizar los detalles de cada Pokemon (tipos, habilidades, estadísticas)
- Evolucionar a los Pokemon
- Añadir a los Pokemon a su lista de favoritos

## Corriendo el proyecto

Para correr el proyecto, primero debe clonar el repositorio:

```
git clone https://github.com/aloussase/Pokemon.App
cd Pokemon.App
```

### API REST

La API REST se encuentra en el directorio `api`. Está escrita en express, por lo
que necesitará tener instalado Nodejs.

Para la conexión a la base de datos, el repositorio incluye un archivo
`docker-compose.yml` que puede ejecutar con el comando:

```
docker-compose up -d
```

Esto creará un contenedor con PostgreSQL en el puerto 5432 y creará las tablas
necesarias para la aplicación.

Luego, corra los siguientes comandos para ejecutar el servidor:

```
npm install
npm run build
node build/index.js
```

> **Note**
> Para que todo funcione correctamente, deberá hacer una copia del archivo
> `.env.example` y llamarlo `.env`. En este archivo deberá configurar las
> variables de entorno según sea apropiado.

Si va a utlizar la base de datos mediante docker-compose, puede dejar los
valores por defecto.

### Aplicación Móvil

> **Note**
> Estas instrucciones son para dispositivos Android.

La aplicación móvil se encuentra en el directorio `app`, por lo que se asume que
todos los comandos indicados a continuación serán ejecutados en ese directorio.

Deberá tener Java 17 instalado para que la generación del APK sea exitosa.
Además, deberá contar con una instalación del SDK de Flutter y las herramientas
de línea de comando. Para más información, siga los pasos en la guía oficial:
https://docs.flutter.dev/get-started/install/linux/android.

Una vez se tengan todas las dependencias instaladas, deberá editar el archivo
`config.dart` con la dirección donde está corriendo su instancia del backend.

Luego de esto, puede proceder a compilar el APK:

```
flutter build apk
```

Si tiene su dispositivo móvil conectado al ordenador, puede proceder a instalar
el aplicativo con el siguiente comando:

```
flutter install
```

## Licencia

MIT
