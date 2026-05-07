# Contexto API Superheroes - Migración Flutter

## URL Base de la API (En Producción)
```
https://superheroes-api-iy4v.onrender.com
```

## Descripción General
La API de Superheroes es una aplicación Spring Boot 4.0.4 con Java 21 que gestiona:
- **Autenticación**: Registro y login de usuarios con JWT
- **Centro**: Gestión de superhéroes creados por usuarios
- **Reacciones**: Usuarios pueden reaccionar (like, love, hate, sad, angry) a los superhéroes

**Cambio Principal vs Tweets**: 
- Antes era `Tweet` (un campo de texto)
- Ahora es `Superheroe` (5 campos: nombre, habilidades, debilidades, enemigos, urlPhoto)

---

## Endpoints de la API

### 1. AUTENTICACIÓN (Sin requiere token)

#### POST /api/auth/signup
- **Descripción**: Registrar nuevo usuario
- **Autenticación**: NO requiere token
- **Request Body**:
```json
{
  "username": "string",
  "email": "string",
  "password": "string"
}
```
- **Response** (200 OK):
```json
{
  "message": "User registered successfully!"
}
```

#### POST /api/auth/signin
- **Descripción**: Obtener JWT token
- **Autenticación**: NO requiere token
- **Request Body**:
```json
{
  "username": "string",
  "password": "string"
}
```
- **Response** (200 OK):
```json
{
  "id": 1,
  "username": "string",
  "email": "string",
  "accessToken": "eyJhbGciOiJIUzI1NiJ9...",
  "roles": ["ROLE_USER"]
}
```
- **Important**: Guardar `accessToken` para usar en requests autenticados

---

### 2. SUPERHÉROES (GET: público | POST/DELETE: requiere token)

#### GET /api/superheroes
- **Descripción**: Obtener lista de todos los superhéroes
- **Autenticación**: NO requiere token
- **Query Parameters**: Ninguno (retorna todos)
- **Response** (200 OK):
```json
[
  {
    "id": 1,
    "nombre": "Super Vero",
    "habilidades": "Vuelo, fuerza y visión láser",
    "debilidades": "Kryptonita, cafe frío",
    "enemigos": "Dr. Bug",
    "urlPhoto": "https://example.com/supervero.png",
    "postedBy": {
      "username": "vero",
      "email": "vero@test.com"
    },
    "likes": [
      {
        "id": 1,
        "reactionId": 1,
        "reaction": {
          "id": 1,
          "description": "REACTION_LIKE"
        }
      }
    ]
  }
]
```

#### POST /api/superheroes
- **Descripción**: Crear nuevo superhéroe (usuario autenticado)
- **Autenticación**: **REQUIERE JWT token en header**
```
Authorization: Bearer {accessToken}
```
- **Request Body**:
```json
{
  "nombre": "string",
  "habilidades": "string",
  "debilidades": "string",
  "enemigos": "string",
  "urlPhoto": "string"
}
```
- **Response** (200 OK): Retorna el superhéroe creado con id, postedBy y likes

#### DELETE /api/superheroes/{id}
- **Descripción**: Eliminar superhéroe (solo si eres el creador)
- **Autenticación**: **REQUIERE JWT token en header**
```
Authorization: Bearer {accessToken}
```
- **Response** (200 OK): `{"message": "Superhero deleted successfully"}`

---

### 3. REACCIONES (GET: público | POST/DELETE: requiere token)

#### GET /api/reactions
- **Descripción**: Obtener lista de tipos de reacciones disponibles (LIKE, LOVE, etc.)
- **Autenticación**: NO requiere token
- **Response** (200 OK):
```json
[
  {
    "id": 1,
    "description": "REACTION_LIKE"
  },
  {
    "id": 2,
    "description": "REACTION_LOVE"
  }
]
```

#### POST /api/reactions/create
- **Descripción**: Crear una reacción a un superhéroe
- **Autenticación**: **REQUIERE JWT token en header**
```
Authorization: Bearer {accessToken}
```
- **Request Body**:
```json
{
  "superheroeId": 1,
  "reactionId": 1
}
```
- **Response** (200 OK): Retorna objeto `SuperheroeReaction` con datos anidados

#### GET /api/reactions/superheroe/{superheroeId}
- **Descripción**: Obtener la lista de reacciones de un superhéroe específico (para saber quiénes reaccionaron)
- **Autenticación**: NO requiere token
- **Response** (200 OK):
```json
[
    {
        "id": 1,
        "user": { "id": 1, "username": "vero" },
        "reaction": { "id": 1, "description": "REACTION_LIKE" }
    }
]
```

#### GET /api/reactions/superheroe/{superheroeId}/count
- **Descripción**: Contar el número total de reacciones de un superhéroe
- **Autenticación**: NO requiere token
- **Response** (200 OK): `25` (un número)

#### GET /api/reactions/superheroe/{superheroeId}/count/{reactionId}
- **Descripción**: Contar cuántas reacciones de un tipo específico tiene un superhéroe (ej. cuántos "likes")
- **Autenticación**: NO requiere token
- **Response** (200 OK): `10` (un número)

