import 'dart:io';

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:Prizm/Home_NotFound.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Chart.dart';
import 'History.dart';
import 'main.dart';

class Notfound_Bottom extends StatefulWidget{
  @override
  _BottomState createState() => _BottomState();
}

class _BottomState extends State<Notfound_Bottom> {
  int _selectedIndex = 1;
  final List _pages = [History(), NotFound(), Chart()];


  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  var deviceData;
  var _deviceData;

  Future<void> initPlatformState() async {
    if(Platform.isAndroid) {
      deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
    } else if (Platform.isIOS) {
      IosDeviceInfo info = await deviceInfoPlugin.iosInfo;
    }
    setState(() {
      _deviceData = deviceData;
    });
  }

  double _readAndroidBuildData(AndroidDeviceInfo build) {
    return build.displayMetrics.widthPx;
  }
  @override
  void initState() {
    initPlatformState();
    super.initState();
  }

  PageController pageController = PageController(initialPage: 1);

  Widget buildPageView() {
    return PageView(
      controller: pageController,
      children: MyApp.isWatch?[NotFound()]:[_pages[0], _pages[1], _pages[2]],
    );
  }

  void pageChanged(int index) {
    setState(() {
      _selectedIndex = index;
      pageController.animateToPage(index, duration: const Duration(milliseconds: 500), curve: Curves.ease);
      pageController.jumpToPage(MyApp.isWatch?0:_selectedIndex);

    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setEnabledSystemUIMode(    // 상단 상태바 제거
        SystemUiMode.manual,
        overlays: [
          SystemUiOverlay.bottom
        ]
    );
    return MyApp.isWatch?Scaffold(
          body: buildPageView(),
    ):WillPopScope(
        onWillPop: (){
          if(_selectedIndex == 1 && pageController.offset == _deviceData /3) {
            return _onBackKey();
          } else {
            return _backToHome();
          }
        },
        child: Scaffold(
          body: buildPageView(),
          bottomNavigationBar: StyleProvider(
            style: isDarkMode ? Style_dark() : Style(),
            child: ConvexAppBar(
              items: [
                TabItem(icon: Image.asset('assets/history.png'), title: '히스토리'),
                TabItem(icon: isDarkMode
                    ?Image.asset('assets/search_dark.png')
                    :Image.asset('assets/search.png')
                ),
                TabItem(icon: Image.asset('assets/chart.png'), title: '차트')
              ],
              onTap: pageChanged,
              height: 70,
              initialActiveIndex: null,
              style: TabStyle.fixedCircle,
              elevation: 1,
              backgroundColor: isDarkMode ? Colors.black : Colors.white,
            ),
          ),
        )
    );
  }

  Future<bool> _onBackKey() async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return await showDialog(
      context: context,
      barrierDismissible: false, //다이얼로그 바깥을 터치 시에 닫히도록 하는지 여부 (true: 닫힘, false: 닫히지않음)
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
                                              : Colors.black.withOpacity(0.1))
                                  )
                              ),
                              margin: const EdgeInsets.only(left: 20),
                              child: TextButton(
                                  onPressed: () {
                                    exit(0);
                                  },
                                  child: const Text('종료',
                                      style: TextStyle(fontSize: 20, color: Colors.red))
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
                                  color: isDarkMode
                                      ? Colors.white.withOpacity(0.8)
                                      : Colors.black.withOpacity(0.3),
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

  Future<bool> _backToHome() async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return TabPage();
        });
  }
}