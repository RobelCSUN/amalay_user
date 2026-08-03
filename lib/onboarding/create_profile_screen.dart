// lib/onboarding/create_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:amalay_user/app/app_routes.dart';
import 'package:amalay_user/models/user_profile.dart';
import 'package:amalay_user/repositories/user_repository.dart';
import 'package:amalay_user/services/auth/auth_service.dart';
import 'package:amalay_user/theme/app_colors.dart';
import 'package:amalay_user/theme/app_text_styles.dart';
import 'package:amalay_user/widgets/themed_background.dart';
import 'package:amalay_user/widgets/themed_panel.dart';

class CreateProfileScreen extends StatefulWidget {
  final UserRepository userRepository;
  final AuthService authService;

  const CreateProfileScreen({
    super.key,
    required this.userRepository,
    required this.authService,
  });

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  static const int _stepCount = 6;

  final _nameCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  int _step = 0;
  DateTime? _birthDate;
  String? _gender;
  final Set<String> _lookingFor = {};
  final Set<String> _activities = {};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(_refresh);
    _cityCtrl.addListener(_refresh);
    _bioCtrl.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cityCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  bool get _stepValid {
    switch (_step) {
      case 0:
        return _nameCtrl.text.trim().length >= 2;
      case 1:
        return _birthDate != null && _ageAt(_birthDate!) >= kMinAge;
      case 2:
        return _gender != null && _lookingFor.isNotEmpty;
      case 3:
        return _cityCtrl.text.trim().length >= 2;
      case 4:
        return _activities.length >= kMinActivities;
      case 5:
        return _bioCtrl.text.trim().length >= kMinBioLength;
      default:
        return false;
    }
  }

  int _ageAt(DateTime birthDate) {
    final now = DateTime.now();
    var age = now.year - birthDate.year;
    final hadBirthday =
        (now.month > birthDate.month) ||
        (now.month == birthDate.month && now.day >= birthDate.day);
    if (!hadBirthday) age -= 1;
    return age;
  }

  void _next() {
    if (!_stepValid) return;
    if (_step < _stepCount - 1) {
      setState(() => _step += 1);
    } else {
      _save();
    }
  }

