/// [QUÉ ES]: Constructor de consultas/búsquedas complejas para superhéroes
/// [PARA QUÉ SIRVE]: Construye filtros y búsquedas de forma fluida y escalable
/// [PATRÓN DE DISEÑO]: Builder - Creacional
/// [RAZÓN Y UTILIDAD]: Permite armar búsquedas complejas sin explosion de parámetros. Ejemplo: 
/// query.byName('Batman').byHability('Fuerza').build(). Cumple con SRP y facilita testing.

class SuperheroeQueryBuilder {
  String? _name;
  String? _hability;
  String? _weakness;
  String? _enemy;
  String? _author;
  int? _limit;
  int? _offset;

  SuperheroeQueryBuilder byName(String name) {
    _name = name;
    return this;
  }

  SuperheroeQueryBuilder byHability(String hability) {
    _hability = hability;
    return this;
  }

  SuperheroeQueryBuilder byWeakness(String weakness) {
    _weakness = weakness;
    return this;
  }

  SuperheroeQueryBuilder byEnemy(String enemy) {
    _enemy = enemy;
    return this;
  }

  SuperheroeQueryBuilder byAuthor(String author) {
    _author = author;
    return this;
  }

  SuperheroeQueryBuilder limit(int limit) {
    _limit = limit;
    return this;
  }

  SuperheroeQueryBuilder offset(int offset) {
    _offset = offset;
    return this;
  }

  /// Construye el mapa de parámetros de búsqueda
  Map<String, dynamic> build() {
    final params = <String, dynamic>{};

    if (_name != null && _name!.isNotEmpty) {
      params['nombre'] = _name;
    }
    if (_hability != null && _hability!.isNotEmpty) {
      params['habilidades'] = _hability;
    }
    if (_weakness != null && _weakness!.isNotEmpty) {
      params['debilidades'] = _weakness;
    }
    if (_enemy != null && _enemy!.isNotEmpty) {
      params['enemigos'] = _enemy;
    }
    if (_author != null && _author!.isNotEmpty) {
      params['author'] = _author;
    }
    if (_limit != null) {
      params['limit'] = _limit;
    }
    if (_offset != null) {
      params['offset'] = _offset;
    }

    return params;
  }

  /// Construye una cadena de consulta URL
  String buildQueryString() {
    final params = build();
    if (params.isEmpty) return '';
    return '?' +
        params.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
            .join('&');
  }

  /// Reinicia el builder
  void reset() {
    _name = null;
    _hability = null;
    _weakness = null;
    _enemy = null;
    _author = null;
    _limit = null;
    _offset = null;
  }
}
