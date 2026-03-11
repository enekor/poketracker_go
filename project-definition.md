# PokéTracker GO — Definición de Proyecto

## 1. Descripción general

Aplicación móvil (Android) desarrollada en **Flutter** que funciona como una Pokédex personal para **Pokémon GO**. El usuario puede consultar todos los Pokémon existentes (obtenidos de la **PokeAPI**) y marcar los que ya posee, tanto en su versión **normal** como **shiny**. Los Pokémon no obtenidos se muestran en silueta/escala de grises; los obtenidos se muestran a todo color.

---

## 2. Stack tecnológico

| Concepto | Tecnología |
|---|---|
| Framework | Flutter (Dart) |
| Estado | GetX (`GetxController`, `Obx`) |
| Almacenamiento local | Hive (boxes tipados) |
| Fuente de datos | PokeAPI v2 (`https://pokeapi.co/api/v2/`) |
| Plataforma objetivo | Android |
| Versión mínima de Dart | 3.0+ |
| Versión mínima de Flutter | 3.10+ |

---

## 3. Tema visual — Estilo Pokémon GO

La aplicación sigue la estética de Pokémon GO con soporte para **modo claro y modo oscuro**.

### 3.1 Paleta de colores

| Token | Modo claro | Modo oscuro | Uso |
|---|---|---|---|
| `primary` | `#1E88E5` (azul Pokémon GO) | `#1E88E5` | AppBar, botones principales, chips activos |
| `primaryDark` | `#1565C0` | `#0D47A1` | StatusBar, elementos de énfasis |
| `secondary` | `#FFD600` (amarillo Pokémon) | `#FFC107` | FABs, acentos, indicadores de selección |
| `background` | `#F5F5F5` | `#121212` | Fondo general |
| `surface` | `#FFFFFF` | `#1E1E1E` | Cards, tiles del grid, modales |
| `onSurface` | `#212121` | `#E0E0E0` | Texto principal |
| `onSurfaceVariant` | `#757575` | `#9E9E9E` | Texto secundario, números de Pokédex |
| `generationHeader` | `#E3F2FD` | `#1A237E` | Fondo de headers sticky de generación |
| `owned` | sin filtro (color completo) | sin filtro (color completo) | Sprite de Pokémon poseído |
| `notOwned` | escala de grises + opacidad 0.5 | escala de grises + opacidad 0.4 | Sprite de Pokémon no poseído |
| `selectedBorder` | `#4CAF50` (verde) | `#66BB6A` | Borde de celda en modo selección múltiple |

### 3.2 Tipografía

- Fuente principal: la por defecto de Flutter (`Roboto` en Android).
- Headers de generación: `bold`, tamaño 16sp.
- Nombre de Pokémon: `medium`, tamaño 12sp.
- Número de Pokédex: `regular`, tamaño 10sp, color `onSurfaceVariant`.

### 3.3 Componentes visuales clave

- **AppBar**: fondo `primary`, con el logo/texto de la app centrado. En modo oscuro mismo azul pero con elevación sutil.
- **Grid tiles**: esquinas redondeadas (8dp), sombra suave en modo claro, borde sutil en modo oscuro. Fondo `surface`.
- **Barra de generaciones**: fila horizontal scrollable de chips. Chip activo: fondo `primary`, texto blanco. Chip inactivo: fondo `surface`, texto `onSurface`.
- **Barra de búsqueda**: campo con icono de lupa, fondo `surface`, bordes redondeados (24dp).
- **Indicador Normal/Shiny**: dos tabs o dots en la parte superior del grid. Tab activa subrayada con `secondary`.
- **Modo selección**: overlay semitransparente con check verde (`selectedBorder`) sobre las celdas seleccionadas.

### 3.4 Toggle de tema

- Se almacena la preferencia en Hive (box de settings).
- Accesible desde un icono de sol/luna en el AppBar o en la pantalla de home/settings.
- Se gestiona con un `ThemeController` (GetxController) que expone un `RxBool isDarkMode` y aplica el `ThemeData` correspondiente con `Get.changeTheme()`.

