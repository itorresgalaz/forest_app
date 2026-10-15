# forestchallenger

App Flutter que consume [Open Brewery DB](https://www.openbrewerydb.org/) para listar, buscar y ver el detalle de cervecerías. Usa Clean Architecture (Domain / Data / Presentation), BLoC y Cubit para el estado, e inyección de dependencias con `get_it` + `injectable`.

- API: `https://api.openbrewerydb.org/v1`
- Entrada: `main.dart` → `configureDependencies()` → `AppRouter` → `MaterialApp.router`

## Índice

- [Stack](#stack)
- [Arquitectura](#arquitectura)
- [Conceptos (Event → Bloc → State)](#conceptos-event--bloc--state)
- [Flujos](#flujos)
- [Estados](#estados)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Inyección de dependencias](#inyección-de-dependencias)
- [Pruebas](#pruebas)
- [Comandos](#comandos)
- [Estado del proyecto](#estado-del-proyecto)
- [What you intentionally left out](#what-you-intentionally-left-out)
- [Any trade-offs you made](#any-trade-offs-you-made)
- [What you would improve with more time](#what-you-would-improve-with-more-time)
- [Notas](#notas)

## Stack

Dependencias principales:

| Paquete | Uso |
| --- | --- |
| `flutter_bloc` | BLoC y Cubit en la capa de presentación |
| `bloc_concurrency` | Transformers de eventos (`restartable` en listado/búsqueda, `droppable` en paginación) |
| `dio` | Cliente HTTP hacia Open Brewery DB |
| `get_it` + `injectable` | Inyección de dependencias (código generado) |
| `equatable` | Comparación por valor en entidades y estados |
| `go_router` | Navegación (`/breweries`, `/breweries/:id`) |
| `url_launcher` | Abrir el sitio web y el teléfono desde el detalle |
| `stream_transform` | Utilidades de streams |

Dev: `bloc_test`, `mocktail`, `build_runner`, `injectable_generator`.

## Arquitectura

```text
PRESENTATION (Screen - Widgets - Bloc - Cubit)
  BreweryListScreen + BreweryDetailScreen
  BreweryListBloc + BreweryDetailCubit
        |
        v
DOMAIN (Entities - Repository)
  Brewery
  BreweryRepository (contrato)
        ^
        |
DATA (RepositoryImpl - Datasource - DTO (Data transfer object))
  BreweryRepositoryImpl
  BreweryRemoteDataSource
  BreweryDto + Dio
```

Responsabilidades:

- **Presentation:** pantallas y estado de UI. `BreweryListBloc` maneja listado, búsqueda con debounce y paginación; `BreweryDetailCubit` maneja el detalle.
- **Domain:** entidad `Brewery` y el contrato `BreweryRepository`. No depende de Flutter ni de Dio.
- **Data:** implementa el contrato (`BreweryRepositoryImpl`), llama al datasource remoto y mapea DTO → entidad.

Se usó BLoC para el listado por la interacción entre paginación, carga y búsqueda; y Cubit para el detalle, cuyo flujo es más simple. La separación entre capas se apoya en el contrato de repositorio y la inyección de dependencias.

## Conceptos (Event → Bloc → State)

| Pregunta | Respuesta | Concepto |
| --- | --- | --- |
| ¿Qué ocurrió? | Se solicitó la lista | Event |
| ¿Qué debe hacer la app? | Consultar el repositorio | Bloc |
| ¿Qué debe mostrar la pantalla? | Loading, Loaded o Failure | State |

## Flujos

### Apertura de la app

```mermaid
flowchart TD
A["Usuario abre la pantalla"] --> B["Solicitar primera página"]
B --> C["Mostrar Loading"]
C --> D["Consultar BreweryRepository"]
D --> E{"¿Qué resultado obtuvimos?"}
E -->|Hay datos| F["Mostrar Loaded"]
E -->|Lista vacía| G["Mostrar Empty"]
E -->|Excepción| H["Mostrar Failure"]
H -->|Reintentar| B
```

### Listado

```mermaid
flowchart TD
A["Abrir pantalla"] --> B["BreweryListRequested"]
B --> C["BreweryListBloc"]
C --> D["Loading"]
C --> E["Repository: obtener página 1"]
E --> F{"Resultado"}
F -->|Con datos| G["Loaded"]
F -->|Sin datos| H["Empty"]
F -->|Error| I["Failure"]
I -->|Reintentar| B
```

### Paginación

```mermaid
flowchart TD
A["Usuario llega al final"] --> B["BreweryListNextRequested"]
B --> C{"¿Loaded, hasMore y no está cargando?"}
C -->|No| D["Ignorar evento"]
C -->|Sí| E["Conservar lista y mostrar carga inferior"]
E --> F["Solicitar nextPage"]
F --> G{"Resultado"}
G -->|Éxito| H["Acumular cervecerías y actualizar página"]
G -->|Error| I["Conservar lista y mostrar error de paginación"]
```

### Detalle de la cervecería

```mermaid
flowchart TD
A["Usuario selecciona cervecería"] --> B["GoRouter obtiene el ID"]
B --> C["BlocProvider crea BreweryDetailCubit"]
C --> D["Cubit.loadBrewery(id) muestra Loading"]
D --> E["Repository.getBrewery(id)"]
E --> F{"Resultado"}
F -->|Éxito| G["Loaded: nombre, dirección, teléfono y web"]
F -->|AppException| H["Failure: mensaje"]
F -->|Error inesperado| H
G --> I["AppBar muestra el nombre"]
G --> K["Teléfono y web abren en apps externas"]
H --> J["Reintentar con breweryId"]
```

### Búsqueda

Implementada en `BreweryListBloc` con el evento `BrewerySearchChanged`: debounce de 350 ms, transformer `restartable` y un contador de generación que descarta respuestas obsoletas. La API (`/breweries/search`) exige al menos 3 caracteres: con 1 o 2 el BLoC emite `Empty` sin llamar al repositorio, y con el campo vacío vuelve a la lista general.

```mermaid
flowchart TD
A["Usuario escribe"] --> B["BrewerySearchChanged"]
B --> C["BLoC invalida solicitudes anteriores"]
C --> D["Loading"]
D --> E["Esperar 350 ms"]
E --> F{"¿La solicitud sigue vigente?"}
F -->|No| G["Ignorar"]
F -->|Sí| H{"Texto de búsqueda"}
H -->|Vacío| I["Obtener lista general"]
H -->|1 o 2 caracteres| J["Indicar mínimo 3 caracteres"]
H -->|3 o más caracteres| K["Buscar en API"]
I --> L["Loaded / Empty / Failure"]
K --> L
L --> M["Paginar conservando el término"]
```

## Estados

- **Listado** (`BreweryListState`): `Initial`, `Loading`, `Loaded`, `Empty`, `Failure`. Todos llevan `query` (búsqueda activa) y `Loaded` añade `isLoadingMore` y `paginationError` para la carga incremental.
- **Detalle** (`BreweryDetailState`): `Initial`, `Loading`, `Loaded`, `Failure`.

## Estructura del proyecto

```text
lib/
  main.dart
  core/
    di/          injection.dart, injection.config.dart (generado)
    errors/      app_exception.dart, dio_exception.dart
    network/     api_url.dart (Dio + baseUrl)
    router/      app_router.dart
  domain/
    entities/    brewery.dart
    repositories/brewery_repository.dart
  data/
    datasources/ brewery_remote_datasource.dart
    models/      brawery_dto.dart
    repositories_impl/ brewery_repository_impl.dart
  presentation/
    bloc/        brewery_list_bloc.dart (+ event, state)
    cubit/       brewery_detail_cubit.dart (+ state)
    screens/     brewery_list_screen.dart, brewery_details_screen.dart
    widgets/     brewery_tile.dart (usado por el listado)
    brewery_type_label.dart
test/
  presentation/
    bloc/  brewery_list_bloc_test.dart
    cubit/ brewery_detail_cubit_test.dart
```

## Inyección de dependencias

`configureDependencies()` en `core/di/injection.dart` inicializa `get_it` con `injectable`. El grafo se genera en `injection.config.dart` con `build_runner`:

- `Dio` → `lazySingleton` (`ApiUrl`)
- `BreweryRemoteDatasource` → `lazySingleton`
- `BreweryRepositoryImpl` → `LazySingleton` como `BreweryRepository`
- `BreweryListBloc` y `BreweryDetailCubit` → `factory` (instancia nueva por pantalla)

Tras cambiar anotaciones, regenerar con `dart run build_runner build --delete-conflicting-outputs`.

## Pruebas

Un test de BLoC responde tres preguntas:

- **Given:** ¿en qué situación comenzamos?
- **When:** ¿qué evento ejecutamos?
- **Then:** ¿qué estados esperamos recibir?

Responsabilidad de cada etapa:

```mermaid
flowchart TD
A["brewery_list_bloc_test.dart"] --> B["MockBreweryRepository"]
B --> C["Simula las respuestas del repositorio"]
A --> D["blocTest"]
D --> E["build: construye BreweryListBloc"]
E --> F["act: envía eventos"]
F --> G["expect: comprueba estados"]
G --> H["verify: comprueba llamadas"]
```

Cobertura actual:

- `brewery_list_bloc_test.dart`: carga inicial (Loading → Loaded), lista vacía (Empty), error (`ServerException` → Failure), paginación (acumula página 2) y fallo en página 2 (conserva la lista y expone `paginationError`).
- `brewery_detail_cubit_test.dart`: detalle exitoso (Loading → Loaded) y fallo de red (Loading → Failure).
- Búsqueda: debounce (solo la última consulta llega al repositorio).

Ejecutar:

## Comandos

```sh
flutter pub add dio
flutter pub add bloc_concurrency
flutter pub add flutter_bloc
flutter pub add get_it
flutter pub add injectable
flutter pub add equatable
flutter pub add go_router
flutter pub add stream_transform
# dev
flutter pub add --dev bloc_test
flutter pub add --dev mocktail

# ejecutar la app
flutter run

# pruebas
flutter test
```

## Estado del proyecto

- Listado con paginación: implementado (`BreweryListBloc`, `brewery_list_screen.dart`).
- Detalle y navegación: implementado (`BreweryDetailCubit`, `brewery_details_screen.dart`, ruta `/breweries/:id`).
- Búsqueda con debounce: implementado (`BrewerySearchChanged` en el BLoC, `searchBreweries` en datasource/repositorio y campo de búsqueda en `brewery_list_screen.dart`).
- Detalle: el teléfono y el sitio web se abren en apps externas con `url_launcher` (con aviso si el sistema no puede abrirlos).
- Pruebas: BLoC del listado (incluida búsqueda), Cubit del detalle.

## Notas

- Entidades generadas desde el JSON con [quicktype](https://app.quicktype.io/).

## No se realizó en esta revision

- Configuración de plataforma para `url_launcher`: se usa `launchUrl` directamente (sin `canLaunchUrl`), por lo que no hacen falta `<queries>` en Android ni `LSApplicationQueriesSchemes` en iOS.
- UX de búsqueda: sin estado dedicado de "sin coincidencias" más allá de `Empty`, sin botón para limpiar el campo ni historial.
- Limpieza de código: template `blocTest` comentado, bloques comentados en `event`/`state` y la extension `brewery_type_label.dart` (sin uso).
- Scaffolding de plataformas (`android/`, `ios/`, `.metadata`, `analysis_options.yaml`, `pubspec.lock`) presente en disco pero sin commitear.

## Decisiones

- Se uso BLoC para el listado (paginación + búsqueda) y Cubit para el detalle, por tener este último un flujo más simple.
- Un único estado `BreweryListLoaded` con `isLoadingMore` y `paginationError` en lugar de estados separados para la carga incremental.
- Normalización del sitio web: si el dato no trae esquema se asume `https://`.
- Al buscar se vuelve a la página 1 (`jumpTo(0)`) y se descartan respuestas obsoletas con un contador de generación, en vez de cancelar la petición HTTP.
- Debounce fijo de 350 ms; la API exige al menos 3 caracteres.

## Por revisar en futuros commit

- Tests de widget/pantalla y de `url_launcher` (mock del `MethodChannel`), además de los casos faltantes.
- Pull-to-refresh, manejo de "sin conexión" y caché. (soporte sin conexión).
- Mapbox con marcadores para ver detalles de una cervecería.
- Diseño de UI
- i18n (los textos están fijos en español) y accesibilidad de los enlaces (`Semantics`).
- Refactor de `brewery_list_screen.dart` (extraer el campo de búsqueda y el footer) y limpieza del código comentado.
