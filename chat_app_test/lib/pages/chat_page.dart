
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_test/models/chat_user_model.dart';
import 'package:chat_app_test/models/message_model.dart';
import 'package:chat_app_test/providers/auth_provider.dart';
import 'package:chat_app_test/widgets/alert_widgets.dart';
import 'package:chat_app_test/widgets/loading.dart';
import 'package:chat_app_test/widgets/message_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';


///pagina principal de chat
class ChatPage extends StatefulWidget {

  final ChatUserModel chatUserModel;


  const ChatPage({super.key, required this.chatUserModel});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  List<MessageModel> listMessages = [];

  TextEditingController textEditingController = TextEditingController();
  bool isShowEmoji = false;


  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProviders>(context);
    final currentSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        //FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: appbar(),
          ),
            
          body: Column(
            children: [
            
              Expanded(
                child: StreamBuilder(
                  stream: authProvider.getAllMessages(chatUserModel: widget.chatUserModel),
                  //initialData: const [],
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
              
                    if(!snapshot.hasData){
                      return const Center(child:LoadingMessages(),);
                    }else if(snapshot.connectionState == ConnectionState.waiting){
                      return const Center(child:LoadingMessages(),);
                    }else{
              
                      final List<DocumentSnapshot> data = snapshot.data.docs;
            
                      listMessages = data.map((e) => MessageModel.fromJson( e.data() as Map<String, dynamic>)  ).toList() ?? [];
            
              
                      if(listMessages.isNotEmpty){
                        return ListView.builder(
                          physics:const  BouncingScrollPhysics(),
                          itemCount: listMessages.length,
                          itemBuilder: (BuildContext context, int index) {
                            return  MessageCard(  messageModel:  listMessages[index],); 
                          },
                        );
              
                      }else{
                        return const Center(child: Text('No hay mensajes.' , style: TextStyle(fontSize: 17),));
                      }
              
                    }
                  },
                ),
              ),
            
              ///enviar mensaje y controles de chat  
              chatInput(), 
            
              //showemoji.
              if(isShowEmoji) 
              SizedBox(
                height: currentSize.height  * .20,
                child: EmojiPicker(
                    textEditingController: textEditingController, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                    config: Config(
                        columns: 8,
                        emojiSizeMax: 20 * (Platform.isIOS ? 1.30 : 1.0), 
                    ),
                ),
              ),
            
            ],
          ),
        ),
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
    
              const Text('Ultima vez recientemente' , style: 
               TextStyle(
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
          child:  Row(
            children: [
              //emoji button
              IconButton(onPressed: () {
                setState(() => isShowEmoji = !isShowEmoji );
              },
               icon: const Icon(Icons.emoji_emotions_rounded, color: Colors.blueAccent,)), 

               //espacio para escribir 
               Expanded(
                 child: TextField(
                  onTap: () {
                    //FocusScope.of(context).unfocus();
                    //if(isShowEmoji) setState(() => isShowEmoji = !isShowEmoji );
                  },
                  controller:  textEditingController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: 'Escribir algo..',
                    hintStyle: TextStyle(color: Colors.blueAccent, ),
                    border: InputBorder.none,
                  ),
                 ),
               ),

               //acceso a gallery
              IconButton(onPressed: () {
                 //acceso a galeria o camara.
                 FocusScope.of(context).unfocus();
                 AlertWidgets.currentContext = context;
                 AlertWidgets.showDialogImage(context: context, chatUserModel: widget.chatUserModel );
               },
               icon: const Icon(Icons.image, color: Colors.blueAccent,)),
              
            ],
          ),
        )), 

        //enviar el mensaje de texto.
        InkWell(
          onTap: () async{
            //enviar el mensaje
            if(textEditingController.text.isEmpty) return;

            final authProviders = Provider.of<AuthProviders>(context, listen: false);

            await authProviders.sendMessage(
              chatUserModel: widget.chatUserModel,
              msgs: textEditingController.text,
              type: 'text'
            );

            textEditingController.text = '';


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