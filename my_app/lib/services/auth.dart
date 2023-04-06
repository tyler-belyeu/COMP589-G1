import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_app/services/database.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, get the UserCredential
    // return await FirebaseAuth.instance.signInWithCredential(credential);
    final result = await FirebaseAuth.instance.signInWithCredential(credential);

    // create new firestore document for new users with their uid
    User? user = result.user;
    // DatabaseService db = DatabaseService(uid: user!.uid);
    // List userGroups = await db.getUserData('groups');
    // await db.updateUserData(userGroups == null ? userGroups : []);
    // await db.updateUserData([]);
    await DatabaseService(uid: user!.uid).updateUserData([]);

    return result;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
