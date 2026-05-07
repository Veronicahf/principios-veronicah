# 🏗️ Arquitectura Técnica - Superheroes App

## 📐 Diagrama General

```
┌─────────────────────────────────────────────────────────────────┐
│                    FLUTTER CLIENT (Android/iOS)                  │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐                                                 │
│  │ UI Layer    │ - SuperHeroCard (HomePage)                      │
│  │ (main.dart) │ - LoginPage, SignupPage, CreateHeroPage        │
│  └──────┬──────┘                                                 │
│         ↓                                                         │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │ Services Layer (HTTP Clients)                               │ │
│  ├─────────────────────────────────────────────────────────────┤ │
│  │ • AuthService         - Handle auth & JWT tokens            │ │
│  │ • ReactionService     - CRUD para reacciones                │ │
│  │ • CommentService      - CRUD para comentarios               │ │
│  └──────┬───────────────────────────────────────────────────────┘ │
│         ↓ (HTTP con JWT Bearer Token)                           │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │ Models Layer                                                │ │
│  ├─────────────────────────────────────────────────────────────┤ │
│  │ • User, Superheroe, Reaction                               │ │
│  │ • SuperheroeReaction, Comment                              │ │
│  └─────────────────────────────────────────────────────────────┘ │
└────────────────────────────┬───────────────────────────────────────┘
                             │ HTTPS
                             ↓
      ┌──────────────────────────────────────────────────┐
      │  SPRING BOOT BACKEND (Render)                    │
      │  https://superheroes-api-iy4v.onrender.com       │
      ├──────────────────────────────────────────────────┤
      │  ┌─────────────────────────────────────────────┐ │
      │  │ REST Controllers                            │ │
      │  ├─────────────────────────────────────────────┤ │
      │  │ • AuthController     → /api/auth/*          │ │
      │  │ • SuperheroeController → /api/superheroes   │ │
      │  │ • ReactionController → /api/reactions/*     │ │
      │  │ • CommentController  → /api/comments/*      │ │
      │  └──────────┬──────────────────────────────────┘ │
      │             ↓                                    │
      │  ┌─────────────────────────────────────────────┐ │
      │  │ Service Layer (Business Logic)              │ │
      │  ├─────────────────────────────────────────────┤ │
      │  │ • AuthService, JwtUtils                     │ │
      │  │ • SuperheroeService                         │ │
      │  │ • ReactionService (upsert pattern)          │ │
      │  │ • CommentService                            │ │
      │  └──────────┬──────────────────────────────────┘ │
      │             ↓                                    │
      │  ┌─────────────────────────────────────────────┐ │
      │  │ Repository Layer (JPA/Hibernate)            │ │
      │  ├─────────────────────────────────────────────┤ │
      │  │ • UserRepository                            │ │
      │  │ • SuperheroeRepository                      │ │
      │  │ • ReactionRepository                        │ │
      │  │ • CommentRepository                         │ │
      │  └──────────┬──────────────────────────────────┘ │
      │             ↓                                    │
      │  ┌─────────────────────────────────────────────┐ │
      │  │ Entities (Domain Models)                    │ │
      │  ├─────────────────────────────────────────────┤ │
      │  │ • User, Role                                │ │
      │  │ • Superheroe (nueva estructura)             │ │
      │  │ • Reaction (tipos de reacciones)            │ │
      │  │ • SuperheroeReaction (relación M2M)         │ │
      │  │ • Comment                                   │ │
      │  └─────────────────────────────────────────────┘ │
      └────────────────────┬────────────────────────────┘
                           │ JDBC
                           ↓
      ┌──────────────────────────────────────────────────┐
      │  PostgreSQL (Aiven)                              │
      │  Database: superheroes_db                        │
      ├──────────────────────────────────────────────────┤
      │ Tables:                                          │
      │ • users                                          │
      │ • roles                                          │
      │ • user_roles (M2M)                               │
      │ • superheroes                                    │
      │ • reactions (LIKE, LOVE, HATE, SAD, ANGRY)       │
      │ • superheroe_reactions (M2M)                     │
      │ • comments                                       │
      └──────────────────────────────────────────────────┘
```

---

## 🔄 Flujo de Datos

### 1. **Reaccionar a un Superhéroe**

