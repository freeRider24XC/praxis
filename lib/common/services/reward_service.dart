import 'package:praxis/common/models/index.dart';
import 'package:praxis/common/services/database_service.dart';

class RewardService {
  static const int todoCompletedPraise = 1;
  static const int projectCompletedPraise = 2;
  static const int goalCompletedPraise = 3;
  static const int dailyReviewPraise = 1;

  static Future<void> ensureSeededTemplates() async {
    if (DatabaseService.getRewardTemplates().isNotEmpty) {
      return;
    }

    await DatabaseService.addRewardTemplate(
      RewardTemplate(
        title: '散步 20 分钟',
        description: '立刻离开屏幕，轻量恢复一下。',
        priceInPraisePoints: 3,
        tier: RewardTier.small,
      ),
    );
    await DatabaseService.addRewardTemplate(
      RewardTemplate(
        title: '一顿喜欢的正餐',
        description: '阶段性庆祝，不赶时间地好好吃一顿。',
        priceInPraisePoints: 8,
        tier: RewardTier.medium,
      ),
    );
    await DatabaseService.addRewardTemplate(
      RewardTemplate(
        title: '半天完全放松',
        description: '为自己留出半天恢复和庆祝时间。',
        priceInPraisePoints: 15,
        tier: RewardTier.large,
      ),
    );
  }

  static int getPraisePointsBalance() {
    return DatabaseService.getPraisePointBalance();
  }

  static Future<void> awardForTodo(Todo todo) async {
    await DatabaseService.addPraisePointLedger(
      PraisePointLedger(
        delta: todoCompletedPraise,
        source: PraisePointSource.todoCompleted,
        sourceId: todo.id,
        description: '完成事项：${todo.title}',
      ),
    );
  }

  static Future<void> awardForProject(Project project) async {
    await DatabaseService.addPraisePointLedger(
      PraisePointLedger(
        delta: projectCompletedPraise,
        source: PraisePointSource.projectCompleted,
        sourceId: project.id,
        description: '完成项目：${project.name}',
      ),
    );
  }

  static Future<void> awardForGoal(Goal goal) async {
    await DatabaseService.addPraisePointLedger(
      PraisePointLedger(
        delta: goalCompletedPraise,
        source: PraisePointSource.goalCompleted,
        sourceId: goal.id,
        description: '完成目标：${goal.title}',
      ),
    );
  }

  static Future<void> awardForDailyReview(DailyReview review) async {
    await DatabaseService.addPraisePointLedger(
      PraisePointLedger(
        delta: dailyReviewPraise,
        source: PraisePointSource.dailyReview,
        sourceId: review.id,
        description: '完成每日复盘',
      ),
    );
  }

  static Future<RewardRedemption> redeemReward(RewardTemplate template) async {
    final balance = getPraisePointsBalance();
    if (balance < template.priceInPraisePoints) {
      throw StateError('犒赏点不足');
    }

    final redemption = RewardRedemption(
      rewardTemplateId: template.id,
      priceInPraisePoints: template.priceInPraisePoints,
    );
    await DatabaseService.addRewardRedemption(redemption);

    await DatabaseService.addPraisePointLedger(
      PraisePointLedger(
        delta: -template.priceInPraisePoints,
        source: PraisePointSource.rewardRedemption,
        sourceId: redemption.id,
        description: '兑换奖励：${template.title}',
      ),
    );

    final rewardTodo = RewardTodo(
      rewardTemplateId: template.id,
      redemptionId: redemption.id,
      title: '兑现奖励：${template.title}',
      description: template.description,
      dueDate: DateTime.now().add(const Duration(days: 2)),
    );
    await DatabaseService.addRewardTodo(rewardTodo);

    redemption.rewardTodoId = rewardTodo.id;
    await DatabaseService.updateRewardRedemption(redemption);
    return redemption;
  }

  static Future<void> completeRewardTodo(RewardTodo rewardTodo) async {
    rewardTodo.status = RewardTodoStatus.completed;
    rewardTodo.completedAt = DateTime.now();
    await DatabaseService.updateRewardTodo(rewardTodo);

    final redemption =
        DatabaseService.getRewardRedemptionById(rewardTodo.redemptionId);
    if (redemption != null) {
      redemption.status = RewardRedemptionStatus.fulfilled;
      await DatabaseService.updateRewardRedemption(redemption);
    }
  }
}
