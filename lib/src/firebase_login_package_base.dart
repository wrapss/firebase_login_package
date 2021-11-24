import 'package:firebase_auth/firebase_auth.dart';

class PhoneSignInFailure implements Exception {}

class PhoneVerificationInFailure implements Exception {}

class LogOutFailure implements Exception {}

class AuthenticationRepository {
  final FirebaseAuth _firebaseAuth;
  User? user;
  String? message;
  late String _verificationId;

  AuthenticationRepository(this._firebaseAuth);

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
          await _firebaseAuth.signInWithCredential(phoneAuthCredential);
        },
        verificationFailed: (FirebaseAuthException authException) {
          message = authException.message;
        },
        codeSent: (String verificationId, [int? forceResendingToken]) {
          _verificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
      print(message);
      print(_verificationId);
    } on Exception {
      throw PhoneVerificationInFailure;
    }
  }

  Future<void> signInWithPhoneNumber(String smsCode) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: smsCode,
      );
      user = (await _firebaseAuth.signInWithCredential(credential)).user!;
    } on Exception {
      throw PhoneSignInFailure;
    }
  }
}
