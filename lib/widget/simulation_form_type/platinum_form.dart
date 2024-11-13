// import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
// import 'package:flutter/material.dart';
// import 'package:kredit_pensiun_app/model/option_model.dart';
// import 'package:kredit_pensiun_app/model/simulation_form_model.dart';
// import 'package:kredit_pensiun_app/model/simulation_model.dart';
// import 'package:kredit_pensiun_app/model/submission_model.dart';
// import 'package:kredit_pensiun_app/model/user_model.dart';
// import 'package:kredit_pensiun_app/repository/job_repository.dart';
// import 'package:kredit_pensiun_app/repository/simulation_repository.dart';
// import 'package:kredit_pensiun_app/repository/submission_repository.dart';
// import 'package:kredit_pensiun_app/util/form_error/platinum_form_error.dart';
// import 'package:kredit_pensiun_app/util/form_util.dart';
// import 'package:kredit_pensiun_app/util/shared_preferences_util.dart';
// import 'package:kredit_pensiun_app/widget/custom_date_field.dart';
// import 'package:kredit_pensiun_app/widget/custom_select_field.dart';
// import 'package:kredit_pensiun_app/widget/custom_text_field.dart';
// import 'package:kredit_pensiun_app/widget/elevated_button_loading.dart';

// class PlatinumForm extends StatefulWidget {
//   final bool isLoading;
//   final bool showError;
//   final Function(SimulationFormModel, SimulationModel) onSubmit;
//   final Color inputColor;
//   final UserModel userModel;
//   final PlatinumFormModel? formModel;

//   const PlatinumForm({
//     Key? key,
//     required this.isLoading,
//     required this.showError,
//     required this.onSubmit,
//     required this.inputColor,
//     required this.userModel,
//     this.formModel,
//   }) : super(key: key);

//   @override
//   _PlatinumFormState createState() => _PlatinumFormState();
// }

// class _PlatinumFormState extends State<PlatinumForm> {
//   late TextEditingController _inputNameController;
//   late TextEditingController _inputPhoneController;
//   DateTime? _inputBirthDate;
//   late TextEditingController _inputSalaryController;
//   late TextEditingController _inputAngsuranController;
//   OptionModel? _inputTenor;
//   OptionModel? _inputProvinsi;
//   OptionModel? _inputSalaryPlace;
//   bool _isSubmitting = false;
//   SubmissionCheck? submissionCheck;

//   var defaultCurrencyFormatter = CurrencyTextInputFormatter(
//     locale: 'id',
//     decimalDigits: 0,
//     symbol: '',
//   );

//   PlatinumFormModel? get formModel => widget.formModel;

//   @override
//   void initState() {
//     super.initState();
//     submissionCheck = null;

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
//       _inputTenor = formModel!.tenor;
//       _inputProvinsi = formModel!.province;
//       _inputSalaryPlace = formModel!.salaryPlace;
//     }
//     _inputSalaryController = TextEditingController(
//       text: formModel == null
//           ? ''
//           : defaultCurrencyFormatter.format(formModel!.salary.toString()),
//     );
//     _inputAngsuranController = TextEditingController(
//       text: formModel == null
//           ? ''
//           : defaultCurrencyFormatter.format(formModel!.angsuran.toString()),
//     );
//     // _inputTenorController = TextEditingController(
//     //   text: formModel == null
//     //       ? ''
//     //       : defaultCurrencyFormatter.format(formModel!.tenor.toString()),
//     // );
//   }

//   @override
//   void dispose() {
//     _inputNameController.dispose();
//     _inputPhoneController.dispose();
//     _inputSalaryController.dispose();
//     _inputAngsuranController.dispose();
//     // _inputTenorController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);

