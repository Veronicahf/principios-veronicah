/// [QUÉ ES]: Interfaz que define el contrato del servicio de superhéroes
/// [PARA QUÉ SIRVE]: Abstrae la implementación de operaciones CRUD de superhéroes
/// [PATRÓN DE DISEÑO]: -
/// [RAZÓN Y UTILIDAD]: Cumple DIP (SOLID): desacopla presentación de implementación. Facilita testing 
/// y permite múltiples implementaciones (API real, mock, caché, etc.).

import '../models/superheroe.dart';

abstract class ISuperheroeService {
  /// Obtiene todos los superhéroes
  Future<List<Superheroe>> fetchSuperheroes();

  /// Crea un nuevo superhéroe
  Future<Superheroe> createSuperheroe(Superheroe superheroe);

  /// Elimina un superhéroe
  Future<void> deleteSuperheroe(int id);

  /// Limpia recursos
  void dispose();
}
