import 'package:firebase_auth/firebase_auth.dart';

class PhoneSignInFailure implements Exception {}

class PhoneVerificationInFailure implements Exception {}

class LogOutFailure implements Exception {}

class AuthenticationRepository {
  final FirebaseAuth firebaseAuth;
  User? user;
  String? message;
  late String _verificationId;

  AuthenticationRepository(this.firebaseAuth);

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    try {
      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
          await firebaseAuth.signInWithCredential(phoneAuthCredential);
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
      user = (await firebaseAuth.signInWithCredential(credential)).user!;
    } on Exception {
      throw PhoneSignInFailure;
    }
  }

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  Future<void> logOut() async {
    try {
      await Future.wait([
        firebaseAuth.signOut(),
      ]);
    } on Exception {
      throw LogOutFailure();
    }
  }
}
