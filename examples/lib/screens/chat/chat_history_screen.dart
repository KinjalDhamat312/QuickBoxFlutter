import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:quickblox_sdk/chat/constants.dart';
import 'package:quickblox_sdk/models/qb_dialog.dart';
import 'package:quickblox_sdk/models/qb_message.dart';
import 'package:quickblox_sdk/quickblox_sdk.dart';
import 'package:quickblox_sdk_example/utils/base_state.dart';
import 'package:quickblox_sdk_example/utils/chat_clipper.dart';
import 'package:quickblox_sdk_example/utils/dialog_utils.dart';

import '../../credentials.dart';
import 'model/chat_model.dart';

class ChatHistoryScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ChatHistoryScreenState();
}

class ChatHistoryScreenState extends BaseState<ChatHistoryScreen> {
  bool _isLoading = true;
  bool _isLoadMore = false;
  List<QBMessage> _chatList = [];

  ScrollController scrollController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();

  StreamSubscription _newMessageSubscription;

  @override
  void initState() {
    super.initState();
    createDialog();
    subscribeNewMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat"),
      ),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [_buildListMessage(), _buildInput()],
        ),
      ),
    );
  }

  Widget _buildListMessage() {
    return Expanded(
        child: (!_isLoading && _chatList.isEmpty)
            ? Container(
                color: Colors.transparent,
                child: Center(
                  child: Text("No message found"),
                ),
              )
            : (_isLoading && _chatList.isEmpty)
                ? Container(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor),
                    ),
                  )
                : NotificationListener<ScrollNotification>(
                    onNotification: (scrollInfo) {
                      return false;
                    },
                    child: ListView.builder(
                      padding:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                      itemBuilder: (context, index) {
                        return _messageView(
                            _chatList[index].senderId == LOGGED_USER_ID,
                            _chatList[index]);
                      },
                      itemCount: _chatList.length,
                      reverse: true,
                      controller: scrollController,
                    ),
                  ));
  }

  _messageView(bool isSend, QBMessage chatModel) {
    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: Column(
        children: [
          Container(
              alignment: isSend ? Alignment.topRight : Alignment.topLeft,
              margin: EdgeInsets.only(
                  left: isSend ? 90 : 0, right: isSend ? 0 : 90, top: 10),
              child: CustomPaint(
                  painter: ChatBubble(
                      type: isSend
                          ? BubbleType.sendBubble
                          : BubbleType.receiverBubble,
                      radius: 10,
                      nipSize: 5,
                      color: isSend ? Colors.blue : Colors.grey),
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 8,
                      bottom: 8,
                      left: isSend ? 10 : 20,
                      right: isSend ? 20 : 10,
                    ),
                    child: Text(
                      chatModel.body ?? 0,
                      style: TextStyle(
                          color: isSend ? Colors.white : Colors.black,
                          fontSize: 14),
                    ),
                  )))
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Row(
      children: <Widget>[
        Expanded(
            child: Stack(
          children: [
            Container(
              height: 40.0,
              margin: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  border: Border.all(color: Colors.grey)),
              child: Center(
                child: TextField(
                  textInputAction: TextInputAction.newline,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 1,
                  minLines: 1,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  controller: _textEditingController,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.only(left: 12, right: 12),
                    hintText: "Message",
                    hintStyle: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        )),
        Material(
          child: Container(
            height: 40.0,
            width: 40.0,
            margin: EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              icon: Icon(
                Icons.send,
                color: Colors.black,
              ),
              onPressed: () async {
                if (_textEditingController.text.isNotEmpty) {
                  _sendChatMessage(context, _textEditingController.text);
                }
              },
            ),
          ),
          color: Colors.white,
        ),
      ],
    );
  }

  void getDialogMessages() async {
    try {
      List<QBMessage> messages = await QB.chat.getDialogMessages(DIALOG_ID);
      int countMessages = messages.asMap().length;
      setState(() {
        _isLoading = false;
        _chatList = messages;
      });
    } on PlatformException catch (e) {
      setState(() {
        _isLoading = false;
      });
      DialogUtils.showError(context, e);
    }
  }

  void createDialog() async {
    List<int> occupantsIds = [OPPONENT_ID];
    String dialogName =
        "FLUTTER_CHAT_" + new DateTime.now().millisecond.toString();

    int dialogType = QBChatDialogTypes.CHAT;

    try {
      QBDialog createdDialog = await QB.chat
          .createDialog(occupantsIds, dialogName, dialogType: dialogType);
      DIALOG_ID = createdDialog.id;

      debugPrint("===> Chat createDialog $DIALOG_ID");
      // displayToast("The dialog ${createdDialog.id} was created");
      getDialogMessages();
      // getDialogMessages();
    } on PlatformException catch (e) {
      DialogUtils.showError(context, e);
    }
  }

  void _sendChatMessage(BuildContext context, String text) async {
    try {
      QBMessage message = QBMessage();
      message.senderId = LOGGED_USER_ID;
      message.recipientId = OPPONENT_ID;
      message.body = text;
      message.dialogId = DIALOG_ID;

      await QB.chat.sendMessage(DIALOG_ID, body: text, saveToHistory: true);
      setState(() {
        _chatList.insert(0, message);
      });
      _textEditingController.text = "";
    } on PlatformException catch (e) {
      DialogUtils.showError(context, e);
    }
  }

  void subscribeNewMessage() async {
    if (_newMessageSubscription != null) {
      return;
    }
    try {
      displayToast("subscribeNewMessage");
      _newMessageSubscription = await QB.chat
          .subscribeChatEvent(QBChatEvents.RECEIVED_NEW_MESSAGE, (data) {
        Map<String, Object> map = new Map<String, dynamic>.from(data);
        displayToast("subscribeNewMessage call $map");

        var chat = ChatModel.fromJson(map);
        debugPrint("===> message ${map.toString()}");

        if (chat.payload.senderId != LOGGED_USER_ID) {
          QBMessage message = QBMessage();
          message.senderId = chat.payload.senderId;
          message.recipientId = chat.payload.recipientId;
          message.body = chat.payload.body;
          message.dialogId = chat.payload.dialogId;
          setState(() {
            _chatList.insert(0, message);
          });
        }

        debugPrint("===> message ${map.toString()}");
      }, onErrorMethod: (error) {
        DialogUtils.showError(context, error);
      });
      // displayToast("Subscribed: " + QBChatEvents.RECEIVED_NEW_MESSAGE);
    } on PlatformException catch (e) {
      DialogUtils.showError(context, e);
    }
  }

  void unsubscribeNewMessage() {
    if (_newMessageSubscription != null) {
      _newMessageSubscription.cancel();
      _newMessageSubscription = null;
      // displayToast("Unsubscribed: " + QBChatEvents.RECEIVED_NEW_MESSAGE);
    } else {}
  }

  @override
  void dispose() {
    super.dispose();
    unsubscribeNewMessage();
  }
}
