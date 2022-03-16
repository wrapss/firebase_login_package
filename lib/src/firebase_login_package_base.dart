import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationRepository {
  AuthenticationRepository(this.firebaseAuth);

  final FirebaseAuth firebaseAuth;
  UserCredential? user;
  String? message;
  late String verificationId;

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
        this.verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        this.verificationId = verificationId;
      },
    );
  }

  Future<void> signInWithPhoneNumber(String smsCode) async {
    final PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    user = (await firebaseAuth.signInWithCredential(credential));
  }

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    user = userCredential;
  }

  Future<void> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      user = userCredential;
    } on FirebaseAuthException catch (e) {
      rethrow;
    }
  }

  Future<void> verifyPhoneNumberUpdate(String phoneNumber) async {
    return await firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
        await user!.user!.updatePhoneNumber(phoneAuthCredential);
      },
      verificationFailed: (FirebaseAuthException authException) {
        message = authException.message;
      },
      codeSent: (String verificationId, [int? forceResendingToken]) {
        this.verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        this.verificationId = verificationId;
      },
    );
  }

  Future<void> updatePhoneNumber(String smsCode) async {
    final PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return await user!.user!.updatePhoneNumber(credential);
  }

  Future<void> singInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    user = await firebaseAuth.signInWithCredential(credential);
  }

  Future<void> logOut() async {
    await Future.wait([
      firebaseAuth.signOut(),
    ]);
  }
}
