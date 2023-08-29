import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'Watch_Swipe_Controller.dart';
import 'vmidc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'Settings.dart';
import 'main.dart';
import 'package:http/http.dart' as http;


/*
 * 뒤로가기 등 여러가지 Dialog 를 Debug Mode 에서 실행시
 * px overflow 에러가 날수 있지만 apk 추출하여 확인하면 정상적으로 출력됨 (iOS는 run --release)
 * 여러가지 overflow 에러는 꼭 release 버전에서 확인 해보고 수정필요
 *
 * Emulator 에서는 마이크 녹음 기능이 없기때문에 vmidc start 버튼을 누르면 에러 발생
 * Emulator 에서 검색 버튼 누른 후 화면 확인 등 체크 할땐 vmidc.start() 주석 후 확인 권장
 *
*/
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> {

  Future<void> logSetscreen() async {
    await MyApp.analytics.setCurrentScreen(screenName: 'Home');
  }

  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  final double _size = 220;
  final double watch_size = 150;
  var isRunning = false;

  final VMIDC _vmidc = VMIDC();
  final _ctrl = StreamController<List>();
  String _id = '';

  late dynamic _background = const ColorFilter.mode(Colors.transparent, BlendMode.clear);

  late var settingIcon = ImageIcon(Image.asset('assets/settings.png').image);

  /*
   * 하단 RichText 에서 삼항연산자로 활용하기위해 TextSpan 미리 정의
   */

  late TextSpan _textSpan_light = const TextSpan(children: [
    TextSpan(text: '지금 이 곡을 찾으려면 ', style: TextStyle(fontSize: 17, color: Colors.black)),
    TextSpan(
        text: '프리즘 ',
        style: TextStyle(
            color: Color.fromRGBO(43, 226, 193, 1),
            fontSize: 17,
            fontWeight: FontWeight.bold
        )
    ),
    TextSpan(text: '을 눌러주세요!', style: TextStyle(fontSize: 17, color: Colors.black)),
  ]);

  late TextSpan _textSpan_dark = const TextSpan(children: [
    TextSpan(text: '지금 이 곡을 찾으려면 ', style: TextStyle(fontSize: 17, color: Colors.white)),
    TextSpan(
        text: '프리즘 ',
        style: TextStyle(
            color: Color.fromRGBO(43, 226, 193, 1),
            fontSize: 17,
            fontWeight: FontWeight.bold
        )
    ),
    TextSpan(text: '을 눌러주세요!', style: TextStyle(fontSize: 17, color: Colors.white)),
  ]);


  @override
  void initState() {
    MyApp.isReady = false;
    Future.delayed(const Duration(milliseconds: 2000), () {
      logSetscreen();
      Permission.microphone.request();
      initConnectivity();
      //219.250.104.102
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
      print("IPHERE"+MyApp.vmidc);
      _vmidc.init(ip: "${MyApp.vmidc}", port: 8551, sink: _ctrl.sink).then((ret) {//ip, port 번호 변경시 여기만 변경
        if (!ret) {
          print('server error');
        } else {
          _ctrl.stream.listen((data) async {
            if (data.length == 2) {
              _id = '${data[0]} (${data[1]})'; // TODO: 5-1
            } else {
              _id = 'error';
            }
            await _vmidc.stop();
            setState(() {
              MyApp.isRunning == false;
            });
          });
        }
      });

    });
    super.initState();
  }

  @override
  void dispose() {
    _vmidc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    double c_height = MediaQuery.of(context).size.height;
    double c_width = MediaQuery.of(context).size.width;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isTransParents = settingIcon.color == const Color(0x00000000);  // Setting Icon 색에 따라 leading Icon 투명화
    final isPad = c_width > 550;
    return WillPopScope(
          onWillPop: () async {
            exit(0);
          },
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(top: c_height/2.5),
                // width: double.infn b inity,
                decoration: BoxDecoration(
                    image: DecorationImage(
                      scale: 2,
                        image: AssetImage('assets/BG_light.gif'),
                        colorFilter: _background,
                        fit: BoxFit.none,
                        alignment: const Alignment(0, -0.9),
                    )
                ),
              ),
              Center(
                  child: IconButton(
                    // padding: EdgeInsets.only(top: 25),
                      icon:Image.asset('assets/_prizm.png'),
                      iconSize: watch_size,
                      onPressed: () async {

                        var status = await Permission.microphone.status;
                        if (status == PermissionStatus.permanentlyDenied) {
                          PermissionToast();
                          Permission.microphone.request();
                          return;
                        } else if (status == PermissionStatus.denied) {
                          requestMicPermission(context);
                          Permission.microphone.request();
                          return;
                        }

                        if (await Permission.microphone.status.isGranted) {
                          _vmidc.start(); //인식 시작하는 부분 TODO: 주석처리풀기
                          MyApp.isRunning = true;
                          await MyApp.analytics.logEvent(name: 'vmidc_start');
                          if(!mounted){
                            return;
                          }
                          setState(() {
                            // settingIcon = ImageIcon(Image.asset('assets/settings.png').image, color: Colors.transparent);
                            _background = const ColorFilter.mode(Colors.transparent, BlendMode.color);
                          });
                          if (_vmidc.isRunning() == true) {
                            _vmidc.stop();
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const TabPage()));
                          }
                        }
                      }
                  ),
              )
            ]
          ),
        );
  }

  Future<bool> _onBackKey() async {
    print("run onBackKey1 Function");
    if (isRunning == true) {
      _vmidc.stop();
      Navigator.push(context, MaterialPageRoute(builder: (context) => const TabPage()));
      return false;
    }
    else {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
      return await showDialog(
        context: context,
        barrierDismissible: false, //다이얼로그 바깥을 터치 시에 닫히도록 하는지 여부 (true: 닫힘)
        builder: (BuildContext context) {
          double c_height = MediaQuery.of(context).size.height;
          double c_width = MediaQuery.of(context).size.width;
          return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Container(
                height: c_height * 0.18,
                width: c_width * 0.8,
                margin: const EdgeInsets.only(top: 20, bottom: 20),
                color: isDarkMode ? const Color.fromRGBO(66, 66, 66, 1) : Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: c_height * 0.115,
                      child: const Center(
                        child: Text('종료 하시겠습니까?', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          border: Border(
                              top: BorderSide(
                                  color: isDarkMode
                                      ? const Color.fromRGBO(94, 94, 94, 1)
                                      : Colors.black.withOpacity(0.1))
                          )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: c_width * 0.4,
                            height: c_height * 0.08,
                            child: Container(
                                decoration: BoxDecoration(
                                    color: isDarkMode ? const Color.fromRGBO(66, 66, 66, 1) : Colors.white,
                                    border: Border(
                                        right: BorderSide(
                                            color: isDarkMode
                                                ? const Color.fromRGBO(94, 94, 94, 1)
                                                : Colors.black.withOpacity(0.1)
                                        )
                                    )
                                ),
                                margin: const EdgeInsets.only(left: 20),
                                child: TextButton(
                                    onPressed: () {
                                      exit(0);
                                    },
                                    child: const Text('종료',
                                        style: TextStyle(fontSize: 20, color: Colors.red)
                                    )
                                )
                            ),
                          ),
                          Container(
                              margin: const EdgeInsets.only(right: 20),
                              color: isDarkMode ? const Color.fromRGBO(66, 66, 66, 1) : Colors.white,
                              width: c_width * 0.345,
                              height: c_height * 0.08,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('취소',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: isDarkMode ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.3),
                                  ),
                                ),
                              )
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
          );
        },
      );
    }
    return false;
  }

  Future<bool> requestMicPermission(BuildContext context) async {
    PermissionStatus status = await Permission.microphone.request();
    if (!status.isGranted) {  // 마이크 승인상태가 아닐시
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return _showDialog(context);
          });
      return false;
    }
    return true;
  }


  _showDialog(BuildContext context) { // 휴대폰 권한설정으로 이동
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))
      ),
      content: Builder(
        builder: (context) {
          var width = MediaQuery.of(context).size.width;
          var height = MediaQuery.of(context).size.height;
          return Container(
            width: width*0.7,
            height: height*0.15,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Prizm 사용을 위해 마이크 권한을 ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17
                        )
                      ),
                      TextSpan(
                        text: ' 허용',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20
                        )
                      ),
                      TextSpan(
                        text: ' 해주세요',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17
                        )
                      )
                    ]
                  )
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      child: TextButton(
                        onPressed: () {
                          openAppSettings();
                        },
                        child: const Text('권한 설정',
                         style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    if(!mounted) {
      return;
    }
    switch (await result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.none:
        setState(() => _connectionStatus = result.toString());
        break;
      default:
        setState(() => _connectionStatus = '네트워크 연결을 확인 해주세요 DEFAULT');
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
}

void NetworkToast() {
  Fluttertoast.showToast(
      msg: '네트워크 연결을 확인 해주세요.',
      backgroundColor: Colors.grey,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER
  );
}

void PermissionToast() {
  Fluttertoast.showToast(
      msg: '마이크 권한을 허용해주세요.',
      backgroundColor: Colors.grey,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER
  );
}
