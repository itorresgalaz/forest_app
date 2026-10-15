# forestchallenger

App Flutter de cervecerías (Open Brewery DB) con Clean Architecture, BLoC y inyección de dependencias.

## Conceptos

Pregunta -> Respuesta -> Concepto

- Que ocurrio? -> Se solicito lista -> Event
- Que debe hacer la app -> Consultar Repo -> Bloc
- Que debe mostrar en screen -> Loading, Loaded o Failure -> State

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
## Estados

`Initial`, `Loading`, `Loaded`, `Failure`, `Empty`

## AL ABRIR LA APP

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

Se utilizó BLoC para el listado debido a la interacción entre paginación, estados de carga y búsqueda. Para el detalle se utilizó Cubit, ya que su flujo es más sencillo. La aplicación separa Domain, Data y Presentation mediante contratos de repositorio e inyección de dependencias. Se priorizó completar las funcionalidades principales y agregar pruebas significativas antes de implementar funcionalidades opcionales.

Herramienta usada para generar las entidades desde el JSON: https://app.quicktype.io/


## LISTADO

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

## PAGINACION

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

## DETALLE DE LA CERVECERIA
```mermaid
flowchart TD
A["Usuario selecciona cervecería"] --> B["GoRouter recibe el ID"]
B --> C["Se crea BreweryDetailCubit"]
C --> D["loadBrewery(id)"]
D --> E["Emitir Loading"]
E --> F["Repository.getBreweryById(id)"]
F --> G{"Resultado"}
G -->|Éxito| H["Loaded: Brewery"]
G -->|Error conocido| I["Failure: mensaje"]
G -->|Error inesperado| I
```
Pendiente: `BreweryDetailScreen` es un `Placeholder`, la ruta está comentada y no existe el Cubit.

```mermaid
flowchart TD
A["Seleccionar cervecería"] --> B["GoRouter con ID"]
B --> C["BreweryDetailScreen"]
C --> D["Cubit: cargar detalle"]
D --> E["Loading"]
D --> F["Repository: buscar por ID"]
F --> G{"Resultado"}
G -->|Éxito| H["Loaded: nombre, dirección, teléfono, web"]
G -->|Error| I["Failure: informar y reintentar"]
```

## Buscar

Pendiente (Fase 3): `BrewerySearchChanged` está comentado.

```mermaid
flowchart TD
A["Usuario escribe IPA"] --> B["Evento: búsqueda modificada"]
B --> C["Esperar pausa de escritura"]
C --> D["Comenzar nueva búsqueda"]
D --> E["Estado Loading"]
E --> F["Consultar repositorio con IPA"]
F --> G{"¿Resultado?"}
G -->|Con datos| H["Estado Loaded"]
G -->|Sin datos| I["Estado Empty"]
G -->|Error| J["Estado Failure"]
classDef event fill:#dbeafe,color:#1e40af,stroke:#93c5fd
classDef state fill:#dcfce7,color:#166534,stroke:#86efac
class B event
class E,H,I,J state
```


## TEST

```mermaid
flowchart TD
A["Test envía BreweryListRequested"] --> B["BreweryListBloc"]
B --> C["Emite Loading"]
B --> D["MockBreweryRepository"]
D --> E["Devuelve 20 cervecerías simuladas"]
E --> F["BLoC emite Loaded"]
F --> G{"¿Se emitieron los estados esperados?"}
G -->|Sí| H["TEST PASSED"]
G -->|No| I["TEST FAILED"]
```

Un TEST en bloc debe responder 3 preguntas:

- Given: ¿en qué situación comenzamos?
- When: ¿qué evento ejecutamos?
- Then: ¿qué estados esperamos recibir?

Responsabilidad de cada etapa del test:

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
```

## Estado

- Listado con paginación: implementado (`BreweryListBloc`).
- Detalle y navegación: pendiente.
- Búsqueda con debounce: pendiente.
- Pruebas del BLoC: implementado (`test/presentation/bloc/brewery_list_bloc_test.dart`).
