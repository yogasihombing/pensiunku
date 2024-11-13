import 'package:age_calculator/age_calculator.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:email_validator/email_validator.dart';
import 'package:pensiunku/util/form_error/customer_support_form_error.dart';
import 'package:pensiunku/util/form_error/employment_info_form_error.dart';
import 'package:pensiunku/util/form_error/ktp_form_error.dart';
import 'package:pensiunku/util/form_error/ktp_referal_form_error.dart';
import 'package:pensiunku/util/form_error/pegawai_aktif_form_error.dart';
import 'package:pensiunku/util/form_error/pensiun_form_error.dart';
import 'package:pensiunku/util/form_error/platinum_form_error.dart';
import 'package:pensiunku/util/form_error/pra_pensiun_form_error.dart';

class FormUtil {
  static String? onSubmitPegawaiAktifForm({
    String? name,
    String? phone,
    DateTime? birthDate,
    String? salary,
    String? tenor,
    String? plafond,
  }) {
    List<String?> inputs = [
      name,
      phone,
      salary,
      tenor,
      plafond,
    ];
    if (inputs.any((input) => input?.isEmpty == true || input == null)) {
      return 'Lengkapi data di simulasi';
    }
    PegawaiAktifFormError formError = validatePegawaiAktifForm(
      phone: phone,
      birthDate: birthDate,
      salary: salary,
      tenor: tenor,
      plafond: plafond,
    );
    if (!formError.isValid) {
      return 'Masih terdapat error di form simulasi';
    }
    return null;
  }

  static String? onSubmitPensiunForm({
    String? name,
    String? phone,
    String? statusPensiun,
    DateTime? birthDate,
    String? salary,
    String? salaryPlace,
    String? tenor,
    String? plafond,
    String? sisaHutang,
    String? bankHutang,
  }) {
    List<String?> inputs = [
      name,
      phone,
      statusPensiun,
      salary,
      salaryPlace,
      tenor,
      plafond,
      bankHutang,
    ];
    if (inputs.any((input) => input?.isEmpty == true || input == null)) {
      return 'Lengkapi data di simulasi';
    }
    PensiunFormError formError = validatePensiunForm(
      phone: phone,
      birthDate: birthDate,
      salary: salary,
      tenor: tenor,
      plafond: plafond,
    );
    if (!formError.isValid) {
      print(formError);
      return 'Masih terdapat error di form simulasi';
    }
    return null;
  }

  static String? onSubmitPraPensiunForm({
    String? name,
    String? phone,
    DateTime? birthDate,
    // String? age,
    String? salary,
    String? salaryPlace,
    String? tenor,
    String? plafond,
  }) {
    List<String?> inputs = [
      name,
      phone,
      // age,
      salary,
      salaryPlace,
      tenor,
      plafond,
    ];
    if (inputs.any((input) => input?.isEmpty == true || input == null)) {
      return 'Lengkapi data di simulasi';
    }
    PraPensiunFormError formError = validatePraPensiunForm(
      phone: phone,
      birthDate: birthDate,
      // age: age,
      salary: salary,
      tenor: tenor,
      plafond: plafond,
    );
    if (!formError.isValid) {
      return 'Masih terdapat error di form simulasi';
    }
    return null;
  }

  static String? onSubmitPlatinumForm({
    String? name,
    String? phone,
    DateTime? birthDate,
    String? salary,
    String? angsuran,
    String? tenor,
    String? province,
    String? salaryPlace,
  }) {
    List<String?> inputs = [
      name,
      phone,
      salary,
      angsuran,
      tenor,
      province,
      salaryPlace,
    ];
    if (inputs.any((input) => input?.isEmpty == true || input == null)) {
      print(inputs);
      return 'Lengkapi data di simulasi';
    }
    PlatinumFormError formError = validatePlatinumForm(
      phone: phone,
      birthDate: birthDate,
      salary: salary,
      angsuran: angsuran,
      tenor: tenor,
    );
    if (!formError.isValid) {
      return 'Masih terdapat error di form simulasi';
    }
    return null;
  }

  static String? onSubmitCustomerSupportForm({
    String? name,
    String? phone,
    String? email,
    String? question,
  }) {
    List<String?> inputs = [
      name,
      phone,
      email,
      question,
    ];
    if (inputs.any((input) => input?.isEmpty == true || input == null)) {
      return 'Harap isi form dengan lengkap';
    }
    CustomerSupportFormError formError = validateCustomerSupportForm(
      phone: phone,
      email: email,
      question: question,
    );
    if (!formError.isValid) {
      return 'Masih terdapat error di form';
    }
    return null;
  }

