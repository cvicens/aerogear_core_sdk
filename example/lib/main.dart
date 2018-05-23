import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aerogear_core_sdk/aerogear_core_sdk.dart';
import 'package:aerogear_core_sdk/model/mobile_service.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  
  bool _init = false;

  MobileService _service;

  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    String platformVersion;
    MobileService service;

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      service = await AerogearCoreSdk.getConfiguration("cloud");
      print('service => ' + service.toString());
    } on PlatformException {
      _showSnackbar('Failed to get configuration');
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted)
      return;

    setState(() {
      _init = true;
      _service = service;
    });
  }

cloudRequest() async {
    dynamic data;
    String message;

    try {
      Map<String, dynamic> options = {
        "path" : _service.url,
        "method": "GET",
        "contentType": "application/json",
        "timeout": 25000
      };
      data = await AerogearCoreSdk.cloud(options);
      print('data ==> ' + data.toString());
      message = data.toString();
      _showSnackbar(message);
    } on PlatformException catch (e, s) {
      print('Exception details:\n $e');
      print('Stack trace:\n $s');
      message = 'Error calling hello/';
      _showSnackbar(message);
    }
  }

  void _showSnackbar (String message) {
    final snackbar = new SnackBar(
      content: new Text(message),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        key: scaffoldKey,
        appBar: new AppBar(
          title: new Text('Aerogear Core SDK plugin example'),
        ),
        body:  new Center(
          child: new Container(
            padding: const EdgeInsets.fromLTRB(32.0, 28.0, 32.0, 8.0),
            child: new RaisedButton(
              child: new Text(_init ? 'Call ' + _service.name : 'Init in progress...'),
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              onPressed: !_init ? null : () {
                // Perform some action
                cloudRequest();
              }
            )
          )
        ),
      )
    );
  }
}
