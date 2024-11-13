import 'package:pensiunku/model/submission_model.dart';
import 'package:sqflite/sqflite.dart';

class SubmissionDao {
  final Database database;

  SubmissionDao(this.database);

  static const TABLE_NAME = 'submissions';

  insert(List<SubmissionModel> submission) async {
    Batch batch = database.batch();
    submission.asMap().forEach((index, submission) {
      batch.insert(
        TABLE_NAME,
        submission.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
    await batch.commit();
  }

  Future<List<SubmissionModel>> getAll() async {
    final submissionsJson = await database.query(
      TABLE_NAME,
      orderBy: 'id asc',
    );
    if (submissionsJson.length > 0) {
      List<SubmissionModel> submissions = [];
      for (var i = 0; i < submissionsJson.length; i++) {
        submissions.add(
          SubmissionModel.fromJson(submissionsJson[i]),
        );
      }
      return submissions;
    }
    return [];
  }

  removeAll() async {
    await database.delete(
      TABLE_NAME,
    );
  }
}
