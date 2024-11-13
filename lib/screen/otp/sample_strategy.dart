import 'package:otp_autofill/otp_autofill.dart';

/// Dummy class that will emulate receiving OTP SMS after certain seconds.
///
class SampleStrategy extends OTPStrategy {
  @override
  Future<String> listenForCode() {
    return Future.delayed(
      const Duration(seconds: 70),
      () => 'Your code is 54321',
    );
  }
}
