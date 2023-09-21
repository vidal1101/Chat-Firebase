import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_test/models/chat_user_model.dart';
import 'package:chat_app_test/pages/chat_page.dart';
import 'package:flutter/material.dart';


class ChatUserCard extends StatefulWidget {

  final ChatUserModel chatUserModel;

  const ChatUserCard({super.key, required this.chatUserModel});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    final currentSize = MediaQuery.of(context).size;
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
        child:   ListTile(
          leading: CachedNetworkImage(
            imageUrl: widget.chatUserModel.photoUrl,
            imageBuilder: (context, imageProvider) => CircleAvatar(
              backgroundImage: imageProvider,
            ),
            placeholder: (context, url) => const Center(child: Icon(Icons.person)), // Puedes personalizar el placeholder
            errorWidget: (context, url, error) => const Icon(Icons.error), // Puedes personalizar el widget de error
          ),
          title: Text(widget.chatUserModel.nickname),
          subtitle: Text('last message'),
          trailing: Text('12:00pm', 
          style: TextStyle(color: Colors.black54),),
        ),
      ),
    );
  }
}