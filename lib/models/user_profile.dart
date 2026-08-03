/// Activities users can pick during onboarding and display on their profile.
const List<String> kProfileActivities = [
  'Coffee dates',
  'Hiking',
  'Music',
  'Dancing',
  'Cooking',
  'Travel',
  'Faith & church',
  'Movies',
  'Fitness',
  'Art',
  'Reading',
  'Soccer',
  'Photography',
  'Gaming',
  'Volunteering',
  'Foodie adventures',
  'Running',
  'Board games',
];

const List<String> kGenderOptions = ['Woman', 'Man', 'Nonbinary'];

/// Minimum number of activities a user must pick during onboarding.
const int kMinActivities = 3;

/// Minimum bio length so profiles feel real.
const int kMinBioLength = 20;

/// Minimum age to use the app.
const int kMinAge = 18;

class UserProfile {
  final String firstName;
  final DateTime birthDate;
  final String gender;
  final List<String> lookingFor;
  final String city;
  final List<String> activities;
  final String bio;

  const UserProfile({
    required this.firstName,
    required this.birthDate,
    required this.gender,
    required this.lookingFor,
    required this.city,
    required this.activities,
    required this.bio,
  });

  int ageOn(DateTime date) {
    var age = date.year - birthDate.year;
    final hadBirthdayThisYear =
        (date.month > birthDate.month) ||
        (date.month == birthDate.month && date.day >= birthDate.day);
    if (!hadBirthdayThisYear) age -= 1;
    return age;
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'birthDate': birthDate.toIso8601String(),
      'gender': gender,
      'lookingFor': lookingFor,
      'city': city,
      'activities': activities,
      'bio': bio,
    };
  }

  static UserProfile? fromMap(Map<String, dynamic>? map) {
    if (map == null) return null;
    final birthDateRaw = map['birthDate'];
    final birthDate = birthDateRaw is String
        ? DateTime.tryParse(birthDateRaw)
        : null;
    if (birthDate == null) return null;

    return UserProfile(
      firstName: (map['firstName'] as String?) ?? '',
      birthDate: birthDate,
      gender: (map['gender'] as String?) ?? '',
      lookingFor: List<String>.from(map['lookingFor'] as List? ?? const []),
      city: (map['city'] as String?) ?? '',
      activities: List<String>.from(map['activities'] as List? ?? const []),
      bio: (map['bio'] as String?) ?? '',
    );
  }
}
