// import 'package:age_calculator/age_calculator.dart';
// import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
// import 'package:flutter/material.dart';
// import 'package:kredit_pensiun_app/model/option_model.dart';
// import 'package:kredit_pensiun_app/model/simulation_form_model.dart';
// import 'package:kredit_pensiun_app/model/simulation_model.dart';
// import 'package:kredit_pensiun_app/model/submission_model.dart';
// import 'package:kredit_pensiun_app/model/user_model.dart';
// import 'package:kredit_pensiun_app/repository/debt_bank_repository.dart';
// import 'package:kredit_pensiun_app/repository/salary_place_repository.dart';
// import 'package:kredit_pensiun_app/repository/simulation_repository.dart';
// import 'package:kredit_pensiun_app/repository/submission_repository.dart';
// import 'package:kredit_pensiun_app/util/form_error/pra_pensiun_form_error.dart';
// import 'package:kredit_pensiun_app/util/form_util.dart';
// import 'package:kredit_pensiun_app/util/shared_preferences_util.dart';
// import 'package:kredit_pensiun_app/widget/custom_date_field.dart';
// import 'package:kredit_pensiun_app/widget/custom_month_year_field.dart';
// import 'package:kredit_pensiun_app/widget/custom_select_field.dart';
// import 'package:kredit_pensiun_app/widget/custom_text_field.dart';
// import 'package:kredit_pensiun_app/widget/elevated_button_loading.dart';

// class PraPensiunForm extends StatefulWidget {
//   final bool isLoading;
//   final bool showError;
//   final Function(SimulationFormModel, SimulationModel) onSubmit;
//   final Color inputColor;
//   final UserModel userModel;
//   final PraPensiunFormModel? formModel;

//   const PraPensiunForm({
//     Key? key,
//     required this.isLoading,
//     required this.showError,
//     required this.onSubmit,
//     required this.inputColor,
//     required this.userModel,
//     this.formModel,
//   }) : super(key: key);

//   @override
//   _PraPensiunFormState createState() => _PraPensiunFormState();
// }

// class _PraPensiunFormState extends State<PraPensiunForm> {
//   late TextEditingController _inputNameController;
//   late TextEditingController _inputPhoneController;
//   DateTime? _inputBirthDate;
//   DateTime? _inputBup;
//   // late TextEditingController _inputAgeController;
//   late TextEditingController _inputSalaryController;
//   OptionModel? _inputSalaryPlace;
//   List<OptionModel> _salaryPlaces = [];
//   // late TextEditingController _inputSalaryPlaceController;
//   late TextEditingController _inputTenorController;
//   late TextEditingController _inputPlafondController;
//   late TextEditingController _inputRemainingDebtController;
//   OptionModel? _inputDebtBank;
//   bool _isSubmitting = false;
//   SubmissionCheck? submissionCheck;

//   var defaultCurrencyFormatter = CurrencyTextInputFormatter(
//     locale: 'id',
//     decimalDigits: 0,
//     symbol: '',
//   );

//   PraPensiunFormModel? get formModel => widget.formModel;

//   @override
//   void initState() {
//     super.initState();
//     submissionCheck = null;

//     SalaryPlaceRepository().getAll().then((result) {
//       setState(() {
//         _salaryPlaces = result.data!
//             .map(
//               (salaryPlace) => OptionModel(
//                 id: salaryPlace.id,
//                 text: salaryPlace.text,
//               ),
//             )
//             .toList();
//       });
//     });

//     String? token = SharedPreferencesUtil()
//         .sharedPreferences
//         .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

//     SubmissionRepository().getSubmissionCheck(token!).then((result) {
//       if (result.error == null) {
//         setState(() {
//           submissionCheck = result.data!;
//           _inputBirthDate = submissionCheck!.tanggalLahir!;
//         });
//       }
//     });

