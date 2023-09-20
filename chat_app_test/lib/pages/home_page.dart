
import 'dart:convert';

import 'package:chat_app_test/helper/constanst.dart';
import 'package:chat_app_test/providers/auth_provider.dart';
import 'package:chat_app_test/widgets/loading.dart';
import 'package:chat_app_test/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  String? name ="";
  String? urlImage  = "";


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero,() {
      getInfor();
    },);
  }

  void getInfor()async{
    final authProvider = Provider.of<AuthProviders>(context, listen: false);

     name = await authProvider.sharedPreferences.getString(FirestoneConstants.nickName);
     urlImage = await authProvider.sharedPreferences.getString(FirestoneConstants.photoUrl);
     setState(() {
       
     });
  }



  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProviders>(context);
    return  Scaffold(
      appBar: AppBar(
        title: Text(name.toString()),
        actions: [
          IconButton(onPressed: () async{
            final authProvider = Provider.of<AuthProviders>(context, listen: false);
            await authProvider.handlesingOut();
            Navigator.pushReplacementNamed(context, 'login');
          }, icon: const Icon(Icons.close)), 
        ],
      ),
      body: StreamBuilder(
        stream: authProvider.firebaseFirestore.collection(FirestoneConstants.pathUsercolection).snapshots(),
        //initialData: const [],
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          final listTemp = [];

          if(!snapshot.hasData){
            return const Center(child:LoadingView(),);
          }else if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(child:LoadingView(),);
          }else{

            final data = snapshot.data.docs;
            for (var element in data) {
              print('Data: ${ jsonEncode(element.data()) }');
              listTemp.add(element.data()['nickname']);
            }
            

            return ListView.builder(
              physics:const  BouncingScrollPhysics(),
              itemCount: listTemp.length,
              itemBuilder: (BuildContext context, int index) {
                return Text("Nombre: ${listTemp[index]}");
              },
            );
          }

        },
      ),
    );
  }
}