#### DELETE /api/reactions/{reactionId}
- **Descripción**: Eliminar una reacción que creaste
- **Autenticación**: **REQUIERE JWT token en header**
- **Response** (200 OK): Confirmación de eliminación

---

### 4. COMENTARIOS (GET: público | POST: requiere token)

#### POST /api/comments/create
- **Descripción**: Crear un nuevo comentario en un superhéroe
- **Autenticación**: **REQUIERE JWT token en header**
- **Request Body**:
```json
{
  "superheroeId": 1,
  "content": "¡Este es un gran superhéroe!"
}
```
- **Response** (200 OK): `{"message": "Comentario creado exitosamente!"}`

#### GET /api/comments/superheroe/{superheroeId}
- **Descripción**: Obtener la lista de comentarios de un superhéroe
- **Autenticación**: NO requiere token
- **Response** (200 OK):
```json
[
    {
        "id": 1,
        "content": "¡Este es un gran superhéroe!",
        "createdAt": "2023-05-20T10:00:00",
        "user": { "id": 1, "username": "vero" }
    }
]
```

#### GET /api/comments/superheroe/{superheroeId}/count
- **Descripción**: Contar el número total de comentarios de un superhéroe
- **Autenticación**: NO requiere token
- **Response** (200 OK): `15` (un número)

---

## Cambios Necesarios en Flutter

### 1. **Modelos (Models)**
**De:**
```dart
class Tweet {
  String content;  // Campo único
}
```

**A:**
```dart
class Superheroe {
//... (sin cambios aquí)
}

class SuperheroeReaction {
//... (sin cambios aquí)
}

class Reaction {
//... (sin cambios aquí)
}

// NUEVO MODELO
class Comment {
  int id;
  String content;
  DateTime createdAt;
  User user;
}
```

### 2. **Servicios API (ApiService)**
**Cambios en URLs:**
- `POST /api/tweets` → `POST /api/superheroes`
- `GET /api/tweets` → `GET /api/superheroes`
- `DELETE /api/tweets/{id}` → `DELETE /api/superheroes/{id}`
- `POST /api/tweet-reactions` → `POST /api/reactions/create`
- Agregar: `GET /api/reactions` (para cargar lista de reacciones disponibles)
- **NUEVO**: Endpoints de comentarios (`/api/comments/...`)
- **NUEVO**: Endpoints de conteo y listado de reacciones (`/api/reactions/superheroe/...`)

**Cambios en Request/Response Bodies:**
- Reemplazo de campo `content` con 5 campos: nombre, habilidades, debilidades, enemigos, urlPhoto
- `tweetId` → `superheroeId` en requests de reacción
- **NUEVO**: Body para crear comentarios

### 3. **Pantallas (UI)**
- **CreateTweetScreen** → **CreateSuperheroeScreen**
  - 1 TextField (content) → 5 TextFields (nombre, habilidades, debilidades, enemigos, URL foto)
  - Validación más compleja (5 campos vs 1)

- **TweetListScreen** → **SuperheroeListScreen**
  - Mostrar 5 campos en lugar de texto simple
  - Imagen del superhéroe desde URL
  - Mismo sistema de reacciones/likes
  - **NUEVO**: Sección para mostrar comentarios y su conteo

- **ReactionSelector** 
  - Cargar dinámicamente desde GET /api/reactions
  - Mostrar los 5 tipos: Like, Love, Hate, Sad, Angry

### 4. **Flujo de Autenticación (Sin cambios)**
- Login/Register: Mismo
- Guardar token: Mismo
- Usa token en Authorization header: Mismo
- Refresh token: Mismo

---

## Resumen de Cambios Clave

| Aspecto | Tweets | Superheroes |
|---------|--------|-------------|
| **Campos principales** | content (1) | nombre, habilidades, debilidades, enemigos, urlPhoto (5) |
| **Endpoint de crear** | POST /api/tweets | POST /api/superheroes |
| **Endpoint de listar** | GET /api/tweets | GET /api/superheroes |
| **Endpoint de eliminar** | DELETE /api/tweets/{id} | DELETE /api/superheroes/{id} |
| **ID en reacciones** | tweetId | superheroeId |
| **Endpoint reacciones** | /api/tweet-reactions | /api/reactions/create |
| **NUEVO: Comentarios** | No existía | POST /api/comments/create, GET /api/comments/superheroe/{id} |
| **Autenticación** | JWT Bearer token | JWT Bearer token (sin cambios) |

---

## Ejemplo Completo: Crear Superhéroe desde Flutter

```dart
// 1. Obtener token del login
final response = await http.post(
  Uri.parse('https://superheroes-api-iy4v.onrender.com/api/auth/signin'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({'username': 'vero', 'password': '123456'}),
);
final token = jsonDecode(response.body)['accessToken'];

// 2. Crear superhéroe con el token
final superheroeResponse = await http.post(
  Uri.parse('https://superheroes-api-iy4v.onrender.com/api/superheroes'),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  },
  body: jsonEncode({
    'nombre': 'Flash',
    'habilidades': 'Velocidad sobrehumana',
    'debilidades': 'Cansancio',
    'enemigos': 'Captain Cold',
    'urlPhoto': 'https://example.com/flash.png',
  }),
);

// 3. (NUEVO) Crear un comentario
final commentResponse = await http.post(
  Uri.parse('https://superheroes-api-iy4v.onrender.com/api/comments/create'),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  },
  body: jsonEncode({
    'superheroeId': 1, // ID del superhéroe creado
    'content': '¡El más rápido!'
  }),
);
```

