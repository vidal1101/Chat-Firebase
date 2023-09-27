import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_test/helper/helper.dart';
import 'package:chat_app_test/models/message_model.dart';
import 'package:chat_app_test/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class MessageCard extends StatefulWidget {

  final MessageModel messageModel;

  const MessageCard({super.key, required this.messageModel});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProviders>(context);
    final currentSize = MediaQuery.of(context).size;


    return authProvider.userCurrentInfo.id == widget.messageModel.fromId ? 
      _greenMessages(currentSize) : 
      _blueMessages(currentSize);
  }


  // mensahes remitente
  Widget _blueMessages(Size media){

    if(widget.messageModel.read.isEmpty){
      final authProvider = Provider.of<AuthProviders>(context, listen: false);
      authProvider.updateMessageReadStatus(widget.messageModel);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: media.width * .04 , vertical: media.height * .01
            ),
            padding: EdgeInsets.all(media.width * .04 ),
            decoration: BoxDecoration(color: Color.fromARGB(255, 221, 245, 255),
              border: Border.all(color: Colors.lightBlue),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30), 
                bottomRight: Radius.circular(30),
              )
            ),
            child: widget.messageModel.type == 'image' 
              ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: widget.messageModel.msg,
                  imageBuilder: (context, imageProvider) => CircleAvatar(
                    backgroundImage: imageProvider,
                  ),
                  placeholder: (context, url) => const Center(child: Icon(Icons.image)), // Puedes personalizar el placeholder
                  errorWidget: (context, url, error) => const Icon(Icons.error), // Puedes personalizar el widget de error
                ),
              ) 
              : Text(widget.messageModel.msg,
                style: const TextStyle(color: Colors.black , fontSize: 15),
              ),
          ),
        ),


        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(FunctionHelpersChat.getFormatTime(context: context, time: widget.messageModel.sent ), style: TextStyle(fontSize: 12 , color: Colors.black54),),
        )
      ],
    );
  }

  //mensajes nuestros
  Widget _greenMessages(Size media){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

          //message time
        Row(
          children: [
            SizedBox(width: media.width * .04,),
            //el leido del mensaje
            if(widget.messageModel.read.isNotEmpty)
              const Icon(Icons.done_all_rounded, color: Colors.blueGrey, size: 20,), 

            const SizedBox(width: 2,), 
            
            //hora de envio
            Text(FunctionHelpersChat.getFormatTime(context: context, time: widget.messageModel.sent ),
             style: const TextStyle(fontSize: 12 , color: Colors.black54),),
          ],
        ), 

        

        //contenido del mensaje
        Flexible(
          child: Container(
            margin:   EdgeInsets.symmetric(
              horizontal: media.width * .04 , vertical: media.height * .01
            ),
            padding:  EdgeInsets.all(media.width * .04 ),
            decoration: BoxDecoration(color: const Color.fromARGB(255, 218, 255, 176),
              border: Border.all(color: Colors.lightGreen),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30), 
                bottomLeft: Radius.circular(30),
              )
            ),
            child:  widget.messageModel.type == 'image' 
              ? ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CachedNetworkImage(
                  imageUrl: widget.messageModel.msg,
                  fit: BoxFit.fill,
                  placeholder: (context, url) => const Center(child: Icon(Icons.image)), // Puedes personalizar el placeholder
                  errorWidget: (context, url, error) => const Icon(Icons.error), // Puedes personalizar el widget de error
                ),
              ) 
              : Text(widget.messageModel.msg,
                style: const TextStyle(color: Colors.black , fontSize: 15),
              ),
          ),
        ),


        
      ],
    );
  }

}