//     bool isLoading = widget.isLoading || _isSubmitting;
//     PlatinumFormError formError;
//     if (widget.showError) {
//       formError = FormUtil.validatePlatinumForm(
//         phone: _inputPhoneController.text,
//         birthDate: _inputBirthDate,
//         salary: _inputSalaryController.text,
//         angsuran: _inputAngsuranController.text,
//       );
//     } else {
//       formError = PlatinumFormError();
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
//         //   enabled: !isLoading,
//         //   onChanged: (_) {
//         //     setState(() {});
//         //   },
//         //   errorText: formError.errorPhone,
//         //   borderRadius: 36.0,
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
//                       AssetImage('assets/application_screen/platinum_bg.png'),
//                 )),
//               ),
//               Positioned.fill(
//                 top: 160,
//                 left: 15,
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     'Platinum',
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
//             hintText: 'Gaji Pensiun',
//             fillColor: widget.inputColor,
//             errorText: formError.errorSalary,
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
//             searchLabelText: '',
//             options: JobRepository.getSalaryPlacesPlatinum(),
//             currentOption: _inputSalaryPlace,
//             enabled: !isLoading,
//             onChanged: (OptionModel newValue) {
//               setState(() {
//                 _inputSalaryPlace = newValue;
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
//           child: CustomSelectField(
//             labelText: 'Jangka Waktu Pinjaman',
//             searchLabelText: 'Cari Jangka Waktu Pinjaman',
//             options: JobRepository.getPlatinumTenors(),
//             currentOption: _inputTenor,
//             enabled: !isLoading,
//             onChanged: (OptionModel newValue) {
//               setState(() {
//                 _inputTenor = newValue;
//               });
//             },
//             fillColor: widget.inputColor,
//             useLabel: false,
//             buttonType: 'button_text_field',
//             hintText: 'Jangka Waktu Pinjaman',
//             borderRadius: 36.0,
//           ),
//         ),
//         // CustomTextField(
//         //   labelText: 'Jangka Waktu Pinjaman',
//         //   keyboardType: TextInputType.number,
//         //   useLabel: false,
//         //   hintText: 'Jangka Waktu Pinjaman',
//         //   suffix: Text('bulan'),
//         //   fillColor: widget.inputColor,
//         //   enabled: !isLoading,
//         //   onChanged: (String newTimeRange) {
//         //     setState(() {});
//         //   },
//         //   errorText: formError.errorTenor,
//         //   inputFormatters: [
//         //     CurrencyTextInputFormatter(
//         //       locale: 'id',
//         //       decimalDigits: 0,
//         //       symbol: '',
//         //     ),
//         //   ],
//         //   controller: _inputTenorController,
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
//             controller: _inputAngsuranController,
//             labelText: '',
//             keyboardType: TextInputType.number,
//             useLabel: false,
//             hintText: 'Angsuran Pinjaman Yang di Inginkan',
//             errorText: formError.errorAngsuran,
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
//             labelText: 'Provinsi Tempat Tinggal Anda',
//             searchLabelText: 'Cari Provinsi',
//             options: JobRepository.getPlatinumProvinces(),
//             currentOption: _inputProvinsi,
//             enabled: !isLoading,
//             onChanged: (OptionModel newValue) {
//               setState(() {
//                 _inputProvinsi = newValue;
//               });
//             },
//             fillColor: widget.inputColor,
//             useLabel: false,
//             buttonType: 'button_text_field',
//             hintText: 'Provinsi Tempat Tinggal Anda',
//             borderRadius: 36.0,
//           ),
//         ),
//         SizedBox(height: 12.0),
//         // Row(
//         //   // mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         //   children: [
//         //     SizedBox(width: 20.0),
//         // ElevatedButtonSecond(
//         //   text: 'Tanya Kami',
//         //   onTap: () {
//         //     Navigator.push(context,
//         //         MaterialPageRoute(builder: (context) => LiveChat()));
//         //   },
//         //   isLoading: false,
//         //   disabled: false,
//         // ),
//         // Spacer(),
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

//   void _onSubmit() {
//     String? submitError = FormUtil.onSubmitPlatinumForm(
//       name: _inputNameController.text,
//       phone: _inputPhoneController.text,
//       birthDate: _inputBirthDate,
//       salary: _inputSalaryController.text,
//       angsuran: _inputAngsuranController.text,
//       tenor: _inputTenor?.text,
//       province: _inputProvinsi?.text,
//       salaryPlace: _inputSalaryPlace?.text,
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

//     PlatinumFormModel formModel = PlatinumFormModel(
//       name: _inputNameController.text,
//       phone: _inputPhoneController.text,
//       birthDate: _inputBirthDate!,
//       salary: int.parse(_inputSalaryController.text.replaceAll('.', '')),
//       // tenor: int.parse(_inputTenorController.text.replaceAll('.', '')),
//       tenor: _inputTenor!,
//       province: _inputProvinsi!,
//       angsuran: int.parse(_inputAngsuranController.text.replaceAll('.', '')),
//       salaryPlace: _inputSalaryPlace!,
//     );
//     SimulationRepository()
//         .simulateForm(
//       token!,
//       SimulationFormType.Platinum,
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

// cek juga di simulation_form.dart juga case SimulationFormType.Platinum: