# 🚀 Quick Start Guide - SuperHeroes Project (Refactorizado)

## 📌 ¿Qué Cambió?

### Antes (❌ Acoplado)
```dart
// Imports directos de servicios viejos
import 'services/auth_service.dart';
import 'services/superheroe_service.dart';
// ...
final authService = AuthService();
final heroService = SuperheroeService();
```

### Después (✅ Desacoplado)
```dart
// Import único del facade
import 'core/facades/app_coordinator.dart';
// ...
final coordinator = AppCoordinator();
await coordinator.login('user', 'pass');
final heroes = await coordinator.getAllSuperheroes();
```

---

## 🎯 Conceptos Clave

| Concepto | Qué es | Ubicación | Por qué |
|----------|--------|-----------|--------|
| **AppCoordinator** | Facade que unifica todos los servicios | `core/facades/` | Interfaz única y simple para UI |
| **Interfaces** | Contratos que definen comportamiento | `domain/services/` | Desacoplamiento total |
| **Implementaciones** | Código real que hace el trabajo | `data/services/` | Separado de la lógica |
| **Decorators** | Agregan funcionalidad sin modificar | `core/decorators/` | Logging y caché automático |
| **Factories** | Crean objetos de forma controlada | `core/factories/` | Parseo seguro y consistente |

---

## 📦 Usar en Screens/Widgets

### ✨ Patrón Estándar

```dart
import 'core/facades/app_coordinator.dart';

class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  final AppCoordinator _coordinator = AppCoordinator();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _coordinator.getAllSuperheroes(),
        builder: (context, snapshot) {
          // UI aquí
        },
      ),
    );
  }
}
```

---

## 🔧 Métodos Disponibles en AppCoordinator

### Autenticación
```dart
await coordinator.login(username, password);
await coordinator.register(username, email, password, roles);
await coordinator.logout();
bool autenticado = coordinator.isAuthenticated();
User? usuario = coordinator.getCurrentUser();
```

### Superhéroes
```dart
List<Superheroe> heroes = await coordinator.getAllSuperheroes();
await coordinator.createSuperheroe(superheroe);
await coordinator.deleteSuperheroe(heroId);
```

### Comentarios
```dart
List<Comment> comments = await coordinator.getCommentsForSuperheroe(heroId);
await coordinator.createComment(heroId, textContent);
await coordinator.deleteComment(commentId);
```

### Reacciones
```dart
List<Reaction> reactions = await coordinator.getAvailableReactions();
List<SuperheroeReaction> heroReactions = await coordinator.getReactionsForSuperheroe(heroId);
SuperheroeReaction? myReaction = await coordinator.getCurrentUserReaction(heroId);
await coordinator.addReaction(heroId, reactionId);
await coordinator.removeReaction(heroId);
```

---

## 📁 Dónde Encontrar Qué

| Necesito... | Ubicación |
|-------------|-----------|
| Modificar colores o tema | `lib/presentation/theme/app_theme.dart` |
| Agregar nuevo endpoint | `lib/data/services/` → `lib/domain/services/` |
| Cambiar URL API | `lib/core/constants/app_constants.dart` |
| Agregar nuevo screen | `lib/presentation/screens/` |
| Crear nuevo widget | `lib/presentation/widgets/` |
| Parsear nuevo modelo | `lib/core/factories/` |
| Entender un patrón | `DOCUMENTACION_PATRONES.md` |

---

## 🔍 Debug & Troubleshooting

### Error: "Undefined class AppCoordinator"
```dart
// ❌ INCORRECTO
import 'facades/app_coordinator.dart';

// ✅ CORRECTO
import 'core/facades/app_coordinator.dart';
```

### Error: "Cannot import from old paths"
```dart
// ❌ INCORRECTO (borrados)
import 'models/superheroe.dart';
import 'services/auth_service.dart';

// ✅ CORRECTO (nuevas ubicaciones)
import 'domain/models/superheroe.dart';
import 'core/facades/app_coordinator.dart';
```

### API Response no parsea correctamente
→ Revisar `lib/core/factories/` para agregar nuevo factory method

### Necesito agregar logging
→ Usar `LoggingDecorator.executeWithLogging()` en AppCoordinator

### Necesito cacheo automático
→ Usar `CacheDecorator.executeWithCache()` en AppCoordinator

---

## 🎓 Aprender Arquitectura

```
Lectura Recomendada (en orden):
1. lib/main.dart                    → Punto de entrada
2. lib/core/facades/app_coordinator.dart → Interfaz principal
3. lib/core/constants/app_constants.dart → Configuración
4. lib/presentation/screens/        → Cómo usar AppCoordinator
5. DOCUMENTACION_PATRONES.md        → Entender cada patrón
```

