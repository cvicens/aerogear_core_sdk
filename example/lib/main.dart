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
  String _platformVersion = 'Unknown';

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
      platformVersion = await AerogearCoreSdk.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }


    try {
      // TODO: We should use the service type and not the id, v0.2.2 is broken hence this workaround
      // TODO: Why can't I have several Custom Runtime Connectors?
      service = await AerogearCoreSdk.getConfiguration("Custom Runtime Connector");
      //service = await AerogearCoreSdk.getConfiguration("wine-pairing-gramola-ios");
      print('service => ' + service.toString());
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted)
      return;

    setState(() {
      _platformVersion = platformVersion;
      _init = true;
      _service = service;
    });
  }

sayHello(String name) async {
    dynamic data;
    String message;
    
    String hello = (name == null || name.length <= 0) ? 'world' : name;

    try {
      Map<String, dynamic> options = {
        //"path": "https://cvicensa-rzu6bexawadjetudwkhtfndd-demos-dev.mbaas2.tom.redhatmobile.com/hello?hello=" + hello.replaceAll(' ', ''),
        //"path" : "https://cvicensa-rzu6bexawadjetudwkhtfndd-demos-dev.mbaas2.tom.redhatmobile.com/events/SPAIN/MADRID",
        "path" : _service.url + '/pairing?foodType=FISH',
        "method": "GET",
        "contentType": "application/json",
        "timeout": 25000 // timeout value specified in milliseconds. Default: 60000 (60s)
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
          title: new Text('Plugin example app'),
        ),
        body:  new ListView(children: [
              new Center(
                child: new Text('Running on: $_platformVersion\n'),
              ),
              const Divider(
                height: 1.0,
              ),
              new Container(
                  padding: const EdgeInsets.fromLTRB(32.0, 28.0, 32.0, 8.0),
                  child: new RaisedButton(
                      child: new Text(_init ? 'Say Hello to Username' : 'Init in progress...'),
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      onPressed: !_init ? null : () {
                              // Perform some action
                              sayHello("Flutter!");
                      }
                  )
              )
          ]
        ),
      )
    );
  }
}
