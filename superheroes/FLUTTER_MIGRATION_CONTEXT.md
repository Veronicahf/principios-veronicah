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

### 3. REACCIONES (GET: público | POST: requiere token)

#### GET /api/reactions
- **Descripción**: Obtener lista de reacciones disponibles
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
  },
  {
    "id": 3,
    "description": "REACTION_HATE"
  },
  {
    "id": 4,
    "description": "REACTION_SAD"
  },
  {
    "id": 5,
    "description": "REACTION_ANGRY"
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
- **Response** (200 OK): Retorna objeto SuperheroeReaction con datos anidados

#### DELETE /api/reactions/{reactionId}
- **Descripción**: Eliminar una reacción
- **Autenticación**: **REQUIERE JWT token en header**
```
Authorization: Bearer {accessToken}
```
- **Response** (200 OK): Confirmación de eliminación

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
  int id;
  String nombre;
  String habilidades;
  String debilidades;
  String enemigos;
  String urlPhoto;
  User postedBy;
  List<SuperheroeReaction> likes;
}

class SuperheroeReaction {
  int id;
  int reactionId;
  Reaction reaction;
  int superheroeId;
}

class Reaction {
  int id;
  String description;  // "REACTION_LIKE", "REACTION_LOVE", etc.
}
```

### 2. **Servicios API (ApiService)**
**Cambios en URLs:**
- `POST /api/tweets` → `POST /api/superheroes`
- `GET /api/tweets` → `GET /api/superheroes`
- `DELETE /api/tweets/{id}` → `DELETE /api/superheroes/{id}`
- `POST /api/tweet-reactions` → `POST /api/reactions/create`
- Agregar: `GET /api/reactions` (para cargar lista de reacciones disponibles)

**Cambios en Request/Response Bodies:**
- Reemplazo de campo `content` con 5 campos: nombre, habilidades, debilidades, enemigos, urlPhoto
- `tweetId` → `superheroeId` en requests de reacción

### 3. **Pantallas (UI)**
- **CreateTweetScreen** → **CreateSuperheroeScreen**
  - 1 TextField (content) → 5 TextFields (nombre, habilidades, debilidades, enemigos, URL foto)
  - Validación más compleja (5 campos vs 1)

- **TweetListScreen** → **SuperheroeListScreen**
  - Mostrar 5 campos en lugar de texto simple
  - Imagen del superhéroe desde URL
  - Mismo sistema de reacciones/likes

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
```

---

## Notas Importantes

1. ✅ La API en Render está en producción y lista
2. ✅ Todos los endpoints funcionan correctamente
3. ✅ Requiere JWT token para POST/DELETE
4. ✅ GET es público (no requiere token)
5. ⚠️ Token expira en 24 horas (86400000 ms)
6. ⚠️ Manejar excepciones de red (Render puede estar en "cold start")
