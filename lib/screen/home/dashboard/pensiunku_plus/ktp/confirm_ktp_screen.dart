import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pensiunku/model/ktp_model.dart';
import 'package:pensiunku/model/submission_model.dart';
import 'package:pensiunku/repository/submission_repository.dart';

import 'package:pensiunku/util/form_error/ktp_form_error.dart';
import 'package:pensiunku/util/form_util.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/util/widget_util.dart';
import 'package:pensiunku/widget/custom_date_field.dart';
import 'package:pensiunku/widget/custom_text_field.dart';
import 'package:pensiunku/widget/elevated_button_loading.dart';
import 'package:pensiunku/widget/floating_bottom_navigation_bar.dart';

class ConfirmKtpScreenArgs {
  final SubmissionModel submissionModel;
  final KtpModel ktpModel;
  final void Function(BuildContext context) onSuccess;

  ConfirmKtpScreenArgs({
    required this.submissionModel,
    required this.ktpModel,
    required this.onSuccess,
  });
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class ConfirmKtpScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/ktp/confirm';
  final SubmissionModel submissionModel;
  final KtpModel ktpModel;
  final void Function(BuildContext context) onSuccess;

  const ConfirmKtpScreen({
    Key? key,
    required this.submissionModel,
    required this.ktpModel,
    required this.onSuccess,
  }) : super(key: key);

  @override
  _ConfirmKtpScreenState createState() => _ConfirmKtpScreenState();
}

class _ConfirmKtpScreenState extends State<ConfirmKtpScreen> {
  bool _isLoading = false;
  late KtpModel ktpModel;
  late TextEditingController _inputNikController;
  late TextEditingController _inputNameController;
  DateTime? _inputBirthDate;
  late TextEditingController _inputAddressController;
  late TextEditingController _inputJobController;
  // OptionModel? _inputJob;
  bool _isBottomNavBarVisible = false;

  @override
  void initState() {
    super.initState();

    ktpModel = widget.ktpModel.clone();
    _inputNikController = TextEditingController(text: ktpModel.nik);
    _inputNameController = TextEditingController(text: ktpModel.name);
    _inputAddressController = TextEditingController(text: ktpModel.address);
    if (ktpModel.birthDate != null) {
      _inputBirthDate = ktpModel.birthDate;
    }
    _inputJobController = TextEditingController(text: ktpModel.job);

    Future.delayed(Duration(milliseconds: 0), () {
      setState(() {
        _isBottomNavBarVisible = true;
      });
    });
  }

  @override
  void dispose() {
    _inputNikController.dispose();
    _inputNameController.dispose();
    _inputAddressController.dispose();
    _inputJobController.dispose();
    super.dispose();
  }

