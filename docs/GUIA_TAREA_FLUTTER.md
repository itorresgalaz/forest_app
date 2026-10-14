# Guía del desafío Flutter: qué debes realizar

## 1. Objetivo y criterio de evaluación

Debes construir una aplicación pequeña en Flutter con dos pantallas: un listado de cervecerías y el detalle de una cervecería seleccionada. Los datos se obtienen de la API pública Open Brewery DB.

El desafío busca evaluar cómo priorizas, organizas el código y tomas decisiones cuando el tiempo es limitado. El enunciado aclara que no espera un producto terminado. La prioridad es completar los requisitos principales, manejar situaciones de error y poder explicar las decisiones tomadas.

Esta guía explica el archivo `Forest Senior Mobile Engineer (Flutter) Test.md`. Los ejemplos de estructura y las recomendaciones de implementación son propuestas para resolverlo; no son requisitos adicionales del evaluador. Actualmente la carpeta contiene documentación, pero aún no incluye un proyecto Flutter.

## 2. Tecnologías sugeridas

El equipo utiliza las siguientes herramientas:

| Herramienta | Para qué sirve en este desafío |
| --- | --- |
| Flutter | Construir las pantallas y la navegación. |
| `flutter_bloc` | Administrar la lógica y los estados con Cubit o Bloc. |
| `bloc_concurrency` | Controlar el procesamiento de eventos; puede ayudar en la búsqueda. |
| `get_it` e `injectable` | Registrar y proporcionar dependencias. |
| `dio` | Realizar solicitudes HTTP a la API. |
| `bloc_test` y `mocktail` | Probar estados usando repositorios simulados. |
| Mapbox | Implementar el bonus de mapa, si lo eliges. |
| Geolocator | Obtener la ubicación para el bonus de distancia. |
| Sentry | Registrar errores; aparece en el stack, pero no se exige integrarlo. |

Puedes utilizar otras bibliotecas o patrones. Si lo haces, explica por qué los elegiste y qué ventajas o limitaciones tienen. No necesitas instalar todas las herramientas: algunas corresponden a mejoras opcionales.

## 3. API que utilizarás

El enunciado indica que la API no requiere autenticación. Los endpoints suministrados son:

| Operación | Endpoint del enunciado |
| --- | --- |
| Listado paginado | `https://api.openbrewerydb.org/v1/breweries?per_page=20&page=1` |
| Detalle por identificador | `https://api.openbrewerydb.org/v1/breweries/{id}` |
| Búsqueda | `https://api.openbrewerydb.org/v1/breweries/search?query={q}` |

En el listado, `per_page=20` solicita veinte elementos y `page=1` corresponde a la primera página. Para cargar más resultados, cambia el número de página. En el detalle, reemplaza `{id}` por el identificador seleccionado. En la búsqueda, envía el texto como parámetro de consulta mediante el cliente HTTP para codificarlo correctamente.

Durante la implementación, inspecciona respuestas reales para confirmar nombres de campos, tipos y valores ausentes. Aunque el enunciado menciona coordenadas, conviene contemplar datos incompletos al implementar mapa o distancia. Esta guía reproduce los endpoints del desafío; no constituye una verificación del servicio en vivo.

## 4. Requisito principal: listado de cervecerías

### Qué debe mostrar

Cada elemento debe presentar:

- Nombre de la cervecería.
- Tipo de cervecería.
- Ciudad.

Cada elemento debe permitir navegar al detalle. Conserva su identificador para realizar la solicitud de la segunda pantalla.

### Cómo implementar la paginación

Carga la primera página al abrir la pantalla. Después permite solicitar la siguiente, por ejemplo al acercarse al final del listado o mediante un botón «Cargar más». El enunciado exige paginación, pero no fija el mecanismo visual.

Añade los nuevos resultados al listado existente. Mantén información sobre la página actual, si hay una solicitud en curso y si quedan resultados. Evita solicitar simultáneamente la misma página. Avanza la página después de una respuesta exitosa para que un error no provoque que te saltes resultados.

Como recomendación, conserva los elementos ya cargados si falla una página posterior y ofrece reintentar. Define el final de la paginación de acuerdo con el comportamiento confirmado de la API.

### Estados que debes representar

- **Carga inicial:** muestra un indicador mientras esperas la primera respuesta.
- **Éxito:** presenta los elementos obtenidos.
- **Vacío:** informa que no hay resultados; no dejes una pantalla sin explicación.
- **Error:** presenta un mensaje comprensible ante una solicitud fallida.
- **Carga de otra página:** indica que se están obteniendo más resultados, conservando la lista visible.

Los tres estados exigidos expresamente son carga, error y vacío. La distinción entre carga inicial y paginación es una recomendación para que la experiencia sea clara.

### Cómo comprobarlo

Abre la aplicación, verifica los tres datos de cada elemento, carga otra página y confirma que se agregan resultados. Simula una respuesta vacía y un fallo de red; ambas situaciones deben tener una representación visible.

## 5. Requisito principal: detalle de una cervecería

