# Supervisa Task Manager

Aplicación móvil de gestión de tareas desarrollada en Flutter como prueba técnica para prácticas profesionales. Permite crear, consultar, editar y eliminar tareas con persistencia local mediante SQLite, filtros por prioridad y estado, e interfaz basada en Material Design 3.

El proyecto está diseñado con una arquitectura limpia pero simple, dividida en capas de modelo, repositorio, proveedor de estado e interfaz de usuario. Cada capa tiene una responsabilidad única y bien definida, lo que facilita el mantenimiento, las pruebas y la comprensión del código.

## Características

- CRUD completo de tareas (crear, leer, editar, eliminar)
- Persistencia local con SQLite (sqflite)
- Gestión de estado con Provider + ChangeNotifier
- Filtros por prioridad (alta, media, baja) y estado (pendiente, en progreso, completada)
- Interfaz moderna con Material Design 3
- Validaciones: título obligatorio, máximo 150 caracteres, descripción máxima 1000 caracteres, títulos únicos
- Confirmación antes de eliminar tareas
- Indicador de carga y estado vacío
- Banner de filtros activos
- Inmutabilidad del modelo con `copyWith()`
- Manejo de errores con excepciones de validación y captura de violaciones de constraints en SQLite

## Capturas de pantalla

## Tecnologías

| Tecnología | Propósito |
|---|---|
| **Flutter** 3.44.4 | Framework de interfaz de usuario |
| **Dart** 3.12.2 | Lenguaje de programación |
| **Provider** 6.1.5 | Gestión de estado |
| **sqflite** 2.4.3 | Base de datos SQLite local |
| **path** 1.9.1 | Construcción de rutas de archivo multiplataforma |
| **intl** 0.20.3 | Formateo de fechas (DateFormat) |
| **sqflite_common_ffi** 2.4.2 | Soporte de SQLite en pruebas (dev) |

### Decisiones técnicas

- **Provider sobre Riverpod/Bloc/GetX**: Es el más simple de los gestores de estado recomendados oficialmente. Suficiente para una aplicación con un solo proveedor. Menos boilerplate que Bloc, más estable que GetX.
- **SQLite sobre Firebase/Hive**: Los requerimientos exigen persistencia local relacional. SQLite soporta consultas SQL, constraints UNIQUE, ordenación y filtros eficientes sin depender de conexión a internet.
- **Repository Pattern sobre acceso directo a SQLite**: Aísla las consultas SQL de la lógica de presentación. Si en el futuro cambia la fuente de datos (ej: API REST), solo se modifica el repositorio.
- **Singleton en DatabaseService**: Una única conexión a la base de datos durante toda la vida de la aplicación. Centraliza el acceso y evita conexiones múltiples innecesarias.
- **Inmutabilidad del modelo**: `Task` con campos `final` y `copyWith()`. Evita efectos secundarios al compartir objetos entre capas.
- **ValidaciónException propia sobre FormatException**: Usar una excepción específica para validaciones es más semántico que reutilizar una excepción pensada para errores de parseo.

## Arquitectura

```
UI (Screens + Widgets)
        ↓
   TaskProvider
        ↓
  TaskRepository
        ↓
 DatabaseService
        ↓
    SQLite (sqflite)
```

| Capa | Responsabilidad |
|---|---|
| **Task** (modelo) | Representa una tarea. Contiene los enums `TaskPriority` y `TaskStatus`. Métodos `toMap()`, `fromMap()`, `copyWith()`. |
| **DatabaseService** | Singleton. Abre la conexión a SQLite, crea la tabla y maneja migraciones (`onCreate`, `onUpgrade`). |
| **TaskRepository** | CRUD contra la base de datos. Métodos: `getAll()`, `insert()`, `update()`, `delete()`, `existsTitle()`. No contiene lógica de negocio ni validaciones. |
| **TaskProvider** | Gestiona el estado de la aplicación. Expone listas de tareas, filtros y estado de carga. Valida datos, llama al repositorio y notifica cambios a la UI. |
| **Screens** | TaskListScreen (lista + filtros) y TaskFormScreen (crear/editar). Solo muestran información y delegan acciones al Provider. |
| **Widgets** | TaskCard (widget reutilizable de presentación pura con callbacks). |

### Flujo de datos