---

## 4. Arquitectura y estructura de carpetas

La arquitectura se basa en la separación por **features/pantallas**. Cada pantalla se descompone en **3 archivos** dentro de su propia carpeta:

| Archivo | Responsabilidad |
|---|---|
| `*_screen.dart` | Widget raíz de la pantalla. Solo compone layout llamando a widgets de `*_widgets.dart` y accediendo al service con `Get.find()`. No contiene lógica de negocio ni widgets complejos inline. |
| `*_widgets.dart` | Todos los widgets reutilizables/internos de esa pantalla (cards, grids, dialogs, etc.). Reciben datos por parámetro; no instancian controllers directamente. |
| `*_service.dart` | Lógica de negocio, acceso a datos (llamadas a PokeAPI, lectura/escritura en Hive) **y funciones auxiliares** (handlers, formateo, filtrado). Se expone como `GetxController` para inyección con `Get.put()` / `Get.find()`. |

### Árbol de carpetas

```
lib/
├── main.dart
├── app/
│   ├── routes/
│   │   └── app_routes.dart              # Rutas nombradas de GetX
│   └── theme/
│       ├── app_theme.dart               # ThemeData claro y oscuro
│       ├── app_colors.dart              # Constantes de color (paleta completa)
│       └── theme_controller.dart        # GetxController para toggle claro/oscuro
│
├── core/
│   ├── constants/
│   │   ├── api_constants.dart           # Base URLs, endpoints PokeAPI
│   │   └── pokemon_generations.dart     # Mapa de generaciones → rangos de IDs
│   ├── models/
│   │   ├── pokemon_model.dart           # Modelo de Pokémon (id, name, sprites, types, generation)
│   │   └── user_pokemon_model.dart      # Modelo Hive: {pokemonId, hasNormal, hasShiny}
│   ├── services/
│   │   ├── api_service.dart             # Cliente HTTP genérico (GET a PokeAPI)
│   │   └── hive_service.dart            # Inicialización de Hive, open boxes, CRUD genérico
│   └── utils/
│       └── image_utils.dart             # Helpers para aplicar escala de grises / color a sprites
│
├── features/
│   ├── home/
│   │   ├── home_screen.dart             # Pantalla de inicio / menú principal
│   │   ├── home_widgets.dart
│   │   └── home_service.dart
│   │
│   ├── pokedex/
│   │   ├── pokedex_screen.dart          # Pantalla principal: PageView horizontal [normal | shiny]
│   │   ├── pokedex_widgets.dart         # PokemonGridTile, GenerationHeader, SearchBar, etc.
│   │   └── pokedex_service.dart         # GetxController: carga, filtra, scroll sync, búsqueda
│   │
│   ├── pokemon_selector/
│   │   ├── pokemon_selector_screen.dart # Pantalla de selección múltiple para registrar Pokémon
│   │   ├── pokemon_selector_widgets.dart
│   │   └── pokemon_selector_service.dart
│   │
│   └── pokemon_detail/
│       ├── pokemon_detail_screen.dart
│       ├── pokemon_detail_widgets.dart
│       └── pokemon_detail_service.dart
```

---

## 5. Modelos de datos

### 5.1 `PokemonModel`

```dart
class PokemonModel {
  final int id;
  final String name;
  final String spriteUrl;      // sprite normal
  final String spriteShinyUrl; // sprite shiny
  final List<String> types;
  final int generation;        // 1-9

  PokemonModel({...});

  factory PokemonModel.fromPokeApi(Map<String, dynamic> json);
}
```

### 5.2 `UserPokemonModel` (Hive)

```dart
@HiveType(typeId: 0)
class UserPokemonModel extends HiveObject {
  @HiveField(0)
  final int pokemonId;

  @HiveField(1)
  bool hasNormal;

  @HiveField(2)
  bool hasShiny;

  UserPokemonModel({
    required this.pokemonId,
    this.hasNormal = false,
    this.hasShiny = false,
  });
}
```

