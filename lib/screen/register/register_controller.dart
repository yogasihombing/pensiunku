class RegisterController {
  bool isAllInputValid(
      String inputName,
      bool inputNameTouched,
      // String inputEmail,
      // bool inputEmailTouched,
      // String inputBirthDate,
      // bool inputBirthDateTouched,
      // String inputJob,
      // bool inputJobTouched,
      ) {
    return getInputNameError(inputName, inputNameTouched) != null;
    // getInputEmailError(inputEmail, inputEmailTouched) != null ||
    // getInputBirthDateError(inputBirthDate, inputBirthDateTouched) != null ||
    // getInputJobError(inputJob, inputJobTouched) != null;
  }

  String? getInputNameError(String inputName, bool inputNameTouched) {
    if (!inputNameTouched) {
      return null;
    }

    if (inputName.isEmpty) {
      return "Nama harus diisi";
    }
    return null;
  }

  String? getInputEmailError(String inputEmail, bool inputEmailTouched) {
    if (!inputEmailTouched) {
      return null;
    }

    if (inputEmail.isEmpty) {
      return "Email harus diisi";
    }
    return null;
  }

  String? getInputBirthDateError(
      String inputBirthDate, bool inputBirthDateTouched) {
    if (!inputBirthDateTouched) {
      return null;
    }

    if (inputBirthDate.isEmpty) {
      return "Tanggal Lahir harus diisi";
    }
    return null;
  }

  String? getInputJobError(String inputJob, bool inputJobTouched) {
    if (!inputJobTouched) {
      return null;
    }

    if (inputJob.isEmpty) {
      return "Pekerjaan harus diisi";
    }
    return null;
  }
}