import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Define o caminho do banco no Android/iOS
    String path = join(await getDatabasesPath(), 'payer_vendas.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Cria a tabela simples (SQL Puro)
        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            transactionId TEXT,
            value REAL,
            status TEXT,
            date TEXT,
            receiptText TEXT
          )
        ''');
      },
    );
  }

  // Salvar Venda (Recebe um Map/JSON direto)
  Future<int> insertTransaction(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('transactions', row);
  }

  // Ler Todas
  Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await database;
    return await db.query('transactions', orderBy: "id DESC");
  }
}
