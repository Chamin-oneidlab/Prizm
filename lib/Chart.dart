import 'dart:async';
// import 'package:firebase/firebase.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'Home.dart';
import 'Settings.dart';
import 'PlayInfo.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'main.dart';

/*
 *  차트 리스트 불러오는 속도가 느린데 쿼리문 문제인듯하니 임차장님께 개선요청 (이미 느린거 알고는 계심)
 */

class Chart extends StatefulWidget {
  const Chart({super.key});

  @override
  _Chart createState() => _Chart();
}

class _Chart extends State<Chart> {
  Future<void>logSetscreen() async {
    await MyApp.analytics.setCurrentScreen(screenName: 'Chart');
  }


  String? _deviceId;

  Future<void> initPlatformState() async {
    String? deviceId;
    try {
      deviceId = await PlatformDeviceId.getDeviceId;
    } on PlatformException {
      deviceId = 'Failed to get Id';
    }

    if (!mounted) return;

    setState(() {
      _deviceId = deviceId;
      print('deviceId : $_deviceId');
    });
  }

  List charts = [];

  void fetchData() async {
    try {
      http.Response response = await http.get(Uri.parse('https://${MyApp.ranks}'));
      print("@>@>@>@>@");
      print(MyApp.ranks);
      String jsonData = response.body;
      charts = jsonDecode(jsonData.toString());
      setState(() {});
    } catch (e) {
      NetworkToast();
      rethrow;
    }
  }