1. El usuario interactúa con una pantalla (ej: pulsa "Guardar")
2. La pantalla llama a un método del Provider (ej: `addTask()`)
3. El Provider valida los datos, llama al Repository
4. El Repository ejecuta SQL a través de DatabaseService
5. El resultado se propaga hacia arriba: datos → Provider → UI

## Estructura del proyecto

```
lib/
├── main.dart                          # Punto de entrada, Provider + MaterialApp
├── database/
│   └── database_service.dart          # Conexión SQLite (singleton)
├── models/
│   └── task.dart                      # Modelo Task + enums TaskPriority, TaskStatus
├── providers/
│   └── task_provider.dart             # Estado global + validaciones
├── repositories/
│   └── task_repository.dart           # CRUD contra SQLite
├── screens/
│   ├── task_list_screen.dart          # Pantalla principal (lista + filtros)
│   └── task_form_screen.dart          # Formulario de crear/editar
└── widgets/
    └── task_card.dart                 # Widget reutilizable de tarjeta de tarea
```

## Instalación

```bash
# Clonar el repositorio
git clone https://github.com/JoseHidalgo1/prueba-tecnica-supervisa-crud.git
cd prueba-tecnica-supervisa-crud

# Instalar dependencias
flutter pub get

# Ejecutar en dispositivo o emulador
flutter run
```

### Requisitos

- Flutter SDK 3.44.4 o superior
- Dart 3.12.2 o superior
- Dispositivo Android/iOS o emulador

## Funcionalidades

### Crear tarea
Pulsa el botón `+` en la esquina inferior derecha. Completa el formulario y pulsa "Crear tarea".

### Editar tarea
Toca una tarjeta de tarea en la lista. Modifica los campos y pulsa "Guardar cambios".

### Eliminar tarea
Pulsa el icono de eliminar en una tarjeta. Confirma la eliminación en el diálogo.

### Filtrar tareas
Pulsa el icono de filtro en la barra superior. Selecciona prioridad y/o estado. La lista se actualiza automáticamente.

## Validaciones implementadas

| Validación | Lugar | Comportamiento |
|---|---|---|
| Título obligatorio | Form (validador) + Provider | Error visual + excepción |
| Título máximo 150 caracteres | Form (maxLength) | Contador y bloqueo |
| Descripción máximo 1000 caracteres | Form (maxLength) + Provider | Contador y bloqueo |
| Título único | Provider (existsTitle) | SnackBar informativo |
| Violación UNIQUE de SQLite | Provider (try/catch) | Fallback: SnackBar informativo |
| Tarea no encontrada al editar/eliminar | Provider (affected == 0) | SnackBar informativo |

## Pruebas

```bash
# Análisis estático
flutter analyze

# Pruebas unitarias y de widgets
flutter test
```

El proyecto incluye un test de widget que verifica que la pantalla principal se renderiza correctamente con la configuración de Provider y SQLite en entorno de prueba.

## Aprendizajes y conceptos aplicados

- Arquitectura en capas (Model → Repository → Provider → UI)
- Patrón Repository para acceso a datos
- Singleton para recursos compartidos (DatabaseService)
- Gestión de estado con Provider + ChangeNotifier
- Persistencia local con SQLite (sqflite)
- Migraciones de esquema de base de datos (onCreate, onUpgrade)
- Inmutabilidad con copyWith
- Widgets reutilizables y de presentación pura
- Navegación entre pantallas con Navigator.push/pop
- Formularios con validación y AutovalidateMode
- Manejo de excepciones con excepciones personalizadas
- Defensa en profundidad (validación + constraint UNIQUE)
- Material Design 3 con ColorScheme.fromSeed
- Flujo de trabajo Git con ramas por característica
- Conventional Commits

## Mejoras futuras

- Búsqueda de tareas por texto
- Ordenamiento por fecha, prioridad o estado
- Soporte para modo oscuro (ya preparado por ColorScheme.fromSeed)
- Tema claro/oscuro configurable
- Notificaciones para fechas límite próximas
- Categorías o etiquetas personalizadas
- Sincronización con API REST
- Tests de integración
- Internacionalización (i18n) completa

## Autor

Desarrollado como prueba técnica para práctica profesional de Ingeniería de Sistemas.

## Licencia

Este proyecto es de uso académico y demostrativo.
