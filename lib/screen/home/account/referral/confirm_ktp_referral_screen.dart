import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pensiunku/data/api/base_api.dart';
import 'package:pensiunku/model/ktp_model.dart';
import 'package:pensiunku/model/referral_model.dart';
import 'package:pensiunku/repository/referral_repository.dart';
import 'package:pensiunku/screen/home/home_screen.dart';
import 'package:pensiunku/util/form_error/ktp_referal_form_error.dart';
import 'package:pensiunku/util/form_util.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/util/widget_util.dart';
import 'package:pensiunku/widget/custom_date_field.dart';
import 'package:pensiunku/widget/custom_text_field.dart';
import 'package:pensiunku/widget/elevated_button_loading.dart';
import 'package:pensiunku/widget/floating_bottom_navigation_bar.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class ConfirmKtpReferalScreenArgs {
  final ReferralModel referralModel;
  final KtpModel ktpModel;
  final void Function(BuildContext context) onSuccess;

  ConfirmKtpReferalScreenArgs({
    required this.referralModel,
    required this.ktpModel,
    required this.onSuccess,
  });
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class ConfirmKtpReferalScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/ktp/confirm/referal';
  final ReferralModel referralModel;
  final KtpModel ktpModel;
  final void Function(BuildContext context) onSuccess;

  const ConfirmKtpReferalScreen({
    Key? key,
    required this.referralModel,
    required this.ktpModel,
    required this.onSuccess,
  }) : super(key: key);

  @override
  _ConfirmKtpReferalScreenState createState() =>
      _ConfirmKtpReferalScreenState();
}

class _ConfirmKtpReferalScreenState extends State<ConfirmKtpReferalScreen> {
  bool _isLoading = false;
  KtpModel? ktpModel;
  ReferralModel get referralModel => widget.referralModel;
  late TextEditingController _inputNikController;
  late TextEditingController _inputNameController;
  late TextEditingController _inputAddressController;
  DateTime? _inputBirthDate;
  late TextEditingController _inputJobController;
  late TextEditingController _inputReferalController;
  bool _isBottomNavBarVisible = false;
  late File imageFile;
  // SubmissionModel get submissionModel => widget.submissionModel;

  // After downloading, we'll display the downloaded image
  File? _displayImage;
  late String fotoKtpFileName;

  @override
  void initState() {
    super.initState();

    ktpModel = ktpModel?.clone();
    _inputNikController = TextEditingController(
      text: referralModel.nikKtp == null
          ? widget.ktpModel.nik
          : referralModel.nikKtp,
    );
    _inputNameController = TextEditingController(
      text: referralModel.nameKtp == null
          ? widget.ktpModel.name
          : referralModel.nameKtp,
    );
    _inputAddressController = TextEditingController(
      text: referralModel.addressKtp == null
          ? widget.ktpModel.address
          : referralModel.addressKtp,
    );
    if (widget.ktpModel.birthDate != null) {
      _inputBirthDate = widget.ktpModel.birthDate;
    }
    _inputJobController = TextEditingController(
      text: referralModel.jobKtp == null
          ? widget.ktpModel.job
          : referralModel.jobKtp,
    );
    _inputReferalController = TextEditingController(
      text: referralModel.referal == null
          ? referralModel.referal
          : referralModel.referal,
    );

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
    _inputReferalController.dispose();
    super.dispose();
  }