  static String? onSubmitKtpForm({
    String? nik,
    String? name,
    String? address,
    DateTime? birthDate,
    String? job,
  }) {
    List<String?> inputs = [
      nik,
      name,
      address,
      // birthDate,
      job,
    ];
    if (inputs.any((input) => input?.isEmpty == true || input == null)) {
      return 'Harap isi form dengan lengkap';
    }
    KtpFormError formError = validateKtpForm(
      nik: nik,
      birthDate: birthDate,
    );
    if (!formError.isValid) {
      return 'Masih terdapat error di form';
    }
    return null;
  }

  static String? onSubmitKtpReferalForm({
    String? nik,
    String? name,
    String? address,
    DateTime? birthDate,
    String? job,
    String? referal,
  }) {
    List<String?> inputs = [
      nik,
      name,
      address,
      // birthDate,
      job,
      referal,
    ];
    if (inputs.any((input) => input?.isEmpty == true || input == null)) {
      return 'Harap isi form dengan lengkap';
    }
    KtpFormReferalError formError = validateKtpReferalForm(
      nik: nik,
      birthDate: birthDate,
      referal: referal,
    );
    if (!formError.isValid) {
      print(formError);
      return 'Masih terdapat error di form';
    }
    return null;
  }

  static String? onSubmitEmploymentInfoForm({
    String? salary,
  }) {
    EmploymentInfoFormError formError =
        validateEmploymentInfoForm(salary: salary);
    if (!formError.isValid) {
      return 'Masih terdapat error di form';
    }
    return null;
  }

  static PegawaiAktifFormError validatePegawaiAktifForm({
    // String? name,
    String? phone,
    DateTime? birthDate,
    String? salary,
    String? tenor,
    String? plafond,
  }) {
    // Validate phone
    String? errorPhone = validatePhone(phone);
    // Validate birth date
    String? errorBirthDate = validateBirthDate(birthDate, 240, 768);
    // Validate salary
    String? errorSalary = validateSalary(salary);
    // Validate tenor
    String? errorTenor = validateTenor(tenor, birthDate, 768);
    // Validate plafond
    List<String?> validationPlafond = validatePlafond(plafond, salary);
    String? errorPlafond = validationPlafond[0];
    String? successPlafond = validationPlafond[1];
    return PegawaiAktifFormError(
      errorPhone: errorPhone,
      errorBirthDate: errorBirthDate,
      errorSalary: errorSalary,
      errorTenor: errorTenor,
      errorPlafond: errorPlafond,
      successPlafond: successPlafond,
    );
  }

  static PensiunFormError validatePensiunForm({
    // String? name,
    String? phone,
    DateTime? birthDate,
    String? salary,
    String? tenor,
    String? plafond,
  }) {
    // Validate phone
    String? errorPhone = validatePhone(phone);
    // Validate birth date
    String? errorBirthDate = validateBirthDate(birthDate, 480, 888);
    // Validate salary
    String? errorSalary = validateSalary(salary);
    // Validate tenor
    String? errorTenor = validateTenor(tenor, birthDate, 900);
    // Validate plafond
    List<String?> validationPlafond = validatePlafond(plafond, salary);
    String? errorPlafond = validationPlafond[0];
    String? successPlafond = validationPlafond[1];
    return PensiunFormError(
      errorPhone: errorPhone,
      errorBirthDate: errorBirthDate,
      errorSalary: errorSalary,
      errorTenor: errorTenor,
      errorPlafond: errorPlafond,
      successPlafond: successPlafond,
    );
  }

  static PraPensiunFormError validatePraPensiunForm({
    // String? name,
    String? phone,
    String? age,
    DateTime? birthDate,
    String? salary,
    String? tenor,
    String? plafond,
    DateTime? bup,
  }) {
    // Validate phone
    String? errorPhone = validatePhone(phone);
    // Validate age
    // String? errorAge = validateAge(age);
    // Validate birth date
    String? errorBirthDate = validateBirthDate(birthDate, 600, 720);
    // Validate salary
    String? errorSalary = validateSalary(salary);
    // Validate tenor
    String? errorTenor =
        validateTenor(tenor, birthDate, double.maxFinite.toInt());
    // Validate plafond
    List<String?> validationPlafond = validatePlafond(plafond, salary);
    String? errorPlafond = validationPlafond[0];
    String? successPlafond = validationPlafond[1];
    return PraPensiunFormError(
      errorPhone: errorPhone,
      errorBirthDate: errorBirthDate,
      // errorAge: errorAge,
      errorSalary: errorSalary,
      errorTenor: errorTenor,
      errorPlafond: errorPlafond,
      successPlafond: successPlafond,
    );
  }

