import 'dart:convert';

enum Type {
 text,
 image, 
}

class MessageModel {
    final String msg;
    final String read;
    final String told;
    final String type;
    final String fromId;
    final String sent;

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

    factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        msg: json["msg"] ?? '',
        read: json["read"] ?? '',
        told: json["told"] ?? '',
        type: json["type"] ?? Type.text, // el tipo se refiere al objeto imagen.
        fromId: json["fromId"] ?? '',
        sent: json["sent"] ?? '',
    );

    Map<String, dynamic> toJson() => {
        "msg": msg,
        "read": read,
        "told": told,
        "type": type,
        "fromId": fromId,
        "sent": sent,
    };
}
