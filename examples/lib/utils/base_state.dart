import 'package:flutter/material.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<bool> backButtonPressed() async {
    return false;
  }

  Size get screenSize => MediaQuery.of(context).size;

  double widthRatio(double ratio) => screenSize.width * ratio;

  double heightRatio(double ratio) => screenSize.height * ratio;

  void changeFocus(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  void removeFocus() {
    FocusScope.of(context).unfocus();
  }
}
