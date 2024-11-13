class KtpFormReferalError {
  final String? errorNik;
  final String? errorName;
  final String? errorAddress;
  final String? errorBirthDate;
  final String? errorJob;
  final String? errorReferal;

  KtpFormReferalError({
    this.errorNik,
    this.errorName,
    this.errorAddress,
    this.errorBirthDate,
    this.errorJob,
    this.errorReferal,
  });

  bool get isValid {
    return errorNik == null &&
        errorName == null &&
        errorAddress == null &&
        errorBirthDate == null &&
        errorJob == null &&
        errorReferal == null;
  }
}
