class PensiunFormError {
  final String? errorName;
  final String? errorPhone;
  final String? errorBirthDate;
  final String? errorSalary;
  final String? errorsalaryPlace;
  final String? errorTenor;
  final String? errorPlafond;
  final String? successPlafond;

  PensiunFormError({
    this.errorName,
    this.errorPhone,
    this.errorBirthDate,
    this.errorSalary,
    this.errorsalaryPlace,
    this.errorTenor,
    this.errorPlafond,
    this.successPlafond,
  });

  bool get isValid {
    return errorName == null &&
        errorPhone == null &&
        errorBirthDate == null &&
        errorSalary == null &&
        errorsalaryPlace == null &&
        errorTenor == null &&
        errorPlafond == null;
  }
}
