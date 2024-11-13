import 'package:pensiunku/model/faq_category_model.dart';
import 'package:sqflite/sqflite.dart';

class FaqDao {
  final Database database;

  FaqDao(this.database);

  static const CATEGORY_TABLE_NAME = 'faq_categories';
  static const TABLE_NAME = 'faqs';

  insert(List<FaqCategoryModel> faqCategories) async {
    Batch batch = database.batch();
    faqCategories.asMap().forEach((index, category) {
      batch.insert(
        CATEGORY_TABLE_NAME,
        category.toJson(index),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      category.faqs.asMap().forEach((index2, faq) {
        batch.insert(
          TABLE_NAME,
          faq.toJson(category.name, index2),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    });
    await batch.commit();
  }

  Future<List<FaqCategoryModel>> getAll() async {
    final categoryFaqsJson = await database.query(
      CATEGORY_TABLE_NAME,
      orderBy: 'item_order asc',
    );
    if (categoryFaqsJson.length > 0) {
      List<FaqCategoryModel> faqCategories = [];
      for (var i = 0; i < categoryFaqsJson.length; i++) {
        var category = categoryFaqsJson[i];
        List<Map<String, dynamic>> faqsJson = await database.query(
          TABLE_NAME,
          where: "kategori_faq = ?",
          whereArgs: [category['name']],
          orderBy: 'item_order asc',
        );
        faqCategories.add(
          FaqCategoryModel.fromJson(category, faqsJson),
        );
      }
      return faqCategories;
    }
    return [];
  }

  removeAll() async {
    await database.delete(
      CATEGORY_TABLE_NAME,
    );
    await database.delete(
      TABLE_NAME,
    );
  }
}
