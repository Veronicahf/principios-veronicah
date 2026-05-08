/// [QUÉ ES]: Decorador que agrega caché a servicios
/// [PARA QUÉ SIRVE]: Envuelve servicios para cachear resultados y evitar llamadas repetidas
/// [PATRÓN DE DISEÑO]: Decorator - Estructural
/// [RAZÓN Y UTILIDAD]: Reduce llamadas a API, mejora rendimiento y user experience. Cumple OCP: 
/// agregamos caché sin tocar el servicio original. Facilita testeo y es agnóstico al servicio.

/// Entrada de caché con timestamp
class CacheEntry<T> {
  final T data;
  final DateTime timestamp;
  final Duration ttl; // Time To Live

  CacheEntry(this.data, this.ttl) : timestamp = DateTime.now();

  /// Verifica si el cache ha expirado
  bool isExpired() {
    final now = DateTime.now();
    final expiredAt = timestamp.add(ttl);
    return now.isAfter(expiredAt);
  }
}

/// Decorador genérico para agregar caché
class CacheDecorator<T> {
  final Map<String, CacheEntry<dynamic>> _cache = {};

  /// Obtiene del caché si existe y no ha expirado
  T? getFromCache<R>(String key) {
    final entry = _cache[key] as CacheEntry<R>?;

    if (entry == null) {
      return null;
    }

    if (entry.isExpired()) {
      _cache.remove(key);
      return null;
    }

    return entry.data as T?;
  }

  /// Almacena en caché
  void putCache<R>(String key, R data, Duration ttl) {
    _cache[key] = CacheEntry(data, ttl);
  }

  /// Limpia el caché completo
  void clearCache() {
    _cache.clear();
  }

  /// Limpia una entrada específica
  void invalidateCache(String key) {
    _cache.remove(key);
  }

  /// Envoltura genérica para cachear resultados
  Future<R> executeWithCache<R>(
    String cacheKey,
    Future<R> Function() operation, {
    Duration cacheTtl = const Duration(minutes: 5),
  }) async {
    // Intenta obtener del caché
    final cached = getFromCache<R>(cacheKey);
    if (cached != null) {
      return cached;
    }

    // Si no está en caché, ejecuta la operación
    try {
      final result = await operation();
      putCache(cacheKey, result, cacheTtl);
      return result;
    } catch (e) {
      // En caso de error, intenta obtener del caché sin importar TTL (fallback)
      final staleCache = _cache[cacheKey] as CacheEntry<R>?;
      if (staleCache != null) {
        return staleCache.data;
      }
      rethrow;
    }
  }

  /// Retorna estadísticas del caché
  Map<String, dynamic> getCacheStats() {
    return {
      'totalEntries': _cache.length,
      'entries': _cache.keys.toList(),
    };
  }
}