//     UserModel userModel = widget.userModel;
//     _inputNameController = TextEditingController(
//       text: formModel == null ? userModel.username : formModel!.name,
//     );
//     _inputPhoneController = TextEditingController(
//       text: formModel == null ? userModel.phone : formModel!.phone,
//     );
//     // _inputSalaryPlaceController = TextEditingController(
//     //   text: formModel == null ? '' : formModel!.salaryPlace,
//     // );
//     if (formModel == null) {
//       if (submissionCheck?.tanggalLahir != null) {
//         _inputBirthDate = submissionCheck!.tanggalLahir!;
//       } else if (userModel.birthDate != null) {
//         _inputBirthDate = DateTime.tryParse(userModel.birthDate!);
//       }
//     } else {
//       if (submissionCheck?.tanggalLahir != null) {
//         _inputBirthDate = submissionCheck!.tanggalLahir!;
//       } else {
//         _inputBirthDate = formModel!.birthDate;
//       }
//       _inputSalaryPlace = formModel!.salaryPlace;
//       _inputDebtBank = formModel!.bankHutang;
//     }
//     // _inputAgeController = TextEditingController(
//     //   text: formModel == null
//     //       ? ''
//     //       : defaultCurrencyFormatter.format(formModel!.age.toString()),
//     // );
//     _inputSalaryController = TextEditingController(
//       text: formModel == null
//           ? ''
//           : defaultCurrencyFormatter.format(formModel!.salary.toString()),
//     );
//     _inputTenorController = TextEditingController(
//       text: formModel == null
//           ? ''
//           : defaultCurrencyFormatter.format(formModel!.tenor.toString()),
//     );
//     _inputPlafondController = TextEditingController(
//       text: formModel == null
//           ? ''
//           : defaultCurrencyFormatter.format(formModel!.plafond.toString()),
//     );
//     _inputRemainingDebtController = TextEditingController(
//       text: formModel == null
//           ? '0'
//           : defaultCurrencyFormatter.format(formModel!.sisaHutang.toString()),
//     );
//   }

//   @override
//   void dispose() {
//     _inputNameController.dispose();
//     _inputPhoneController.dispose();
//     // _inputAgeController.dispose();
//     _inputSalaryController.dispose();
//     // _inputSalaryPlaceController.dispose();
//     _inputTenorController.dispose();
//     _inputPlafondController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);

//     bool isLoading = widget.isLoading || _isSubmitting;
//     PraPensiunFormError formError;
//     if (widget.showError) {
//       formError = FormUtil.validatePraPensiunForm(
//         phone: _inputPhoneController.text,
//         birthDate: _inputBirthDate,
//         // age: _inputAgeController.text,
//         salary: _inputSalaryController.text,
//         tenor: _inputTenorController.text,
//         plafond: _inputPlafondController.text,
//       );
//     } else {
//       formError = PraPensiunFormError();
//     }

//     return Column(
//       children: [
//         // CustomTextField(
//         //   controller: _inputNameController,
//         //   labelText: 'Nama Lengkap',
//         //   keyboardType: TextInputType.name,
//         //   useLabel: false,
//         //   hintText: 'Nama Lengkap',
//         //   fillColor: widget.inputColor,
//         //   enabled: !isLoading,
//         //   borderRadius: 36.0,
//         //   contentPadding: const EdgeInsets.symmetric(
//         //     horizontal: 24.0,
//         //     vertical: 20.0,
//         //   ),
//         // ),
//         // SizedBox(height: 12.0),
//         // CustomTextField(
//         //   controller: _inputPhoneController,
//         //   labelText: '',
//         //   keyboardType: TextInputType.phone,
//         //   useLabel: false,
//         //   hintText: 'No. Handphone (WA)',
//         //   fillColor: widget.inputColor,
//         //   onChanged: (_) {
//         //     setState(() {});
//         //   },
//         //   enabled: !isLoading,
//         //   borderRadius: 36.0,
//         //   errorText: formError.errorPhone,
//         //   contentPadding: const EdgeInsets.symmetric(
//         //     horizontal: 24.0,
//         //     vertical: 20.0,
//         //   ),
//         // ),
//         // SizedBox(height: 12.0),
//         Center(
//           child: Stack(
//             children: [
//               new Container(
//                 width: MediaQuery.of(context).size.width,
//                 height: 0.55 * MediaQuery.of(context).size.width,
//                 decoration: new BoxDecoration(
//                     image: new DecorationImage(
//                   fit: BoxFit.cover,
//                   alignment: Alignment(0, -0.5),
//                   image:
//                       AssetImage('assets/application_screen/prapensiun_bg.png'),
//                 )),
//               ),
//               Positioned.fill(
//                 top: 160,
//                 left: 15,
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     'Pra Pensiun',
//                     style: theme.textTheme.headline4?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         submissionCheck?.tanggalLahir == null ?
//         Padding(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 16.0,
//           ),
//           child: CustomDateField(
//             labelText: 'Tanggal Lahir',
//             currentValue: _inputBirthDate,
//             enabled: !isLoading,
//             onChanged: (DateTime? newBirthDate) {
//               setState(() {
//                 _inputBirthDate = newBirthDate;
//               });
//             },
//             errorText: formError.errorBirthDate,
//             useLabel: false,
//             fillColor: widget.inputColor,
//             buttonType: 'button_text_field',
//             borderRadius: 36.0,
//             lastDate: DateTime.now(),
//             hintText: 'Tanggal Lahir',
//           ),
//         ) : Padding(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 16.0,
//           ),
//           child: CustomDateField(
//             labelText: 'Tanggal Lahir',
//             currentValue: _inputBirthDate,
//             enabled: false,
//             onChanged: (DateTime? newBirthDate) {