  static PlatinumFormError validatePlatinumForm({
    // String? name,
    String? phone,
    DateTime? birthDate,
    String? salary,
    String? angsuran,
    String? tenor,
  }) {
    // Validate phone
    String? errorPhone = validatePhone(phone);
    // Validate birth date
    String? errorBirthDate = validateBirthDate(birthDate, 840, 960);
    // Validate salary
    String? errorSalary = validateSalary(salary);
    // Validate angsuran
    String? errorAngsuran = validateAngsuran(angsuran, salary);
    // Validate tenor
    // String? errorTenor =
    //     validateTenor(tenor, birthDate, double.maxFinite.toInt());
    return PlatinumFormError(
      errorPhone: errorPhone,
      errorBirthDate: errorBirthDate,
      errorSalary: errorSalary,
      errorAngsuran: errorAngsuran,
      // errorTenor: errorTenor,
    );
  }

  static EmploymentInfoFormError validateEmploymentInfoForm({
    String? salary,
  }) {
    // Validate salary
    String? errorSalary = validateSalary(salary);
    return EmploymentInfoFormError(
      errorSalary: errorSalary,
    );
  }

  static CustomerSupportFormError validateCustomerSupportForm({
    String? phone,
    String? email,
    String? question,
  }) {
    // Validate phone
    String? errorPhone = validatePhone(phone);
    // Validate email
    String? errorEmail = validateEmail(email);
    // Validate question
    String? errorQuestion = validateQuestion(question);
    return CustomerSupportFormError(
      errorPhone: errorPhone,
      errorEmail: errorEmail,
      errorQuestion: errorQuestion,
    );
  }

  static KtpFormError validateKtpForm({
    String? nik,
    DateTime? birthDate,
  }) {
    // Validate NIK
    String? errorNik = validateNik(nik);
    String? errorBirthDate = validateBirthDate(birthDate, 480, 948);
    return KtpFormError(
      errorNik: errorNik,
      errorBirthDate: errorBirthDate,
    );
  }

  static String? validateNik(String? nik) {
    String? errorNik;
    if (nik?.isNotEmpty == true) {
      if (nik!.length != 16) {
        errorNik = 'NIK harus terdiri dari 16 digit';
      }
    }
    return errorNik;
  }

  static KtpFormReferalError validateKtpReferalForm({
    String? nik,
    DateTime? birthDate,
    String? referal,
  }) {
    // Validate NIK
    String? errorNik = validateNik(nik);
    String? errorBirthDate = validateBirthDate(birthDate, 480, 948);
    String? errorReferal = validateReferal(referal);
    return KtpFormReferalError(
      errorNik: errorNik,
      errorBirthDate: errorBirthDate,
      errorReferal: errorReferal,
    );
  }

  static String? validateReferal(String? referal) {
    String? errorReferal;
    if (referal?.isEmpty == true) {
      errorReferal = 'Kode Referal harus diisi!';
    }
    return errorReferal;
  }

  static String? validateQuestion(String? question) {
    String? errorQuestion;
    if (question?.isNotEmpty == true) {
      if (question!.length < 20) {
        errorQuestion = 'Pertanyaan harus minimal 20 karakter';
      }
    }
    return errorQuestion;
  }

  static String? validateEmail(String? email) {
    String? errorEmail;
    if (email?.isNotEmpty == true) {
      if (!EmailValidator.validate(email!)) {
        errorEmail = 'Email harus valid';
      }
    }
    return errorEmail;
  }

  static String? validatePhone(String? phone) {
    String? errorPhone;
    if (phone?.isNotEmpty == true) {
      if (!phone!.trim().startsWith('0')) {
        errorPhone = "Nomor telepon harus mulai dari angka 0";
      } else if (phone.trim().length < 8) {
        errorPhone = "Nomor telepon harus terdiri dari min. 8 karakter";
      }
    }
    return errorPhone;
  }

  static String? validateAge(String? age) {
    String? errorAge;
    if (age?.isNotEmpty == true) {
      int? ageInt = int.tryParse(age!.replaceAll('.', ''));
      if (ageInt != null) {
        if (ageInt < 0) {
          errorAge = 'Tidak boleh kurang dari 0';
        } else if (ageInt > 65) {
          errorAge = 'Maksimal Usia Pensiun 65 Tahun';
        }
      } else {
        errorAge = 'Harus berupa angka';
      }
    }
    return errorAge;
  }

