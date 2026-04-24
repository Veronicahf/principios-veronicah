class Superheroe {
  final int id;
  final String nombre;
  final String habilidades;
  final String debilidades;
  final String enemigos;
  final String urlPhoto;
  final String postedByUsername;

  Superheroe({
    required this.id,
    required this.nombre,
    required this.habilidades,
    required this.debilidades,
    required this.enemigos,
    required this.urlPhoto,
    this.postedByUsername = '',
  });

  factory Superheroe.fromJson(Map<String, dynamic> json) {
    final postedBy = json['postedBy'];
    String postedByUsername = '';
    if (postedBy is Map<String, dynamic>) {
      postedByUsername = postedBy['username']?.toString() ?? '';
    }

    return Superheroe(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      habilidades: json['habilidades'] ?? '',
      debilidades: json['debilidades'] ?? '',
      enemigos: json['enemigos'] ?? '',
      urlPhoto: json['urlPhoto'] ?? '',
      postedByUsername: postedByUsername,
    );
  }
}