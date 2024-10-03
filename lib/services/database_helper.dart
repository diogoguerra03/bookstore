import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';
import 'dart:typed_data';
import '../models/user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'bookstore.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT UNIQUE, password TEXT)',
        );
      },
    );
  }

  Future<bool> checkUsernameExists(String username) async {
    final db = await database;
    var res = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return res.isNotEmpty;
  }

  // Função para gerar uma chave a partir de uma senha
  encrypt.Key _generateKey(String password) {
    // Usando PBKDF2 para derivar a chave
    final key = utf8.encode(password);
    final digest =
        sha256.convert(key).bytes; // SHA-256 gera uma chave de 256 bits

    // Converte List<int> para Uint8List
    final Uint8List keyBytes = Uint8List.fromList(digest);

    return encrypt.Key(keyBytes);
  }

  Future<bool> addUser(String username, String password) async {
    final db = await database;

    // Crypto password with SHA-256
    final passwordEncoded = utf8.encode(password);
    final passwordHash = sha256.convert(passwordEncoded).toString();

    try {
      await db.insert(
        'users',
        {
          'username': username,
          'password': passwordHash,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } catch (e) {
      return false;
    }

    return true;
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');

    // Converte a lista de mapas em uma lista de usuários
    return List.generate(maps.length, (i) {
      return User(
        id: maps[i]['id'],
        username: maps[i]['username'],
        password: maps[i]['password'],
      );
    });
  }

  // Função para dar delete dos utilizadores
  Future<void> deleteAllUsers() async {
    final db = await database; // Obtém a instância do banco de dados
    await db.delete(
      'users', // Nome da tabela
    );
  }

  // Dentro do seu arquivo database_helper.dart
  Future<bool> authenticateUser(String username, String password) async {
    final db = await database; // Obtém a instância do banco de dados

    final passwordEncoded = utf8.encode(password);
    final passwordHash = sha256.convert(passwordEncoded).toString();

    // Verifica no banco de dados
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, passwordHash], // Compara a senha criptografada
    );

    return result.isNotEmpty; // Retorna true se o usuário existir
  }
}
