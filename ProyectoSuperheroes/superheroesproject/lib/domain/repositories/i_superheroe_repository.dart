/// [QUÉ ES]: Interfaz que define el contrato para acceso a datos de superhéroes
/// [PARA QUÉ SIRVE]: Abstrae la fuente de datos (API, caché, BD local, etc.)
/// [PATRÓN DE DISEÑO]: -
/// [RAZÓN Y UTILIDAD]: Cumple DIP (SOLID): presentación y servicios dependen de repositorio, no de detalles de BD/API. 
/// Facilita testing con mocks y permite cambiar fuente de datos sin afectar dependientes.

import '../models/superheroe.dart';

abstract class ISuperheroeRepository {
  Future<List<Superheroe>> fetchSuperheroes();
  Future<Superheroe> createSuperheroe(Superheroe superheroe);
  Future<void> deleteSuperheroe(int id);
  void dispose();
}
