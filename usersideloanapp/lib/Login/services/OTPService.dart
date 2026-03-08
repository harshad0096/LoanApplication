import 'package:firebase_auth/firebase_auth.dart';

class OTPService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendOTP({
    required String phone,
    required Function(String) codeSent,
    required Function(String) error,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        error(e.message ?? "Verification failed");
      },
      codeSent: (String verificationId, int? resendToken) {
        codeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<String?> verifyOTP({
    required String verificationId,
    required String otp,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      await _auth.signInWithCredential(credential);

      return null;
    } catch (e) {
      return "Invalid OTP";
    }
  }
}
