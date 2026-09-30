import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _picker = ImagePicker();
  AppUser? _user;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final u = await AuthService.instance.currentUser();
    if (mounted) setState(() => _user = u);
  }

  Future<void> _changePhoto(ImageSource source) async {
    final picked = await _picker.pickImage(
        source: source, maxWidth: 800, imageQuality: 85);
    if (picked == null || _user == null) return;
    final updated =
        await AuthService.instance.updateProfilePicture(_user!, picked);
    if (mounted) setState(() => _user = updated);
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from gallery'),
            onTap: () {
              Navigator.pop(ctx);
              _changePhoto(ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('Take a photo'),
            onTap: () {
              Navigator.pop(ctx);
              _changePhoto(ImageSource.camera);
            },
          ),
        ]),
      ),
    );
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My profile'),
        actions: [
          IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              tooltip: 'Log out'),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: _showPhotoOptions,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 64,
                            backgroundImage: user.profilePicturePath != null
                                ? FileImage(File(user.profilePicturePath!))
                                : null,
                            child: user.profilePicturePath == null
                                ? const Icon(Icons.person, size: 64)
                                : null,
                          ),
                          const CircleAvatar(
                              radius: 18, child: Icon(Icons.edit, size: 18)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(user.fullName,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    Text('Admission number: ${user.admissionNumber}'),
                  ],
                ),
              ),
            ),
    );
  }
}
