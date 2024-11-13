import 'package:pensiunku/model/option_model.dart';
import 'package:pensiunku/repository/base_repository.dart';

class DebtBankRepository extends BaseRepository {
  static List<OptionModel> getAllDb() {
    return [
      OptionModel(id: 1, text: 'Tidak Punya Pinjaman'),
      OptionModel(id: 2, text: 'Bank BNI'),
      OptionModel(id: 3, text: 'Bank Woori Saudara'),
      OptionModel(id: 4, text: 'Bank Bumi Arta'),
      OptionModel(id: 5, text: 'Bank Bukopin'),
      OptionModel(id: 6, text: 'Bank BTPN'),
      OptionModel(id: 7, text: 'Bank BJB'),
      OptionModel(id: 8, text: 'Bank Yudha Bakti'),
      OptionModel(id: 9, text: 'Bank BRI'),
      OptionModel(id: 10, text: 'Bank Mandiri'),
      OptionModel(id: 11, text: 'Bank Woori Mantap'),
      OptionModel(id: 12, text: 'BPR'),
      OptionModel(id: 13, text: 'Bank Daerah'),
      OptionModel(id: 14, text: 'Kantor Pos'),
    ];
  }
}
