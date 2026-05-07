# 🚀 Guía de Implementación - Superheroes App (Facebook-Style UI)

## 📋 Requisitos Previos

- ✅ Backend ejecutándose en https://superheroes-api-iy4v.onrender.com
- ✅ Base de datos PostgreSQL en Aiven configurada
- ✅ Flutter 3.x instalado en tu máquina
- ✅ Dart 3.0+ 
- ✅ Visual Studio Code o Android Studio
- ✅ Emulador o dispositivo físico para testing

---

## ⚙️ Pasos de Configuración

### 1. **Preparar la Base de Datos (Aiven)**

#### a) Conectarse a Aiven
```bash
# En Aiven Dashboard
# 1. Ir a tu servicio PostgreSQL
# 2. Copiar la connection string
# 3. Conectarse con pgAdmin o DBeaver
```

#### b) Ejecutar SQL de Inicialización
```sql
-- Ejecutar en Aiven PostgreSQL
-- Archivo: init_reactions.sql

INSERT INTO reactions (id, description) VALUES
(1, 'REACTION_LIKE'),
(2, 'REACTION_LOVE'),
(3, 'REACTION_HATE'),
(4, 'REACTION_SAD'),
(5, 'REACTION_ANGRY')
ON CONFLICT (id) DO NOTHING;

-- Verificar
SELECT * FROM reactions;
```

✅ **Resultado esperado**: 5 filas con las reacciones disponibles

---

### 2. **Configurar Flutter App**

#### a) Clonar o actualizar repositorio
```bash
cd ~/Documentos/copia/superheroesproject
flutter pub get
flutter pub upgrade
```

#### b) Limpiar build
```bash
flutter clean
flutter pub get
```

#### c) Analizar proyecto
```bash
flutter analyze
```

✅ **Resultado esperado**: Sin errores (solo warnings de estilo opcionalmente)

---

### 3. **Testing Local**

#### a) Con emulador Android
```bash
# Iniciar emulador
emulator -avd Pixel_4_API_30

# O usar dispositivo físico conectado
adb devices

# Correr app
flutter run
```

#### b) Con iOS (Mac)
```bash
flutter run -d "iPhone 14"
```

#### c) Acciones a probar en la app
1. ✅ **Signup/Login**: Registrarse y loguearse
2. ✅ **Ver superhéroes**: La lista debe cargar desde API
3. ✅ **Crear superhéroe**: Llenar formulario y crear uno nuevo
4. ✅ **Reaccionar**: Click "Reaccionar" → Selector de emojis → Click emoji
5. ✅ **Ver reacciones**: Click en barra de reacciones → Modal con tabs
6. ✅ **Comentar**: Click botón comentarios → Escribir y publicar
7. ✅ **Cambiar reacción**: Click emoji del usuario → Selector → Nuevo emoji
8. ✅ **Ver historial**: Los comentarios y reacciones deben persistir

---

## 📊 Componentes Principales

### Backend (Spring Boot)
```
Endpoints Principales:
├── Authentication
│   ├── POST /api/auth/signup
│   └── POST /api/auth/signin
├── Superheroes  
│   ├── GET /api/superheroes
│   ├── POST /api/superheroes
│   └── DELETE /api/superheroes/{id}
├── Reactions
│   ├── GET /api/reactions
│   ├── POST /api/reactions/create
│   ├── GET /api/reactions/superheroe/{id}
│   ├── GET /api/reactions/superheroe/{id}/count
│   ├── GET /api/reactions/superheroe/{id}/count/{reactionId}
│   └── DELETE /api/reactions/{id}
└── Comments
    ├── POST /api/comments/create
    ├── GET /api/comments/superheroe/{id}
    └── GET /api/comments/superheroe/{id}/count
```

### Frontend (Flutter)
```
Estructura:
lib/
├── main.dart
│   ├── HomePage (lista de superhéroes)
│   ├── SuperHeroCard (tarjeta individual con UI Facebook)
│   ├── LoginPage
│   ├── SignupPage
│   └── CreateHeroPage
├── models/
│   ├── user.dart
│   ├── superheroe.dart
│   ├── reaction.dart
│   ├── superheroe_reaction.dart
│   └── comment.dart
├── services/
│   ├── auth_service.dart
│   ├── reaction_service.dart
│   └── comment_service.dart
└── repositories/
    ├── superhero_repository.dart
    ├── reaction_repository.dart
    └── comment_repository.dart
```

---

## 🎨 Flujo de Usuario (New UI)