//             },
//             errorText: formError.errorBirthDate,
//             useLabel: false,
//             fillColor: widget.inputColor,
//             buttonType: 'button_text_field',
//             borderRadius: 36.0,
//             lastDate: DateTime.now(),
//             hintText: 'Tanggal Lahir',
//           ),
//         ),
//         SizedBox(height: 12.0),
//         Padding(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 16.0,
//           ),
//           child: CustomMonthYearField(
//             labelText: 'Bulan dan Tahun Pensiun',
//             currentValue: _inputBup,
//             enabled: !isLoading,
//             onChanged: (DateTime? newBup) {
//               setState(() {
//                 _inputBup = newBup;
//               });
//             },
//             // errorText: formError.errorBirthDate,
//             useLabel: false,
//             fillColor: widget.inputColor,
//             buttonType: 'button_text_field',
//             borderRadius: 36.0,
//           ),
//         ),
//         SizedBox(height: 12.0),
//         // CustomTextField(
//         //   labelText: 'Usia Pensiun',
//         //   keyboardType: TextInputType.number,
//         //   useLabel: false,
//         //   hintText: 'Usia Pensiun',
//         //   fillColor: widget.inputColor,
//         //   enabled: !isLoading,
//         //   onChanged: (String newTimeRange) {
//         //     setState(() {});
//         //   },
//         //   // errorText: _timeRangeError,
//         //   inputFormatters: [
//         //     CurrencyTextInputFormatter(
//         //       locale: 'id',
//         //       decimalDigits: 0,
//         //       symbol: '',
//         //     ),
//         //   ],
//         //   errorText: formError.errorAge,
//         //   controller: _inputAgeController,
//         //   borderRadius: 36.0,
//         //   contentPadding: const EdgeInsets.symmetric(
//         //     horizontal: 24.0,
//         //     vertical: 20.0,
//         //   ),
//         // ),
//         // SizedBox(height: 12.0),
//         Padding(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 16.0,
//           ),
//           child: CustomTextField(
//             controller: _inputSalaryController,
//             labelText: '',
//             keyboardType: TextInputType.number,
//             useLabel: false,
//             hintText: 'Estimasi Gaji Pensiun',
//             fillColor: widget.inputColor,
//             onChanged: (String newTimeRange) {
//               setState(() {});
//             },
//             inputFormatters: [
//               CurrencyTextInputFormatter(
//                 locale: 'id',
//                 decimalDigits: 0,
//                 symbol: '',
//               ),
//             ],
//             errorText: formError.errorSalary,
//             enabled: !isLoading,
//             borderRadius: 36.0,
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 24.0,
//               vertical: 20.0,
//             ),
//           ),
//         ),
//         SizedBox(height: 12.0),
//         Padding(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 16.0,
//           ),
//           child: CustomSelectField(
//             labelText: 'Tempat Pengambilan Gaji',
//             searchLabelText: 'Cari Tempat Pengambilan Gaji',
//             options: _salaryPlaces,
//             currentOption: _inputSalaryPlace,
//             enabled: !isLoading,
//             onChanged: (OptionModel newSalaryPlace) {
//               setState(() {
//                 _inputSalaryPlace = newSalaryPlace;
//               });
//             },
//             fillColor: widget.inputColor,
//             useLabel: false,
//             buttonType: 'button_text_field',
//             hintText: 'Tempat Pengambilan Gaji',
//             borderRadius: 36.0,
//           ),
//         ),
//         // CustomTextField(
//         //   controller: _inputSalaryPlaceController,
//         //   labelText: 'Tempat Pengambilan Gaji',
//         //   keyboardType: TextInputType.name,
//         //   useLabel: false,
//         //   hintText: 'Tempat Pengambilan Gaji',
//         //   fillColor: widget.inputColor,
//         //   enabled: !isLoading,
//         //   borderRadius: 36.0,
//         //   contentPadding: const EdgeInsets.symmetric(
//         //     horizontal: 24.0,
//         //     vertical: 20.0,
//         //   ),
//         // ),
//         SizedBox(height: 12.0),
//         Padding(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 16.0,
//           ),
//           child: CustomTextField(
//             labelText: 'Jangka Waktu Pinjaman',
//             keyboardType: TextInputType.number,
//             useLabel: false,
//             hintText: 'Jangka Waktu Pinjaman',
//             suffix: Text('bulan'),
//             fillColor: widget.inputColor,
//             enabled: !isLoading,
//             onChanged: (String newTimeRange) {
//               setState(() {});
//             },
//             errorText: formError.errorTenor,
//             inputFormatters: [
//               CurrencyTextInputFormatter(
//                 locale: 'id',
//                 decimalDigits: 0,
//                 symbol: '',
//               ),
//             ],
//             controller: _inputTenorController,
//             borderRadius: 36.0,
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 24.0,
//               vertical: 20.0,
//             ),
//           ),
//         ),
//         SizedBox(height: 12.0),
//         Padding(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 16.0,
//           ),
//           child: CustomTextField(
//             labelText: 'Plafond',
//             keyboardType: TextInputType.number,
//             useLabel: false,
//             hintText: 'Plafond',
//             fillColor: widget.inputColor,
//             enabled: !isLoading,
//             errorText: formError.errorPlafond,
//             // helperText: formError.successPlafond,
//             onChanged: (String newTimeRange) {
//               setState(() {});
//             },
//             inputFormatters: [
//               CurrencyTextInputFormatter(
//                 locale: 'id',
//                 decimalDigits: 0,
//                 symbol: '',
//               ),
//             ],
//             controller: _inputPlafondController,
//             borderRadius: 36.0,
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 24.0,
//               vertical: 20.0,
//             ),
//           ),
//         ),
//         SizedBox(height: 12.0),
//         Padding(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 16.0,
//           ),
//           child: CustomTextField(
//             labelText: 'Sisa Pinjaman Sebelumnya',
//             keyboardType: TextInputType.number,
//             useLabel: false,
//             hintText: 'Sisa Pinjaman Sebelumnya',
//             fillColor: widget.inputColor,
//             enabled: !isLoading,
//             onChanged: (String newTimeRange) {
//               setState(() {});
//             },
//             inputFormatters: [
//               CurrencyTextInputFormatter(
//                 locale: 'id',
//                 decimalDigits: 0,
//                 symbol: '',
//               ),
//             ],
//             controller: _inputRemainingDebtController,
//             borderRadius: 36.0,
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 24.0,
//               vertical: 20.0,
//             ),
//           ),
//         ),
//         SizedBox(height: 12.0),
//         Padding(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 16.0,
//           ),
//           child: CustomSelectField(
//             labelText: 'Bank Pemberi Pinjaman Sebelumnya',
//             searchLabelText: '',
//             options: DebtBankRepository.getAllDb(),
//             currentOption: _inputDebtBank,
//             enabled: !isLoading,
//             onChanged: (OptionModel newDebtBank) {
//               setState(() {
//                 _inputDebtBank = newDebtBank;
//               });
//             },
//             fillColor: widget.inputColor,
//             useLabel: false,
//             buttonType: 'button_text_field',
//             hintText: 'Bank Pemberi Pinjaman Sebelumnya',
//             borderRadius: 36.0,
//           ),
//         ),
//         SizedBox(height: 12.0),
//         // Row(
//         //   // mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         //   children: [
//         //     SizedBox(width: 20.0),
//         //     ElevatedButtonSecond(
//         //       text: 'Tanya Kami',
//         //       onTap: () {
//         //         Navigator.push(context,
//         //             MaterialPageRoute(builder: (context) => LiveChat()));
//         //       },
//         //       isLoading: false,
//         //       disabled: false,
//         //     ),
//         //     Spacer(),
//         ElevatedButtonLoading(
//           text: 'Submit',
//           onTap: _onSubmit,
//           isLoading: isLoading,
//           disabled: isLoading,
//         ),
//         SizedBox(width: 20.0),
//         //   ],
//         // ),
//         // ElevatedButtonLoading(
//         //   text: 'Lanjut',
//         //   onTap: _onSubmit,
//         //   isLoading: isLoading,
//         //   disabled: isLoading,
//         // ),
//       ],
//     );
//   }