### 5.3 `SettingsModel` (Hive)

```dart
@HiveType(typeId: 1)
class SettingsModel extends HiveObject {
  @HiveField(0)
  bool isDarkMode;

  SettingsModel({this.isDarkMode = false});
}
```

---

## 6. Pantallas — Especificación detallada

### 6.1 Home (`home_screen`)

- Pantalla de entrada a la aplicación.
- Muestra el logo/título de la app.
- Opciones de navegación: ir a Pokédex, ir a Selector de Pokémon.
- Acceso al toggle de tema (claro/oscuro) desde un icono en el AppBar.
- Opcionalmente muestra estadísticas rápidas: "Tienes X/1025 Pokémon" y "X/1025 Shiny".

### 6.2 Pokédex (`pokedex_screen`)

#### 6.2.1 Doble vista Normal / Shiny

- Contiene un `PageView` horizontal con **2 páginas**: vista Normal y vista Shiny.
- Ambas páginas comparten la **misma posición de scroll** de forma que al deslizar lateralmente del grid Normal al Shiny, el rango visible de Pokémon sea el mismo.
  - Ejemplo: si el usuario ve del #101 al #160 en Normal, al hacer swipe lateral verá del #101 al #160 en Shiny.
- Indicador visual (tab o dot indicator) que muestra si se está en Normal o Shiny.

#### 6.2.2 Grid de Pokémon

- Cada Pokémon se representa en una celda de grid mostrando:
  - **Sprite a color** si el usuario lo tiene marcado como poseído.
  - **Sprite en escala de grises / silueta** si no lo tiene (ver colores `owned`/`notOwned` en sección de tema).
  - Número de Pokédex (`#001`) debajo o superpuesto al sprite.
- El grid se renderiza con `GridView.builder` para rendimiento con listas grandes (1000+ Pokémon).

#### 6.2.3 Separación por generaciones

