class PegawaiAktifFormError {
  final String? errorName;
  final String? errorPhone;
  final String? errorBirthDate;
  final String? errorSalary;
  final String? errorTenor;
  final String? errorPlafond;
  final String? successPlafond;

  PegawaiAktifFormError({
    this.errorName,
    this.errorPhone,
    this.errorBirthDate,
    this.errorSalary,
    this.errorTenor,
    this.errorPlafond,
    this.successPlafond,
  });

  bool get isValid {
    return errorName == null &&
        errorPhone == null &&
        errorBirthDate == null &&
        errorSalary == null &&
        errorTenor == null &&
        errorPlafond == null;
  }
}
