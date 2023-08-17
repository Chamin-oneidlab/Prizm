import 'dart:async';
//1544-7556
import 'package:Prizm/Watch_ReSearch.dart';
import 'package:connectivity/connectivity.dart';
import 'package:Prizm/Home.dart';
import 'package:Prizm/vmidc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main.dart';

class NotFound extends StatefulWidget {
  @override
  _NotFound createState() => _NotFound();
}

class _NotFound extends State<NotFound> {

  Future<void> logSetscreen() async {
    await MyApp.analytics.setCurrentScreen(screenName: '검색 실패');
    await MyApp.analytics.logEvent(name: 'NotFound');
  }

  late dynamic _background = const ColorFilter.mode(Colors.transparent, BlendMode.clear);
  final VMIDC _vmidc = VMIDC();
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  final Column _textColumn_light = Column(children: [
    const Text('검색 결과 없음.',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black)
    ),
    Text('노래를 인식할 수 없습니다.',
        style: TextStyle(fontSize: 17, color: Colors.grey.withOpacity(0.6))
    ),
  ]);

  final Column _textColumn_dark = Column(children: const [
    Text('검색 결과 없음.',
        style: TextStyle(
            fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)
    ),
    Text('노래를 인식할 수 없습니다.', style: TextStyle(fontSize: 17, color: Colors.grey)
    ),
  ]);

  final Column _textColumn_light_w = Column(children: [
    const Text('검색된 음악이 없습니다.',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)
    ),
  ]);

  final Column _textColumn_dark_w = Column(children: const [
    Text('검색된 음악이 없습니다.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
  ]);

  @override
  void initState() {
    logSetscreen();
    initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _vmidc.recCtrl.sink.close();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    double c_height = MediaQuery.of(context).size.height;
    double c_width = MediaQuery.of(context).size.width;
    if (_connectionStatus.endsWith('none') == true&&!MyApp.isWatch) {
      NetworkToast();
    }
    return MyApp.isWatch?Container(
      // height: double.infinity,
      //   width: double.infinity, //
        color: const Color.fromRGBO(244, 245, 247, 1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isDarkMode?_textColumn_dark_w:_textColumn_light_w,
            Center(
              child: IconButton(
                  icon:Image.asset('assets/_prizm.png'),
                  iconSize: 110,
                  onPressed: () async {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => TabPage()));
                  }
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.push(context, MaterialPageRoute(builder: (context) => TabPage()));
              },
              child: const Text(
                '다시 검색하기',
                style: TextStyle(
                  color: Colors.lightBlueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        )
    ):WillPopScope(
        onWillPop: () async {
          return _onBackKey();
        },
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: isDarkMode
                  ? const Color.fromRGBO(47, 47, 47, 1)
                  : const Color.fromRGBO(244, 245, 247, 1),
              elevation: 0.0,
              centerTitle: true,
              toolbarHeight: 90,
              title: Image.asset(
                isDarkMode ? 'assets/logo_dark.png' : 'assets/logo_light.png',
                height: 25,
              ),
              leading: IconButton(
                  icon: Image.asset(
                    'assets/x_icon.png',
                    width: 20,
                    color: isDarkMode ? Colors.white : Colors.grey,
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => TabPage()));
                  }),
            ),
            backgroundColor: isDarkMode
                ? const Color.fromRGBO(47, 47, 47, 1)
                : const Color.fromRGBO(244, 245, 247, 1),
            body: Container(
                width: c_width,
                color: isDarkMode
                    ? const Color.fromRGBO(47, 47, 47, 1)
                    : const Color.fromRGBO(244, 245, 247, 1),
                child:
                Column(mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                          height: c_height * 0.59,
                          padding: const EdgeInsets.only(bottom: 50),
                          child: Center(
                              child: Column(children: <Widget>[
                                Center(
                                    child: Container(
                                        padding: const EdgeInsets.only(bottom: 20),
                                        child: isDarkMode ? _textColumn_dark : _textColumn_light
                                    )
                                ),
                                IconButton(
                                  icon: isDarkMode
                                      ? Image.asset('assets/_prizm_dark.png')
                                      : Image.asset('assets/_prizm.png'),
                                  padding: const EdgeInsets.only(bottom: 30),
                                  iconSize: 220,
                                  onPressed: () {
                                    _vmidc.stop();
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => TabPage()));
                                  },
                                )
                              ]))
                      )
                    ])
            )
        )
    );
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    if(!mounted) {
      return;
    }
    switch (await result) {
      case ConnectivityResult.mobile:
      case ConnectivityResult.wifi:
      case ConnectivityResult.none:
        setState(() => _connectionStatus = result.toString());
        break;
      default:
        setState(() => _connectionStatus = '네트워크 연결을 확인 해주세요.');
    }
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result = ConnectivityResult.none;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e);
      rethrow;
    }
    if (!mounted) {
      return Future.value(null);
    }
    return _updateConnectionStatus(result);
  }

  Future<bool> _onBackKey() async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return TabPage();
        });
  }
}