  @override
  void initState() {
    logSetscreen();
    initPlatformState();
    fetchData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    int len = charts.length;
    final isExist = len == 0;
    return WillPopScope(
        onWillPop: () async {
          return _onBackKey();
        },
        child: Scaffold(
            appBar: AppBar(
              shape: Border(
                  bottom: BorderSide(color: Colors.grey.withOpacity(0.3))),
              elevation: 0.0,
              title: Text(
                '차트',
                style: (isDarkMode
                    ? const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)
                    : const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
              ),
              centerTitle: true,
              toolbarHeight: 70,
              backgroundColor: isDarkMode ? Colors.black : Colors.white,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: ImageIcon(
                    Image.asset('assets/settings.png').image,
                  ),
                  color: isDarkMode ? Colors.white : Colors.black,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Settings()),
                    );
                  },
                )
              ],
            ),
            body: Container(
              color: isDarkMode ? Colors.black : Colors.white,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: isDarkMode ? Colors.black : Colors.white,
                    margin: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            padding: const EdgeInsets.only(top: 20),
                            child: Row(
                              children: const [
                                Text(
                                  '프리즘 방송 차트 ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25),
                                ),
                              ],
                            )),
                      ],
                    ),
                  ),
                  isExist
                      ? Container(
                          margin: const EdgeInsets.only(top: 100),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 30),
                                child: Center(
                                  child: Image.asset('assets/loading.gif',
                                      width: 40,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black),
                                ),
                              ),
                              Center(
                                child: Text(
                                  '차트정보를 불러오고 있습니다.',
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22),
                                ),
                              )
                            ],
                          ),
                        )
                      : _listView(charts)
                ],
              ),
            )));
  }

  Widget _listView(charts) {
    return Expanded(
        child: ListView.builder(
            itemCount: charts == null ? 0 : charts.length,
            itemBuilder: (context, index) {
              double c_width = MediaQuery.of(context).size.width;

              final deviceId = _deviceId;
              final chart = charts[index];

              final isArtistNull = chart['title'] == null;
              final isAlbumNull = chart['album'] == null;

              String title = chart['title'];
              String image = chart['image'];
              String artist =
                  isArtistNull ? 'Various Artists' : chart['artist'];
              String song_id = chart['song_id'];
              String Id = deviceId!;

              final isDarkMode =
                  Theme.of(context).brightness == Brightness.dark;

              return GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (BuildContext context) {
                        var chart = charts[index];
                        return SizedBox(
                            height: 230,
                            // height: 300,
                            width: c_width,
                            child: ListView.builder(
                                itemCount: 1,
                                itemBuilder: (context, index) {
                                  double c_width = MediaQuery.of(context).size.width;
                                  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
                                  return Container(
                                    width: c_width,
                                    padding: const EdgeInsets.only(top: 14),
                                    decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? const Color.fromRGBO(36, 36, 36, 1)
                                            : const Color.fromRGBO(250, 250, 250, 2),
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10)
                                        )
                                    ),
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: c_width,
                                            padding: const EdgeInsets.all(13),
                                            child: Row(
                                              children: [
                                                Container(
                                                    // margin : const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                                                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                                                    padding:
                                                        const EdgeInsets.all(1),
                                                    decoration: BoxDecoration(
                                                      color: isDarkMode
                                                          ? const Color
                                                                  .fromRGBO(
                                                              189, 189, 189, 1)
                                                          : Colors.black
                                                              .withOpacity(0.3),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        child:
                                                            SizedBox.fromSize(
                                                          child: Image.network(
                                                            chart['image'],
                                                            width: 90,
                                                            height: 90,
                                                            errorBuilder: (context, error, stackTrace) {
                                                              return SizedBox(
                                                                width: 90,
                                                                height: 90,
                                                                child: Image.asset('assets/no_image.png'),
                                                              );
                                                            },
                                                          ),
                                                        )
                                                    )
                                                ),
                                                Flexible(
                                                    child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                      SizedBox(
                                                        width: c_width * 0.6,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 15),
                                                              child: RichText(
                                                                overflow: TextOverflow.ellipsis,
                                                                maxLines: 2,
                                                                strutStyle: const StrutStyle(fontSize: 18),
                                                                text: TextSpan(
                                                                      text: chart['title'],
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight.bold,
                                                                          fontSize: 18,
                                                                          overflow:
                                                                          TextOverflow.ellipsis,
                                                                          color: isDarkMode ? Colors.white : Colors.black
                                                                      ),
                                                                )
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 15, top: 10),
                                                              child: Text(
                                                                isArtistNull ? 'Various Artists' : chart['artist'],
                                                                style: TextStyle(
                                                                    color: isDarkMode
                                                                        ? Colors.grey.withOpacity(0.8)
                                                                        : const Color.fromRGBO(123, 123, 123, 1),
                                                                    overflow: TextOverflow.ellipsis),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: c_width * 0.05,
                                                        child: IconButton(
                                                            padding: const EdgeInsets.only(bottom: 80),
                                                            icon: ImageIcon(Image.asset('assets/x_icon.png').image, size: 15),
                                                            color: isDarkMode ? Colors.white : Colors.grey,
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            }),
                                                      )
                                                    ])
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            height: 90,
                                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                                            color: isDarkMode ? Colors.black : Colors.white,
                                            child: Column(
                                              children: [
                                                GestureDetector(
                                                    onTap: () { // Text 클릭시 이동
                                                      Navigator.push(context, MaterialPageRoute(
                                                          builder: (context) =>
                                                                  PlayInfo(deviceId: Id, title: title, image: image, artist: artist, song_id: song_id)
                                                          )
                                                      );
                                                    },
                                                    child: Container(
                                                      color: isDarkMode ? Colors.black : Colors.white,
                                                      child: Row(
                                                        children: [
                                                          IconButton(
                                                            padding: const EdgeInsets.only(right: 20),
                                                            icon: ImageIcon(
                                                                Image.asset('assets/list.png').image, size: 30),
                                                            color: const Color.fromRGBO(64, 220, 196, 1),
                                                            onPressed: () { // list icon 클릭시 이동
                                                              Navigator.push(context, MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          PlayInfo(deviceId: Id, title: title, image: image, artist: artist, song_id: song_id)
                                                                  )
                                                              );
                                                            },
                                                          ),
                                                          Text(
                                                            '프리즘 방송 재생정보',
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300,
                                                                color: isDarkMode
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .black),
                                                          )
                                                        ],
                                                      ),
                                                    )),
                                              ],
                                            ),
                                          )
                                        ]),
                                  );
                                }));
                      });
                },
                child: Container(
                  color: isDarkMode ? Colors.black : Colors.white,
                  width: c_width,
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(1),
                        margin: const EdgeInsets.only(left: 15, right: 10),
                        decoration: BoxDecoration(
                            color: isDarkMode
                                ? const Color.fromRGBO(189, 189, 189, 1)
                                : const Color.fromRGBO(228, 228, 228, 1),
                            borderRadius: BorderRadius.circular(10)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox.fromSize(
                            size: const Size.fromRadius(40),
                            child: Image.network(
                              chart['image'],
                              width: 80,
                              height: 80,
                              errorBuilder: (context, error, stackTrace) {
                                return SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: Image.asset('assets/no_image.png'),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: c_width * 0.59,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      chart['title'],
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: RichText(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        text: TextSpan(children: [
                                          TextSpan(
                                              text: isArtistNull
                                                  ? 'Various Artists'
                                                  : chart['artist'],
                                              style: TextStyle(
                                                  color: isDarkMode
                                                      ? Colors.grey
                                                          .withOpacity(0.8)
                                                      : Colors.black
                                                          .withOpacity(0.3))),
                                          TextSpan(
                                            text: ' · ',
                                            style: TextStyle(
                                                color: isDarkMode
                                                    ? Colors.grey
                                                        .withOpacity(0.8)
                                                    : Colors.black
                                                        .withOpacity(0.3)),
                                          ),
                                          TextSpan(
                                            text: isAlbumNull
                                                ? 'Various Album'
                                                : chart['album'],
                                            style: TextStyle(
                                                color: isDarkMode
                                                    ? Colors.grey
                                                        .withOpacity(0.8)
                                                    : Colors.black
                                                        .withOpacity(0.3)),
                                          )
                                        ]),
                                      ))
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(right: 5),
                              width: c_width * 0.09,
                              child: const Icon(Icons.more_vert_sharp,
                                  color: Colors.grey, size: 30),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }));
  }

  Future<bool> _onBackKey() async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return TabPage();
        });
  }
}