---

## ✅ Checklist para Nuevos Desarrolladores

- [ ] Leí README.md
- [ ] Leí RESUMEN_REFACTORING.md
- [ ] Leí DOCUMENTACION_PATRONES.md
- [ ] Entiendo dónde está cada capa (core, domain, data, presentation)
- [ ] He usado AppCoordinator en un screen
- [ ] He checado un decorador en acción
- [ ] He visto cómo se parsea JSON con factories
- [ ] He usado el adapter para normalizar respuestas

---

## 🚀 Ejercicios Prácticos

### 1. Agregar nuevo endpoint
```dart
// 1. Definir en IAuthService
abstract class IAuthService {
  Future<User> resetPassword(String email);
}

// 2. Implementar en AuthServiceImpl
@override
Future<User> resetPassword(String email) async {
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/auth/reset-password'),
    body: jsonEncode({'email': email}),
    // ...
  );
  return UserFactory.fromJson(response);
}

// 3. Agregar método en AppCoordinator
Future<User> resetPassword(String email) async {
  return _authService.resetPassword(email);
}

// 4. Usar en screen
await coordinator.resetPassword(email);
```

### 2. Modificar parseo de modelo
```dart
// En lib/core/factories/superheroe_factory.dart
static Superheroe fromJson(dynamic json) {
  return Superheroe(
    // ... campos existentes
    miNuevoCampo: json['miNuevoCampo'] ?? 'default',
  );
}
```

### 3. Agregar caché a un método
```dart
// En lib/core/facades/app_coordinator.dart
Future<List<Superheroe>> getAllSuperheroes() async {
  return CacheDecorator.executeWithCache(
    'heroes',
    () => _superheroeService.getAll(),
    ttl: Duration(minutes: 10),
  );
}
```

---

## 📞 Referencia Rápida de Archivos

```
MAIN ENTRY POINT
└── lib/main.dart                         (Punto de entrada - LIMPIO)

CORE LAYER (Utilities & Patterns)
├── lib/core/constants/app_constants.dart (Colores, URLs, keys)
├── lib/core/facades/app_coordinator.dart (FACADE PRINCIPAL)
├── lib/core/factories/
│   ├── service_factory.dart              (Singleton + Abstract Factory)
│   ├── superheroe_factory.dart           (Factory Method)
│   └── query_builder.dart                (Builder Pattern)
├── lib/core/adapters/api_response_adapter.dart (Adapter Pattern)
├── lib/core/decorators/
│   ├── logging_decorator.dart            (Decorator - Logging)
│   └── cache_decorator.dart              (Decorator - Cache)
└── lib/core/proxies/service_proxy.dart   (Proxy Pattern)

DOMAIN LAYER (Interfaces & Models)
├── lib/domain/services/
│   ├── i_auth_service.dart
│   ├── i_superheroe_service.dart
│   ├── i_comment_service.dart
│   └── i_reaction_service.dart
├── lib/domain/repositories/
│   ├── i_superheroe_repository.dart
│   ├── i_comment_repository.dart
│   └── i_reaction_repository.dart
└── lib/domain/models/
    ├── user.dart
    ├── superheroe.dart
    ├── comment.dart
    ├── reaction.dart
    └── superheroe_reaction.dart

DATA LAYER (Implementations)
└── lib/data/services/
    ├── auth_service_impl.dart
    ├── superheroe_service_impl.dart
    ├── comment_service_impl.dart
    └── reaction_service_impl.dart

PRESENTATION LAYER (UI)
├── lib/presentation/theme/app_theme.dart (Tema centralizado)
├── lib/presentation/screens/
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   └── home_screen.dart
└── lib/presentation/widgets/
    ├── superhero_card.dart
    └── comments_sheet.dart

DOCUMENTATION
├── RESUMEN_REFACTORING.md                (Resumen de cambios)
├── DOCUMENTACION_PATRONES.md             (Guía de patrones)
└── README.md                             (Documentación original)
```

---

## 🎯 TL;DR (Too Long; Didn't Read)

1. **Todo pasa por AppCoordinator** → Úsalo siempre desde screens/widgets
2. **Nunca importes directamente servicios** → Siempre vía AppCoordinator
3. **Los patrones están en core/** → Entiéndelos pero úsalos automáticamente
4. **La funcionalidad es 100% igual** → Solo cambió la estructura
5. **Lee DOCUMENTACION_PATRONES.md** → Para entender qué pasa detrás

---

**Versión**: 2.0 Refactorizado
**Estado**: ✅ Production Ready
**Último Update**: 7 de mayo de 2026
