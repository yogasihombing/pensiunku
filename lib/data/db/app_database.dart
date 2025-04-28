import 'package:flutter/widgets.dart';
import 'package:pensiunku/data/db/article_dao.dart';
import 'package:pensiunku/data/db/notification_dao.dart';
import 'package:pensiunku/data/db/toko/promo_dao.dart';
import 'package:pensiunku/data/db/faq_dao.dart';
import 'package:pensiunku/data/db/live_update_dao.dart';
import 'package:pensiunku/data/db/referral_dao.dart';
import 'package:pensiunku/data/db/salary_place_dao.dart';
import 'package:pensiunku/data/db/shipping_dao.dart';
import 'package:pensiunku/data/db/submission_dao.dart';
import 'package:pensiunku/data/db/theme_dao.dart';
import 'package:pensiunku/data/db/user_dao.dart';
import 'package:pensiunku/model/notification_model.dart';
import 'package:pensiunku/model/toko/promo_model.dart';
import 'package:pensiunku/model/salary_place_model.dart';
import 'package:pensiunku/model/submission_model.dart';
import 'package:pensiunku/model/theme_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  /// The local database's name.
  static const DB_NAME = 'ies_mobile.db';

  /// The database object.
  late Database _database;

  // FAQ table's data access object.
  late FaqDao faqDao;

  /// [LiveUpdateModel] table's data access object.
  late LiveUpdateDao liveUpdateDao;

  /// [PromoModel] table's data access object.
  late PromoDao promoDao;

  /// [ArticleModel] table's data access object.
  late ArticleDao articleDao;

  /// [UserModel] table's data access object.
  late UserDao userDao;

  /// [NotificationModel] table's data access object.
  late NotificationDao notificationDao;

  /// [SubmissionModel] table's data access object.
  late SubmissionDao submissionDao;

  /// [SalaryPlaceModel] table's data access object.
  late SalaryPlaceDao salaryPlaceDao;

  /// [ReferralModel] table's data access object.
  late ReferralDao referralDao;

  /// [ThemeModel] table's data access object.
  late ThemeDao themeDao;

  /// [ShippingAddress] table's data access object.
  late ShippingDao shippingDao;

  /// The database object getter.
  Database get database => _database;

  static final AppDatabase _singleton = AppDatabase._internal();

  factory AppDatabase() {
    return _singleton;
  }

  AppDatabase._internal();

  _onCreateTables(Database database) async {
    await database.execute('''
        CREATE TABLE ${LiveUpdateDao.TABLE_NAME}(
          l2 TEXT PRIMARY KEY,
          image TEXT,
          l1 TEXT,
          l1_millis INT,
          l3 TEXT
        )
        ''');
    await database.execute('''
        CREATE TABLE ${FaqDao.TABLE_NAME}(
          pertanyaan TEXT PRIMARY KEY,
          kategori_faq TEXT,
          jawaban TEXT,
          item_order INT
        )
        ''');
    await database.execute('''
        CREATE TABLE ${FaqDao.CATEGORY_TABLE_NAME}(
          name TEXT PRIMARY KEY,
          item_order INT
        )
        ''');
    await database.execute('''
        CREATE TABLE ${PromoDao.TABLE_NAME}(
          image TEXT PRIMARY KEY,
          url TEXT,
          item_order INT
        )
        ''');
    await database.execute('''
        CREATE TABLE ${ArticleDao.CATEGORY_TABLE_NAME}(
          name TEXT PRIMARY KEY,
          item_order INT
        )
        ''');
    await database.execute('''
        CREATE TABLE ${ArticleDao.TABLE_NAME}(
          title TEXT PRIMARY KEY,
          image TEXT,
          url TEXT,
          category TEXT,
          item_order INT,
          id INT
        )
        ''');
    await database.execute('''
        CREATE TABLE ${UserDao.TABLE_NAME}(
          id INT PRIMARY KEY,
          telepon TEXT,
          username TEXT,
          email TEXT,
          alamat TEXT,
          kota TEXT,
          tanggal_lahir TEXT,
          pekerjaan TEXT,
          jenis_kelamin TEXT,
          agama TEXT,
          provinsi TEXT,
          kecamatan TEXT,
          kelurahan TEXT,
          kodepos TEXT
        )
        ''');
    await database.execute('''
        CREATE TABLE ${NotificationDao.TABLE_NAME}(
          id INT PRIMARY KEY,
          title TEXT,
          content TEXT,
          created_at TEXT,
          read_at TEXT,
          url TEXT
        )
        ''');
    await database.execute('''
        CREATE TABLE ${SubmissionDao.TABLE_NAME}(
          id INT PRIMARY KEY,
          foto_ktp TEXT,
          foto_selfie TEXT,
          produk TEXT,
          name TEXT,
          phone TEXT,
          tanggal_lahir TEXT,
          gaji INT,
          tenorbulan INT,
          plafond INT,
          nama_bank TEXT,
          instansi TEXT,
          nama_instansi TEXT,
          nip TEXT,
          golongan TEXT,
          estimasi_gaji INT,
          tmt_pensiun TEXT,
          instansi_pensiun TEXT,
          nama_ktp TEXT,
          nik_ktp TEXT,
          alamat_ktp TEXT,
          pekerjaan_ktp TEXT,
          tanggal_lahir_ktp TEXT,
          submitted_at TEXT,
          created_at TEXT,
          bersih INT,
          angsuran INT
        )
        ''');
    await database.execute('''
        CREATE TABLE ${SalaryPlaceDao.TABLE_NAME}(
          id INT PRIMARY KEY,
          text TEXT
        )
        ''');
    await database.execute('''
        CREATE TABLE ${ReferralDao.TABLE_NAME}(
          id INT PRIMARY KEY,
          foto_ktp TEXT,
          nama_ktp TEXT,
          nik_ktp TEXT,
          alamat_ktp TEXT,
          pekerjaan_ktp TEXT,
          tanggal_lahir_ktp TEXT,
          referal TEXT
        )
        ''');
    await database.execute('''
        CREATE TABLE ${ThemeDao.TABLE_NAME}(
          parameter TEXT PRIMARY KEY,
          value TEXT
        )
        ''');
    await database.execute('''
        CREATE TABLE ${ShippingDao.TABLE_NAME}(
          id INT PRIMARY KEY,
          address TEXT,
          province TEXT,
          city TEXT,
          subdistrict TEXT,
          postal_code TEXT,
          mobile TEXT,
          id_user INT,
          is_primary INT,
          kodeongkir INT
        )
        ''');
  }

  init() async {
    // Avoid errors caused by flutter upgrade.
    WidgetsFlutterBinding.ensureInitialized();
    _database = await openDatabase(
      join(
        await getDatabasesPath(),
        DB_NAME,
      ),
      onCreate: (Database database, int version) async {
        await _onCreateTables(database);
      },
      onUpgrade: (Database database, int oldVersion, int newVersion) async {
        await database.execute('DROP TABLE IF EXISTS ${FaqDao.TABLE_NAME}');
        await database
            .execute('DROP TABLE IF EXISTS ${FaqDao.CATEGORY_TABLE_NAME}');
        await database
            .execute('DROP TABLE IF EXISTS ${LiveUpdateDao.TABLE_NAME}');
        await database.execute('DROP TABLE IF EXISTS ${PromoDao.TABLE_NAME}');
        await database
            .execute('DROP TABLE IF EXISTS ${ArticleDao.CATEGORY_TABLE_NAME}');
        await database.execute('DROP TABLE IF EXISTS ${ArticleDao.TABLE_NAME}');
        await database.execute('DROP TABLE IF EXISTS ${UserDao.TABLE_NAME}');
        await database
            .execute('DROP TABLE IF EXISTS ${NotificationDao.TABLE_NAME}');
        await database
            .execute('DROP TABLE IF EXISTS ${SubmissionDao.TABLE_NAME}');
        await database
            .execute('DROP TABLE IF EXISTS ${SalaryPlaceDao.TABLE_NAME}');
        await database
            .execute('DROP TABLE IF EXISTS ${ReferralDao.TABLE_NAME}');
        await database
            .execute('DROP TABLE IF EXISTS ${ThemeDao.TABLE_NAME}');
        await database
            .execute('DROP TABLE IF EXISTS ${ShippingDao.TABLE_NAME}');
        await _onCreateTables(database);
      },
      version: 33,
    );

    faqDao = FaqDao(_database);
    liveUpdateDao = LiveUpdateDao(_database);
    promoDao = PromoDao(_database);
    articleDao = ArticleDao(_database);
    userDao = UserDao(_database);
    notificationDao = NotificationDao(_database);
    submissionDao = SubmissionDao(_database);
    salaryPlaceDao = SalaryPlaceDao(_database);
    referralDao = ReferralDao(_database);
    themeDao = ThemeDao(_database);
    shippingDao = ShippingDao(_database);
  }
}
