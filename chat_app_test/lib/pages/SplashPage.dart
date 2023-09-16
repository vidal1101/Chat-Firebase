
import 'package:chat_app_test/pages/pages.dart';
import 'package:chat_app_test/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed( const Duration(seconds: 5),() {
      checkSignIn(context);
    },);
  }


  void checkSignIn(BuildContext context)async{
    final authProvider = Provider.of<AuthProviders>(context, listen:  false);

    bool isLogin = await authProvider.isLoggedIn();
    if(isLogin){
      Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => HomePage() ));
      return;
    }else{
      Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => LoginPage() ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Cargando, espere por favor ...', 
              style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            CircularProgressIndicator(
              color: Colors.purpleAccent,
            ),
          ],
        ),
      ),
    );
  }
}