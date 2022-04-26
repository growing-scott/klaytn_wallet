import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:http/http.dart';
import 'package:local_assets_server/local_assets_server.dart';
import 'dart:convert' as convert;
import 'package:web3dart/web3dart.dart';

import 'package:http/http.dart' as http;
import 'package:klaytn_wallet/helpers/caver_helper.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Klaytn Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Klaytn Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  double balance = 0.0;
  double balance2 = 0.0;
  String transactionId = '';
  String _transactionHash = '';
  final caverHelper = new CaverHelper();
  final _address = TextEditingController(text: '0x43aa1a5e0de1733c732c6cb94cf8ffd864234742');
  final _amount = TextEditingController(text: '1');

  final JavascriptRuntime jsRuntime = getJavascriptRuntime();

  void _signingTx() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WebViewRoute(setTransaction: _setTransactionHash)),
    );
  }

  void _searchTx() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WebViewTxRoute(transactionHash: _transactionHash)),
    );
  }

  void _setTransactionHash(String transactionHash) {
    print('_setTransactionHash $transactionHash}');
    setState(() {
      _transactionHash = transactionHash;
    });
  }

  void _getBalance() async {
    var url = Uri.https('api.baobab.klaytn.net:8651', '');

    // Await the http get response, then decode the json-formatted response.
    var body = {
      'jsonrpc': '2.0', 'method': 'klay_getBalance', 'params': ['0xf8a9a0f20b2e9ef941ee038c085a79192247b0ab', 'latest'], 'id': '1'
    };
    print(url);
    print(body);
    var response = await http.post(url, headers: <String, String>{
      'Content-Type': 'application/json',
    }, body: jsonEncode(body));
    print(response);

    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
      print(jsonResponse['result']);
      print(caverHelper.fromPeb(jsonResponse['result']));
      setState(() {
        balance = caverHelper.fromPeb(jsonResponse['result']);
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  void _getBalance2() async {
    var url = Uri.https('api.baobab.klaytn.net:8651', '');

    // Await the http get response, then decode the json-formatted response.
    var body = {
      'jsonrpc': '2.0', 'method': 'klay_getBalance', 'params': ['0x43aa1a5e0de1733c732c6cb94cf8ffd864234742', 'latest'], 'id': '1'
    };
    print(url);
    print(body);
    var response = await http.post(url, headers: <String, String>{
      'Content-Type': 'application/json',
    }, body: jsonEncode(body));
    print(response);

    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
      print(jsonResponse['result']);
      print(caverHelper.fromPeb(jsonResponse['result']));
      setState(() {
        balance2 = caverHelper.fromPeb(jsonResponse['result']);
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  Future getAccount(String address) async {
    var url = Uri.https('api.baobab.klaytn.net:8651', '');

    // Await the http get response, then decode the json-formatted response.
    var body = {
      'jsonrpc': '2.0', 'method': 'klay_accountCreated', 'params': [address, 'latest'], 'id': '1'
    };
    print(url);
    print(body);
    var response = await http.post(url, headers: <String, String>{
      'Content-Type': 'application/json',
    }, body: jsonEncode(body));
    print(response.body);

    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
      print(jsonResponse['result']);
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  void _postSend(Uint8List data) async {
    //var url = Uri.https('public-node-api.klaytnapi.com', 'v1/baobab');
    var url = Uri.https('api.baobab.klaytn.net:8651', '');

    print(_amount.text);
    print(BigInt.parse(_amount.text) * BigInt.from(pow(10, 18)));

    final value = BigInt.parse(_amount.text) * BigInt.from(pow(10, 18));

    await getAccount(_address.text);

    // Await the http get response, then decode the json-formatted response.
    /*var body = {
      'jsonrpc': '2.0', 'method': 'klay_signTransaction', 'params': [{
        'typeInt': 8,
        'from': '0xf8a9a0f20b2e9ef941ee038c085a79192247b0ab',
        'to': _address.text,
        'gas': "0x76c0",
        'gasPrice': "0x1176592E00",
        'value': '0x${value.toRadixString(16)}',
      }], 'id': '1'
    };*/

    var body = {
      'jsonrpc': '2.0', 'method': 'klay_signTransaction', 'params': [data], 'id': '1'
    };
    print(url);
    print(body);
    var response = await http.post(url, headers: <String, String>{
      'Content-Type': 'application/json',
    }, body: jsonEncode(body));
    print(response.body);

    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
      print(jsonResponse['result']);
      setState(() {
        transactionId = jsonResponse['result'];
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 15)),
              Text(
                'Address 1: 0xf8a9a0f20b2e9ef941ee038c085a79192247b0ab',
              ),
              Padding(padding: EdgeInsets.only(bottom: 5)),
              Divider(thickness: 1, height: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(onPressed: _getBalance, child: Text('잔고 가져오기')),
                  Text('잔고: $balance'),
                ],
              ),
              Divider(thickness: 1, height: 1),
              Padding(padding: const EdgeInsets.all(8.0), child: Column(
                  children: [
                    TextField(
                      controller: _address,
                      decoration: InputDecoration(
                        labelText: '받는 주소',
                      ),
                    ),
                    TextField(
                      controller: _amount,
                      decoration: InputDecoration(
                        labelText: '수량',
                      ),
                    ),
                    OutlinedButton(onPressed: _signingTx, child: Text('전송', style: TextStyle(color: Colors.red))),
                    //TextButton(onPressed: _postSend, child: Text('보내기')),
                    Text('결과 - 트랜잭션 ID: $_transactionHash'),
                    OutlinedButton(onPressed: _searchTx, child: Text('트랜잭션 조회', style: TextStyle(color: Colors.green),)),
                  ],
              ),),
              Padding(padding: EdgeInsets.only(top: 15)),
              Text(
                'Address 2: 0x43aa1a5e0de1733c732c6cb94cf8ffd864234742',
              ),
              Padding(padding: EdgeInsets.only(bottom: 5)),
              Divider(thickness: 1, height: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(onPressed: _getBalance2, child: Text('잔고 가져오기')),
                  Text('잔고: $balance2'),
                ],
              ),
            ],
          ),
        ),
      ) // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class WebViewRoute extends StatefulWidget {
  const WebViewRoute({Key? key, required this.setTransaction}) : super(key: key);
  final Function(String) setTransaction;

  @override
  _WebViewRouteState createState() => _WebViewRouteState();
}

class _WebViewRouteState extends State<WebViewRoute> {
  String? address;
  int? port;
  String? blockHash;
  bool isListening = false;

  WebViewController? controller;

  //final Completer<WebViewController> _completerController = Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
    _initServer();
    // Enable virtual display.
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  _initServer() async {
    final server = new LocalAssetsServer(
      address: InternetAddress.loopbackIPv4,
      assetsBasePath: 'assets',
      logger: DebugLogger(),
    );

    final address = await server.serve();

    setState(() {
      this.address = address.address;
      port = server.boundPort!;
      isListening = true;
    });
  }

  Future<void> _onNavigationDelegateExample(WebViewController controller) async {
    print('111111111111111111111111111111');
    String _fileText = await rootBundle.loadString('assets/index.html');
    final String contentBase64 = base64Encode(const Utf8Encoder().convert(_fileText));
    await controller.loadUrl('data:text/html;base64,$contentBase64');
    //await controller.loadUrl(Uri.dataFromString(_fileText, mimeType: 'text/html', encoding: Encoding.getByName('utf-8').to));
  }

  JavascriptChannel _responseTransaction(BuildContext context) {
    return JavascriptChannel(
        name: 'transaction',
        onMessageReceived: (JavascriptMessage message) {
          // ignore: deprecated_member_use
          print("transaction 메시지 : ${message.message}");
          Map<String, dynamic> parseMsg = jsonDecode(message.message);
          print(parseMsg['senderTxHash']);
          widget.setTransaction(parseMsg['senderTxHash']);
          Navigator.pop(context);
        });
  }



  @override
  Widget build(BuildContext context) {
    return isListening
        ? WebView(
      debuggingEnabled: true,
      initialUrl: 'http://$address:$port',
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (webViewController) {
        controller = webViewController;
      },
      javascriptChannels: <JavascriptChannel>{
        _responseTransaction(context),
      },
    ) : Center(child: CircularProgressIndicator());
  }
}

class WebViewTxRoute extends StatefulWidget {
  const WebViewTxRoute({Key? key, required this.transactionHash}) : super(key: key);
  final String transactionHash;

  @override
  _WebViewTxRouteState createState() => _WebViewTxRouteState();
}

class _WebViewTxRouteState extends State<WebViewTxRoute> {
  WebViewController? controller;

  @override
  Widget build(BuildContext context) {
    return WebView(
        initialUrl: 'https://baobab.scope.klaytn.com/tx/${widget.transactionHash}',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (webViewController) {
          controller = webViewController;
        }
    );
  }
}