  void _back() {
    if (_step > 0) setState(() => _step -= 1);
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final latestAllowed = DateTime(now.year - kMinAge, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(now.year - 100),
      lastDate: latestAllowed,
      helpText: 'When were you born?',
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final profile = UserProfile(
      firstName: _nameCtrl.text.trim(),
      birthDate: _birthDate!,
      gender: _gender!,
      lookingFor: _lookingFor.toList()..sort(),
      city: _cityCtrl.text.trim(),
      activities: _activities.toList()..sort(),
      bio: _bioCtrl.text.trim(),
    );

    setState(() => _saving = true);
    try {
      await user.updateDisplayName(profile.firstName);
      await widget.userRepository.saveProfile(user.uid, profile);

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      _snack('Could not save your profile. Please try again.');
      debugPrint('[CreateProfile] save failed: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _signOut() async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    try {
      await widget.authService.signOut();
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    } catch (e) {
      _snack('Sign out failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: _step > 0
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _saving ? null : _back,
                )
              : null,
          title: Text(
            'Create your profile',
            style: AppTextStyles.heroTitle.copyWith(fontSize: 20),
          ),
          actions: [
            TextButton(
              onPressed: _saving ? null : _signOut,
              child: Text(
                'Sign out',
                style: AppTextStyles.link.copyWith(fontSize: 14),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_step + 1) / _stepCount,
                    minHeight: 6,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.accentRose,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: ThemedPanel(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: KeyedSubtree(
                          key: ValueKey(_step),
                          child: _buildStep(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (_stepValid && !_saving) ? _next : null,
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _step == _stepCount - 1
                                ? 'Finish & start matching'
                                : 'Next',
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _nameStep();
      case 1:
        return _birthDateStep();
      case 2:
        return _genderStep();
      case 3:
        return _cityStep();
      case 4:
        return _activitiesStep();
      case 5:
      default:
        return _bioStep();
    }
  }

  Widget _stepHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.heroTitle.copyWith(fontSize: 22)),
        const SizedBox(height: 6),
        Text(subtitle, style: AppTextStyles.heroBody.copyWith(fontSize: 14)),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _nameStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader(
          "What's your first name?",
          'This is how you appear to other people on Amalay.',
        ),
        TextField(
          controller: _nameCtrl,
          textCapitalization: TextCapitalization.words,
          style: AppTextStyles.heroBody.copyWith(fontSize: 16),
          cursorColor: Colors.white,
          decoration: const InputDecoration(labelText: 'First name'),
          onSubmitted: (_) => _next(),
        ),
      ],
    );
  }

  Widget _birthDateStep() {
    final age = _birthDate == null ? null : _ageAt(_birthDate!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader(
          'When is your birthday?',
          'You must be at least $kMinAge. Only your age is shown.',
        ),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: _pickBirthDate,
          child: InputDecorator(
            decoration: const InputDecoration(labelText: 'Birth date'),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _birthDate == null
                        ? 'Tap to choose'
                        : '${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}'
                              '${age == null ? '' : '  ($age years old)'}',
                    style: AppTextStyles.heroBody.copyWith(fontSize: 16),
                  ),
                ),
                const Icon(Icons.calendar_month, color: Colors.white70),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _genderStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader(
          'A bit about you',
          'Tell us who you are and who you want to meet.',
        ),
        Text('I am a...', style: AppTextStyles.heroBody),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kGenderOptions.map((option) {
            final selected = _gender == option;
            return ChoiceChip(
              label: Text(option),
              selected: selected,
              onSelected: (_) => setState(() => _gender = option),
              selectedColor: AppColors.accentRose,
              labelStyle: TextStyle(
                color: selected ? AppColors.buttonText : Colors.white,
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: Colors.white12,
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        Text('Looking for...', style: AppTextStyles.heroBody),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kGenderOptions.map((option) {
            final selected = _lookingFor.contains(option);
            return FilterChip(
              label: Text(option),
              selected: selected,
              onSelected: (value) {
                setState(() {
                  if (value) {
                    _lookingFor.add(option);
                  } else {
                    _lookingFor.remove(option);
                  }
                });
              },
              selectedColor: AppColors.accentRose,
              labelStyle: TextStyle(
                color: selected ? AppColors.buttonText : Colors.white,
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: Colors.white12,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _cityStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader(
          'Where do you live?',
          'We use your city to show you people nearby.',
        ),
        TextField(
          controller: _cityCtrl,
          textCapitalization: TextCapitalization.words,
          style: AppTextStyles.heroBody.copyWith(fontSize: 16),
          cursorColor: Colors.white,
          decoration: const InputDecoration(labelText: 'City'),
          onSubmitted: (_) => _next(),
        ),
      ],
    );
  }

  Widget _activitiesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader(
          'What do you love doing?',
          'Pick at least $kMinActivities. These show on your profile and '
              'help start conversations.',
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kProfileActivities.map((activity) {
            final selected = _activities.contains(activity);
            return FilterChip(
              label: Text(activity),
              selected: selected,
              onSelected: (value) {
                setState(() {
                  if (value) {
                    _activities.add(activity);
                  } else {
                    _activities.remove(activity);
                  }
                });
              },
              selectedColor: AppColors.accentRose,
              checkmarkColor: AppColors.buttonText,
              labelStyle: TextStyle(
                color: selected ? AppColors.buttonText : Colors.white,
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: Colors.white12,
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Text(
          '${_activities.length} selected',
          style: AppTextStyles.legal.copyWith(fontSize: 13),
        ),
      ],
    );
  }

  Widget _bioStep() {
    final remaining = kMinBioLength - _bioCtrl.text.trim().length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader(
          'Write your bio',
          'Share what makes you, you. A good bio gets more matches.',
        ),
        TextField(
          controller: _bioCtrl,
          maxLines: 6,
          maxLength: 400,
          style: AppTextStyles.heroBody.copyWith(fontSize: 16),
          cursorColor: Colors.white,
          decoration: const InputDecoration(
            labelText: 'Bio',
            alignLabelWithHint: true,
            counterStyle: TextStyle(color: Colors.white54),
          ),
        ),
        if (remaining > 0)
          Text(
            '$remaining more characters to go',
            style: AppTextStyles.legal.copyWith(fontSize: 13),
          ),
      ],
    );
  }
}