### Flujo 1: Reaccionar a un Superhéroe
```
Usuario ve tarjeta
    ↓
Click "Reaccionar"
    ↓
Dialog con 5 emojis grandes (👍 ❤️ 😠 😢 🔥)
    ↓
Click emoji deseado
    ↓
Reacción se envía a API
    ↓
Actualiza barra de reacciones (👍 2 | ❤️ 1)
    ↓
Botón cambia a "Cambiar" + muestra emoji del usuario
```

### Flujo 2: Ver Quién Reaccionó
```
Usuario ve barra de reacciones (👍 2 | ❤️ 1)
    ↓
Click en cualquier chip (ej. 👍 2)
    ↓
BottomSheet con TabBar (🎯: 👍 2, ❤️ 1, etc.)
    ↓
Tab activo muestra lista de usuarios
    ↓
Swipe para cambiar entre tabs
    ↓
Close o click afuera para cerrar
```

### Flujo 3: Comentar
```
Usuario click botón "Comentarios 3"
    ↓
BottomSheet con lista de comentarios
    ↓
Scroll para ver todos los comentarios
    ↓
TextField: escribir comentario
    ↓
Click "Publicar"
    ↓
Comentario se agrega a lista y API
    ↓
Contador de botón se incrementa
```

---

## 🔒 Autenticación y Tokens

### Token JWT
```dart
// Login response
{
  "id": 1,
  "username": "vero",
  "email": "vero@example.com",
  "accessToken": "eyJhbGciOiJIUzI1NiJ9...",
  "roles": ["ROLE_USER"]
}

// Usar en requests
headers: {
  "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9..."
}
```

### Expiración
- ⏰ Token expira en 24 horas
- 🔄 Al expirar, se cierra sesión y redirige a login
- 📱 Flutter maneja automáticamente esto en AuthService

---

## 🐛 Troubleshooting

### Error: "API no responde"
```
1. Verificar que Render está en línea: https://superheroes-api-iy4v.onrender.com/api/reactions
2. Esperara 30 segundos (posible cold start)
3. Revisar consola de Render para errores
```

### Error: "Reacción no se guarda"
```
1. Verificar que init_reactions.sql se ejecutó
2. Confirmar en pgAdmin que reactions table tiene 5 filas
3. Revisar token JWT en AuthService.dart
```

### Error: "Comentarios no aparecen"
```
1. Verificar endpoint GET /api/comments/superheroe/{id} en Postman
2. Confirmar que superheroe y usuario están relacionados
3. Check si base de datos tiene tabla comments creada
```

### Flutter: "flutter analyze" muestra warnings
```
1. Warnings de "unused_element" son seguros (métodos internos)
2. Si hay "error", revisar sintaxis en main.dart
3. flutter clean && flutter pub get para resetear
```

---

## 📝 Códigos de Respuesta de API

| Código | Significado |
|--------|------------|
| 200 | OK - Éxito |
| 201 | Created - Recurso creado |
| 400 | Bad Request - Datos inválidos |
| 401 | Unauthorized - Token inválido/expirado |
| 403 | Forbidden - Permisos insuficientes |
| 404 | Not Found - Recurso no existe |
| 500 | Server Error - Error interno |
| 503 | Service Unavailable - Render en cold start |

---

## 📚 Recursos Adicionales

- **Documentación Flutter**: https://flutter.dev/docs
- **Documentación Spring Boot**: https://spring.io/projects/spring-boot
- **PostgreSQL Aiven**: https://aiven.io/postgresql
- **Postman Collection**: Ver archivo `superheroes-api.postman_collection.json`

---

## ✅ Checklist Final de Deployment

- [ ] Base de datos PostgreSQL en Aiven conectada y probada
- [ ] SQL de reacciones insertado (`init_reactions.sql`)
- [ ] Backend Spring Boot en Render funcionando
- [ ] Flutter project clonado y dependencies instaladas
- [ ] `flutter analyze` sin errores
- [ ] App corriendo en emulador/dispositivo
- [ ] Login funciona correctamente
- [ ] Puede crear superhéroes
- [ ] Puede reaccionar con emojis
- [ ] Puede ver quién reaccionó
- [ ] Puede comentar
- [ ] Cambiar reacción funciona
- [ ] Comentarios persisten

---

**Última actualización**: Febrero 2024
**Versión**: 2.0 (Con UI tipo Facebook)
**Equipo**: Frontend (Flutter) + Backend (Spring Boot) + DB (PostgreSQL Aiven)
