import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pensiunku/repository/customer_support_repository.dart';
import 'package:pensiunku/util/form_error/customer_support_form_error.dart';
import 'package:pensiunku/util/form_util.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/util/url_util.dart';
import 'package:pensiunku/util/widget_util.dart';
import 'package:pensiunku/widget/contact_list_tile.dart';
import 'package:pensiunku/widget/custom_text_field.dart';
import 'package:pensiunku/widget/elevated_button_loading.dart';
import 'package:pensiunku/widget/floating_bottom_navigation_bar.dart';
import 'package:pensiunku/screen/home/test.dart';

class CustomerSupportScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/customer-support';

  @override
  _CustomerSupportScreenState createState() => _CustomerSupportScreenState();
}

class _CustomerSupportScreenState extends State<CustomerSupportScreen> {
  late TextEditingController _inputNameController;
  late TextEditingController _inputPhoneController;
  late TextEditingController _inputEmailController;
  late TextEditingController _inputQuestionController;
  bool _isBottomNavBarVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _inputNameController = TextEditingController();
    _inputPhoneController = TextEditingController();
    _inputEmailController = TextEditingController();
    _inputQuestionController = TextEditingController();

    Future.delayed(Duration(milliseconds: 0), () {
      setState(() {
        _isBottomNavBarVisible = true;
      });
    });
  }

  @override
  void dispose() {
    _inputNameController.dispose();
    _inputPhoneController.dispose();
    _inputEmailController.dispose();
    _inputQuestionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    CustomerSupportFormError formError = FormUtil.validateCustomerSupportForm(
      phone: _inputPhoneController.text,
      email: _inputEmailController.text,
      question: _inputQuestionController.text,
    );

    return Scaffold(
      appBar:
          WidgetUtil.getNewAppBar(context, 'Customer Support', 2, (newIndex) {
        Navigator.of(context).pop(newIndex);
      }, () {
        Navigator.of(context).pop();
      }, useNotificationIcon: false),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 32.0),
                  Text(
                    'Butuh Bantuan Terkait Layanan?',
                    style: theme.textTheme.headline6?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Tim kami siap membantu anda setiap hari\nSenin-Jumat pukul 08.00-17.00',
                    style: theme.textTheme.bodyText2,
                  ),
                  SizedBox(height: 24.0),
                  Text(
                    'Kontak Langsung',
                    style: theme.textTheme.bodyText1?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12.0),
                  ContactListTile(
                    leading: Icon(
                      Icons.mail_outline,
                      color: Color(0xfffa4097),
                    ),
                    title: 'Email',
                    subtitle: 'ptkreditpensiun@gmail.com',
                    onTap: () {
                      UrlUtil.launchURL('mailto:ptkreditpensiun@gmail.com');
                    },
                  ),
                  SizedBox(height: 12.0),
                  ContactListTile(
                    leading: Icon(
                      Icons.phone_in_talk,
                      color: theme.colorScheme.secondary,
                    ),
                    title: 'Telepon',
                    subtitle: '087786130256',
                    onTap: () {
                      UrlUtil.launchURL('tel:087786130256');
                    },
                  ),
                  SizedBox(height: 12.0),
                  ContactListTile(
                    leading: SvgPicture.asset(
                      'assets/icon/whatsapp.svg',
                      color: Color.fromARGB(255, 50, 211, 102),
                      semanticsLabel: 'WhatsApp Logo',
                    ),
                    title: 'WhatsApp',
                    subtitle: '+6281181106000',
                    onTap: () {
                      UrlUtil.launchURL(
                          'https://wa.me/+6281181106000?text=Hallo%20admin%20kredit%20pensiun,%20saya%20memiliki%20kendala%20dalam%20menggunakan%20aplikasi%20kredit%20pensiun,%20bisa%20tolong%20dijelaskan%20cara%20penggunaannya%20?');
                    },
                  ),
                  SizedBox(height: 12.0),
                  ContactListTile(
                    leading: SvgPicture.asset(
                      'assets/icon/whatsapp.svg',
                      color: Color.fromARGB(255, 50, 211, 102),
                      semanticsLabel: 'WhatsApp Logo',
                    ),
                    title: 'Live Chat',
                    subtitle: 'Kredit Pensiun Admin',
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => LiveChat()));
                    },
                  ),
                  SizedBox(height: 24.0),
                  Text(
                    'Kirim Pertanyaan',
                    style: theme.textTheme.bodyText1?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Silakan isi detail informasi anda di bawah ini',
                    style: theme.textTheme.bodyText2,
                  ),
                  SizedBox(height: 32.0),
                  CustomTextField(
                    controller: _inputNameController,
                    labelText: '',
                    hintText: 'Nama',
                    keyboardType: TextInputType.name,
                    useLabel: false,
                    borderRadius: 36.0,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 20.0,
                    ),
                  ),
                  SizedBox(height: 12.0),
                  CustomTextField(
                    controller: _inputPhoneController,
                    labelText: '',
                    hintText: 'No. Handphone',
                    keyboardType: TextInputType.phone,
                    useLabel: false,
                    borderRadius: 36.0,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 20.0,
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                    errorText: formError.errorPhone,
                  ),
                  SizedBox(height: 12.0),
                  CustomTextField(
                    controller: _inputEmailController,
                    labelText: '',
                    hintText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    useLabel: false,
                    borderRadius: 36.0,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 20.0,
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                    errorText: formError.errorEmail,
                  ),
                  SizedBox(height: 12.0),
                  CustomTextField(
                    controller: _inputQuestionController,
                    labelText: '',
                    keyboardType: TextInputType.multiline,
                    hintText: 'Pertanyaan (Minimal 20 karakter)',
                    minLines: 2,
                    maxLines: 5,
                    useLabel: false,
                    borderRadius: 36.0,
                    onChanged: (_) {
                      setState(() {});
                    },
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 20.0,
                    ),
                    errorText: formError.errorQuestion,
                  ),
                  SizedBox(height: 12.0),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButtonLoading(
                      text: 'Kirim',
                      onTap: _onSubmit,
                      isLoading: _isLoading,
                      disabled: _isLoading,
                    ),
                  ),
                  SizedBox(height: 90.0), // BottomNavBar
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

  void _onSubmit() {
    String? submitError = FormUtil.onSubmitCustomerSupportForm(
      name: _inputNameController.text,
      phone: _inputPhoneController.text,
      email: _inputEmailController.text,
      question: _inputQuestionController.text,
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

    var data = {
      'name': _inputNameController.text,
      'phone': _inputPhoneController.text,
      'email': _inputEmailController.text,
      'question': _inputQuestionController.text,
    };
    CustomerSupportRepository()
        .sendQuestion(
      token!,
      data,
    )
        .then((result) {
      setState(() {
        _isLoading = false;
      });
      if (result.isSuccess) {
        _inputNameController.text = '';
        _inputEmailController.text = '';
        _inputPhoneController.text = '';
        _inputQuestionController.text = '';
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  content: Text('Pertanyaan Anda berhasil dikirim!',
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.green,
                  elevation: 24.0,
                ));
        // WidgetUtil.showSnackbar(context, 'Pertanyaan Anda berhasil dikirim!');
      } else {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  content: Text(
                      result.error ?? 'Gagal mengirim pertanyaan Anda',
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.red,
                  elevation: 24.0,
                ));
        // WidgetUtil.showSnackbar(
        //     context, result.error ?? 'Gagal mengirim pertanyaan Anda');
      }
    });
  }
}
