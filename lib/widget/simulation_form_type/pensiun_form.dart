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
// import 'package:kredit_pensiun_app/repository/status_pensiun_repository.dart';
// import 'package:kredit_pensiun_app/repository/submission_repository.dart';
// import 'package:kredit_pensiun_app/util/form_error/pensiun_form_error.dart';
// import 'package:kredit_pensiun_app/util/form_util.dart';
// import 'package:kredit_pensiun_app/util/shared_preferences_util.dart';
// import 'package:kredit_pensiun_app/widget/custom_date_field.dart';
// import 'package:kredit_pensiun_app/widget/custom_select_field.dart';
// import 'package:kredit_pensiun_app/widget/custom_text_field.dart';
// import 'package:kredit_pensiun_app/widget/elevated_button_loading.dart';

// class PensiunForm extends StatefulWidget {
//   final bool isLoading;
//   final bool showError;
//   final Function(SimulationFormModel, SimulationModel) onSubmit;
//   final Color inputColor;
//   final UserModel userModel;
//   final PensiunFormModel? formModel;

//   const PensiunForm({
//     Key? key,
//     required this.isLoading,
//     required this.showError,
//     required this.onSubmit,
//     required this.inputColor,
//     required this.userModel,
//     this.formModel,
//   }) : super(key: key);

//   @override
//   _PensiunFormState createState() => _PensiunFormState();
// }

// class _PensiunFormState extends State<PensiunForm> {
//   late TextEditingController _inputNameController;
//   late TextEditingController _inputPhoneController;
//   OptionModel? _inputStatus;
//   DateTime? _inputBirthDate;
//   late TextEditingController _inputSalaryController;
//   OptionModel? _inputSalaryPlace;
//   List<OptionModel> _salaryPlaces = [];

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

//   PensiunFormModel? get formModel => widget.formModel;

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
//       _inputStatus = formModel!.statusPensiun;
//       _inputDebtBank = formModel!.bankHutang;
//     }
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
//     _inputSalaryController.dispose();
//     // _inputSalaryPlaceController.dispose();
//     _inputTenorController.dispose();
//     _inputPlafondController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);
//     print(_salaryPlaces);
//     bool isLoading = widget.isLoading || _isSubmitting;
//     PensiunFormError formError;
//     if (widget.showError) {
//       formError = FormUtil.validatePensiunForm(
//         phone: _inputPhoneController.text,
//         birthDate: _inputBirthDate,
//         salary: _inputSalaryController.text,
//         tenor: _inputTenorController.text,
//         plafond: _inputPlafondController.text,
//       );
//     } else {
//       formError = PensiunFormError();
//     }

//     return Column(
//       children: [

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
//                   image: AssetImage('assets/application_screen/pensiun_bg.png'),
//                 )),
//               ),
//               Positioned.fill(
//                 top: 160,
//                 left: 15,
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     'Pensiun',
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
//         SizedBox(height: 12.0),
//         Padding(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 16.0,
//           ),
//           child: CustomSelectField(
//             labelText: 'Status Pensiun',
//             searchLabelText: '',
//             options: StatusPensiunRepository.getAllDb(),
//             currentOption: _inputStatus,
//             enabled: !isLoading,
//             onChanged: (OptionModel newStatus) {
//               setState(() {
//                 _inputStatus = newStatus;
//               });
//             },
//             fillColor: widget.inputColor,
//             useLabel: false,
//             buttonType: 'button_text_field',
//             hintText: 'Status Pensiun',
//             borderRadius: 36.0,
//           ),
//         ),
//         SizedBox(height: 12.0),
//         submissionCheck?.tanggalLahir == null ? Padding(
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
//             useLabel: false,
//             errorText: formError.errorBirthDate,
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
//           child: CustomTextField(
//             controller: _inputSalaryController,
//             labelText: '',
//             keyboardType: TextInputType.number,
//             useLabel: false,
//             hintText: 'Gaji Saat Ini',
//             fillColor: widget.inputColor,
//             onChanged: (String newTimeRange) {
//               setState(() {});
//             },
//             errorText: formError.errorSalary,
//             inputFormatters: [
//               CurrencyTextInputFormatter(
//                 locale: 'id',
//                 decimalDigits: 0,
//                 symbol: '',
//               ),
//             ],
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
//             labelText: 'Kantor Bayar Manfaat Pensiun',
//             searchLabelText: 'Cari Kantor Bayar Manfaat Pensiun',
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
//             hintText: 'Kantor Bayar Manfaat Pensiun',
//             borderRadius: 36.0,
//           ),
//         ),

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

//         ElevatedButtonLoading(
//           text: 'Submit',
//           onTap: _onSubmit,
//           isLoading: isLoading,
//           disabled: isLoading,
//         ),
//         SizedBox(width: 20.0),
//       ],
//     );
//   }

//   void _onSubmit() {
//     String? submitError = FormUtil.onSubmitPensiunForm(
//       name: _inputNameController.text,
//       phone: _inputPhoneController.text,
//       statusPensiun: _inputStatus?.text,
//       birthDate: _inputBirthDate,
//       salary: _inputSalaryController.text,
//       salaryPlace: _inputSalaryPlace?.text,
//       tenor: _inputTenorController.text,
//       plafond: _inputPlafondController.text,
//       sisaHutang: _inputRemainingDebtController.text,
//       bankHutang: _inputDebtBank?.text,
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

//       return;
//     }

//     setState(() {
//       _isSubmitting = true;
//     });
//     String? token = SharedPreferencesUtil()
//         .sharedPreferences
//         .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

//     PensiunFormModel formModel = PensiunFormModel(
//       name: _inputNameController.text,
//       phone: _inputPhoneController.text,
//       statusPensiun: _inputStatus!,
//       birthDate: _inputBirthDate!,
//       salary: int.parse(_inputSalaryController.text.replaceAll('.', '')),
//       tenor: int.parse(_inputTenorController.text.replaceAll('.', '')),
//       plafond: int.parse(_inputPlafondController.text.replaceAll('.', '')),
//       // salaryPlace: _inputSalaryPlaceController.text,
//       salaryPlace: _inputSalaryPlace!,
//       sisaHutang:
//           int.parse(_inputRemainingDebtController.text.replaceAll('.', '')),
//       bankHutang: _inputDebtBank!,
//     );
//     SimulationRepository()
//         .simulateForm(
//       token!,
//       SimulationFormType.Pensiun,
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

// cek di simulation_form.dart juga
