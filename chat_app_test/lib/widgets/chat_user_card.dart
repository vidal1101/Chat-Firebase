import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_test/helper/helper.dart';
import 'package:chat_app_test/models/chat_user_model.dart';
import 'package:chat_app_test/models/message_model.dart';
import 'package:chat_app_test/pages/chat_page.dart';
import 'package:chat_app_test/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class ChatUserCard extends StatefulWidget {

  final ChatUserModel chatUserModel;

  const ChatUserCard({super.key, required this.chatUserModel});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {

  // last message info if( null -> not message )
  MessageModel? lastmessageModel;

  @override
  Widget build(BuildContext context) {
    final currentSize = MediaQuery.of(context).size;
    final authProviders = Provider.of<AuthProviders>(context);
    return Card(
      margin:  EdgeInsets.symmetric(horizontal: currentSize.width * .04 , vertical: 4 ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.blue.shade100,
      elevation: 1,
      child: InkWell(
        onTap: ()async {
          ///navegaf al chat de cada usuario.
           // Definir la duración de la animación
            const Duration duration = Duration(milliseconds: 500);

            // Definir la función de animación personalizada
            PageRouteBuilder pageRouteBuilder = PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  ChatPage(chatUserModel: widget.chatUserModel),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
              transitionDuration: duration,
            );

            // Navegar utilizando la animación personalizada
            await Navigator.of(context).push(pageRouteBuilder);
          
        },
        child:  StreamBuilder(
          stream: authProviders.getLastMessage(widget.chatUserModel),
          builder: (BuildContext context, AsyncSnapshot snapshot) {

            if(!snapshot.hasData){
              return const Center(child:SizedBox(),);
            }else if(snapshot.connectionState == ConnectionState.waiting){
              return const Center(child:SizedBox(),);
            }else{

              final List<DocumentSnapshot> data = snapshot.data.docs;

              final lastMessage = data.map((e) => MessageModel.fromJson( e.data() as Map<String, dynamic>)  ).toList() ?? [];


              if(lastMessage.isNotEmpty){
                lastmessageModel = lastMessage[0];
              }else if(lastMessage.length == 0){
                lastmessageModel = MessageModel(msg: '', read: '', told: '', 
                type: '', fromId: '', sent: '');
              }

              
              return  ListTile(
                
                leading: CachedNetworkImage(
                  imageUrl: widget.chatUserModel.photoUrl,
                  imageBuilder: (context, imageProvider) => CircleAvatar(
                    backgroundImage: imageProvider,
                  ),
                  placeholder: (context, url) => const Center(child: Icon(Icons.person)), // Puedes personalizar el placeholder
                  errorWidget: (context, url, error) => const Icon(Icons.error), // Puedes personalizar el widget de error
                ),
                //nombre del usuario
                title: Text(widget.chatUserModel.nickname),
                //ultimo mensaje
                subtitle: Text(
                   lastMessage == null ? "" : 
                   lastmessageModel!.type == 'image' ? 'Imagen.' :
                   lastmessageModel!.msg ?? "",
                ),
                trailing: lastMessage.length == 0 ? const Text('Nuevo usuario') : // no mostrar nada, si es nuevo usuario
                          lastMessage == null ?  const SizedBox() : //no mostramos ningun mensaje
                  lastmessageModel!.read.isEmpty &&
                  lastmessageModel!.fromId != authProviders.firebaseUserCurrent!.uid ? 
                const CircleAvatar(radius: 5, backgroundColor: Colors.green,) : //mostrado como no leido
                Text(FunctionHelpersChat.getFormatTime(context: context, time: lastmessageModel!.sent )), //sino la ultima vez
              );


            }

          },
        ),
      ),
    );
  }
}