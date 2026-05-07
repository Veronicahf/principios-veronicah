# 🔧 Debugging - Reacciones y Comentarios No Funcionan

## 📊 Síntomas Reportados
- ❌ No se muestran reacciones para escoger
- ❌ No hay contadores de reacciones
- ❌ Comentarios no funcionan
- ❌ No sale nada al dar click

---

## 🔍 Solución Aplicada

He mejorado el código Flutter para:

1. **Mostrar errores**: Ahora muestra `Error: ...` si algo falla
2. **Mostrar estado**: Muestra "Cargando..." mientras se obtienen datos
3. **Logs en consola**: Verás `✅` o `❌` con detalles
4. **Botones resilientes**: Los botones funcionan incluso si hay error

---

## 🚀 Cómo Debuggear

### Paso 1: Ejecutar en modo debug
```bash
cd ~/Documentos/copia/superheroesproject
flutter run -v  # Flag -v = verbose para ver TODOS los logs
```

### Paso 2: Revisar la consola
Busca líneas como:
```
✅ Reacciones disponibles cargadas: 5
✅ Reacciones del superhéroe cargadas: 2
✅ Comentarios cargados: 0
```

O si hay error:
```
❌ Error en _loadInteractions: No se pudieron cargar las reacciones (503)
Stack trace: ...
```

---

## 🆘 Posibles Problemas y Soluciones

### 1. **Error 503 - Servicio No Disponible**
```
❌ No se pudieron cargar las reacciones (503)
```

**Causa**: Render está en "cold start"

**Solución**:
```bash
# Espera 30 segundos y vuelve a intentar
# O calienta la API:
curl -X GET https://superheroes-api-iy4v.onrender.com/api/reactions
```

---

### 2. **Error 401 - No Autorizado**
```
❌ Error: Debes iniciar sesion para reaccionar
```

**Causa**: Token JWT expirado o no guardado

**Solución**:
```bash
# 1. Cierra y reabre la app
# 2. Haz login nuevamente
# 3. Verifica que el token se guarda en AuthService
```

---

### 3. **Error 404 - Endpoint No Existe**
```
❌ No se pudieron cargar las reacciones (404)
```

**Causa**: Backend no tiene el endpoint o URL incorrecta

**Solución**:
```bash
# Verifica que el endpoint existe:
curl -X GET https://superheroes-api-iy4v.onrender.com/api/reactions/superheroe/1

# Debe retornar: [] (array vacío) o [{ reacción }, ...]
# Si retorna 404, el endpoint NO existe en el backend
```

---

### 4. **No Carga Nada (Sin Error)**
```
No aparece "Cargando..." ni error
```

**Causa**: FutureBuilder está esperando pero nunca termina

**Solución**:
```bash
# 1. Verifica que la API responde:
curl -X GET https://superheroes-api-iy4v.onrender.com/api/reactions

# 2. Si no responde rápido, el servidor está caído
# 3. Verifica logs de Render:
#    https://dashboard.render.com → Tu proyecto → Logs
```

---

## 🧪 Pruebas Manuales

### Test 1: Verificar que API funciona
```bash
# En otra terminal
curl -X GET https://superheroes-api-iy4v.onrender.com/api/reactions
# Debe retornar: [{"id":1,"description":"REACTION_LIKE"}, ...]
```

### Test 2: Obtener reacciones de un superhéroe
```bash
curl -X GET https://superheroes-api-iy4v.onrender.com/api/reactions/superheroe/1
# Debe retornar: [] o [{ reacción con usuario }]
```

### Test 3: Obtener comentarios
```bash
curl -X GET https://superheroes-api-iy4v.onrender.com/api/comments/superheroe/1
# Debe retornar: [] o [{ comentario }]
```

---

## 📋 Checklist de Debugging

- [ ] ¿Veo "Cargando..." en el header del superhéroe?
  - **SÍ** → La API tarda, espera unos segundos
  - **NO** → La API no está respondiendo

- [ ] ¿Veo un error en rojo en el header?
  - **SÍ** → El error es visible, léelo y actúa
  - **NO** → Todo debería funcionar

- [ ] ¿Funcionan los botones "Reaccionar" y "Comentarios"?
  - **SÍ** → Haz click y observa los logs
  - **NO** → Verifica que estés logueado

- [ ] ¿Ves logs en la consola Flutter?
  - **SÍ** → Analiza qué dice (✅ o ❌)
  - **NO** → Ejecuta `flutter run -v` (verbose mode)

---

## 🔐 Verificar Autenticación

Si los botones dicen "Error", podría ser falta de token:

```bash
# En el código, verifica que AuthService tiene el token:
# Abre lib/services/auth_service.dart
# Busca: getToken() debe retornar el JWT bearer token

# Si getToken() retorna null:
# 1. El login no guardó el token
# 2. El token expiró (24 horas)
# 3. Hay un bug en AuthService
```

---

## 📝 Información Que Necesito

Si nada funciona, corre esto y comparte la salida:

```bash
cd ~/Documentos/copia/superheroesproject

# 1. Ver versión de Flutter
flutter --version

# 2. Analizar errores
flutter analyze 2>&1 | head -30

# 3. Ejecutar en debug y capturar logs
flutter run -v 2>&1 > flutter_debug.log

# Luego abre flutter_debug.log y busca:
# - "Error en _loadInteractions"
# - "HTTP" o "404" o "503"
# - Cualquier línea con ❌
```

Comparte el contenido de `flutter_debug.log` si algo no funciona.

---

## 🚀 Próximos Pasos

1. **Ejecuta `flutter run -v`** y observa los logs
2. **Identifica dónde está el ❌** (qué paso falla)
3. **Prueba manualmente con curl** el endpoint que falla
4. **Si la API funciona pero Flutter no**, el bug está en el parsing
5. **Si la API no funciona**, el bug está en el backend

---

**Actualizado**: Mayo 2026
**Versión**: 2.0 - Con debugging mejorado
