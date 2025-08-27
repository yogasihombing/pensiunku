import 'package:email_validator/email_validator.dart';

class AccountInfoController {
  bool isAllInputValid(
    String inputName,
    String inputPhone,
    String inputEmail,
  ) {
    return getInputNameError(inputName) != null ||
        getInputPhoneError(inputPhone) != null ||
        getInputEmailError(inputEmail) != null;
  }

  String? getInputNameError(String inputName) {
    if (inputName.isEmpty) {
      return "Nama harus diisi";
    }
    return null;
  }

  String? getInputPhoneError(String inputPhone) {
    if (inputPhone.isEmpty) {
      return "No. Handphone harus diisi";
    } else if (!inputPhone.trim().startsWith('0')) {
      return "Nomor telepon harus mulai dari angka 0";
    } else if (inputPhone.trim().length < 8) {
      return "No. Handphone harus terdiri dari min. 8 karakter";
    }
    return null;
  }

  String? getInputEmailError(String inputEmail) {
    if (inputEmail.isNotEmpty) {
      if (!EmailValidator.validate(inputEmail.trim())) {
        return "Email harus valid";
      }
    }
    return null;
  }
}