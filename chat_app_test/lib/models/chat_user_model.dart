import 'dart:convert';

//modelo para mostrar los usuarios actual de la base de datos firebase 
class ChatUserModel {
    final String photoUrl;
    final String createdAt;
    final String lastActive;
    final String nickname;
    final bool isOnline;
    final String id;
    final String pushToken;
    final dynamic chattingWith;

    ChatUserModel({
        required this.photoUrl,
        required this.createdAt,
        required this.lastActive,
        required this.nickname,
        required this.isOnline,
        required this.id,
        required this.pushToken,
        required this.chattingWith,
    });

    factory ChatUserModel.fromRawJson(String str) => ChatUserModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory ChatUserModel.fromJson(Map<String, dynamic> json) => ChatUserModel(
        photoUrl: json["photoUrl"] ?? '',
        createdAt: json["createdAt"] ?? '',
        lastActive: json["lastActive"] ?? '',
        nickname: json["nickname"] ?? '',
        isOnline: json["isOnline"] ?? false,
        id: json["id"] ?? '',
        pushToken: json["pushToken"] ?? '',
        chattingWith: json["chattingWith"] ?? '',
    );

    Map<String, dynamic> toJson() => {
        "photoUrl": photoUrl,
        "createdAt": createdAt,
        "lastActive": lastActive,
        "nickname": nickname,
        "isOnline": isOnline,
        "id": id,
        "pushToken": pushToken,
        "chattingWith": chattingWith,
    };
}
