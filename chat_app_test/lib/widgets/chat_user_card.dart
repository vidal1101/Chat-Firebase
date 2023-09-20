import 'package:flutter/material.dart';


class ChatUserCard extends StatefulWidget {
  const ChatUserCard({super.key});

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
        child:  const  ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(''),
            child: Icon(Icons.person),
          ),
          title: Text('Nick name'),
          subtitle: Text('last message'),
          trailing: Text('12:00pm', 
          style: TextStyle(color: Colors.black54),),
        ),
      ),
    );
  }
}