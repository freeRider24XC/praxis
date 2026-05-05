import 'package:praxis/common/models/index.dart';
import 'package:praxis/common/services/database_service.dart';

class DomainService {
  static List<LifeDomain> getDomains() {
    return DatabaseService.getAllLifeDomains();
  }

  static LifeDomain? getDomainById(String? id) {
    if (id == null || id.isEmpty) return null;
    return DatabaseService.getLifeDomainById(id);
  }

  static LifeDomain? getFocusedDomain() {
    final profile = DatabaseService.getUserProfile();
    return getDomainById(profile.focusedDomainId);
  }

  static Future<void> setFocusedDomain(String domainId) async {
    final profile = DatabaseService.getUserProfile();
    profile.focusedDomainId = domainId;
    profile.updatedAt = DateTime.now();
    await DatabaseService.saveUserProfile(profile);
  }
}
