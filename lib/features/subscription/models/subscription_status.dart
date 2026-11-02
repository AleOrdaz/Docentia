import 'subscription_config.dart';

enum SubscriptionTier { free, pro }

class SubscriptionStatus {
  final SubscriptionTier tier;
  final BillingPeriod? billingPeriod;
  final DateTime? trialEndsAt;
  final DateTime? proExpiresAt;
  final bool isSimulated;

  const SubscriptionStatus({
    required this.tier,
    this.billingPeriod,
    this.trialEndsAt,
    this.proExpiresAt,
    this.isSimulated = true,
  });

  static const free = SubscriptionStatus(tier: SubscriptionTier.free);

  bool get isOnTrial {
    if (trialEndsAt == null) return false;
    return DateTime.now().isBefore(trialEndsAt!);
  }

  bool get isProActive {
    if (tier != SubscriptionTier.pro) {
      return isOnTrial;
    }
    if (proExpiresAt != null && DateTime.now().isAfter(proExpiresAt!)) {
      return false;
    }
    return true;
  }

  bool get isPro => isProActive;

  bool canAccess(ProFeature feature) => isPro;

  bool canCreateCourse(int activeCourseCount) {
    if (isPro) return true;
    return activeCourseCount < SubscriptionConfig.freeMaxCourses;
  }

  bool canAddStudent(int activeStudentCount) {
    if (isPro) return true;
    return activeStudentCount < SubscriptionConfig.freeMaxStudents;
  }

  Map<String, dynamic> toMap() => {
        'tier': tier.name,
        'billingPeriod': billingPeriod?.name,
        'trialEndsAt': trialEndsAt?.toIso8601String(),
        'proExpiresAt': proExpiresAt?.toIso8601String(),
        'isSimulated': isSimulated,
      };

  factory SubscriptionStatus.fromMap(Map<String, dynamic> map) {
    final tierName = map['tier'] as String? ?? 'free';
    final periodName = map['billingPeriod'] as String?;
    return SubscriptionStatus(
      tier: SubscriptionTier.values.firstWhere(
        (t) => t.name == tierName,
        orElse: () => SubscriptionTier.free,
      ),
      billingPeriod: periodName == null
          ? null
          : BillingPeriod.values.firstWhere(
              (p) => p.name == periodName,
              orElse: () => BillingPeriod.monthly,
            ),
      trialEndsAt: map['trialEndsAt'] != null
          ? DateTime.tryParse(map['trialEndsAt'] as String)
          : null,
      proExpiresAt: map['proExpiresAt'] != null
          ? DateTime.tryParse(map['proExpiresAt'] as String)
          : null,
      isSimulated: map['isSimulated'] as bool? ?? true,
    );
  }

  SubscriptionStatus copyWith({
    SubscriptionTier? tier,
    BillingPeriod? billingPeriod,
    DateTime? trialEndsAt,
    DateTime? proExpiresAt,
    bool? isSimulated,
    bool clearTrial = false,
    bool clearBilling = false,
    bool clearExpiry = false,
  }) {
    return SubscriptionStatus(
      tier: tier ?? this.tier,
      billingPeriod: clearBilling ? null : (billingPeriod ?? this.billingPeriod),
      trialEndsAt: clearTrial ? null : (trialEndsAt ?? this.trialEndsAt),
      proExpiresAt: clearExpiry ? null : (proExpiresAt ?? this.proExpiresAt),
      isSimulated: isSimulated ?? this.isSimulated,
    );
  }
}
