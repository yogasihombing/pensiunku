import 'package:pensiunku/model/article_model.dart';
import 'package:sqflite/sqflite.dart';

class ArticleDao {
  final Database database;

  ArticleDao(this.database);

  static const CATEGORY_TABLE_NAME = 'article_categories';
  static const TABLE_NAME = 'articles';

  insertCategories(List<ArticleCategoryModel> articleCategories) async {
    Batch batch = database.batch();
    articleCategories.asMap().forEach((index, category) {
      batch.insert(
        CATEGORY_TABLE_NAME,
        category.toJson(index),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
    await batch.commit();
  }

  insert(List<ArticleModel> articles) async {
    Batch batch = database.batch();
    articles.asMap().forEach((index, article) {
      batch.insert(
        TABLE_NAME,
        article.toJson(index),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
    await batch.commit();
  }

  Future<List<ArticleCategoryModel>> getAllCategories() async {
    final articleCategoriesJson = await database.query(
      CATEGORY_TABLE_NAME,
      orderBy: 'item_order asc',
    );
    if (articleCategoriesJson.length > 0) {
      List<ArticleCategoryModel> articleCategories = [];
      for (var i = 0; i < articleCategoriesJson.length; i++) {
        articleCategories.add(
          ArticleCategoryModel.fromJson(articleCategoriesJson[i]),
        );
      }
      return articleCategories;
    }
    return [];
  }

  Future<List<ArticleModel>> getAll(String categoryName) async {
    final articlesJson = await database.query(
      TABLE_NAME,
      orderBy: 'item_order asc',
      where: "category = ?",
      whereArgs: [categoryName],
    );
    if (articlesJson.length > 0) {
      List<ArticleModel> articles = [];
      for (var i = 0; i < articlesJson.length; i++) {
        articles.add(
          ArticleModel.fromJson(articlesJson[i]),
        );
      }
      return articles;
    }
    return [];
  }

  removeAllCategories() async {
    await database.delete(
      CATEGORY_TABLE_NAME,
    );
  }

  removeAll(String categoryName) async {
    await database.delete(
      TABLE_NAME,
      where: "category = ?",
      whereArgs: [categoryName],
    );
  }
}
