# forestchallenger

Pregunta   ->   Respuesta -> Concepto

Que ocurrio? ->  Se solicito lista -> Event
Que debe hacer la app -> Consultar Repo -> Bloc
Que debe mostrar en screen -> Loading, Loaded o Failure -> State


Fase 1 — Aplicación mínima funcional
Lista paginada, detalle, carga, errores, estado vacío y navegación.
Prioridad máxima: cumplir el desafío principal.

Fase 2 — Calidad de ingeniería
Arquitectura por capas, DI, excepciones tipadas, pruebas del BLoC y README.
Demostrar decisiones mantenibles y verificables.

Fase 3 — Un bonus
Búsqueda con debounce y tratamiento de respuestas asíncronas.
Solo después de cumplir y probar los requisitos principales.


Arquitectura

PRESENTATION (Screen - Widgets - Bloc - Cubit)
BreweryListScreen + BreweryDetailScreen
BreweryListBloc + BreweryDetailCubit
 |
abajo
DOMAIN (Entities - Repository)
Brewery
BreweryRepository (contrato)
arriba
|
DATA (RepositoryImpl - Datasource - DTO(Data transfers object))
BreweryRepositoryImpl
BreweryRemoteDataSource
BreweryDto + Dio


#LISTADO

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

#PAGINACION

flowchart TD
A["Usuario llega al final"] --> B["BreweryNextPageRequested"]
B --> C{"¿Loaded, hasMore y no está cargando?"}
C -->|No| D["Ignorar evento"]
C -->|Sí| E["Conservar lista y mostrar carga inferior"]
E --> F["Solicitar nextPage"]
F --> G{"Resultado"}
G -->|Éxito| H["Acumular cervecerías y actualizar página"]
G -->|Error| I["Conservar lista y mostrar error de paginación"]

#DETALLE

flowchart TD
A["Seleccionar cervecería"] --> B["GoRouter con ID"]
B --> C["BreweryDetailScreen"]
C --> D["Cubit: cargar detalle"]
D --> E["Loading"]
D --> F["Repository: buscar por ID"]
F --> G{"Resultado"}
G -->|Éxito| H["Loaded: nombre, dirección, teléfono, web"]
G -->|Error| I["Failure: informar y reintentar"]


#Buscar
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

### Estados 
#Initial, Loading, Loaded, Failure, Empty

#AL ABRIR LA APP
flowchart TD
A["Usuario abre la pantalla"] --> B["Solicitar primera página"]
B --> C["Mostrar Loading"]
C --> D["Consultar BreweryRepository"]
D --> E{"¿Qué resultado obtuvimos?"}
E -->|Hay datos| F["Mostrar Loaded"]
E -->|Lista vacía| G["Mostrar Empty"]
E -->|Excepción| H["Mostrar Failure"]
H -->|Reintentar| B

Se utilizó BLoC para el listado debido a la interacción entre paginación, estados de carga y búsqueda. Para el detalle se utilizó Cubit, ya que su flujo es más sencillo. La aplicación separa Domain, Data y Presentation mediante contratos de repositorio e inyección de dependencias. Se priorizó completar las funcionalidades principales y agregar pruebas significativas antes de implementar funcionalidades opcionales.
A new Flutter project.
codex resume 01a120df-c1d9-7e03-8544-cfbddb197536

https://app.quicktype.io/ para transformar la respuesta del json a la entidad

flutter pub add dio
flutter pub add bloc_concurrency
flutter pub add flutter_bloc
flutter pub add get_it
flutter pub add injectable
flutter pub add equatable
flutter pub add go_router
flutter pub add bloc_test
flutter pub add mocktail
flutter pub add stream_transform
