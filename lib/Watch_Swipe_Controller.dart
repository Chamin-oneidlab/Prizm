import 'package:Prizm/main.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'Home.dart';
import 'Watch_ReSearch.dart';
import 'Watch_Search_Result.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Watch_Result_Swipe extends StatefulWidget {
  final String id;

  const Watch_Result_Swipe({Key? key, required this.id}) : super(key: key);

  @override
  State<Watch_Result_Swipe> createState() => _Watch_Result_SwipeState();
}

class _Watch_Result_SwipeState extends State<Watch_Result_Swipe> {
  late List _pages = [];
  var maps;

  void fetchData() async {
    if (!mounted) {
      return;
    }
    String? uid;
    var deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        uid = await PlatformDeviceId.getDeviceId;
        print('uid >> $uid');
      } else if (Platform.isIOS) {
        var iosInfo = await deviceInfoPlugin.iosInfo;
        uid = iosInfo.identifierForVendor!;
      }
    } on PlatformException {
      uid = 'Failed to get Id';
      rethrow;
    }

    try {
      http.Response response = await http.get(Uri.parse(
          // 'http://dev.przm.kr/przm_api/get_song_search/json?id=WA0632182001001&uid=d99df16f4105e7bd7'));
      'http://${MyApp.search}/json?id=${widget.id}&uid=$uid'));
      String jsonData = response.body;
      Map<String, dynamic> map = jsonDecode(jsonData);

      maps = map;
      setState(() {});
    } catch (e) {
      rethrow;
    }
  }

  @override
  void initState() {
    _pages = [Watch_Result(id: widget.id), Watch_ReSurch()];
    fetchData();
    super.initState();
  }

  int _selectedIndex = 0; // 처음에 나올 화면 지정

  PageController pageController = PageController(
    initialPage: 0,
  );

  Widget buildPageView() {
    return PageView(
      controller: pageController,
      children: <Widget>[_pages[0], _pages[1]],
    );
  }

  void pageChanged(int index) {
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedIndex = index;
      pageController.animateToPage(index,
          duration: const Duration(milliseconds: 500), curve: Curves.ease);
      pageController.jumpToPage(_selectedIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    double c_height = MediaQuery.of(context).size.height; // 화면상의 전체 높이
    double c_width = MediaQuery.of(context).size.width; // 화면상의 전치 너비

    return WillPopScope(
      onWillPop: _onBackKey,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
                child: Image.network(
              '${maps['IMAGE']}',
              height: c_height,
              width: c_width,
              fit: BoxFit.fill,
              errorBuilder: (context, error, stackTrace) {
                return SizedBox(
                  child: Image.asset(
                    'assets/no_image.png',
                    height: c_height,
                    fit: BoxFit.fill,
                  ),
                );
              },
            )),
            Container(
              alignment: Alignment.bottomCenter,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black],
                      stops: [.50, .75])),
              child: const SizedBox.shrink(),
            ),
            buildPageView(),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      child: SmoothPageIndicator(
                        controller: pageController, // PageController
                        count: 2,
                        effect: const WormEffect(
                          dotWidth: 4,
                          dotHeight: 5,
                          activeDotColor: Colors.white
                        ), // your preferred effect
                      ),
                    ),
                  ],
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
  Future<bool> _onBackKey() async {
    setState(() {
      pageController.animateToPage(0,
          duration: const Duration(milliseconds: 500), curve: Curves.ease);
    });
    return false;
  }
}
