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
  late dynamic _background = const ColorFilter.mode(Colors.transparent, BlendMode.clear);
  late List _pages = [];
  var maps;
  var artist;
  var title;
  var image="";
  late Future myFuture;
  Future<String> fetchData() async {
    String? uid;

    try {
      if (Platform.isAndroid) {
        uid = await PlatformDeviceId.getDeviceId;
      } else if (Platform.isIOS) {
        var deviceInfoPlugin = DeviceInfoPlugin();
        var iosInfo = await deviceInfoPlugin.iosInfo;
        uid = iosInfo.identifierForVendor!;
      }
    } on PlatformException {
      uid = 'Failed to get Id';
      rethrow;
    }

    try {
      http.Response response = await http.get(Uri.parse(
          'https://${MyApp.search}/json?id=${widget.id}&uid=$uid'));
      String jsonData = response.body;
      Map<String, dynamic> map = jsonDecode(jsonData);
      maps = map;
      title = map['TITLE'];
      artist = map['ARTIST'];
      image = map['IMAGE'];
      _pages = [Watch_Result(id: widget.id,title:title,artist: artist), Watch_ReSurch()];

      setState(() {});
    } catch (e) {
      rethrow;
    }

    return "done";
  }

  @override
  void initState() {
    super.initState();
    myFuture = fetchData();
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

    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          exit(0);
        },
        child: FutureBuilder(
            future: myFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot){
              if(snapshot.hasData == false){
                return Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: c_height/2.5),
                        // width: double.infn b inity,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                              scale: 2,
                              image: AssetImage('assets/BG_light.gif'),
                              colorFilter: const ColorFilter.mode(Colors.transparent, BlendMode.color),
                              fit: BoxFit.none,
                              alignment: const Alignment(0, -0.9),
                            )
                        ),
                      ),
                      Center(
                        child: IconButton(
                          // padding: EdgeInsets.only(top: 25),
                            icon:Image.asset('assets/_prizm.png'),
                            iconSize: 150,
                            onPressed: () async {
                            }
                        ),
                      )
                    ]
                );
              }else if (snapshot.hasError){
                return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        'ERROR: ${snapshot.error}',
                        style: TextStyle(fontSize: 15)
                    )
                );
              }
              else {
                return Scaffold(
                  body: Stack(
                    children: [
                      Container(
                          child: Image.network(
                            image,
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
                          )
                      ),
                      Container(
                        alignment: Alignment.bottomCenter,
                        decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black],
                                stops: [.50, .75])),
                        child: SizedBox.shrink(),
                      ),
                      buildPageView(),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.only(bottom: 5),
                                child: SmoothPageIndicator(
                                  controller: pageController, // PageController
                                  count: 2,
                                  effect: WormEffect(
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
                );
              }
            }
        ),
      ),
    );
  }
  Future<bool> _onBackKey() async {
    // setState(() {
    //   pageController.animateToPage(0,
    //       duration: const Duration(milliseconds: 500), curve: Curves.ease);
    // });
    // return false;
    exit(0);
  }
}
