import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickblox_sdk/auth/module.dart';
import 'package:quickblox_sdk/models/qb_dialog.dart';
import 'package:quickblox_sdk/models/qb_session.dart';
import 'package:quickblox_sdk/models/qb_user.dart';
import 'package:quickblox_sdk/quickblox_sdk.dart';
import 'package:quickblox_sdk_example/screens/chat/user_list.dart';
import 'package:quickblox_sdk_example/utils/base_state.dart';
import 'package:quickblox_sdk_example/utils/dialog_utils.dart';
import 'package:quickblox_sdk_example/utils/progress_dialog.dart';

import '../../credentials.dart';
import '../../data_holder.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginScreenState();
}

class LoginScreenState extends BaseState<LoginScreen> {
  final TextEditingController _userController = TextEditingController(
      text: "test1");
  final TextEditingController _passWordController = TextEditingController(
      text: "Test@123");

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  int userId;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Demo"),
      ),
      body: Container(
        margin: const EdgeInsets.all(30),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _createPhoneNumberFiled("UserName", _userController),
              SizedBox(
                height: 30,
              ),
              _createPhoneNumberFiled("Password", _passWordController),
              SizedBox(
                height: 30,
              ),
              _createUserButton(),
              SizedBox(
                height: 30,
              ),
              _loginButton(),
              SizedBox(
                height: 30,
              ),
              Text("Available User:\n\n"
                  "User Name: test1   Password: Test@123\n"
                  "User Name: test2   Password: Test@123\n\n\n"
                  "Login with this user\n"
                  "or\n"
                  "Create new user",textAlign: TextAlign.center,


              )
            ]),
      ),
    );
  }

  _createPhoneNumberFiled(String hint, TextEditingController controller) =>
      TextFormField(
        textInputAction: TextInputAction.done,
        maxLength: 12,
        controller: controller,
        style: TextStyle(fontSize: 14, color: Colors.black),
        decoration: InputDecoration(
            fillColor: Colors.transparent,
            filled: true,
            isDense: true,
            counterText: "",
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
            hintText: hint,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black))),
      );

  _createUserButton() =>
      InkWell(
        onTap: createUser,
        child: Container(
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.blue,
                boxShadow: getBoxShadow(),
                borderRadius: getBorderRadius()),
            child: Text(
              "Create user",
              style: TextStyle(fontSize: 12, color: Colors.white),
            )),
      );

  _loginButton() =>
      InkWell(
        onTap: login,
        child: Container(
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.blue,
                boxShadow: getBoxShadow(),
                borderRadius: getBorderRadius()),
            child: Text(
              "Login",
              style: TextStyle(fontSize: 12, color: Colors.white),
            )),
      );

  List<BoxShadow> getBoxShadow(
      {double blurRadius = 5, double xOffset = 0, double yOffset = 3}) =>
      [
        BoxShadow(
          color: Colors.grey.shade500,
          blurRadius: blurRadius,
          offset: Offset(
            xOffset,
            yOffset,
          ),
        ),
      ];

  BorderRadius getBorderRadius({double radius = 10}) =>
      BorderRadius.all(Radius.circular(radius));

  void _validate() {
    if (_userController.text.isEmpty) {
      DialogUtils.showOneBtn(context, "Please enter UserName");
    } else if (_passWordController.text.isEmpty) {
      DialogUtils.showOneBtn(context, "Please enter Password");
    } else {
      createUser();
    }
  }

  Future<void> init() async {
    try {
      await QB.settings.init(APP_ID, AUTH_KEY, AUTH_SECRET, ACCOUNT_KEY,
          apiEndpoint: API_ENDPOINT, chatEndpoint: CHAT_ENDPOINT);
      displayToast("The credentails was set");
    } on PlatformException catch (e) {
      DialogUtils.showError(context, e);
    }
  }

  Future<void> createUser() async {
    ProgressDialogUtils.showProgressDialog(context);
    try {
      USER_LOGIN = _userController.text;
      USER_PASSWORD = _passWordController.text;
      QBUser user = await QB.users.createUser(USER_LOGIN, USER_PASSWORD);
      userId = user.id;
      LOGGED_USER_ID = userId;
      displayToast("User create $userId");
      setState(() {});
      ProgressDialogUtils.dismissProgressDialog();
      // login();
    } on PlatformException catch (e) {
      ProgressDialogUtils.dismissProgressDialog();
      debugPrint("===> Error createUser $e");
      DialogUtils.showError(context, e);
    }
  }

  Future<void> login() async {
    USER_LOGIN = _userController.text;
    USER_PASSWORD = _passWordController.text;
    ProgressDialogUtils.showProgressDialog(context);
    try {
      QBLoginResult result = await QB.auth.login(USER_LOGIN, USER_PASSWORD);

      QBUser qbUser = result.qbUser;
      LOGGED_USER_ID = qbUser.id;
      QBSession qbSession = result.qbSession;

      DataHolder.getInstance().setSession(qbSession);
      DataHolder.getInstance().setUser(qbUser);

      displayToast("Login success");
      ProgressDialogUtils.dismissProgressDialog();
      connect();
    } on PlatformException catch (e) {
      debugPrint("===> Error login $e");
      ProgressDialogUtils.dismissProgressDialog();
      DialogUtils.showError(context, e);
    }
  }

  Future<void> setSession() async {
    ProgressDialogUtils.showProgressDialog(context);
    try {
      QBSession qbSession = DataHolder.getInstance().getSession();

      QBSession sessionResult = await QB.auth.setSession(qbSession);

      if (sessionResult != null) {
        DataHolder.getInstance().setSession(sessionResult);
        displayToast("Set session success");
      } else {
        displayToast("The session in null");
      }
      ProgressDialogUtils.dismissProgressDialog();
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => UserListScreen(),
          ));
    } on PlatformException catch (e) {
      debugPrint("===> Error setSession $e");
      ProgressDialogUtils.dismissProgressDialog();
      DialogUtils.showError(context, e);
    }
  }


  void connect() async {
    try {
      // bool connected = await QB.chat.isConnected();
      // debugPrint("===> Chat connect $connected");
      // if (connected) {
      //   await QB.chat.disconnect();
      // }
      await QB.chat.connect(LOGGED_USER_ID, USER_PASSWORD);
      displayToast("The chat was connected");
      _navigateToChat();
      // createDialog();
    } on PlatformException catch (e) {
      _navigateToChat();
      // DialogUtils.showError(context, e);
    }
  }

  _navigateToChat() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => UserListScreen(),
        ));
  }

  getDialog() async {
    try {
      List<QBDialog> dialogs = await QB.chat.getDialogs();
    } on PlatformException catch (e) {
      // Some error occured, look at the exception message for more details
    }
  }
}
