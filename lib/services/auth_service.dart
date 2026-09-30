import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../models/app_user.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _sessionKey = 'logged_in_admission';
  Database? _db;

  Future<Database> get _database async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), 'students.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE users (
          admission_number TEXT PRIMARY KEY,
          first_name TEXT NOT NULL,
          middle_name TEXT,
          last_name TEXT NOT NULL,
          password_hash TEXT NOT NULL,
          salt TEXT NOT NULL,
          profile_picture_path TEXT
        )
      '''),
    );
    return _db!;
  }

  /// Admission numbers are compared case-insensitively, ignoring outer spaces.
  String normalize(String admission) => admission.trim().toUpperCase();

  String _newSalt() {
    final rnd = Random.secure();
    return base64UrlEncode(List<int>.generate(16, (_) => rnd.nextInt(256)));
  }

  String _hash(String password, String salt) =>
      sha256.convert(utf8.encode('$salt$password')).toString();

  /// Returns null on success, or an error message.
  Future<String?> register({
    required String admissionNumber,
    required String firstName,
    String? middleName,
    required String lastName,
    required String password,
    XFile? profilePicture,
  }) async {
    final db = await _database;
    final adm = normalize(admissionNumber);

    final existing = await db.query('users',
        where: 'admission_number = ?', whereArgs: [adm], limit: 1);
    if (existing.isNotEmpty) {
      return 'This admission number is already registered. Please log in.';
    }

    final salt = _newSalt();
    String? savedPath;
    if (profilePicture != null) {
      savedPath = await _saveImage(adm, profilePicture);
    }

    final user = AppUser(
      admissionNumber: adm,
      firstName: firstName.trim(),
      middleName: (middleName?.trim().isEmpty ?? true) ? null : middleName!.trim(),
      lastName: lastName.trim(),
      passwordHash: _hash(password, salt),
      salt: salt,
      profilePicturePath: savedPath,
    );

    try {
      await db.insert('users', user.toMap(),
          conflictAlgorithm: ConflictAlgorithm.abort);
    } on DatabaseException {
      return 'Could not create the account. Please try again.';
    }
    await _setSession(adm);
    return null;
  }

  /// Returns null on success, or an error message.
  Future<String?> login(String admissionNumber, String password) async {
    final db = await _database;
    final adm = normalize(admissionNumber);
    final rows = await db.query('users',
        where: 'admission_number = ?', whereArgs: [adm], limit: 1);
    if (rows.isEmpty) return 'No account found for this admission number.';

    final user = AppUser.fromMap(rows.first);
    if (_hash(password, user.salt) != user.passwordHash) {
      return 'Incorrect password.';
    }
    await _setSession(adm);
    return null;
  }

  Future<AppUser?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final adm = prefs.getString(_sessionKey);
    if (adm == null) return null;
    final db = await _database;
    final rows = await db.query('users',
        where: 'admission_number = ?', whereArgs: [adm], limit: 1);
    return rows.isEmpty ? null : AppUser.fromMap(rows.first);
  }

  Future<AppUser?> updateProfilePicture(AppUser user, XFile picked) async {
    final db = await _database;
    final newPath = await _saveImage(user.admissionNumber, picked);
    if (user.profilePicturePath != null) {
      final old = File(user.profilePicturePath!);
      if (await old.exists()) await old.delete();
    }
    await db.update('users', {'profile_picture_path': newPath},
        where: 'admission_number = ?', whereArgs: [user.admissionNumber]);
    return currentUser();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  Future<void> _setSession(String admission) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, admission);
  }

  /// Copies the picked image into app storage. A timestamp in the file name
  /// avoids Flutter serving a cached copy after the picture changes.
  Future<String> _saveImage(String admission, XFile picked) async {
    final dir = await getApplicationDocumentsDirectory();
    final safe = admission.replaceAll(RegExp(r'[^A-Za-z0-9]'), '_');
    final ext = p.extension(picked.path).isEmpty ? '.jpg' : p.extension(picked.path);
    final dest = p.join(
        dir.path, 'profile_${safe}_${DateTime.now().millisecondsSinceEpoch}$ext');
    await File(picked.path).copy(dest);
    return dest;
  }
}