//   int validatePensiunDate(DateTime? pensiunDate) {
//     if (pensiunDate != null) {
//       DateDuration duration = AgeCalculator.dateDifference(
//           fromDate: DateTime.now(), toDate: pensiunDate);
//       int pensiunAgeInMonths = (duration.years * 12) + duration.months;
//       return pensiunAgeInMonths;
//     } else {
//       return 0;
//     }
//   }

//   int agePensiun(DateTime? birthDate, DateTime? pensiunDate) {
//     if (pensiunDate != null && birthDate != null) {
//       DateDuration durationAgeNow = AgeCalculator.age(birthDate);
//       DateDuration duration = AgeCalculator.dateDifference(
//           fromDate: DateTime.now(), toDate: pensiunDate);
//       int ageInMonths = (durationAgeNow.years * 12) + durationAgeNow.months;
//       int pensiunAgeInMonths = (duration.years * 12) + duration.months;
//       return (pensiunAgeInMonths + ageInMonths) ~/ 12;
//     } else {
//       return 0;
//     }
//   }

//   void _onSubmit() {
//     String? submitError = FormUtil.onSubmitPraPensiunForm(
//       name: _inputNameController.text,
//       phone: _inputPhoneController.text,
//       birthDate: _inputBirthDate,
//       // age: _inputAgeController.text,
//       salary: _inputSalaryController.text,
//       salaryPlace: _inputSalaryPlace?.text,
//       tenor: _inputTenorController.text,
//       plafond: _inputPlafondController.text,
//     );
//     if (submitError != null) {
//       showDialog(
//           context: context,
//           builder: (_) => AlertDialog(
//                 content:
//                     Text(submitError, style: TextStyle(color: Colors.white)),
//                 backgroundColor: Colors.red,
//                 elevation: 24.0,
//               ));
//       // WidgetUtil.showSnackbar(context, submitError);
//       return;
//     }

