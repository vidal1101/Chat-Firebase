import 'package:chat_app_test/providers/auth_provider.dart';
import 'package:chat_app_test/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';


class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext  context) {

    final authProvider = Provider.of<AuthProviders>(context);

    switch (authProvider.status) {
      case Status.authenticateError:
        Fluttertoast.showToast(msg: 'Fallo al iniciar session');  
        break;
      case Status.authenticateCanceled:
        Fluttertoast.showToast(msg: 'Cancelo al iniciar session');  
        break;
      case Status.authenticated: 
        Fluttertoast.showToast(msg: 'Inicio Exitoso.'); 
        break; 
      default:
        break;
    }

    return Scaffold(
      body: Column(
        //mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          IconButton(onPressed: () {
            authProvider.handlesingOut();
          }, icon: const Icon(Icons.close)), 
          
          GestureDetector(
            onTap: () async{
              bool isSuccess = await authProvider.handleSignIn();
              if(isSuccess){
                Navigator.pushNamed(context, "home");
              }
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_circle_rounded, size: 30),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Inicia con Google', 
                    style: TextStyle(
                      fontSize: 30, 
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
          
              ],
            ),
          ),

          //if(authProvider.status == Status.authenticating) const LoadingView(),

          // Positioned(child:
          //  authProvider.status == Status.authenticating ? 
          //  const LoadingView() : const SizedBox.shrink(),
          // ), 
        ],
      ),
    );
  }
}

