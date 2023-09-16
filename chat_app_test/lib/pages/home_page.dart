
import 'package:chat_app_test/helper/constanst.dart';
import 'package:chat_app_test/providers/auth_provider.dart';
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
    return  Scaffold(
      appBar: AppBar(
        // leading: CircleAvatar(
        //   backgroundColor: Colors.white,
        //   radius:30,
        //   backgroundImage: NetworkImage(
        //     urlImage.toString(),
        //     scale: 0.5,
        //   ),
        // ),
        title: Text(name.toString()),
        actions: [
          IconButton(onPressed: () async{
            final authProvider = Provider.of<AuthProviders>(context, listen: false);
            await authProvider.handlesingOut();
            Navigator.pushReplacementNamed(context, 'login');
          }, icon: const Icon(Icons.close)), 
        ],
      ),
    );
  }
}