---

## Pruebas Rápidas con cURL

```bash
# Obtener token
TOKEN=$(curl -s -X POST https://superheroes-api-iy4v.onrender.com/api/auth/signin \
  -H 'Content-Type: application/json' \
  -d '{"username":"vero","password":"123456"}' | jq -r '.accessToken')

# Crear superhéroe
curl -X POST https://superheroes-api-iy4v.onrender.com/api/superheroes \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{
    "nombre":"Flash",
    "habilidades":"Velocidad",
    "debilidades":"Cansancio",
    "enemigos":"Captain Cold",
    "urlPhoto":"https://example.com/flash.png"
  }'

# Obtener superhéroes
curl https://superheroes-api-iy4v.onrender.com/api/superheroes

# (NUEVO) Crear un comentario en el superhéroe con ID 1
curl -X POST https://superheroes-api-iy4v.onrender.com/api/comments/create \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{"superheroeId":1, "content":"¡Mi favorito!"}'

# (NUEVO) Obtener comentarios del superhéroe con ID 1
curl https://superheroes-api-iy4v.onrender.com/api/comments/superheroe/1
```

---

## UI Tipo Facebook - Cambios Recientes (Febrero 2024)

La interfaz de usuario de Flutter se ha rediseñado para ser más similar a redes sociales tipo Facebook, con emojis y contadores interactivos.

### Cambios Principales

#### 1. **Selector de Reacciones con Emojis**
- **Antes**: Modal BottomSheet con ListTiles
- **Ahora**: Dialog con emojis grandes (32pt) dispuestos en grid
- **Emojis disponibles**:
  - 👍 = REACTION_LIKE
  - ❤️ = REACTION_LOVE
  - 😠 = REACTION_HATE
  - 😢 = REACTION_SAD
  - 🔥 = REACTION_ANGRY

#### 2. **Barra de Reacciones (Tipo Facebook)**
- Muestra cada tipo de reacción usado con emoji + contador
- Formato: `👍 5 | ❤️ 3 | 🔥 1`
- Clickeable para abrir modal con lista de quien reaccionó
- Scroll horizontal si hay muchas reacciones

#### 3. **Modal de Reacciones con Tabs**
- TabBar con pestañas por tipo de reacción: `👍 5`, `❤️ 3`, etc.
- Cada tab lista los usuarios que reaccionaron con ese emoji
- Swipe entre tabs para cambiar de tipo de reacción

#### 4. **Botones de Interacción Rediseñados**
- **Botón 1**: Reacción + contador total
  - Muestra emoji del usuario si ya reaccionó
  - Texto: "Reaccionar" o "Cambiar"
  - Click: abre selector de emojis
  
- **Botón 2**: Comentarios + contador
  - Muestra ícono de comentario
  - Número de comentarios disponibles
  - Click: abre modal con lista de comentarios

#### 5. **Modal de Comentarios Mejorado**
- Lista scrollable de comentarios con:
  - Avatar/nombre del autor
  - Fecha relativa ("Hace 5 min")
  - Contenido del comentario
- TextField para escribir nuevo comentario
- Botón "Publicar" con indicador de carga

### Archivos Modificados

- **`lib/main.dart`**: Actualización completa de SuperHeroCard widget
  - Nuevos métodos: `_showReactionSelector()`, `_showReactionsModal()`, `_openCommentsSheet()`, `_buildReactionBar()`, `_formatDate()`
  - Nuevos métodos auxiliares: `_authorLabel()`, `_isMine()`, `_canDeleteHero()`
  
- **`lib/models/reaction.dart`**: Propiedad `emoji` para emojis
  
### SQL Script de Inicialización

Se proporcionó `init_reactions.sql` para poblar la tabla de reacciones en Aiven:

```sql
INSERT INTO reactions (id, description) VALUES
(1, 'REACTION_LIKE'),
(2, 'REACTION_LOVE'),
(3, 'REACTION_HATE'),
(4, 'REACTION_SAD'),
(5, 'REACTION_ANGRY')
ON CONFLICT (id) DO NOTHING;
```

---

## Notas Importantes

1. ✅ La API en Render está en producción y lista
2. ✅ Todos los endpoints funcionan correctamente
3. ✅ Requiere JWT token para POST/DELETE
4. ✅ GET es público (no requiere token)
5. ⚠️ Token expira en 24 horas (86400000 ms)
6. ⚠️ Manejar excepciones de red (Render puede estar en "cold start")
7. ✅ UI tipo Facebook con emojis implementada y lista para usar
8. ⚠️ Ejecutar `init_reactions.sql` en Aiven para poblar tipos de reacciones iniciales
