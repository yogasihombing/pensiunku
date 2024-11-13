class PraPensiunFormError {
  final String? errorName;
  final String? errorPhone;
  final String? errorBirthDate;
  final String? errorAge;
  final String? errorSalary;
  final String? errorSalaryPlace;
  final String? errorTenor;
  final String? errorPlafond;
  final String? successPlafond;

  PraPensiunFormError({
    this.errorName,
    this.errorPhone,
    this.errorBirthDate,
    this.errorAge,
    this.errorSalary,
    this.errorSalaryPlace,
    this.errorTenor,
    this.errorPlafond,
    this.successPlafond,
  });

  bool get isValid {
    return errorName == null &&
        errorPhone == null &&
        errorBirthDate == null &&
        errorAge == null &&
        errorSalary == null &&
        errorSalaryPlace == null &&
        errorTenor == null &&
        errorPlafond == null;
  }
}
