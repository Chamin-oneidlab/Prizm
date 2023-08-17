import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'main.dart';

enum _HighlightTextType { text }

class PlayInfo extends StatefulWidget {
  
  final String title; // 값들을 위젯으로 넘김
  final String image;
  final String artist;
  final String song_id;
  final String deviceId;

  const PlayInfo({
    Key? key,
    required this.title, // key에 담아서 사용
    required this.image,
    required this.artist,
    required this.song_id,
    required this.deviceId,
  }) : super(key: key);

  @override
  State<PlayInfo> createState() {
    return _PlayInfo();
  }
}

class _PlayInfo extends State<PlayInfo> {

  late Timer timer = Timer(const Duration(seconds: 6), () { // n초동안 데이터 받아오고 없으면 검색기록 없다는 메세지로 넘김
    if(!mounted) return;
    setState(() {});
  });

  Future<void> logSetscreen() async {
    await MyApp.analytics.setCurrentScreen(screenName: '프리즘 방송 재생정보');
  }
  TextAlign textAlign = TextAlign.justify;
  FontWeight fontWeight = FontWeight.bold;
  _HighlightTextType type = _HighlightTextType.text;

  List info = [];
  List info_radio = [];

  late int statuscode;

  fetchData() async {

    if(!mounted) return;

    http.Response response = await http.get(
      Uri.parse('https://${MyApp.search}/json?id=${widget.song_id}')
    );
    print("********");
    print('https://${MyApp.search}/json?id=${widget.song_id}');

    statuscode = response.statusCode;
    try {

      var jsonData = response.body;
      Map<String, dynamic> map = jsonDecode(jsonData);
      info = map['tv'];
      info_radio = map['radio'];
      setState(() {});

    } catch (e) {
      // print('json 통신 실패');
      rethrow;
    }
  }


  @override
  void initState() {
    logSetscreen();
    fetchData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
    final isExistTV = info.isEmpty||info == null;
    final isExistRadio = info_radio.isEmpty||info_radio==null;
    print("!@#####");
    print(info_radio);

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    double c_width = MediaQuery.of(context).size.width * 1.0;
    double c_height = MediaQuery.of(context).size.height * 1.0;
    return Scaffold(
      appBar: AppBar(
        title: Text("프리즘 방송 재생정보",
            style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: isDarkMode ? Colors.white : Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        elevation: 1.0,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        toolbarHeight: 70,
      ),
      body: Container(
        height: 2800,
        color: isDarkMode ? Colors.black : Colors.white,
        child: Scrollbar(
            child: SizedBox(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: c_width,
                        color: isDarkMode ? const Color.fromRGBO(36, 36, 36, 1) : const Color.fromRGBO(250, 250, 250, 1),
                        height: 100,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                padding: const EdgeInsets.all(1),
                                margin: const EdgeInsets.only(
                                    right: 30, top: 20, left: 20, bottom: 20),
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? const Color.fromRGBO(189, 189, 189, 1)
                                      : const Color.fromRGBO(228, 228, 228, 1),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: SizedBox.fromSize(
                                      size: const Size.fromRadius(28),
                                      child: Image.network(
                                        widget.image,
                                        width: 70,
                                        height: 70,
                                        errorBuilder: (context, error, stackTrace) {
                                          return SizedBox(
                                              width: 70,
                                              height: 70,
                                              child: Image.asset(
                                                  'assets/no_image.png')
                                          );
                                        },
                                      )
                                  ),
                                )
                            ),
                            Container(
                                width: c_width * 0.6,
                                padding: const EdgeInsets.only(top: 25),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(widget.title,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            overflow: TextOverflow.ellipsis,
                                            color: isDarkMode ? Colors.white : Colors.black
                                        )
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 5),
                                      child: Text(widget.artist,
                                          style: TextStyle(
                                              color: isDarkMode
                                                  ? const Color.fromRGBO(123, 123, 123, 1)
                                                  : const Color.fromRGBO(151, 151, 151, 1),
                                              overflow: TextOverflow.ellipsis
                                          )
                                      ),
                                    )
                                  ],
                                )
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 20, right: 20),
                        child: Column(
                          children: [
                            SizedBox(
                                height: c_height * 0.421,
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.only(top: 30, bottom: 10),
                                        child: Text('최신 TV 방송내역',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 22,
                                              color: isDarkMode ? Colors.white : Colors.black),
                                        ),
                                      ),
                                      Expanded(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                  child: isExistTV
                                                      ? loading() : _tv_list(info)
                                              )
                                            ],
                                          )
                                      )
                                    ]
                                )
                            ),
                            SizedBox(
                                height: c_height * 0.42,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: const Text('최신 RADIO 방송내역',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)
                                      ),
                                    ),
                                    Expanded(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              child: isExistRadio
                                                  ? loading() : _radio_list(info_radio),
                                            )
                                          ],
                                        )
                                    )
                                  ],
                                )
                            ),
                          ],
                        ),
                      )
                    ]),
              ),
            )),
      ),
    );
  }

  loading() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if(timer.isActive) { //TODO::
      return Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 70, bottom: 30),
            child: Center(
              child: Image.asset('assets/loading.gif',
                width: 40,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
          Center(
            child: Text(
              '방송 정보를 불러오고 있습니다.',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 22
              ),
            ),
          )
        ],
      );
    } else {
      return SizedBox(
        child: Center(
          child: Text('최신 방송 정보가 없습니다.',
          style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 22
            )
          ),
        ),
      );
    }
  }
  Widget _radio_list(info_radio) {
    return Expanded(
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: info_radio == null ? 0 : info_radio.length,
          itemBuilder: (context, index) {

            String radioDate = info_radio[index]['RADIO_DATE'];
            String parseRadioDate = DateFormat('yyyy.MM.dd').format(DateTime.parse(radioDate)).toString();
            final isDarkMode = Theme.of(context).brightness == Brightness.dark;
            return Row(children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    margin: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          color: isDarkMode
                              ? const Color.fromRGBO(189, 189, 189, 1)
                              : Colors.black.withOpacity(0.3),
                          width: 3
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox.fromSize(
                        child: Image.network(
                          info_radio[index]['RADIO_LOGO'], // 방송 이미지가 생긴다면 RADIO_IMAGE
                          width: 140,
                          height: 140,
                          errorBuilder: (context, error, stackTrace) {
                            return SizedBox(
                              width: 140,
                              height: 140,
                              child: Image.asset('assets/no_image.png'),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color.fromRGBO(51, 211, 180, 1)
                          ),
                          child: Text(
                            info_radio[index]['RADIO_TYPE'],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(
                          width: 65,
                          height: 22,
                          child: Text(info_radio[index]['CL_NM'],
                              style: TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                  fontSize: 16
                              )
                          ),
                        )
                      ]),
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 3, 0, 10),
                        width: 140,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 3),
                              child: Text(info_radio[index]['RADIO_NAME'],
                                  style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: isDarkMode ? Colors.white : Colors.black
                                  )
                              ),
                            ),
                                Text(
                                    parseRadioDate,
                                style: TextStyle(
                                    color: isDarkMode ? Colors.grey.withOpacity(0.8) : Colors.black.withOpacity(0.3)
                                )
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              )
            ]);
          }),
    );
  }
}