```
Flutter:
  SuperHeroCard → Click "Reaccionar"
  ↓
  _showReactionSelector() abre Dialog
  ↓
  Usuario selecciona emoji (ej. 👍)
  ↓
  ReactionService.createOrUpdateReaction(superheroeId, reactionId)
  ↓
  POST /api/reactions/create con JWT token
  
Backend:
  ReactionController.create()
  ↓
  ReactionService.findByUserIdAndSuperheroeId()
    → Si existe: UPDATE (upsert pattern)
    → Si no existe: INSERT
  ↓
  SuperheroeReactionRepository.save()
  ↓
  PostgreSQL INSERT/UPDATE en superheroe_reactions

Flutter (Response):
  FutureBuilder actualiza _interactionFuture
  ↓
  SuperHeroCard rebuilds
  ↓
  Barra de reacciones se actualiza con new emoji
```

### 2. **Ver Quién Reaccionó**

```
Flutter:
  SuperHeroCard → Click en chip de reacción (👍 2)
  ↓
  _showReactionsModal() abre BottomSheet con TabBar
  ↓
  ReactionService.fetchReactionsBySuperheroe(superheroeId)
  ↓
  GET /api/reactions/superheroe/{id}

Backend:
  ReactionController.getReactionsBySuperheroe()
  ↓
  SuperheroeReactionRepository.findBySuperheroeId()
  ↓
  PostgreSQL SELECT de superheroe_reactions con users (JOIN)
  
Response:
  [
    { id: 1, userId: 1, reactionId: 1, user: {username: "vero"}, 
      reaction: {id: 1, description: "REACTION_LIKE", emoji: "👍"} },
    ...
  ]

Flutter:
  TabBar muestra { emoji: "👍", count: 2 }
  ↓
  Tab content filtra reacciones por tipo
  ↓
  Muestra ListView de usuarios
```

### 3. **Comentar**

```
Flutter:
  SuperHeroCard → Click "Comentarios 3"
  ↓
  _openCommentsSheet() abre BottomSheet
  ↓
  CommentService.fetchCommentsBySuperheroe(superheroeId)
  ↓
  GET /api/comments/superheroe/{id}

Backend:
  CommentController.getCommentsBySuperheroe()
  ↓
  CommentRepository.findBySuperheroeId(sorted by createdAt DESC)
  ↓
  PostgreSQL SELECT con user JOIN
  
Response:
  [
    { id: 1, content: "¡Genial!", createdAt: "2024-02-14T10:00:00", 
      user: {id: 1, username: "vero"} },
    ...
  ]

Flutter:
  Muestra lista con ListView.builder
  ↓
  Usuario escribe comentario
  ↓
  CommentService.createComment(superheroeId, content)
  ↓
  POST /api/comments/create

Backend:
  CommentController.create()
  ↓
  CommentService.saveComment()
  ↓
  CommentRepository.save()
  ↓
  PostgreSQL INSERT en comments

Response:
  { message: "Comentario creado exitosamente!" }

Flutter:
  BottomSheet cierra
  ↓
  HomePage se recarga
  ↓
  SuperHeroCard se actualiza
  ↓
  Nuevo comentario aparece en lista
```

---

## 🔐 Autenticación y Autorización

### JWT Token Flow

```
1. SIGNUP
   POST /api/auth/signup
   → Backend crea User en BD
   → Response: { message: "User registered successfully!" }

2. SIGNIN
   POST /api/auth/signin
   → Backend valida credenciales
   → Genera JWT token (24h expiration)
   → Response: { 
       id, username, email,
       accessToken: "eyJhbGciOiJIUzI1NiJ9...",
       roles: ["ROLE_USER"]
     }

3. AUTHENTICATED REQUEST
   GET/POST con header:
   Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
   
   Backend:
   AuthTokenFilter intercepta request
   ↓
   JwtUtils.validateJwtToken()
   ↓
   Si válido: UserDetailsServiceImpl.loadUserByUsername()
   ↓ 
   Si inválido: AuthEntryPointJwt.commence() → 401
```

### Permisos por Endpoint

