import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationRepository {
  AuthenticationRepository(this.firebaseAuth);

  final FirebaseAuth firebaseAuth;
  User? user;
  String? message;
  late String _verificationId;

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
    } on FirebaseAuthException catch (e) {
      return print(e);
    }
  }

  Future<void> signInWithPhoneNumber(String smsCode) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: smsCode,
      );
      user = (await firebaseAuth.signInWithCredential(credential)).user!;
    } on FirebaseAuthException catch (e) {
      return print(e);
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
      return print(e);
    }
  }

  Future<void> verifyPhoneNumberUpdate(String phoneNumber) async {
    try {
      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
          await user!.updatePhoneNumber(phoneAuthCredential);
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
    } on FirebaseAuthException catch (e) {
      return print(e);
    }
  }

  Future<void> updatePhoneNumber(String smsCode) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: smsCode,
      );
      await user!.updatePhoneNumber(credential);
    } on FirebaseAuthException catch (e) {
      return print(e);
    }
  }

  Future<void> logOut() async {
    try {
      await Future.wait([
        firebaseAuth.signOut(),
      ]);
    } on FirebaseAuthException catch (e) {
      return print(e);
    }
  }
}
