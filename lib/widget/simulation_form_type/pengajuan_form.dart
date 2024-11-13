// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/container.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:pensiunku/data/api/submission_api.dart';
// import 'package:pensiunku/model/simulation_form_model.dart';
// import 'package:pensiunku/model/simulation_model.dart';
// import 'package:pensiunku/model/submission_model.dart';
// import 'package:pensiunku/model/user_model.dart';
// import 'package:pensiunku/util/form_util.dart';
// import 'package:pensiunku/widget/custom_text_field.dart';

// class PengajuanForm extends StatefulWidget {
//   final bool isLoading;
//   final bool showError;
//   final Function(SimulationFormModel, SimulationModel) onSubmit;
//   final Color inputColor;
//   final UserModel userModel;
//   final PengajuanFormModel? formModel;

//   const PengajuanForm({
//     Key? key,
//     required this.isLoading,
//     required this.showError,
//     required this.onSubmit,
//     required this.inputColor,
//     required this.userModel,
//     this.formModel,
//   }) : super(key: key);

//   @override
//   State<PengajuanForm> createState() => _PengajuanFormState();
// }

// class _PengajuanFormState extends State<PengajuanForm> {
//   late TextEditingController _inputUsiaController;
//   late TextEditingController _inputDomisiliController;
//   late TextEditingController _inputInstansiController;
//   late TextEditingController _inputNipController;
//   late TextEditingController _inputKtpController;
//   late TextEditingController _inputNpwpController;
//   bool _isSubmitting = false;
//   SubmissionCheck? _submissionCheck;

//   PengajuanFormModel? get formModel => widget.formModel;

// //  @override
// //   void initState() {
// //     super.initState();

// //     UserModel userModel = widget.userModel;
// //     _inputUsiaController = TextEditingController(
// //       text: formModel == null ? userModel.birthDate : formModel!.usia,
// //     );
// //     _inputDomisiliController = TextEditingController(
// //       text: formModel == null ? userModel.city : formModel!.domisili,
// //     );

// //     _inputSalaryController = TextEditingController(
// //       text: formModel == null
// //           ? ''
// //           : defaultCurrencyFormatter.format(formModel!.salary.toString()),
// //     );
// //     _inputTenorController = TextEditingController(
// //       text: formModel == null
// //           ? ''
// //           : defaultCurrencyFormatter.format(formModel!.tenor.toString()),
// //     );
// //     _inputPlafondController = TextEditingController(
// //       text: formModel == null
// //           ? ''
// //           : defaultCurrencyFormatter.format(formModel!.plafond.toString()),
// //     );
// //     _inputRemainingDebtController = TextEditingController(
// //       text: formModel == null
// //           ? '0'
// //           : defaultCurrencyFormatter.format(formModel!.sisaHutang.toString()),
// //     );
//   // }

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);
//     bool isLoading = widget.isLoading || _isSubmitting;
//     // PengajuanFormError formError;
//     // if (widget.showError) {
//     //   formError = FormUtil.validatePengajuanForm(
//     //     usia: _inputUsiaController.text,
//     //     domisili: _inputDomisiliController.text,
//     //     instansi: _inputInstansiController.text,
//     //     nip: _inputNipController.text,
//     //     ktp: _inputKtpController.text,
//     //     npwp: _inputNpwpController.text,
//     //   );
//     // }else{
//     //   formError = PengajuanFormError();
//     // }
//     return Column(
//       children: [
//         CustomTextField(
//           controller: _inputUsiaController,
//           labelText: 'Usia',
//           keyboardType: TextInputType.number,
//           useLabel: false,
//           hintText: 'Usia',
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
//           controller: _inputDomisiliController,
//           labelText: 'Domisili',
//           keyboardType: TextInputType.text,
//           useLabel: false,
//           hintText: 'Domisili',
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
//           controller: _inputInstansiController,
//           labelText: 'Instansi',
//           keyboardType: TextInputType.text,
//           useLabel: false,
//           hintText: 'Instansi',
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
//           controller: _inputNipController,
//           labelText: 'NIP',
//           keyboardType: TextInputType.number,
//           useLabel: false,
//           hintText: 'NIP',
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
//           controller: _inputKtpController,
//           labelText: 'KTP',
//           keyboardType: TextInputType.number,
//           useLabel: false,
//           hintText: 'KTP',
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
//           controller: _inputNpwpController,
//           labelText: 'NPWP',
//           keyboardType: TextInputType.number,
//           useLabel: false,
//           hintText: 'NPWP',
//           fillColor: widget.inputColor,
//           enabled: !isLoading,
//           borderRadius: 36.0,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 24.0,
//             vertical: 20.0,
//           ),
//         ),
//         SizedBox(height: 12.0),
//       ],
//     );
//   }
// }
