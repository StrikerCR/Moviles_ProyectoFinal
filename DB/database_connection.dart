import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBConnection {
  static final DBConnection _instance = DBConnection._internal();
  static Database? _database;

  factory DBConnection() {
    return _instance;
  }

  DBConnection._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'escom.db');

    return await openDatabase(
      path,
      version: 3, // Cambia la versión si haces modificaciones
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Actualiza la base de datos eliminando y recreando las tablas
        await db.execute('DROP TABLE IF EXISTS alumno');
        await db.execute('DROP TABLE IF EXISTS directivos');
        await _createTables(db);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    // Crear tabla alumno
    await db.execute('''
      CREATE TABLE alumno (
        noBoleta TEXT PRIMARY KEY,
        nombre_es TEXT NOT NULL,
        contraseña TEXT NOT NULL,
        correo TEXT NOT NULL
      )
    ''');

    // Insertar datos iniciales en tabla alumno
    await db.execute('''
      INSERT INTO alumno (noBoleta, nombre_es, contraseña, correo) VALUES
      ("2022630203", "Rafael Cabañas Rocha", "ch1chen0l", "rcabanasr28@gmail.com"),
      ("2022630240", "Diana Paola Fernández Baños", "burbujas26", "dfernandezb26@gmail.com"),
      ("2022630001", "Maximo Rocha Baños", "caradebola", "max@max.com");
    ''');

    // Crear tabla directivos
    await db.execute('''
      CREATE TABLE directivos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre_dir TEXT NOT NULL,
        depto_direc TEXT NOT NULL,
        correo_direc TEXT NOT NULL,
        telefono_direc TEXT NOT NULL
      )
    ''');

    // Insertar datos iniciales en tabla directivos
    await db.execute('''
      INSERT INTO directivos (nombre_dir, depto_direc, correo_direc, telefono_direc) VALUES
      ("M. EN C. ANDRÉS ORTIGOZA CAMPOS", "Dirección", "direccion_escom@ipn.mx", "57296000 Ext. 46188"),
      ("M. EN C. IGNACIO RÍOS DE LA TORRE", "Decanato", "", "57296000 Ext. 52024"),
      ("M. EN P. LAURA LAZCANO XOXOTLA", "Coordinación de Enlace y Gestión Técnica", "enlace_escom@ipn.mx", "57296000 Ext. 52013"),
      ("M. EN D.T.I. RICARDO ÁNGEL AGUILAR PÉREZ", "Unidad de Informática", "udi_escom@ipn.mx", "57296000 Ext. 52015"),
      ("M. EN C. IVÁN GIOVANNY MOSSO GARCÍA", "Subdirección Académica", "sub_academica_escom@ipn.mx", "57296000 Ext. 52023"),
      ("M. EN A.P. MARÍA DEL ROSARIO GALEANA CHÁVEZ", "Depto. de Ciencias e Ingeniería de la Computación", "cic_escom@ipn.mx", "57296000 Ext. 52067"),
      ("DRA. DENI DEL CARMEN BECERRIL ELIAS", "Depto. de Ingeniería en Sistemas Computacionales", "escom_disc@ipn.mx", "57296000 Ext. 52072"),
      ("DRA. CLAUDIA CELIA DÍAZ HUERTA", "Depto. de Innovación Educativa", "innova.escom@ipn.mx", "57296000 Ext. 52044"),
      ("LIC. DIANA GABRIELA HORCASITAS DOMÍNGUEZ", "Depto. de Evaluación y Seguimiento Académico", "es_academico_escom@ipn.mx", "57296000 Ext. 52021"),
      ("M. EN ADM. DE N. MARÍA MAGDALENA SALDIVAR ALMOREJO", "Depto. de Formación Integral e Institucional", "fii_escom@ipn.mx", "57296000 Ext. 52020"),
      ("M. EN C. ELIZABETH MORENO GALVÁN", "Unidad de Tecnología Educativa y Campus Virtual", "uteycv.escom@ipn.mx", "57296000 Ext. 52011");
    ''');
  }
}
