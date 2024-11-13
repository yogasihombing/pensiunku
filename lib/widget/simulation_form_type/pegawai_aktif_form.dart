// import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
// import 'package:flutter/material.dart';
// import 'package:kredit_pensiun_app/model/simulation_form_model.dart';
// import 'package:kredit_pensiun_app/model/simulation_model.dart';
// import 'package:kredit_pensiun_app/model/user_model.dart';
// import 'package:kredit_pensiun_app/repository/simulation_repository.dart';
// import 'package:kredit_pensiun_app/util/form_error/pegawai_aktif_form_error.dart';
// import 'package:kredit_pensiun_app/util/form_util.dart';
// import 'package:kredit_pensiun_app/util/shared_preferences_util.dart';
// import 'package:kredit_pensiun_app/util/widget_util.dart';
// import 'package:kredit_pensiun_app/widget/custom_date_field.dart';
// import 'package:kredit_pensiun_app/widget/custom_text_field.dart';
// import 'package:kredit_pensiun_app/widget/elevated_button_loading.dart';

// class PegawaiAktifForm extends StatefulWidget {
//   final bool isLoading;
//   final bool showError;
//   final Function(PegawaiAktifFormModel, SimulationModel) onSubmit;
//   final Color inputColor;
//   final UserModel userModel;
//   final PegawaiAktifFormModel? formModel;

//   const PegawaiAktifForm({
//     Key? key,
//     required this.isLoading,
//     required this.showError,
//     required this.onSubmit,
//     required this.inputColor,
//     required this.userModel,
//     this.formModel,
//   }) : super(key: key);

//   @override
//   _PegawaiAktifFormState createState() => _PegawaiAktifFormState();
// }

// class _PegawaiAktifFormState extends State<PegawaiAktifForm> {
//   late TextEditingController _inputNameController;
//   late TextEditingController _inputPhoneController;
//   DateTime? _inputBirthDate;
//   late TextEditingController _inputSalaryController;
//   late TextEditingController _inputTenorController;
//   late TextEditingController _inputPlafondController;

//   bool _isSubmitting = false;

//   PegawaiAktifFormModel? get formModel => widget.formModel;

//   var defaultCurrencyFormatter = CurrencyTextInputFormatter(
//     locale: 'id',
//     decimalDigits: 0,
//     symbol: '',
//   );

//   @override
//   void initState() {
//     super.initState();

//     UserModel userModel = widget.userModel;
//     _inputNameController = TextEditingController(
//         text: formModel == null ? userModel.username : formModel!.name);
//     _inputPhoneController = TextEditingController(
//         text: formModel == null ? userModel.phone : formModel!.phone);
//     if (formModel == null) {
//       if (userModel.birthDate != null) {
//         _inputBirthDate = DateTime.tryParse(userModel.birthDate!);
//       }
//     } else {
//       _inputBirthDate = formModel!.birthDate;
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
//   }

//   @override
//   void dispose() {
//     _inputNameController.dispose();
//     _inputPhoneController.dispose();
//     _inputSalaryController.dispose();
//     _inputTenorController.dispose();
//     _inputPlafondController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     bool isLoading = widget.isLoading || _isSubmitting;
//     PegawaiAktifFormError formError;
//     if (widget.showError) {
//       formError = FormUtil.validatePegawaiAktifForm(
//         phone: _inputPhoneController.text,
//         birthDate: _inputBirthDate,
//         salary: _inputSalaryController.text,
//         tenor: _inputTenorController.text,
//         plafond: _inputPlafondController.text,
//       );
//     } else {
//       formError = PegawaiAktifFormError();
//     }

