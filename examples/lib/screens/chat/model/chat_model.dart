class ChatModel {
  Payload payload;
  String type;

  ChatModel({this.payload, this.type});

  ChatModel.fromJson(Map<dynamic, dynamic> json) {
    payload =
    json['payload'] != null ? new Payload.fromJson(json['payload']) : null;
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    if (this.payload != null) {
      data['payload'] = this.payload.toJson();
    }
    data['type'] = this.type;
    return data;
  }
}

class Payload {
  bool markable;
  int senderId;
  List<int> deliveredIds;
  List<int> readIds;
  int recipientId;
  bool delayed;
  String id;
  int dateSent;
  String dialogId;
  String body;
  Properties properties;

  Payload(
      {this.markable,
        this.senderId,
        this.deliveredIds,
        this.readIds,
        this.recipientId,
        this.delayed,
        this.id,
        this.dateSent,
        this.dialogId,
        this.body,
        this.properties});

  Payload.fromJson(Map<dynamic, dynamic> json) {
    markable = json['markable'];
    senderId = json['senderId'];
    deliveredIds = json['deliveredIds'].cast<int>();
    readIds = json['readIds'].cast<int>();
    recipientId = json['recipientId'];
    delayed = json['delayed'];
    id = json['id'];
    dateSent = json['dateSent'];
    dialogId = json['dialogId'];
    body = json['body'];
    properties = json['properties'] != null
        ? new Properties.fromJson(json['properties'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['markable'] = this.markable;
    data['senderId'] = this.senderId;
    data['deliveredIds'] = this.deliveredIds;
    data['readIds'] = this.readIds;
    data['recipientId'] = this.recipientId;
    data['delayed'] = this.delayed;
    data['id'] = this.id;
    data['dateSent'] = this.dateSent;
    data['dialogId'] = this.dialogId;
    data['body'] = this.body;
    if (this.properties != null) {
      data['properties'] = this.properties.toJson();
    }
    return data;
  }
}

class Properties {
  String dateSent;
  String saveToHistory;
  String dialogId;
  String messageId;

  Properties(
      {this.dateSent, this.saveToHistory, this.dialogId, this.messageId});

  Properties.fromJson(Map<dynamic, dynamic> json) {
    dateSent = json['date_sent'];
    saveToHistory = json['save_to_history'];
    dialogId = json['dialog_id'];
    messageId = json['message_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['date_sent'] = this.dateSent;
    data['save_to_history'] = this.saveToHistory;
    data['dialog_id'] = this.dialogId;
    data['message_id'] = this.messageId;
    return data;
  }
}