import 'package:pensiunku/model/option_model.dart';
import 'package:pensiunku/repository/base_repository.dart';

class StatusPensiunRepository extends BaseRepository {
  static List<OptionModel> getAllDb() {
    return [
      OptionModel(id: 1, text: 'Pensiun'),
      OptionModel(id: 2, text: 'Pensiun Janda/Duda'),
    ];
  }
}
