import 'package:pensiunku/model/option_model.dart';

class ReligionRepository {
  static List<OptionModel> religions = [
      OptionModel(id: 1, text: 'ISLAM'),
      OptionModel(id: 2, text: 'KRISTERN'),
      OptionModel(id: 3, text: 'KATOLIK'),
      OptionModel(id: 4, text: 'BUDHA'),
      OptionModel(id: 5, text: 'HINDU'),
      OptionModel(id: 6, text: 'KONGHUCHU'),
      OptionModel(id: 7, text: 'ALIRAN KEPERCAYAAN'),
  ];

  static List<OptionModel> getReligions() {
    return religions;
  }

  static OptionModel getReligionById(String religionId){
    final matchedReligion = religions.where((element) => element.id.toString() == religionId);
    if (matchedReligion.isNotEmpty){
      return matchedReligion.first;
    }
    return OptionModel(id: 0, text: '');
  }


}
