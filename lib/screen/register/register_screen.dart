import 'package:flutter/material.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/home/home_screen.dart';
import 'package:pensiunku/screen/register/register_controller.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/widget/custom_text_field.dart';
import 'package:pensiunku/widget/elevated_button_loading.dart';

class RegisterScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/register';

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // AccountModel _accountModel = AccountModel();
  RegisterController _controller = RegisterController();
  bool _isLoading = false;

  String _inputName = '';
  bool _inputNameTouched = false;
  late TextEditingController _inputNameController;

  // String _inputEmail = '';
  // bool _inputEmailTouched = false;
  // late TextEditingController _inputEmailController;

  // String _inputBirthDate = '';
  // bool _inputBirthDateTouched = false;

  // String _inputJob = '';
  // bool _inputJobTouched = false;

  String _inputReferral = '';
  // late TextEditingController _inputReferralController;

  @override
  void initState() {
    super.initState();

    _inputNameController = TextEditingController()
      ..addListener(() {
        setState(() {
          _inputName = _inputNameController.text;
          _inputNameTouched = true;
        });
      });
    // _inputEmailController = TextEditingController()
    //   ..addListener(() {
    //     setState(() {
    //       _inputEmail = _inputEmailController.text;
    //       _inputEmailTouched = true;
    //     });
    //   });
    // _inputReferralController = TextEditingController()
    //   ..addListener(() {
    //     setState(() {
    //       _inputReferral = _inputReferralController.text;
    //     });
    //   });
  }

  @override
  void dispose() {
    _inputNameController.dispose();
    // _inputEmailController.dispose();
    // _inputReferralController.dispose();
    super.dispose();
  }

  /// Register user
  _register() {
    setState(() {
      _inputNameTouched = true;
      // _inputEmailTouched = true;
      // _inputBirthDateTouched = true;
      // _inputJobTouched = true;
    });
    if (_controller.isAllInputValid(
      _inputName,
      _inputNameTouched,
      // _inputEmail,
      // _inputEmailTouched,
      // _inputBirthDate,
      // _inputBirthDateTouched,
      // _inputJob,
      // _inputJobTouched,
    )) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    var data = {
      'username': _inputName,
      // 'email': _inputEmail,
      // 'tanggal_lahir': _inputBirthDate,
      // 'pekerjaan': _inputJob,
    };
    if (_inputReferral.trim().isNotEmpty) {
      data['referal'] = _inputReferral;
    }

    UserRepository().updateOne(token!, data).then((result) {
      setState(() {
        _isLoading = false;
      });
      if (result.isSuccess) {
        Navigator.of(context).pushReplacementNamed(HomeScreen.ROUTE_NAME);
      } else {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  content: Text(result.error ?? 'Gagal menyimpan data user',
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.red,
                  elevation: 24.0,
                ));
        // WidgetUtil.showSnackbar(
        //   context,
        //   result.error ?? 'Gagal menyimpan data user',
        // );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String? inputNameError =
        _controller.getInputNameError(_inputName, _inputNameTouched);
    // String? inputEmailError =
    //     _controller.getInputEmailError(_inputEmail, _inputEmailTouched);
    // String? inputBirthDateError = _controller.getInputBirthDateError(
    //     _inputBirthDate, _inputBirthDateTouched);
    // String? inputJobError =
    //     _controller.getInputJobError(_inputJob, _inputJobTouched);

    return Scaffold(
      backgroundColor: Color(0xfff6f6f6),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: 24.0),
                SizedBox(
                  height: 180,
                  child: Image.asset('assets/register_screen/image_1.png'),
                ),
                SizedBox(height: 24.0),
                CustomTextField(
                  controller: _inputNameController,
                  labelText: '',
                  keyboardType: TextInputType.name,
                  enabled: !_isLoading,
                  errorText: inputNameError,
                  borderRadius: 36.0,
                  hintText: 'Nama',
                  useLabel: false,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 20.0,
                  ),
                ),
                // SizedBox(height: 24.0),
                // CustomTextField(
                //   controller: _inputEmailController,
                //   labelText: '',
                //   keyboardType: TextInputType.emailAddress,
                //   enabled: !_isLoading,
                //   errorText: inputEmailError,
                //   borderRadius: 36.0,
                //   hintText: 'Email',
                //   useLabel: false,
                //   fillColor: Colors.white,
                //   contentPadding: EdgeInsets.symmetric(
                //     horizontal: 24.0,
                //     vertical: 20.0,
                //   ),
                // ),
                // // SizedBox(height: 12.0),
                // // CustomTextField(
                // //   labelText: 'Alamat',
                // //   keyboardType: TextInputType.multiline,
                // //   enabled: !_isLoading,
                // //   minLines: 2,
                // //   maxLines: 5,
                // // ),
                // SizedBox(height: 12.0),
                // CustomDateField(
                //   labelText: 'Tanggal Lahir',
                //   currentValue: _accountModel.birthDate,
                //   enabled: !_isLoading,
                //   onChanged: (DateTime? newBirthDate) {
                //     setState(() {
                //       _inputBirthDate =
                //           DateFormat('yyyy-MM-dd').format(newBirthDate!);
                //       _accountModel.birthDate = newBirthDate;
                //     });
                //   },
                //   buttonType: 'button_text_field',
                //   errorText: inputBirthDateError,
                //   hintText: 'Tanggal Lahir',
                //   useLabel: false,
                //   fillColor: Colors.white,
                //   borderRadius: 36.0,
                //   lastDate: DateTime.now(),
                // ),
                // // SizedBox(height: 12.0),
                // // CustomSelectField(
                // //   labelText: 'Jenis Kelamin',
                // //   searchLabelText: 'Pilih Jenis Kelamin',
                // //   currentOption: _accountModel.gender,
                // //   options: GenderRepository.getGenders(),
                // //   enabled: !_isLoading,
                // //   onChanged: (OptionModel newGender) {
                // //     setState(() {
                // //       _accountModel.gender = newGender;
                // //     });
                // //   },
                // //   enableSearch: false,
                // //   buttonType: 'grey_select_button',
                // // ),
                // SizedBox(height: 12.0),
                // CustomSelectField(
                //   labelText: 'Pekerjaan',
                //   searchLabelText: 'Cari Pekerjaan',
                //   currentOption: _accountModel.job,
                //   options: JobRepository.getJobs(),
                //   enabled: !_isLoading,
                //   onChanged: (OptionModel newJob) {
                //     setState(() {
                //       _inputJob = newJob.text;
                //       _accountModel.job = newJob;
                //     });
                //   },
                //   buttonType: 'button_text_field',
                //   errorText: inputJobError,
                //   hintText: 'Pekerjaan',
                //   useLabel: false,
                //   fillColor: Colors.white,
                //   borderRadius: 36.0,
                // ),
                // SizedBox(height: 24.0),
                // CustomTextField(
                //   controller: _inputReferralController,
                //   labelText: '',
                //   keyboardType: TextInputType.name,
                //   enabled: !_isLoading,
                //   borderRadius: 36.0,
                //   hintText: 'Referal',
                //   useLabel: false,
                //   fillColor: Colors.white,
                //   contentPadding: EdgeInsets.symmetric(
                //     horizontal: 24.0,
                //     vertical: 20.0,
                //   ),
                // ),
                SizedBox(height: 24.0),
                ElevatedButtonLoading(
                  text: 'Daftar',
                  onTap: _register,
                  isLoading: _isLoading,
                  disabled: _isLoading,
                ),
                SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
