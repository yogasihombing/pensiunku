import 'package:pensiunku/model/option_model.dart';

class GenderRepository {
  static List<OptionModel> genders = [
    OptionModel(id: 1, text: 'LAKI-LAKI'),
    OptionModel(id: 2, text: 'PEREMPUAN'),
  ];

  static List<OptionModel> getGenders() {
    return genders;
  }

  static OptionModel getGenderById(String genderId) {
    final matchedGender =
        genders.where((element) => element.id.toString() == genderId);
    if (matchedGender.isNotEmpty) {
      return matchedGender.first;
    }
    return OptionModel(id: 0, text: '');
  }
}
