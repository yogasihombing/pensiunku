class KtpFormError {
  final String? errorNik;
  final String? errorName;
  final String? errorAddress;
  final String? errorBirthDate;
  final String? errorJob;

  KtpFormError({
    this.errorNik,
    this.errorName,
    this.errorAddress,
    this.errorBirthDate,
    this.errorJob,
  });

  bool get isValid {
    return errorNik == null &&
        errorName == null &&
        errorAddress == null &&
        errorBirthDate == null &&
        errorJob == null;
  }
}
