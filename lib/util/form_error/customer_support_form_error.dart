class CustomerSupportFormError {
  final String? errorName;
  final String? errorPhone;
  final String? errorEmail;
  final String? errorQuestion;

  CustomerSupportFormError({
    this.errorName,
    this.errorPhone,
    this.errorEmail,
    this.errorQuestion,
  });

  bool get isValid {
    return errorName == null &&
        errorPhone == null &&
        errorEmail == null &&
        errorQuestion == null;
  }
}