| Endpoint | Auth | Descripción |
|----------|------|-------------|
| POST /auth/signup | ❌ | Cualquiera |
| POST /auth/signin | ❌ | Cualquiera |
| GET /superheroes | ❌ | Público |
| POST /superheroes | ✅ | Solo autenticado |
| DELETE /superheroes/{id} | ✅ | Creator o ADMIN |
| GET /reactions | ❌ | Público |
| POST /reactions/create | ✅ | Solo autenticado |
| DELETE /reactions/{id} | ✅ | Creator |
| POST /comments/create | ✅ | Solo autenticado |
| GET /comments/* | ❌ | Público |

---

## 📊 Modelos de Datos (Actualizado)

### User
```json
{
  "id": 1,
  "username": "vero",
  "email": "vero@example.com",
  "password": "hashed_password",
  "roles": ["ROLE_USER"],
  "superheroes": [...],
  "reactions": [...],
  "comments": [...]
}
```

### Superheroe (ACTUALIZADO)
```json
{
  "id": 1,
  "nombre": "Super Vero",
  "habilidades": "Vuelo, fuerza",
  "debilidades": "Kryptonita",
  "enemigos": "Dr. Bug",
  "urlPhoto": "https://example.com/image.png",
  "postedBy": { "id": 1, "username": "vero" },
  "likes": [...reactions...],
  "comments": [...comments...]
}
```

### Reaction
```json
{
  "id": 1,
  "description": "REACTION_LIKE",
  "emoji": "👍"
}
```

### SuperheroeReaction
```json
{
  "id": 1,
  "user": { "id": 1, "username": "vero" },
  "superheroe": { "id": 1, "nombre": "Super Vero" },
  "reaction": { "id": 1, "description": "REACTION_LIKE", "emoji": "👍" }
}
```

### Comment
```json
{
  "id": 1,
  "content": "¡Este es un gran superhéroe!",
  "createdAt": "2024-02-14T10:00:00",
  "user": { "id": 1, "username": "vero" },
  "superheroe": { "id": 1, "nombre": "Super Vero" }
}
```

---

## 🎯 Patrones de Diseño Utilizados

### 1. **Repository Pattern**
```dart
abstract class IReactionRepository {
  Future<List<Reaction>> fetchAvailableReactions();
  Future<List<SuperheroeReaction>> fetchReactionsBySuperheroe(int id);
}

class ReactionService implements IReactionRepository {
  // Implementación
}
```

### 2. **Service Layer Pattern**
```dart
class ReactionService {
  Future<SuperheroeReaction> createOrUpdateReaction(
    int superheroeId, int reactionId
  ) async {
    // Lógica de negocio
  }
}
```

### 3. **Upsert Pattern (Backend)**
```java
@PostMapping("/create")
public ResponseEntity<?> create(@RequestBody SuperheroeReactionRequest request) {
    Optional<SuperheroeReaction> existing = 
        reactionRepo.findByUserIdAndSuperheroeId(userId, superheroeId);
    
    if (existing.isPresent()) {
        // UPDATE: cambiar reacción existente
        existing.get().setReaction(reaction);
        return reactionRepo.save(existing.get());
    } else {
        // INSERT: nueva reacción
        SuperheroeReaction newReaction = new SuperheroeReaction(user, superhero, reaction);
        return reactionRepo.save(newReaction);
    }
}
```

### 4. **FutureBuilder Pattern (Flutter)**
```dart
FutureBuilder<_HeroInteractionData>(
  future: _interactionFuture,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      final data = snapshot.data;
      // Renderizar con datos
    }
    return CircularProgressIndicator();
  }
)
```

---

## 📈 Performance Considerations

### Backend
- ✅ **Índices**: `superheroe_reactions(user_id, superheroe_id)` unique
- ✅ **Lazy Loading**: JPA con `@OneToMany(fetch = FetchType.LAZY)`
- ⚠️ **Pagination**: GET /superheroes podría implementar pagination si hay muchos

### Frontend
- ✅ **Lazy Loading**: Reacciones y comentarios cargan solo cuando se necesitan
- ✅ **Caching**: AuthService guarda usuario en memoria
- ⚠️ **Network**: Maneja timeouts y retry logic

---

## 🚀 Stack Tecnológico

| Capa | Tecnología | Versión |
|------|-----------|---------|
| Frontend | Flutter | 3.x |
| Front Lang | Dart | 3.0+ |
| Backend | Spring Boot | 4.0.4 |
| Backend Lang | Java | 21 |
| ORM | Hibernate/JPA | Jakarta |
| Database | PostgreSQL | 14+ |
| DB Hosting | Aiven | - |
| App Hosting | Render | - |
| HTTP | HTTP/HTTPS | 1.1 |
| Auth | JWT | HS256 |
| API Style | REST | - |

---

**Última actualización**: Febrero 2024
**Versión**: 2.0
**Arquitecto**: Veronicah Team