  /// Submit form
  void _submitForm() {
    String? submitError = FormUtil.onSubmitKtpReferalForm(
      nik: _inputNikController.text,
      name: _inputNameController.text,
      address: _inputAddressController.text,
      birthDate: _inputBirthDate,
      job: _inputJobController.text,
      referal: _inputReferalController.text,
    );
    if (submitError != null) {
      WidgetUtil.showSnackbar(context, submitError);
      return;
    }
    setState(() {
      _isLoading = true;
    });

    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    ReferralRepository()
        .uploadKtp(
      token!,
      widget.referralModel.copyWith(
        nikKtp: _inputNikController.text,
        nameKtp: _inputNameController.text,
        addressKtp: _inputAddressController.text,
        birthDateKtp: _inputBirthDate,
        jobKtp: _inputJobController.text,
        referal: _inputReferalController.text,
      ),
      imageFile.path,
    )
        .then((result) {
      setState(() {
        _isLoading = false;
      });
      if (result.isSuccess) {
        setState(() {
          _isLoading = false;
        });
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  content: Text('Berhasil mengirimkan info data referal',
                      style: TextStyle(color: Colors.black)),
                  backgroundColor: Colors.white,
                  elevation: 24.0,
                ));
        Navigator.of(context)
            .pushNamedAndRemoveUntil(HomeScreen.ROUTE_NAME, (route) => false);
      } else {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  content: Text(
                      result.error ?? 'Gagal mengirimkan info data referal',
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.red,
                  elevation: 24.0,
                ));
        WidgetUtil.showSnackbar(
            context, result.error ?? 'Gagal mengirimkan info data pribadi');
      }
    });
  }

  Future<void> _downloadFotoKtp(String url) async {
    final response = await http.get(Uri.parse(url));

    // Get the image name
    final imageName = fotoKtpFileName;
    // Get the document directory path
    final appDir = await SharedPreferencesUtil.getAppDir();

    // This is the saved image path
    // You can use it to display the saved image later
    final localPath = path.join(appDir.path, imageName);

    //check it the file on local path
    if (File(path.join(appDir.path, imageName)).existsSync()) {
      //use local file
      imageFile = File(path.join(appDir.path, imageName));
    } else {
      //Downloading
      imageFile = File(localPath);
      await imageFile.writeAsBytes(response.bodyBytes);
    }

    setState(() {
      _displayImage = imageFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    fotoKtpFileName = referralModel.fotoKtp.toString();
    _downloadFotoKtp(
        '${BaseApi.baseUrl}/fotoktp/${referralModel.fotoKtp?.replaceAll('.jpg', '')}');
    KtpFormReferalError formError = FormUtil.validateKtpReferalForm(
      nik: _inputNikController.text,
      birthDate: _inputBirthDate,
      referal: _inputReferalController.text,
    );
    return Scaffold(
      appBar: WidgetUtil.getNewAppBar(
        context,
        'Informasi Identitas',
        2,
        (newIndex) {
          Navigator.of(context).pop(newIndex);
        },
        () {
          Navigator.of(context).pop();
        },
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
                  _buildBody(),
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
                    currentValue: _inputBirthDate,
                    enabled: !_isLoading,
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
                    lastDate: DateTime.now().add(
                      Duration(days: 50 * 365), // 50 years
                    ),
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
                  CustomTextField(
                    labelText: '',
                    inputFormatters: [UpperCaseTextFormatter()],
                    enabled: !_isLoading,
                    controller: _inputReferalController,
                    useLabel: false,
                    hintText: 'Kode Referal',
                    borderRadius: 36.0,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 20.0,
                    ),
                    fillColor: Color(0xfff6f6f6),
                    onChanged: (_) {
                      setState(() {});
                    },
                    errorText: formError.errorReferal,
                  ),
                  SizedBox(height: 12.0),
                  Text(
                    '*Jika terdapat kekeliruan pada data KTP, mohon untuk melakukan edit mandiri!',
                    style: theme.textTheme.subtitle1?.copyWith(
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(height: 12.0),
                  ElevatedButtonLoading(
                    text: 'Simpan',
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
          //   currentIndex: 2,
          //   onTapItem: (newIndex) {
          //     Navigator.of(context).pop(newIndex);
          //   },
          // ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (referralModel.fotoKtp != null) {
      return SizedBox(
        child: _displayImage != null ? Image.file(_displayImage!) : Container(),
      );
    } else {
      return SizedBox(
        child: Image.file(File(widget.ktpModel.image.path)),
      );
    }
  }
}