//     return Column(
//       children: [
//         CustomTextField(
//           controller: _inputNameController,
//           labelText: 'Nama Lengkap',
//           keyboardType: TextInputType.name,
//           useLabel: false,
//           hintText: 'Nama Lengkap',
//           fillColor: widget.inputColor,
//           enabled: !isLoading,
//           borderRadius: 36.0,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 24.0,
//             vertical: 20.0,
//           ),
//         ),
//         SizedBox(height: 12.0),
//         CustomTextField(
//           controller: _inputPhoneController,
//           labelText: '',
//           keyboardType: TextInputType.phone,
//           useLabel: false,
//           hintText: 'No. Handphone (WA)',
//           fillColor: widget.inputColor,
//           enabled: !isLoading,
//           borderRadius: 36.0,
//           errorText: formError.errorPhone,
//           onChanged: (_) {
//             setState(() {});
//           },
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 24.0,
//             vertical: 20.0,
//           ),
//         ),
//         SizedBox(height: 12.0),
//         CustomDateField(
//           labelText: 'Tanggal Lahir',
//           currentValue: _inputBirthDate,
//           enabled: !isLoading,
//           onChanged: (DateTime? newBirthDate) {
//             setState(() {
//               _inputBirthDate = newBirthDate;
//             });
//           },
//           errorText: formError.errorBirthDate,
//           useLabel: false,
//           fillColor: widget.inputColor,
//           buttonType: 'button_text_field',
//           borderRadius: 36.0,
//           lastDate: DateTime.now(),
//         ),
//         SizedBox(height: 12.0),
//         CustomTextField(
//           controller: _inputSalaryController,
//           labelText: '',
//           keyboardType: TextInputType.number,
//           useLabel: false,
//           hintText: 'Gaji Saat Ini',
//           fillColor: widget.inputColor,
//           onChanged: (String newTimeRange) {
//             setState(() {});
//           },
//           inputFormatters: [
//             CurrencyTextInputFormatter(
//               locale: 'id',
//               decimalDigits: 0,
//               symbol: '',
//             ),
//           ],
//           errorText: formError.errorSalary,
//           enabled: !isLoading,
//           borderRadius: 36.0,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 24.0,
//             vertical: 20.0,
//           ),
//         ),
//         SizedBox(height: 12.0),
//         CustomTextField(
//           labelText: 'Jangka Waktu Pinjaman',
//           keyboardType: TextInputType.number,
//           useLabel: false,
//           hintText: 'Jangka Waktu Pinjaman',
//           suffix: Text('bulan'),
//           fillColor: widget.inputColor,
//           enabled: !isLoading,
//           onChanged: (String newTimeRange) {
//             setState(() {});
//           },
//           errorText: formError.errorTenor,
//           inputFormatters: [
//             CurrencyTextInputFormatter(
//               locale: 'id',
//               decimalDigits: 0,
//               symbol: '',
//             ),
//           ],
//           controller: _inputTenorController,
//           borderRadius: 36.0,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 24.0,
//             vertical: 20.0,
//           ),
//         ),
//         SizedBox(height: 12.0),
//         CustomTextField(
//           labelText: 'Plafond',
//           keyboardType: TextInputType.number,
//           useLabel: false,
//           hintText: 'Plafond',
//           fillColor: widget.inputColor,
//           enabled: !isLoading,
//           errorText: formError.errorPlafond,
//           // helperText: formError.successPlafond,
//           onChanged: (String newTimeRange) {
//             setState(() {});
//           },
//           inputFormatters: [
//             CurrencyTextInputFormatter(
//               locale: 'id',
//               decimalDigits: 0,
//               symbol: '',
//             ),
//           ],
//           controller: _inputPlafondController,
//           borderRadius: 36.0,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 24.0,
//             vertical: 20.0,
//           ),
//         ),
//         SizedBox(height: 12.0),
//         ElevatedButtonLoading(
//           text: 'Hitung',
//           onTap: _onSubmit,
//           isLoading: isLoading,
//           disabled: isLoading,
//         ),
//       ],
//     );
//   }

//   void _onSubmit() {
//     String? submitError = FormUtil.onSubmitPegawaiAktifForm(
//       name: _inputNameController.text,
//       phone: _inputPhoneController.text,
//       birthDate: _inputBirthDate,
//       salary: _inputSalaryController.text,
//       tenor: _inputTenorController.text,
//       plafond: _inputPlafondController.text,
//     );
//     if (submitError != null) {
//       WidgetUtil.showSnackbar(context, submitError);
//       return;
//     }

//     setState(() {
//       _isSubmitting = true;
//     });
//     String? token = SharedPreferencesUtil()
//         .sharedPreferences
//         .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

//     PegawaiAktifFormModel formModel = PegawaiAktifFormModel(
//       name: _inputNameController.text,
//       phone: _inputPhoneController.text,
//       birthDate: _inputBirthDate!,
//       salary: int.parse(_inputSalaryController.text.replaceAll('.', '')),
//       tenor: int.parse(_inputTenorController.text.replaceAll('.', '')),
//       plafond: int.parse(_inputPlafondController.text.replaceAll('.', '')),
//     );
//     SimulationRepository()
//         .simulateForm(
//       token!,
//       SimulationFormType.PegawaiAktif,
//       formModel,
//     )
//         .then((result) {
//       setState(() {
//         _isSubmitting = false;
//       });
//       if (result.isSuccess) {
//         widget.onSubmit(formModel, result.data!);
//       } else {
//         WidgetUtil.showSnackbar(
//             context, result.error ?? 'Gagal mengirimkan form simulasi');
//       }
//     });
//   }
// }


//hal yang perlu diperhatikan di simulation_form.dart -> return pegawai aktif from