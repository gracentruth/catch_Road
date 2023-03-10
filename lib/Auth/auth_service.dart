import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../LoginPage.dart';
import '../screen/mainHome.dart';

class AuthService {
  handleAuthState() {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          return MainHomePage();
        } else {

          return LoginPage();

        }
      },
    );
  }

  void signOut() {}

  void signInWithGoogle() {}
}

final FirebaseAuth _auth = FirebaseAuth.instance;
final User? user = _auth.currentUser;
final uid = user!.uid;
final GoogleSignIn googleSignIn = new GoogleSignIn();

final DateTime timestamp = DateTime.now();
// final GoogleSignInAccount? gCurrentUser = googleSignIn.currentUser;

final userReference = FirebaseFirestore.instance.collection('users');
// User? currentUser;

signInWithGoogle() async {
  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser =
      await GoogleSignIn(scopes: <String>["email"]).signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication googleAuth =
      await googleUser!.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  // saveUserInfoFirestore();
  DocumentSnapshot documentSnapshot =
      await userReference.doc(googleUser.email).get();

  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithCredential(credential);
}

userstart() {
  FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get()
      .then((doc) async {
    print('?????? ??????');
    if (!doc.exists) {
      userReference.doc().set({
        'profileName': FirebaseAuth.instance.currentUser!.displayName!,
        'url': FirebaseAuth.instance.currentUser!.photoURL!,
        'email': FirebaseAuth.instance.currentUser!.email,
        'status_message': 'I promise to take the test honestly before GOD.',
        'uid': FirebaseAuth.instance.currentUser!.uid
      }).whenComplete(() {
        print('??????');
      });
    } else {
      print('?????? ?????? ?????????');
    }
  });
}

Future<void> signOut() async {
  // logOut ??????
  await _auth.signOut();
  print('logOut');
}

contentsFunction(
    user, _photo, TitleController, contentsController, priceController) async {
  //????????? ????????? ?????? (?????? ??????, ??????, ??????, ??? ?????? )

  // ??????????????? ?????? ?????? ????????? ?????? ??????.
  final firebaseStorageRef = FirebaseStorage.instance;
  List _like = [];
  List wish = [];
  if (_photo != null) {
    TaskSnapshot task = await firebaseStorageRef
        .ref() // ?????????
        .child('post') // collection ??????
        .child(
            '${_photo} + ${FirebaseAuth.instance.currentUser!.displayName!}') // ???????????? ????????? ????????????
        .putFile(_photo!);
    //  var doc = FirebaseFirestore.instance.collection('Product').doc(priceController.text);
    //     doc.set({
    //       'id': doc.id,
    //       'datetime' : DateTime.now().toString(),
    //       'displayName':FirebaseAuth.instance.currentUser!.displayName!,
    //       'title' : TitleController.text,
    //       'content' : contentsController.text,
    //       'imageUrl' : _photo,
    //       'price' : priceController.text,
    //       'like' : _like,
    //     }).whenComplete(() => print('????????? ?????? ??????'));
    if (task != null) {
      var downloadUrl = await task.ref
          .getDownloadURL()
          .whenComplete(() => print('?????? ????????? ??????'));
      var doc = FirebaseFirestore.instance
          .collection('Product')
          .doc(priceController.text);
      doc.set({
        'uid': FirebaseAuth.instance.currentUser!.uid,
        'id': doc.id,
        'datetime': DateTime.now().toString(),
        'displayName': FirebaseAuth.instance.currentUser!.displayName!,
        'title': TitleController.text,
        'content': contentsController.text,
        'imageUrl': downloadUrl,
        'price': priceController.text,
        'like': _like,
        'modify': ' ',
        'wish': wish
      }).whenComplete(() => print('????????? ?????? ??????'));
    } else {}
  } else {
    var doc = FirebaseFirestore.instance
        .collection('Product')
        .doc(priceController.text);
    doc.set({
      'uid': FirebaseAuth.instance.currentUser!.uid,
      'id': doc.id,
      'datetime': DateTime.now().toString(),
      'displayName': FirebaseAuth.instance.currentUser!.displayName!,
      'title': TitleController.text,
      'content': contentsController.text,
      'imageUrl': 'https://handong.edu/site/handong/res/img/logo.png',
      'price': priceController.text,
      'like': _like,
      'modify': ' ',
      'wish': wish
    }).whenComplete(() => print('????????? ?????? ??????'));
  }
}

contentsUpdate(user, _photo, TitleController, contentsController,
    priceController, url) async {
  final firebaseStorageRef = FirebaseStorage.instance;
  List _like = [];
  if (_photo != null) {
    TaskSnapshot task = await firebaseStorageRef
        .ref() // ?????????
        .child('post') // collection ??????
        .child(
            '${_photo} + ${FirebaseAuth.instance.currentUser!.displayName!}') // ???????????? ????????? ????????????
        .putFile(_photo!);

    if (task != null) {
      var downloadUrl = await task.ref
          .getDownloadURL()
          .whenComplete(() => print('?????? ????????? ??????'));
      var doc = FirebaseFirestore.instance
          .collection('Product')
          .doc(priceController.text);
      doc.update({
        'id': doc.id,
        'displayName': FirebaseAuth.instance.currentUser!.displayName!,
        'title': TitleController.text,
        'content': contentsController.text,
        'imageUrl': downloadUrl,
        'price': priceController.text,
        'like': _like,
        'modify': DateTime.now().toString(),
      }).whenComplete(() => print('????????? ?????? ??????'));
    }
  } else {
    var doc = FirebaseFirestore.instance
        .collection('Product')
        .doc(priceController.text);
    doc.update({
      'id': doc.id,
      'displayName': FirebaseAuth.instance.currentUser!.displayName!,
      'title': TitleController.text,
      'content': contentsController.text,
      'imageUrl': url,
      'price': priceController.text,
      'like': _like,
      'modify': DateTime.now().toString(),
    });
  }
}

LikeFunction(like, id, user) async {
  // ????????? ??????
  List _likes = like;
  _likes.add(user);
  var doc = FirebaseFirestore.instance.collection('Product').doc(id);
  doc.update({'like': _likes, '${user}': user}).whenComplete(
      () => print('????????? ???????????? ??????'));
}

Wishlist(
    user, TitleController, contentsController, priceController, url, wish) {
  var doc = FirebaseFirestore.instance
      .collection('${FirebaseAuth.instance.currentUser!.displayName!}Wish')
      .doc(priceController.text);
  doc.set({
    'id': doc.id,
    'displayName': FirebaseAuth.instance.currentUser!.displayName!,
    'title': TitleController.text,
    'content': contentsController.text,
    'imageUrl': url,
    'price': priceController.text,
    'wish': wish
  }).whenComplete(() => print('????????? ?????? ??????'));
}

wishupdate(user, priceController, num, list) {
  //
  var doc = FirebaseFirestore.instance
      .collection('Product')
      .doc(priceController.text);
  if (num == 0) {
    doc.update({'wish': list}).whenComplete(() => print('?????? ??????'));
  } else {
    doc.update({'wish': list}).whenComplete(() => print('?????? ??????'));
  }
}

wishupdateTowish(user, priceController, num, list) {
  //
  var doc =
      FirebaseFirestore.instance.collection('Product').doc(priceController);
  if (num == 0) {
    doc.update({'wish': list}).whenComplete(() => print('?????? ??????'));
  } else {
    doc.update({'wish': list}).whenComplete(() => print('?????? ??????'));
  }
}