Widget _tv_list(info) {
  return Expanded(
    child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: info == null ? 0 : info.length,
        itemBuilder: (context, index) {
          String tvDate = info[index]['TV_DATE'];
          String parseTvDate = DateFormat('yyyy.MM.dd').format(DateTime.parse(tvDate)).toString();

          final isDarkMode = Theme.of(context).brightness == Brightness.dark;
          return Row(children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(1),
                  margin: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        width: 3,
                        color: isDarkMode
                            ? const Color.fromRGBO(189, 189, 189, 1)
                            : Colors.black.withOpacity(0.3)
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox.fromSize(
                      child: Image.network(
                        info[index]['TV_LOGO'],     // 방송 이미지 생기면 TV_IMAGE
                        width: 140,
                        height: 140,
                        errorBuilder: (context, error, stackTrace) {
                          return SizedBox(
                            width: 140,
                            height: 140,
                            child: Image.asset('assets/no_image.png'),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color.fromRGBO(51, 211, 180, 1)
                            ),
                            child: Text(
                                info[index]['TV_TYPE'],
                                style: const TextStyle(color: Colors.white)
                            ),
                          ),
                          SizedBox(
                            width: 65,
                            height: 22,
                            child: Text(info[index]['CL_NM'],
                                style: TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? Colors.white : Colors.black,
                                    fontSize: 16
                                )
                            ),
                          ),
                        ]),
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 3, 0, 10),
                      width: 140,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 3),
                            child: Text(info[index]['TV_NAME'],
                                style: TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: isDarkMode ? Colors.white : Colors.black
                                )
                            ),
                          ),
                          Text(
                              parseTvDate,
                              style: TextStyle(
                                  color: isDarkMode ? Colors.grey.withOpacity(0.8) : Colors.black.withOpacity(0.3)
                              )
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ],
            )
          ]);
        }),
  );
}
