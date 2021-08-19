import 'package:flutter/material.dart';

class ProgressDialogUtils {
  static final ProgressDialogUtils _instance = ProgressDialogUtils.internal();
  static bool _isLoading = false;

  ProgressDialogUtils.internal();

  factory ProgressDialogUtils() => _instance;

  static BuildContext _context;

  static void dismissProgressDialog() {
    if (_isLoading) {
      Navigator.of(_context).pop();
      _isLoading = false;
    }
  }

  static bool get isProgressLoading => _isLoading;

  static void showProgressDialog(BuildContext context,
      {bool isDismissible}) async {
    _context = context;
    _isLoading = true;

    await showDialog(
        context: _context,
        barrierDismissible: false,
        useRootNavigator: false,
        builder: (context) {
          return SimpleDialog(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            children: <Widget>[
              Material(
                type: MaterialType.transparency,
                child: WillPopScope(
                  onWillPop: () async => isDismissible ?? false,
                  child: Center(
                      child: Container(
                    width: 120.0,
                    height: 120.0,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                          Padding(
                            child: Text(
                                "Please wait",
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 12)),
                            padding: EdgeInsets.only(top: 15.0),
                          )
                        ],
                      ),
                    ),
                  )),
                ),
              )
            ],
          );
        });
  }
}
