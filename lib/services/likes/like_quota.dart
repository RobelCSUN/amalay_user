/// Free-tier daily like quota logic.
///
/// Pure so it can be unit tested. The counter lives on the user's Firestore
/// doc (`likesToday`, `likesResetAt`) and resets at local midnight. Premium
/// users bypass the limit entirely (enforced server-side in a later phase).
class LikeQuota {
  static const int freeDailyLimit = 10;

  final int likesToday;
  final DateTime? resetAt;

  const LikeQuota({required this.likesToday, required this.resetAt});

  /// The count that applies at [now], accounting for the daily reset.
  int effectiveCount(DateTime now) {
    if (resetAt == null || !_isSameDay(resetAt!, now)) return 0;
    return likesToday;
  }

  int remaining(DateTime now, {required bool isPremium}) {
    if (isPremium) return -1; // unlimited
    return (freeDailyLimit - effectiveCount(now)).clamp(0, freeDailyLimit);
  }

  bool canLike(DateTime now, {required bool isPremium}) {
    if (isPremium) return true;
    return effectiveCount(now) < freeDailyLimit;
  }

  /// The quota state after one like is spent at [now].
  LikeQuota afterLike(DateTime now) {
    return LikeQuota(likesToday: effectiveCount(now) + 1, resetAt: now);
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
