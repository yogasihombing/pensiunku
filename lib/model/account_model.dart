import 'package:pensiunku/model/option_model.dart';

class AccountModel {
  String? fullName;
  String? phone;
  String? emailAddress;
  String? address;
  OptionModel? province;
  OptionModel? city;
  OptionModel? job;
  OptionModel? gender;
  DateTime? birthDate;

  AccountModel({
    this.fullName,
    this.phone,
    this.emailAddress,
    this.province,
    this.city,
    this.job,
    this.gender,
    this.birthDate,
  });
}