Al seleccionar un elemento, navega a una segunda pantalla y consulta el endpoint de detalle usando su identificador. El requisito pide que esta pantalla obtenga el detalle; mostrar únicamente los datos que ya tenía el listado no cubre ese punto.

Debes mostrar:

- Nombre.
- Dirección.
- Teléfono.
- Sitio web.

Representa la carga y los errores de esta solicitud. Si falta un dato, usa una indicación como «No disponible». Construye la dirección con los campos presentes para evitar textos como `null` o separadores sobrantes.

Permitir abrir el sitio web o llamar por teléfono puede resultar útil, pero el enunciado solo exige mostrar esos datos.

**Comprobación:** selecciona distintas cervecerías, verifica que cada pantalla corresponde al identificador elegido y comprueba el comportamiento cuando falla la solicitud o falta un campo.

## 6. Requisito principal: arquitectura por capas

La aplicación debe separar acceso a datos, lógica y presentación. Una organización posible es:

```text
lib/
├── main.dart
├── core/
│   ├── di/
│   ├── errors/
│   └── network/
│

├── domain/
│   ├── entities/
│   └── repositories/
│
├── data/
│   ├── datasources/
│   ├── dto/
│   └── repositories/
│
└── presentation/
    ├── bloc/
    │   └── brewery_list/
    │
    ├── cubit/
    │   └── brewery_detail/
    │
    ├── screens/
    └── widgets/

test/
    └── presentation/
        ├── bloc/
        └── cubit/
```

No necesitas crear carpetas sin contenido ni multiplicar clases sin una responsabilidad concreta.

### Dominio

Define la entidad que utiliza la aplicación y el contrato del repositorio. Por ejemplo, una entidad `Brewery` y un contrato `BreweryRepository` con operaciones para listar y obtener detalle.

El dominio debe expresar los datos y operaciones del problema sin depender de widgets ni del formato específico de una respuesta HTTP.

### Datos

Implementa el cliente de la API, los DTO y el repositorio concreto. Un DTO representa la estructura recibida del servicio; su mapeo produce la entidad utilizada por las otras capas.

El flujo esperado es: respuesta JSON → DTO → entidad. Aquí también se interpretan los fallos de red y las respuestas inválidas.

### Presentación y lógica

Los widgets muestran información y notifican acciones. Un Cubit o Bloc coordina las solicitudes y emite estados. Utiliza estados sellados para representar los resultados posibles, por ejemplo carga, éxito, vacío y error.

Puedes tener un Cubit para el listado y otro para el detalle. El enunciado admite Cubit o Bloc; no exige usar ambos ni añadir casos de uso para cada operación.

### Inyección de dependencias

Configura las dependencias en un punto de composición: cliente HTTP, fuente de datos, repositorio y Cubit/Bloc. Proporciona las dependencias mediante constructores y expón los controladores a las pantallas mediante los mecanismos apropiados de Flutter Bloc.

Evita que los widgets consulten directamente el localizador de servicios, por ejemplo llamando a `getIt<BreweryRepository>()` para buscar datos. La pantalla debe interactuar con su lógica de presentación.

**Comprobación:** debes poder sustituir el repositorio por un fake en una prueba sin conectar la API ni construir toda la aplicación.

## 7. Requisito principal: manejo de errores

Los repositorios deben lanzar excepciones tipadas. Esto significa distinguir fallos mediante tipos definidos, en lugar de propagar solamente mensajes o detalles del cliente HTTP. Posibles ejemplos son una excepción de conexión, una de servicio y una de datos inválidos; los nombres y la cantidad quedan a tu criterio.

El Cubit/Bloc captura esos fallos y los convierte en estados que la interfaz puede presentar. Por ejemplo, un fallo de conexión puede producir un mensaje «No se pudo cargar la información. Intenta nuevamente».

No uses bloques `catch` vacíos ni conviertas un error en una lista vacía: «no hay resultados» y «no pudimos obtener resultados» son situaciones diferentes. Conserva información técnica útil para diagnóstico sin mostrar excepciones crudas al usuario.

## 8. Requisito principal: pruebas

Debes incluir **al menos una prueba significativa**. No se exige cobertura completa ni un porcentaje mínimo.

El ejemplo sugerido es probar un Cubit/Bloc con un repositorio fake o simulado:

1. Configura el repositorio para devolver cervecerías conocidas.
2. Ejecuta la acción de carga.
3. Verifica la secuencia carga → éxito y los datos resultantes.

Otra prueba útil configura el repositorio para lanzar una excepción tipada y verifica carga → error. Si el tiempo lo permite, cubrir ambas rutas ofrece evidencia del comportamiento principal.

Usa archivos terminados en `_test.dart` y nombres descriptivos, como «emite carga y éxito cuando el repositorio devuelve cervecerías». Evita depender de la API real en estas pruebas, ya que la red introduciría resultados variables.

## 9. Bonus: elige una mejora

El enunciado pide elegir una mejora que priorizarías de forma realista. Completa primero los requisitos principales. Una mejora bien terminada aporta más que varias a medias.