  static String? validateBirthDate(
    DateTime? birthDate,
    int minAgeInMonths,
    int maxAgeInMonths,
  ) {
    String? errorBirthDate;
    if (birthDate != null) {
      DateDuration duration = AgeCalculator.age(birthDate);
      int ageInMonths = (duration.years * 12) + duration.months;
      if (ageInMonths < minAgeInMonths) {
        int minAgeInYears = minAgeInMonths ~/ 12;
        errorBirthDate =
            'Usia tidak boleh kurang dari $minAgeInMonths bulan ($minAgeInYears tahun)';
      } else if (ageInMonths > maxAgeInMonths) {
        int maxAgeInYears = maxAgeInMonths ~/ 12;
        errorBirthDate =
            'Usia tidak boleh lebih dari $maxAgeInMonths bulan ($maxAgeInYears tahun)';
      }
    } else {
      errorBirthDate = 'Harus berupa tanggal valid';
    }
    return errorBirthDate;
  }

  static String? validateSalary(String? salary) {
    String? errorSalary;
    if (salary?.isNotEmpty == true) {
      int? salaryInt = int.tryParse(salary!.replaceAll('.', ''));
      if (salaryInt != null) {
        if (salaryInt < 0) {
          errorSalary = 'Tidak boleh kurang dari 0';
        }
      } else {
        errorSalary = 'Harus berupa angka';
      }
    }
    return errorSalary;
  }

  static String? validateAngsuran(String? angsuran, String? salary) {
    String? errorAngsuran;
    if (angsuran?.isNotEmpty == true && salary?.isNotEmpty == true) {
      int? angsuranInt = int.tryParse(angsuran!.replaceAll('.', ''));
      int? salaryInt = int.tryParse(salary!.replaceAll('.', ''));
      if (angsuranInt != null && salaryInt != null) {
        var f = CurrencyTextInputFormatter(
            locale: 'id', decimalDigits: 0, symbol: '');
        int? maxAngsuran = (salaryInt * 0.9).round();
        if (angsuranInt > maxAngsuran) {
          errorAngsuran =
              'Angsuran tidak boleh lebih dari ${f.format(maxAngsuran.toString())}';
        }
      } else {
        errorAngsuran = 'Harus berupa angka';
      }
    }
    return errorAngsuran;
  }

  static String? validateTenor(
    String? tenor,
    DateTime? birthDate,
    int maxTenorInMonths,
  ) {
    String? errorTenor;
    if (tenor?.isNotEmpty == true) {
      int? tenorInt = int.tryParse(tenor!.replaceAll('.', ''));
      if (tenorInt != null) {
        if (tenorInt < 0) {
          errorTenor = 'Tidak boleh kurang dari 0 bulan';
        } else if (tenorInt > 180) {
          errorTenor = 'Tidak boleh lebih dari 180 bulan';
        }
        if (birthDate != null) {
          DateDuration duration = AgeCalculator.age(birthDate);
          int ageInMonths = (duration.years * 12) + duration.months;
          int maxTenor = maxTenorInMonths - ageInMonths;
          if (tenorInt > maxTenor) {
            errorTenor = 'Tidak boleh lebih dari $maxTenor bulan';
          }
        }
      } else {
        errorTenor = 'Harus berupa angka';
      }
    }
    return errorTenor;
  }

  static List<String?> validatePlafond(String? plafond, String? salary) {
    String? errorPlafond;
    String? successPlafond;
    if (plafond?.isNotEmpty == true) {
      // int salaryInt = int.tryParse(salary?.replaceAll('.', '') ?? '') ?? 0;
      int? plafondInt = int.tryParse(plafond!.replaceAll('.', ''));
      if (plafondInt != null) {
        if (plafondInt < 0) {
          errorPlafond = 'Tidak boleh kurang dari 0';
          // } else if (plafondInt > salaryInt) {
          //   errorPlafond = 'Status: Reject';
        } else if (plafondInt > 500000000) {
          errorPlafond = 'Tidak boleh lebih dari 500.000.000';
        } else {
          successPlafond = 'Status: Passed';
        }
      } else {
        errorPlafond = 'Harus berupa angka';
      }
    }
    return [errorPlafond, successPlafond];
  }
}
