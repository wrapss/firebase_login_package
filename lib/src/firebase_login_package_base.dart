import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationRepository {
  AuthenticationRepository(this.firebaseAuth);

  final FirebaseAuth firebaseAuth;
  User? user;
  String? message;
  late String _verificationId;

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    return await firebaseAuth.verifyPhoneNumber(
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
  }

  Future<void> signInWithPhoneNumber(String smsCode) async {
    final PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: smsCode,
    );
    user = (await firebaseAuth.signInWithCredential(credential)).user!;
  }

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    user = userCredential.user;
  }

  Future<void> verifyPhoneNumberUpdate(String phoneNumber) async {
    return await firebaseAuth.verifyPhoneNumber(
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
  }

  Future<void> updatePhoneNumber(String smsCode) async {
    final PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: smsCode,
    );
    return await user!.updatePhoneNumber(credential);
  }

  Future<void> logOut() async {
    await Future.wait([
      firebaseAuth.signOut(),
    ]);
  }
}
