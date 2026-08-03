import 'package:flutter_test/flutter_test.dart';

import 'package:amalay_user/services/likes/like_quota.dart';

void main() {
  final noon = DateTime(2026, 8, 3, 12);

  group('LikeQuota', () {
    test('fresh user has full quota', () {
      const quota = LikeQuota(likesToday: 0, resetAt: null);
      expect(quota.canLike(noon, isPremium: false), isTrue);
      expect(
        quota.remaining(noon, isPremium: false),
        LikeQuota.freeDailyLimit,
      );
    });

    test('counts likes spent today', () {
      final quota = LikeQuota(likesToday: 4, resetAt: noon);
      expect(
        quota.remaining(noon.add(const Duration(hours: 2)), isPremium: false),
        LikeQuota.freeDailyLimit - 4,
      );
    });

    test('blocks at the daily limit', () {
      final quota = LikeQuota(
        likesToday: LikeQuota.freeDailyLimit,
        resetAt: noon,
      );
      expect(quota.canLike(noon, isPremium: false), isFalse);
      expect(quota.remaining(noon, isPremium: false), 0);
    });

    test('resets the next day', () {
      final quota = LikeQuota(
        likesToday: LikeQuota.freeDailyLimit,
        resetAt: noon,
      );
      final tomorrow = noon.add(const Duration(days: 1));
      expect(quota.canLike(tomorrow, isPremium: false), isTrue);
      expect(quota.effectiveCount(tomorrow), 0);
    });

    test('premium bypasses the limit', () {
      final quota = LikeQuota(
        likesToday: LikeQuota.freeDailyLimit + 50,
        resetAt: noon,
      );
      expect(quota.canLike(noon, isPremium: true), isTrue);
    });

    test('afterLike increments and stamps the reset day', () {
      const quota = LikeQuota(likesToday: 0, resetAt: null);
      final next = quota.afterLike(noon);
      expect(next.likesToday, 1);
      expect(next.resetAt, noon);

      final afterStale = LikeQuota(
        likesToday: 9,
        resetAt: noon.subtract(const Duration(days: 2)),
      ).afterLike(noon);
      expect(afterStale.likesToday, 1, reason: 'stale counter resets first');
    });
  });
}
