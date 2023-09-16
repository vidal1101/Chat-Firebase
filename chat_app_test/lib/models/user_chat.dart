import 'package:chat_app_test/helper/constanst.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserChat {

  String id = '';
  String photoURL= '';
  String nickName ='';
  String aboutMe ='';
  String phoneNumber= '';

  UserChat({
    required this.id, 
    required  this.photoURL, 
    required this.nickName,
    required this.aboutMe, 
    required this.phoneNumber,
  });

  Map<String, String> toJson(){
    return {
      FirestoneConstants.nickName : nickName,
      FirestoneConstants.aboutMe : aboutMe, 
      FirestoneConstants.photoUrl : photoURL, 
      FirestoneConstants.phoneNumber : phoneNumber,
    };
  }


  factory UserChat.fromDocument(DocumentSnapshot documentSnapshot){
    String aboutme = "";
    String photourL = "";
    String nickname = "";
    String phonenumber = "";


    try {
      aboutme = documentSnapshot.get(FirestoneConstants.aboutMe); 
      photourL = documentSnapshot.get(FirestoneConstants.photoUrl); 
      nickname = documentSnapshot.get(FirestoneConstants.nickName); 
      phonenumber = documentSnapshot.get(FirestoneConstants.phoneNumber); 

    } catch (e) {
      debugPrint(e.toString()); 
    }

    return UserChat(id: documentSnapshot.id,
      photoURL: photourL, nickName: nickname, aboutMe: aboutme, phoneNumber: phonenumber);
    
  }



}