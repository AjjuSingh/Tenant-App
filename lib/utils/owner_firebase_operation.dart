import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:geo_firestore/geo_firestore.dart';
import 'package:rent_app/models/map_marker_user_model.dart';
import 'package:rent_app/utils/owner_firebase_interface.dart';

class OwnerFirebaseOperation extends OwnerFirebaseInterface {
  final Firestore _db = Firestore.instance;
  Future<void> storeLocationWithUid(Map<String, dynamic> userRegistrationData, String uid) async {
    try {

      GeoFirestore geoFirestore = GeoFirestore(_db.collection("location"));

      await _db.collection("location").document(uid).setData({"imageUrl": userRegistrationData["profileImage"]});
      await geoFirestore.setLocation(
          uid, GeoPoint(userRegistrationData["latitude"], userRegistrationData["longitude"]));
    } catch (e) {
      print("Error occured ::::: " + e.toString());
    }
  }

  @override
  Future<void> updateRegistrationProfile(
      Map<String, dynamic> userRegistrationData, String userUid, String userType) async {
    // Find document for current userUid
    try {
      await _db
          .collection("user")
          .where("uid", isEqualTo: userUid)
          .reference()
          .getDocuments()
          .then((value) => value.documents[0].reference)
          .then((postRef) {
        _db.runTransaction((transaction) async {
          DocumentSnapshot snapshot = await transaction.get(postRef);
          if (snapshot.exists) {
            await transaction.update(postRef, userRegistrationData);
          }
        });
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Future<String> profilePictureUrl(File profileImage, String userUid) async {
    // Profile url is generated after uploading to firebase storage
    StorageReference storageReference =
        FirebaseStorage().ref().child("rentAppUserProfilePic/${userUid}_profile_pic.png");
    StorageUploadTask uploadTask = storageReference.putFile(profileImage);
    StorageTaskSnapshot snapshot = await uploadTask.onComplete;
    return snapshot.storageMetadata.path;
  }

  @override
  // ignore: missing_return
  Future<bool> uploadHomePicture(List<File> homeImages, String uid) async {
    try {
      for (int i = 0; i < homeImages.length; i++) {
        StorageReference storageReference = FirebaseStorage().ref().child("homeImages/${uid}_home_${i.toString()}");
        storageReference.putFile(homeImages[i]);
      }
      return true;
    } catch (e) {
      print("Error found:::::: " + e.toString());
    }
  }

  @override
  Future<String> getDownloadUrlProfilePicture(String userUid) async {
    StorageReference storageReference =
        FirebaseStorage().ref().child("rentAppUserProfilePic/${userUid}_profile_pic.png");

    var link = await storageReference.getDownloadURL();
    return link;
  }

  @override
  Stream<MapMarkerUserModel> streamMapMarkerUserModel(String uid) {

  }
}
