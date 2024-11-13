class PlatinumFormError {
  final String? errorName;
  final String? errorPhone;
  final String? errorBirthDate;
  final String? errorSalary;
  final String? errorAngsuran;
  final String? errorTenor;
  final String? errorPlafond;
  final String? successPlafond;

  PlatinumFormError({
    this.errorName,
    this.errorPhone,
    this.errorBirthDate,
    this.errorSalary,
    this.errorAngsuran,
    this.errorTenor,
    this.errorPlafond,
    this.successPlafond,
  });

  bool get isValid {
    return errorName == null &&
        errorPhone == null &&
        errorBirthDate == null &&
        errorAngsuran == null &&
        errorSalary == null &&
        errorTenor == null &&
        errorPlafond == null;
  }
}
