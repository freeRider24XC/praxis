import 'package:praxis/common/repositories/local_praxis_repository.dart';
import 'package:praxis/common/repositories/praxis_repository.dart';

class RepositoryProvider {
  static PraxisRepository instance = LocalPraxisRepository();
}
