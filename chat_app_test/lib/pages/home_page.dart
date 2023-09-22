
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_test/helper/constanst.dart';
import 'package:chat_app_test/models/chat_user_model.dart';
import 'package:chat_app_test/providers/auth_provider.dart';
import 'package:chat_app_test/widgets/loading.dart';
import 'package:chat_app_test/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  List<ChatUserModel> listTemp = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero,() {
      getInfoCurrentUser();
    },);
  }

  getInfoCurrentUser()async{
    final authProvider = Provider.of<AuthProviders>(context, listen: false);
    authProvider.getSelfInfo();
  }




  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProviders>(context);
    return  Scaffold(
      appBar: AppBar(
        leading: photoProfile(),
        title:  nameUser(), 
        actions: [
          IconButton(onPressed: () async{
            final authProvider = Provider.of<AuthProviders>(context, listen: false);
            await authProvider.handlesingOut();
            Navigator.pushReplacementNamed(context, 'login');
          }, icon: const Icon(Icons.close)), 
        ],
      ),
      body: StreamBuilder(
        stream: authProvider.getAllUsers(),
        //initialData: const [],
        builder: (BuildContext context, AsyncSnapshot snapshot) {

          if(!snapshot.hasData){
            return const Center(child:LoadingView(),);
          }else if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(child:LoadingView(),);
          }else{

            final List<DocumentSnapshot> data = snapshot.data.docs;

            listTemp = data.map((e) => ChatUserModel.fromJson( e.data() as Map<String, dynamic>)  ).toList() ?? [];
            //authProvider.listChat  = listTemp;

            if(listTemp.isNotEmpty){
              return ListView.builder(
                physics:const  BouncingScrollPhysics(),
                itemCount: listTemp.length,
                itemBuilder: (BuildContext context, int index) {
                  return ChatUserCard(chatUserModel: listTemp[index]);
                },
              );

            }else{
              return const Center(child: Text('No hay chats en este momento..' , style: TextStyle(fontSize: 17),));
            }

          }
        },
      ),
    );
  }


  
  Widget nameUser(){
    final authProvider = Provider.of<AuthProviders>(context, listen: false);
    switch (authProvider.enumLoadUser) {
      case EnumLoadUser.load:
        return Text(authProvider.userCurrentInfo.nickname);
      default:
        return const SizedBox();
    }
  }

  Widget photoProfile(){
    final authProvider = Provider.of<AuthProviders>(context, listen: false);
    switch (authProvider.enumLoadUser) {
      case EnumLoadUser.load:
        return CachedNetworkImage(
            imageUrl: authProvider.userCurrentInfo.photoUrl,
            imageBuilder: (context, imageProvider) => Padding(
              padding: const EdgeInsets.all(6.0),
              child: CircleAvatar(
                radius: 20,
                backgroundImage: imageProvider,
              ),
            ),
            placeholder: (context, url) => const Center(child: Icon(Icons.person)), // Puedes personalizar el placeholder
            errorWidget: (context, url, error) => const Icon(Icons.error), // Puedes personalizar el widget de error
          );
      default:
        return const SizedBox();
    }
  }


}