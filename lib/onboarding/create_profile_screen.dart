// lib/screens/profile/create_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:amalay_user/repositories/user_repository.dart';
import 'package:amalay_user/services/auth/auth_service.dart';
import 'package:amalay_user/screens/home/home_screen.dart'; // ⬅️ added for stack reset

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _repo = UserRepository();
  final _authService = AuthService();

  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    final name = _nameCtrl.text.trim();

    if (user == null) return;
    if (name.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your name')));
      return;
    }

    setState(() => _saving = true);
    try {
      // Update display name (no reload to avoid extra auth event)
      await user.updateDisplayName(name);

      // Mark profile complete in Firestore
      await _repo.markProfileComplete(user.uid, displayName: name);

      if (!mounted) return;
      // Return "true" so HomeScreen (if awaiting) knows it completed
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _signOut() async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();

    try {
      await _authService.signOut();

      if (!mounted) return;
      // Hard reset back to HomeScreen so the auth listener shows the login UI
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sign out failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Profile'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _signOut,
            child: const Text('Sign out'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Just your display name for now.',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameCtrl,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _saving ? null : _save(),
                decoration: const InputDecoration(
                  labelText: 'Display name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save & Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
