class RegisterController {
  // Memastikan semua input valid
  bool isAllInputValid(
    String inputName,
    bool inputNameTouched,
    String inputPhone,
    bool inputPhoneTouched,
    String inputCity,
    bool inputCityTouched,
    String inputEmail,
    bool inputEmailTouched,
    // String inputBirthDate,
    // bool inputBirthDateTouched,
    // String inputJob,
    // bool inputJobTouched,
  ) {
    return getInputNameError(inputName, inputNameTouched) != null;
    getInputPhoneError(inputPhone, inputPhoneTouched) != null;
    getInputCityError(inputCity, inputCityTouched) != null;
    getInputEmailError(inputEmail, inputEmailTouched) != null;
    // getInputBirthDateError(inputBirthDate, inputBirthDateTouched) != null ||
    // getInputJobError(inputJob, inputJobTouched) != null;
  }

  // Validasi Nama Lengkap
  String? getInputNameError(String inputName, bool inputNameTouched) {
    if (!inputNameTouched) {
      return null;
    }

    if (inputName.isEmpty) {
      return "Nama harus diisi";
    }
    return null;
  }

  // Validasi nomor telepon
  String? getInputPhoneError(String inputPhone, bool inputPhoneTouched) {
    if (!inputPhoneTouched) {
      return null;
    }

    if (inputPhone.isEmpty) {
      return 'Nomor Telepon Harus diisi';
    }
    return null;
  }

  // Validasi Kota domisili
  String? getInputCityError(String inputCity, bool inputCityTouched) {
    if (!inputCityTouched) {
      return null;
    }

    if (inputCity.isEmpty) {
      return 'Kota Domisili Harus diisi';
    }
    return null;
  }

  // Validasi email
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
