import 'dart:async';
import 'package:flutter/material.dart';
import 'package:freerasp/talsec_app.dart';
import 'package:freerasp/utils/hash_converter.dart';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({final Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
  /// ThreatTypes to hold current state (Android)
  final ThreatType _root = ThreatType("Root");
  final ThreatType _emulator = ThreatType("Emulator");
  final ThreatType _tamper = ThreatType("Tamper");
  final ThreatType _hook = ThreatType("Hook");
  final ThreatType _deviceBinding = ThreatType("Device binding");
  final ThreatType _untrustedSource = ThreatType("Untrusted source of installation");
  final ThreatType _debugger = ThreatType("Debugger");

  List<Widget> get overview {
      return [
        Text(_root.state),
        Text(_debugger.state),
        Text(_emulator.state),
        Text(_tamper.state),
        Text(_hook.state),
        Text(_deviceBinding.state),
        Text(_untrustedSource.state),
      ];
  }

  @override
  void initState() {
    super.initState();
    initSecurityState();
  }

  Future<void> initSecurityState() async {
    print("Hello");
    String base64Hash = hashConverter.fromSha256toBase64('88:8c:7f:02:d6:2e:ed:3a:53:bb:9c:a6:6b:82:5c:0d:78:a8:e5:b6:b2:11:28:bc:f5:ac:67:c8:e0:a3:7c:5a');
    final TalsecConfig config = TalsecConfig(
      androidConfig: AndroidConfig(
        expectedPackageName: 'com.dsaghicha.testApp',
        expectedSigningCertificateHash: base64Hash,
        supportedAlternativeStores: ["com.sec.android.app.samsungapps"],
      ),
      watcherMail: 'darshaandaghicha@gmail.com',
    );

    final TalsecCallback callback = TalsecCallback(
      androidCallback: AndroidCallback(
        onRootDetected: () => _updateState(_root),
        onEmulatorDetected: () => _updateState(_emulator),
        onHookDetected: () => _updateState(_hook),
        onTamperDetected: () => _updateState(_tamper),
        onDeviceBindingDetected: () => _updateState(_deviceBinding),
        onUntrustedInstallationDetected: () => _updateState(_untrustedSource),
      ),
      onDebuggerDetected: () => _updateState(_debugger),
    );

    final TalsecApp app = TalsecApp(
      config: config,
      callback: callback,
    );

    app.start();
    if (!mounted) return;
  }

  void _updateState(final ThreatType type) {
    setState(() {
      // ignore: parameter_assignments
      type.threatFound();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page', overview: overview,),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.overview});
  final String title;
  final List<Widget> overview;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            ...widget.overview,
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ThreatType {
  final String _text;
  bool _isSecure = true;

  ThreatType(this._text);

  void threatFound() => _isSecure = false;

  String get state => '$_text: ${_isSecure ? "Secured" : "Detected"}\n';
}