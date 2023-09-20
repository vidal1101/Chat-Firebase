import 'package:chat_app_test/models/chat_user_model.dart';
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
          ///navegaf al chat.
          
        },
        child:   ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(widget.chatUserModel.photoUrl),
            //child: const Icon(Icons.person),
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