  /// Submit form
  _submitForm() {
    String? submitError = FormUtil.onSubmitKtpForm(
      nik: _inputNikController.text,
      name: _inputNameController.text,
      address: _inputAddressController.text,
      birthDate: _inputBirthDate,
      job: _inputJobController.text,
    );
    if (submitError != null) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                content:
                    Text(submitError, style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.red,
                elevation: 24.0,
              ));
      // WidgetUtil.showSnackbar(context, submitError);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    // SubmissionRepository()
    //     .uploadKtp(
    //   token!,
    //   widget.submissionModel.copyWith(
    //     nikKtp: _inputNikController.text,
    //     nameKtp: _inputNameController.text,
    //     addressKtp: _inputAddressController.text,
    //     birthDateKtp: _inputBirthDate,
    //     jobKtp: _inputJobController.text,
    //   ),
    //   ktpModel.image.path,
    // )
    //     .then((result) {
    //   setState(() {
    //     _isLoading = false;
    //   });
    //   if (result.isSuccess) {
    //     setState(() {
    //       _isLoading = false;
    //     });
    //     Navigator.of(context).pop(true);
    //   } else {
    //     showDialog(
    //         context: context,
    //         builder: (_) => AlertDialog(
    //               content: Text(
    //                   result.error ?? 'Gagal mengirimkan info data pribadi',
    //                   style: TextStyle(color: Colors.white)),
    //               backgroundColor: Colors.red,
    //               elevation: 24.0,
    //             ));
    //     // WidgetUtil.showSnackbar(
    //     //     context, result.error ?? 'Gagal mengirimkan info data pribadi');
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    KtpFormError formError = FormUtil.validateKtpForm(
      nik: _inputNikController.text,
      birthDate: _inputBirthDate,
    );
    return Scaffold(
      appBar: WidgetUtil.getNewAppBar(
        context,
        'Informasi Identitas',
        1,
        (newIndex) {
          Navigator.of(context).pop(newIndex);
        },
        () {
          Navigator.of(context).pop();
        },
        useNotificationIcon: false
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 24.0,
              ),
              child: Column(
                children: [
                  SizedBox(
                    child: Image.file(
                      File(widget.ktpModel.image.path),
                    ),
                  ),
                  SizedBox(height: 24.0),
                  CustomTextField(
                    labelText: '',
                    keyboardType: TextInputType.number,
                    enabled: !_isLoading,
                    controller: _inputNikController,
                    useLabel: false,
                    hintText: 'NIK',
                    borderRadius: 36.0,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 20.0,
                    ),
                    fillColor: Color(0xfff6f6f6),
                    onChanged: (_) {
                      setState(() {});
                    },
                    errorText: formError.errorNik,
                  ),
                  SizedBox(height: 12.0),
                  CustomTextField(
                    labelText: '',
                    enabled: !_isLoading,
                    controller: _inputNameController,
                    inputFormatters: [UpperCaseTextFormatter()],
                    useLabel: false,
                    hintText: 'Nama Lengkap',
                    borderRadius: 36.0,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 20.0,
                    ),
                    fillColor: Color(0xfff6f6f6),
                  ),
                  SizedBox(height: 12.0),
                  CustomTextField(
                    labelText: '',
                    inputFormatters: [UpperCaseTextFormatter()],
                    enabled: !_isLoading,
                    controller: _inputAddressController,
                    minLines: 2,
                    maxLines: 5,
                    useLabel: false,
                    hintText: 'Alamat',
                    borderRadius: 36.0,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 20.0,
                    ),
                    fillColor: Color(0xfff6f6f6),
                  ),
                  SizedBox(height: 12.0),
                  CustomDateField(
                    labelText: 'Tanggal Lahir',
                    enabled: !_isLoading,
                    currentValue: _inputBirthDate,
                    onChanged: (DateTime? newBirthDate) {
                      setState(() {
                        _inputBirthDate = newBirthDate;
                      });
                    },
                    useLabel: false,
                    errorText: formError.errorBirthDate,
                    buttonType: 'button_text_field',
                    borderRadius: 36.0,
                    fillColor: Color(0xfff6f6f6),
                    lastDate: DateTime.now(),
                  ),
                  SizedBox(height: 12.0),
                  CustomTextField(
                    labelText: '',
                    inputFormatters: [UpperCaseTextFormatter()],
                    enabled: !_isLoading,
                    controller: _inputJobController,
                    useLabel: false,
                    hintText: 'Pekerjaan',
                    borderRadius: 36.0,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 20.0,
                    ),
                    fillColor: Color(0xfff6f6f6),
                  ),
                  SizedBox(height: 12.0),
                  ElevatedButtonLoading(
                    text: 'Lanjutkan',
                    onTap: _submitForm,
                    isLoading: _isLoading,
                    disabled: _isLoading,
                  ),
                  SizedBox(height: 80.0), // BottomNavBar
                ],
              ),
            ),
          ),
          // FloatingBottomNavigationBar(
          //   isVisible: _isBottomNavBarVisible,
          //   currentIndex: 1,
          //   onTapItem: (newIndex) {
          //     Navigator.of(context).pop(newIndex);
          //   },
          // ),
        ],
      ),
    );
  }
}
