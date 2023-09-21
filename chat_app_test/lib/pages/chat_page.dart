import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_test/models/chat_user_model.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {

  final ChatUserModel chatUserModel;


  const ChatPage({super.key, required this.chatUserModel});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: appbar(),
      ),

      body: Column(
        children: [

          chatInput(), 
        ],
      ),

    );
  }

  Widget appbar(){
    return Padding(
      padding: const EdgeInsets.only(top:  20), 
      child: Row(
        children: [
          IconButton(onPressed:() => Navigator.of(context).pop(),
           icon: const Icon(Icons.arrow_back_ios_sharp, color: Colors.black54,)
          ),
          
          CachedNetworkImage(
              imageUrl: widget.chatUserModel.photoUrl,
              imageBuilder: (context, imageProvider) => CircleAvatar(
                backgroundImage: imageProvider,
              ),
              placeholder: (context, url) => const Center(child: Icon(Icons.person)), // Puedes personalizar el placeholder
              errorWidget: (context, url, error) => const Icon(Icons.error), // Puedes personalizar el widget de error
          ),
    
          const SizedBox(width: 10,),
    
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.chatUserModel.nickname , style: 
              const TextStyle(
                fontSize: 16, 
                color: Colors.black54, 
                fontWeight: FontWeight.w500,
              ),), 
    
              Text('Last seen recently' , style: 
              const TextStyle(
                fontSize: 12, 
                color: Colors.black54, 
              ),)
            ],
          )
        ],
      ),
    );
  }


  Widget chatInput(){
    return Row(
      children: [

        Expanded(child: 
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: const  Row(
            children: [
              //emoji button
              IconButton(onPressed: null,
               icon: Icon(Icons.emoji_emotions_rounded, color: Colors.blueAccent,)), 

               //espacio para escribir 
               Expanded(
                 child: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Escribir algo..',
                    hintStyle: TextStyle(color: Colors.blueAccent, ),
                    border: InputBorder.none,
                  ),
                 ),
               ),

               //acceso a gallery
               IconButton(onPressed: null,
               icon: Icon(Icons.image, color: Colors.blueAccent,)),

               //acceso a camara.
               IconButton(onPressed: null,
               icon: Icon(Icons.camera_alt, color: Colors.blueAccent,)),  
            ],
          ),
        )), 

        //enviar el mensaje
        InkWell(
          onTap: () {
            //enviar el mensaje
          },
          child: const Padding(
            padding:  EdgeInsets.only(top: 10 , bottom: 10 , left: 5, right: 10), 
            child: CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.send, color: Colors.white, size: 26,),
            ),
          ),
        ),

      ],
    );
  }


}