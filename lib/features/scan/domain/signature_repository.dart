import 'signature.dart';

abstract interface class SignatureRepository {
  Future<void> add(Signature signature);
  Future<List<Signature>> list();
  Future<void> delete(String id);
}
