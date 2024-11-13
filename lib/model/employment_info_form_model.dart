import 'package:pensiunku/model/option_model.dart';

class EmploymentInfoFormModel {
  final OptionModel? institution;
  final String? institutionName;
  final String? nip;
  final OptionModel? group;
  final int? salary;
  final DateTime? tmtRetirement;
  final OptionModel? retirementInstitution;

  EmploymentInfoFormModel({
    this.institution,
    this.institutionName,
    this.nip,
    this.group,
    this.salary,
    this.tmtRetirement,
    this.retirementInstitution,
  });
}