- Los Pokémon se agrupan por generación (Gen 1: #1-151, Gen 2: #152-251, etc.).
- En el scroll vertical el grid muestra un **header sticky** con el nombre de la generación antes de su bloque de Pokémon.
- En la **parte superior** de la pantalla hay una fila horizontal scrollable de chips con las generaciones (I, II, III…) que al pulsarse hace scroll automático hasta esa generación.
- El scroll es continuo: al terminar una generación se ve directamente la siguiente.

#### 6.2.4 Búsqueda

- Barra de búsqueda fija en la parte superior (debajo de la barra de generaciones).
- Acepta:
  - **Número de Pokédex** (ej: `25` o `#25`): hace scroll directo a esa posición.
  - **Nombre** (ej: `Pikachu`): filtra y hace scroll al resultado.
- Búsqueda en tiempo real (on-change) con debounce de ~300ms.

### 6.3 Selector de Pokémon (`pokemon_selector_screen`)

- Pantalla dedicada a marcar/desmarcar Pokémon que el usuario posee.
- Muestra el mismo grid de Pokémon que la Pokédex pero con **modo de selección múltiple activo por defecto**.
- Cada tap en una celda la marca/desmarca (toggle) con indicador visual (check verde, borde `selectedBorder`).
- Tabs o toggle para elegir si se está registrando **Normales** o **Shinys**.
- Botón de confirmar (FAB o barra inferior) que guarda en Hive todos los cambios de una vez.
- Incluye la misma barra de generaciones y búsqueda que la Pokédex para facilitar la navegación.

### 6.4 Detalle de Pokémon (`pokemon_detail_screen`)

- Se accede al pulsar un Pokémon en la Pokédex (no en el selector).
- Muestra sprite grande (normal y shiny), nombre, número, tipos, y stats básicos.
- Indica visualmente si el usuario lo tiene (normal y/o shiny).

---

## 7. Flujo de datos

```
PokeAPI  ──GET──▶  api_service.dart  ──▶  *_service.dart (GetxController)
                                              │
                                              ├──▶  Lista<PokemonModel>  (.obs)
                                              │
                                              └──▶  Hive (UserPokemonModel)
                                                       │
                                                       ▼
                                              Estado combinado:
                                              Pokémon + posesión usuario
                                                       │
                                                       ▼
                                              *_screen / *_widgets
                                              (Obx reactivo)
```

1. Al iniciar la app, el service carga desde PokeAPI la lista completa de Pokémon (nombre, id, sprites) y la almacena en memoria como `RxList<PokemonModel>`.
2. En paralelo, lee de Hive la box de `UserPokemonModel` para saber qué Pokémon tiene el usuario.
3. Los widgets leen ambas listas de forma reactiva (`Obx`) y renderizan color o escala de grises según corresponda.
4. Al marcar/desmarcar en el selector, el service actualiza Hive y la variable reactiva se refresca automáticamente.

---

## 8. Mapa de generaciones

```dart
const Map<int, Map<String, dynamic>> pokemonGenerations = {
  1: {'name': 'Generación I - Kanto',     'start': 1,   'end': 151},
  2: {'name': 'Generación II - Johto',    'start': 152, 'end': 251},
  3: {'name': 'Generación III - Hoenn',   'start': 252, 'end': 386},
  4: {'name': 'Generación IV - Sinnoh',   'start': 387, 'end': 493},
  5: {'name': 'Generación V - Unova',     'start': 494, 'end': 649},
  6: {'name': 'Generación VI - Kalos',    'start': 650, 'end': 721},
  7: {'name': 'Generación VII - Alola',   'start': 722, 'end': 809},
  8: {'name': 'Generación VIII - Galar',  'start': 810, 'end': 905},
  9: {'name': 'Generación IX - Paldea',   'start': 906, 'end': 1025},
};
```

---

## 9. Dependencias principales (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.6
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  http: ^1.2.0
  cached_network_image: ^3.3.0

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.0
```

---

## 10. Reglas para el LLM

> **IMPORTANTE**: Cualquier modelo de lenguaje que trabaje con este proyecto DEBE seguir estas reglas al generar código.

1. **Respetar la estructura de 3 archivos por pantalla** (`*_screen.dart`, `*_widgets.dart`, `*_service.dart`). Nunca mezclar responsabilidades entre ellos.
2. **Toda la lógica de negocio, acceso a datos Y funciones auxiliares** (handlers, formateo, filtrado) va en `*_service.dart` como `GetxController`.
3. **`*_widgets.dart`** contiene widgets extraídos y reutilizables. Reciben datos por parámetro; no instancian controllers directamente.
4. **`*_screen.dart`** solo compone layout usando widgets de `*_widgets.dart` y accede al service con `Get.find()`. Aquí se hace `Get.put()` del service correspondiente.
5. **Usar GetX** para estado reactivo: variables `.obs`, widgets `Obx()`, navegación con `Get.toNamed()`.
6. **Usar Hive** para persistencia local con modelos tipados y adapters generados con `build_runner`.
7. **Sprites**: usar `cached_network_image` para cachear las imágenes de la PokeAPI.
8. **No usar paquetes no listados** en la sección de dependencias sin confirmación explícita.
9. **Nomenclatura**: archivos en `snake_case`, clases en `PascalCase`, variables y funciones en `camelCase`.
10. **Cada archivo nuevo** debe incluir un comentario en la primera línea indicando su ruta relativa: `// lib/features/pokedex/pokedex_widgets.dart`.
11. **No generar código de un feature completo de una vez**. Ir archivo por archivo confirmando con el usuario antes de avanzar al siguiente.
12. **Tema**: respetar la paleta de colores definida en la sección 3. No inventar colores fuera de la paleta. Usar siempre los tokens del `ThemeData` en lugar de colores hardcodeados en widgets.
13. **Modo oscuro**: todo widget debe adaptarse automáticamente al tema activo a través de `Theme.of(context)`. Nunca usar colores directos.
