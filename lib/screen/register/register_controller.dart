class RegisterController {
  // Memastikan semua input valid
  bool isAllInputValid(
    String inputName,
    bool inputNameTouched,
    String inputEmail,
    bool inputEmailTouched,
  ) {
    return getInputNameError(inputName, inputNameTouched) == null &&
        getInputEmailError(inputEmail, inputEmailTouched) == null;
  }

  // Validasi Nama Lengkap dengan aturan yang lebih ketat
  String? getInputNameError(String inputName, bool touched) {
    if (!touched) return null;

    // Cek apakah nama kosong
    if (inputName.trim().isEmpty) {
      return "Nama lengkap harus diisi";
    }

    // Cek panjang minimum nama
    if (inputName.trim().length < 2) {
      return "Nama lengkap minimal 2 karakter";
    }

    // Cek panjang maksimum nama
    if (inputName.trim().length > 50) {
      return "Nama lengkap maksimal 50 karakter";
    }

    // Cek karakter yang diperbolehkan (huruf dan spasi)
    if (!RegExp(r'^[a-zA-Z\s]*$').hasMatch(inputName)) {
      return "Nama lengkap hanya boleh berisi huruf dan spasi";
    }

    return null;
  }

  // Validasi email dengan aturan yang lebih ketat
  String? getInputEmailError(String inputEmail, bool touched) {
    if (!touched) return null;

    // Cek apakah email kosong
    if (inputEmail.trim().isEmpty) {
      return "Email harus diisi";
    }

    // Validasi format email dan domain gmail.com
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@gmail\.com$',
      caseSensitive: false,
    );

    if (!emailRegex.hasMatch(inputEmail.trim())) {
      return "Masukkan email Gmail yang valid";
    }

    // Cek panjang minimum sebelum @gmail.com
    final localPart = inputEmail.split('@')[0];
    if (localPart.length < 3) {
      return "Bagian sebelum @gmail.com minimal 3 karakter";
    }

    // Cek panjang maksimum email
    if (inputEmail.length > 254) {
      return "Email terlalu panjang";
    }

    return null;
  }
}


// class RegisterController {
//   // Memastikan semua input valid
//   bool isAllInputValid(
//     String inputName,
//     bool inputNameTouched,
//     String inputEmail,
//     bool inputEmailTouched,
//     // String inputBirthDate,
//     // bool inputBirthDateTouched,
//     // String inputJob,
//     // bool inputJobTouched,
//   ) {
//     return getInputNameError(inputName, inputNameTouched) == null &&
//         getInputEmailError(inputEmail, inputEmailTouched) == null;
//     // getInputBirthDateError(inputBirthDate, inputBirthDateTouched) != null ||
//     // getInputJobError(inputJob, inputJobTouched) != null;
//   }

//   // Validasi Nama Lengkap
//   String? getInputNameError(String inputName, bool touched) {
//     if (touched && inputName.trim().isEmpty) {
//       return "Nama lengkap harus diisi";
//     }
//     return null;
//   }

//   // Validasi email
//   String? getInputEmailError(String inputEmail, bool touched) {
//     if (touched && inputEmail.trim().isEmpty) {
//       return "Email harus diisi";
//     }
//     return null;
//   }

  // // Validasi nomor telepon
  // String? getInputPhoneError(String inputPhone, bool inputPhoneTouched) {
  //   if (!inputPhoneTouched) {
  //     return null;
  //   }

  //   if (inputPhone.isEmpty) {
  //     return 'Nomor Telepon Harus diisi';
  //   }
  //   return null;
  // }

  // // Validasi Kota domisili
  // String? getInputCityError(String inputCity, bool inputCityTouched) {
  //   if (!inputCityTouched) {
  //     return null;
  //   }

  //   if (inputCity.isEmpty) {
  //     return 'Kota Domisili Harus diisi';
  //   }
  //   return null;
  // }

  // String? getInputBirthDateError(
  //     String inputBirthDate, bool inputBirthDateTouched) {
  //   if (!inputBirthDateTouched) {
  //     return null;
  //   }

  //   if (inputBirthDate.isEmpty) {
  //     return "Tanggal Lahir harus diisi";
  //   }
  //   return null;
  // }

  // String? getInputJobError(String inputJob, bool inputJobTouched) {
  //   if (!inputJobTouched) {
  //     return null;
  //   }

  //   if (inputJob.isEmpty) {
  //     return "Pekerjaan harus diisi";
  //   }
  //   return null;
  // }