### Opción A: mapa

Muestra marcadores de cervecerías en Mapbox y permite seleccionar una al tocar su marcador. Maneja coordenadas ausentes o inválidas. Documenta la configuración necesaria para ejecutar esta funcionalidad.

### Opción B: distancia

Solicita permiso de ubicación, obtiene la posición con Geolocator y ordena las cervecerías por distancia. Puedes calcularla mediante Haversine o Turf. Contempla permisos denegados y ubicación no disponible. Explica si ordenas únicamente las cervecerías cargadas, pues ordenar una página no equivale a ordenar todos los resultados del servicio.

### Opción C: búsqueda con debounce

Añade una búsqueda que espere una breve pausa al escribir antes de consultar la API. El intervalo lo eliges tú. Evita que una respuesta de una consulta anterior sustituya los resultados de una consulta más reciente. Puedes usar `bloc_concurrency` o una solución equivalente, pero debes implementar explícitamente la espera del debounce; controlar concurrencia por sí solo no la garantiza.

Como recomendación para un alcance acotado, esta opción permite ampliar el listado existente sin incorporar mapas ni permisos de ubicación.

### Opción D: soporte sin conexión

Guarda persistentemente la última lista obtenida con éxito y muéstrala al volver a abrir la aplicación. Una variable en memoria no basta porque se pierde al cerrar el proceso. Define cómo actualizas el caché y qué ocurre si falla la actualización o no existen datos guardados.

## 10. Qué queda fuera del alcance

El enunciado indica que no debes dedicar tiempo a:

- Una interfaz visual perfecta al píxel.
- Autenticación.
- Cobertura total de pruebas.
- CI/CD.

Una interfaz sencilla y entendible es suficiente. Prioriza funcionamiento, estados visibles, separación de responsabilidades y una explicación clara de tus decisiones.

## 11. Orden recomendado de trabajo

1. Crear el proyecto Flutter y elegir las dependencias necesarias.
2. Inspeccionar respuestas de listado y detalle.
3. Definir entidad, DTO, mapeo, contrato del repositorio y errores.
4. Implementar la fuente de datos y el repositorio.
5. Configurar la inyección de dependencias.
6. Implementar y probar los estados de carga del listado.
7. Construir la pantalla de listado y su paginación.
8. Implementar la navegación, solicitud y pantalla de detalle.
9. Comprobar estados vacíos, errores y campos ausentes.
10. Añadir el bonus elegido si el alcance principal está resuelto.
11. Ejecutar las comprobaciones y preparar el README y la entrega.

## 12. Comandos para desarrollo y comprobación

Cuando exista el proyecto Flutter, ejecuta desde su raíz:

```bash
flutter pub get
flutter run
```

El primero instala las dependencias declaradas y el segundo inicia la aplicación en un dispositivo o emulador disponible.

Para verificar el trabajo:

```bash
dart format lib test
flutter analyze
flutter test
```

Estos comandos formatean el código, ejecutan el análisis estático y corren las pruebas. Si eliges herramientas con generación de código, documenta también los comandos correspondientes. El desafío no exige entregar un APK.

## 13. Qué debes entregar

Entrega un repositorio Git o un archivo ZIP con el proyecto y un README breve que explique:

- **Cómo ejecutarlo:** requisitos, instalación, comandos y configuración necesaria.
- **Qué completaste:** requisitos principales y bonus implementado.
- **Qué dejaste fuera:** funcionalidades pendientes u omisiones deliberadas.
- **Qué decisiones tomaste:** bibliotecas, arquitectura y compromisos entre tiempo y alcance.
- **Qué mejorarías con más tiempo:** mejoras concretas, relacionadas con tu implementación.

Si te apartas del stack sugerido, justifica la elección. Es mejor describir honestamente una limitación que afirmar que una funcionalidad está terminada cuando solo está parcialmente implementada.

## 14. Lista de revisión antes de entregar

- [ ] La aplicación inicia siguiendo el README.
- [ ] El listado muestra nombre, tipo y ciudad.
- [ ] La paginación incorpora resultados de páginas posteriores.
- [ ] Los estados de carga, error y vacío son visibles.
- [ ] La selección abre el detalle y consulta por identificador.
- [ ] El detalle muestra nombre, dirección, teléfono y sitio web.
- [ ] Los datos ausentes y los fallos no provocan una pantalla inexplicable.
- [ ] Existen capas de datos, dominio y presentación con responsabilidades claras.
- [ ] Hay mapeo de DTO a entidad, Cubit/Bloc y estados sellados.
- [ ] Las dependencias se inyectan sin consultar el localizador desde widgets.
- [ ] El repositorio lanza excepciones tipadas y la presentación las transforma en estados.
- [ ] Existe al menos una prueba significativa y pasa.
- [ ] El bonus elegido funciona o su omisión está documentada.
- [ ] Se ejecutaron el análisis estático y las pruebas.
- [ ] El README explica ejecución, alcance, omisiones, decisiones y mejoras futuras.