//     setState(() {
//       _isSubmitting = true;
//     });
//     String? token = SharedPreferencesUtil()
//         .sharedPreferences
//         .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

//     PraPensiunFormModel formModel = PraPensiunFormModel(
//       name: _inputNameController.text,
//       phone: _inputPhoneController.text,
//       birthDate: _inputBirthDate!,
//       age: agePensiun(_inputBirthDate, _inputBup),
//       salary: int.parse(_inputSalaryController.text.replaceAll('.', '')),
//       tenor: int.parse(_inputTenorController.text.replaceAll('.', '')),
//       plafond: int.parse(_inputPlafondController.text.replaceAll('.', '')),
//       // salaryPlace: _inputSalaryPlaceController.text,
//       salaryPlace: _inputSalaryPlace!,
//       bup: validatePensiunDate(_inputBup),
//       sisaHutang:
//           int.parse(_inputRemainingDebtController.text.replaceAll('.', '')),
//       bankHutang: _inputDebtBank!,
//     );
//     SimulationRepository()
//         .simulateForm(
//       token!,
//       SimulationFormType.PraPensiun,
//       formModel,
//     )
//         .then((result) {
//       setState(() {
//         _isSubmitting = false;
//       });
//       if (result.isSuccess) {
//         widget.onSubmit(formModel, result.data!);
//       } else {
//         showDialog(
//             context: context,
//             builder: (_) => AlertDialog(
//                   content: Text(
//                       result.error ?? 'Gagal mengirimkan form simulasi',
//                       style: TextStyle(color: Colors.white)),
//                   backgroundColor: Colors.red,
//                   elevation: 24.0,
//                 ));
//         // WidgetUtil.showSnackbar(
//         //     context, result.error ?? 'Gagal mengirimkan form simulasi');
//       }
//     });
//   }
// }

// cek juga di simulation_form.dart juga case SimulationFormType.PraPensiun:
