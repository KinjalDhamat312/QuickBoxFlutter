import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:quickblox_sdk/models/qb_user.dart';
import 'package:quickblox_sdk/quickblox_sdk.dart';
import 'package:quickblox_sdk_example/credentials.dart';
import 'package:quickblox_sdk_example/utils/base_state.dart';
import 'package:quickblox_sdk_example/utils/dialog_utils.dart';

import 'chat_history_screen.dart';

class UserListScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => UserListScreenState();
}

class UserListScreenState extends BaseState<UserListScreen> {
  List<QBUser> userList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User List"),
      ),
      body: Container(
        margin: const EdgeInsets.all(30),
        child: (!_isLoading && userList.isEmpty)
            ? Container(
                color: Colors.transparent,
                child: Center(
                  child: Text("No user found"),
                ),
              )
            : (_isLoading && userList.isEmpty)
                ? Container(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor),
                    ),
                  )
                : ListView.separated(
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          OPPONENT_ID = userList[index].id;
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    ChatHistoryScreen(),
                              ));
                        },
                        child: Container(
                            padding: const EdgeInsets.only(bottom: 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Name: ${userList[index].login}"),
                                Text("Id: ${userList[index].id}"),
                              ],
                            )),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                    itemCount: userList.length,
                  ),
      ),
    );
  }

  Future<void> getUsers() async {
    try {
      List<QBUser> tempList = await QB.users.getUsers();
      tempList.forEach((element) {
        if (element.id != LOGGED_USER_ID) {
          userList.add(element);
        }
      });
      setState(() {
        _isLoading = false;
      });
    } on PlatformException catch (e) {
      setState(() {
        _isLoading = false;
      });
      DialogUtils.showError(context, e);
    }
  }
}
