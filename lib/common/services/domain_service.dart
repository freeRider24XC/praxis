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

  static LifeDomain inferDomainFromIntent(String intent) {
    final text = intent.trim().toLowerCase();
    final domains = getDomains();

    final keywordMap = <String, List<String>>{
      '职业发展': ['工作', '职业', '求职', '简历', '面试', '副业', '客户', '作品集', '涨薪', '转岗', '创业'],
      '健康身体': ['健身', '减肥', '减重', '跑步', '睡眠', '饮食', '身体', '运动', '体重', '早睡'],
      '财务管理': ['存钱', '理财', '财务', '预算', '收入', '支出', '债务', '现金流', '记账'],
      '人际关系': ['关系', '恋爱', '朋友', '伴侣', '家庭', '父母', '沟通', '社交', '同事'],
      '成长学习': ['学习', '阅读', '英语', '课程', '考试', '写作', '复习', '知识', '技能'],
    };

    LifeDomain? bestDomain;
    var bestScore = -1;

    for (final domain in domains) {
      final keywords = keywordMap[domain.name] ?? const <String>[];
      var score = 0;
      for (final keyword in keywords) {
        if (text.contains(keyword)) {
          score += 1;
        }
      }
      if (score > bestScore) {
        bestScore = score;
        bestDomain = domain;
      }
    }

    return bestDomain ?? domains.first;
  }
}
