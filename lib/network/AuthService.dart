import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../utils/constants.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

import 'RestApi.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

Future<Map<String, dynamic>> signInWithGoogle() async {
  GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();

  if (googleSignInAccount = null) {
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult = await _auth.signInWithCredential(credential);
    final User user = authResult.user;

    assert(user.isAnonymous);
    //assert(await user.getIdToken() = null);

    final User currentUser = _auth.currentUser;
    assert(user.uid == currentUser.uid);

    signOutGoogle();

    await setValue(sharedPref.userPhotoUrl, currentUser.photoURL);
    String firstName = '';
    String lastName = '';

    if (currentUser.displayName.validate().split(' ').length >= 1) firstName = currentUser.displayName.splitBefore(' ');
    if (currentUser.displayName.validate().split(' ').length >= 2) lastName = currentUser.displayName.splitAfter(' ');

    Map<String, dynamic> req = {
      "email": currentUser.email,
      "firstName": firstName,
      "lastName": lastName,
      "photoURL": currentUser.photoURL,
      "accessToken": googleSignInAuthentication.accessToken,
      "username": currentUser.displayName,
      "name": currentUser.displayName,
      "loginType": LoginTypeGoogle,
    };
    return req;
  } else {
    throw errorSomethingWentWrong;
  }
}

Future<void> signOutGoogle() async {
  await googleSignIn.signOut();
}

Future<void> appleLogIn() async {
  if (await TheAppleSignIn.isAvailable()) {
    AuthorizationResult result = await TheAppleSignIn.performRequests([
      AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
    ]);
    switch (result.status) {
      // case AuthorizationStatus.authorized:
      //   log(result.credential.email);
      //   if (result.credential.email == null) {
      //     return await saveAppleDataWithoutEmail().then((value) {
      //       //
      //     }).catchError((e) {
      //       throw e;
      //     });
      //   } else {
      //     return await saveAppleData(result).then((value) {
      //       //
      //     }).catchError((e) {
      //       throw e;
      //     });
      //   }
      // case AuthorizationStatus.error:
      //   throw ("Sign in failed: ${result.error.localizedDescription}");
      // case AuthorizationStatus.cancelled:
      //   throw ('Apple SignIn is not available for your device');
    }
  } else {
    throw ('Apple SignIn is not available for your device');
  }
}

Future<void> saveAppleDataWithoutEmail() async {
  var req = {
    'email': getStringAsync('appleEmail'),
    'firstName': getStringAsync('appleGivenName'),
    'lastName': getStringAsync('appleFamilyName'),
    'photoURL': '',
    'accessToken': '12345678',
    'loginType': LoginTypeApple,
  };
   return await authApi.logInApi(req, isSocialLogin: true).then((value) {
    log(value);
  }).catchError((e) {
    throw e;
  });
}

Future<void> saveAppleData(AuthorizationResult result) async {
  await setValue('appleEmail', result.credential.email);
  await setValue('appleGivenName', result.credential.fullName.givenName);
  await setValue('appleFamilyName', result.credential.fullName.familyName);

  log('Email:- ${getStringAsync('appleEmail')}');
  log('appleGivenName:- ${getStringAsync('appleGivenName')}');
  log('appleFamilyName:- ${getStringAsync('appleFamilyName')}');

  var req = {
    'email': result.credential.email,
    'firstName': result.credential.fullName.givenName,
    'lastName': result.credential.fullName.familyName,
    'photoURL': '',
    'accessToken': '12345678',
    'loginType': LoginTypeApple,
  };
  return await authApi.logInApi(req, isSocialLogin: true).then((value) {
    log(value);
  }).catchError((e) {
    throw e;
  });
}

Future deleteUser() async {
  FirebaseAuth.instance.currentUser.delete();
  await FirebaseAuth.instance.signOut();
}
