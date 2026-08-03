import 'package:flutter_test/flutter_test.dart';

import 'package:amalay_user/models/user_profile.dart';

void main() {
  group('UserProfile', () {
    final profile = UserProfile(
      firstName: 'Selam',
      birthDate: DateTime(1998, 6, 15),
      gender: 'Woman',
      lookingFor: const ['Man'],
      city: 'Addis Ababa',
      activities: const ['Coffee dates', 'Hiking', 'Music'],
      bio: 'Coffee lover who hikes every weekend and sings badly.',
    );

    test('round-trips through a map', () {
      final restored = UserProfile.fromMap(profile.toMap());
      expect(restored, isNotNull);
      expect(restored!.firstName, 'Selam');
      expect(restored.birthDate, DateTime(1998, 6, 15));
      expect(restored.gender, 'Woman');
      expect(restored.lookingFor, ['Man']);
      expect(restored.city, 'Addis Ababa');
      expect(restored.activities, hasLength(3));
      expect(restored.bio, contains('Coffee'));
    });

    test('computes age before and after birthday', () {
      expect(profile.ageOn(DateTime(2026, 6, 14)), 27);
      expect(profile.ageOn(DateTime(2026, 6, 15)), 28);
      expect(profile.ageOn(DateTime(2026, 8, 3)), 28);
    });

    test('fromMap returns null for missing or corrupt data', () {
      expect(UserProfile.fromMap(null), isNull);
      expect(UserProfile.fromMap({'firstName': 'X'}), isNull);
      expect(
        UserProfile.fromMap({'firstName': 'X', 'birthDate': 'not-a-date'}),
        isNull,
      );
    });
  });
}
