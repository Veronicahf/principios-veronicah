import '../models/superheroe.dart';

abstract class ISuperheroeRepository {
  Future<List<Superheroe>> fetchSuperheroes();
  Future<Superheroe> createSuperheroe(Superheroe superheroe);
  Future<void> deleteSuperheroe(int id);
  void dispose();
}