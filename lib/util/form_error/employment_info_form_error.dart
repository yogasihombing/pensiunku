class EmploymentInfoFormError {
  final String? errorSalary;

  EmploymentInfoFormError({
    this.errorSalary,
  });

  bool get isValid {
    return errorSalary == null;
  }
}
