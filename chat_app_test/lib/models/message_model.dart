import 'dart:convert';

enum Type {
 text,
 image, 
}

class MessageModel {
    late final String msg;
    late final String read;
    late final String told;
    late final String type;
    late final String fromId;
    late final String sent;

    MessageModel({
        required this.msg,
        required this.read,
        required this.told,
        required this.type,
        required this.fromId,
        required this.sent,
    });

    factory MessageModel.fromRawJson(String str) => MessageModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    MessageModel.fromJson(Map<String, dynamic> json){
        msg = json["msg"].toString();
        read =  json["read"].toString();
        told = json["told"].toString() ;
        type = json["type"].toString() == "image" ? 'image' : 'text';
        fromId = json["fromId"].toString();
        sent = json["sent"].toString() ;
    }

    Map<String, dynamic> toJson() => {
        "msg": msg,
        "read": read,
        "told": told,
        "type": type,
        "fromId": fromId,
        "sent": sent,
    };
}
