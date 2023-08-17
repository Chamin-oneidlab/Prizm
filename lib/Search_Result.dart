// --no-sound-null-safety
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:share_plus/share_plus.dart';
import 'chart/chart_container.dart';
import 'main.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class Result extends StatefulWidget {
  late final String id;

  Result({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  _Result createState() => _Result();
}

class _Result extends State<Result> {
  Future <void> logSetscreen() async {
    await MyApp.analytics.setCurrentScreen(screenName: 'ios 검색결과');
  }
  //-----------
  late dynamic _background = const ColorFilter.mode(
      Colors.transparent, BlendMode.color
  );
  //-----------
  late Future myFuture;
  var maps;
  List programs = [];
  List song_cnts = [];

  var image;
  var title;
  var artist;
  var album;
  var date_;
  var count;

  var cnt;

  List reversedDate = [];
  List dateList = [];

  var intY;
  List listY = [];
  var intX;
  List listX = [];

  var dateTime;
  var date;
  var now = DateTime.now();
  var year;

  List<FlSpot> FlSpotDataAll = [];
  var sum;
  var avgY;

  Future<String> fetchData() async {
    String? _uid;
    var deviceInfoPlugin = DeviceInfoPlugin();

    try {
      if(Platform.isAndroid) {
        _uid = await PlatformDeviceId.getDeviceId;
        print('android uid : $_uid');
      } else if(Platform.isIOS) {
        var iosInfo = await deviceInfoPlugin.iosInfo;
        _uid = iosInfo.identifierForVendor!;
        print('ios uid : $_uid');
      }
    } on PlatformException {
      _uid = 'Failed to get Id';
    }

// json for title album artist
    try {
      http.Response response = await http.get(
          Uri.parse('https://${MyApp.search}/json?id=${widget.id}&uid=$_uid')
      );

      String jsonData = response.body;
      Map<String, dynamic> map = jsonDecode(jsonData);

      maps = map;
      image = maps['IMAGE'];
      title = maps['TITLE'];
      artist = maps['ARTIST'];
      album = maps['ALBUM'];
      date_ = maps['date'];
      count = maps['count'];
      song_cnts = maps['song_cnts'];

      setState(() {});
    } catch (e) {
      print('json 가져오기 실패');
      print(e);
    }

//json for program list

    try {
      http.Response response = await http.get(
          Uri.parse('https://${MyApp.programs}/json?id=${widget.id}')
        // Uri.parse('${MyApp.Uri}get_song_programs/json?id=${widget.id}')
      );
      String jsonData = response.body;

      programs = jsonDecode(jsonData.toString());
      setState(() {});
    } catch (e) {
      print('fail to get json');
      print(e);
    }

    try {
      List _contain = [];  // 실데이타 파싱
      sum = 0;
      for (int i = 0; i <= song_cnts.length - 1; i++) {
        intX = int.parse(song_cnts[i]['F_MONTH'].toString());
        intY = int.parse(song_cnts[i]['CTN']);
        listX.add(intX);
        listY.add(intY);
        listX.sort();
        listY.sort();
        _contain.add(song_cnts[i]['F_MONTH'].toString());
        for (var y = 0; y < listY.length; y++) {
          sum += listY[y];
        }
      }
      avgY = sum / listY.length;

      List _dateList = [];
      var _dateTime;
      var _month;
      var _year;

//차트 x 축 기준 만들기
      for (var i = 1; i < 13; i++) {
        _dateTime = DateTime(now.year, now.month - i, 1);
        _month = DateFormat('MM').format(_dateTime);
        _year = DateFormat('yyyy').format(_dateTime);
        _dateList.add(_year + _month);
      }
      List _reverse = List.from(_dateList.reversed);

// 현재월
// 차트 실데이터 파싱
      for (int j = 0; j < _reverse.length; j++) {

//없는 월 제외
        double mon = double.parse(j.toString()) + 1;

        FlSpotDataAll.insert(j, FlSpot(mon, 0));
        for (int jj = 0; jj < song_cnts.length; jj++) {
          if (song_cnts[jj]['F_MONTH'].toString() == _reverse[j]) {
            cnt = double.parse(song_cnts[jj]['CTN']);
            FlSpotDataAll.removeAt(j);
            FlSpotDataAll.insert(j, FlSpot(mon, cnt));
          }
        }
      }
      FlSpotDataAll.removeWhere((items) => items.props.contains(0.0));
    } catch (e) {
      print('fail to make FlSpotData');
      print(e);
    }
    return 'done';
  }

  final duplicateItems =
  List<String>.generate(1000, (i) => "$Container(child:Text $i)");
  var items = <String>[];

  Future<void> getLink() async {
    final dynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse('https://oneidlab.page.link/'),
      uriPrefix: 'https://oneidlab.page.link/prizmios',
      iosParameters: const IOSParameters(
          bundleId: 'com.ios.prizm',
          appStoreId: '123456789',
          minimumVersion: '1.0.0'
      ),
    );
  }

  @override
  void initState() {
    logSetscreen();
    getLink();
    myFuture = fetchData();
    super.initState();
  }

  @override
  void dispose() {
    print('dispose');
    line_chart(song_cnts);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    double c_height = MediaQuery.of(context).size.height;
    double c_width = MediaQuery.of(context).size.width * 1.0;
    final isPad = c_width > 550;
    final isCNTS = song_cnts.length > 3;
    final isExist = programs.length == 0;
    final isImage = true;
    final isFlip = c_height / c_width > 2.3;
    final isUltra = c_height > 1000;
    final isPlus = 1000 < c_height && 1300 >= c_height && c_width > 500;
    final isNormal = c_height < 850;

    // print('height = ${c_height.toInt()}');
    // print('width = ${c_width.toInt()}');
    // print('height / width = ${c_height/c_width}');

    return
      WillPopScope(
        onWillPop: () async {
          return _onBackKey();
        },
        child: FutureBuilder(
            future: myFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot){
              if(snapshot.hasData == false){
                return Scaffold(
                  bottomNavigationBar: StyleProvider(
                      style: isDarkMode? Style_dark() : Style(),
                      child: ConvexAppBar(
// type: BottomNavigationBarType.fixed, // bottomNavigationBar item이 4개 이상일 경우
                        items: [
                          TabItem(
                            icon: Image.asset('assets/history.png'),
                            title: '히스토리',
                          ),
                          TabItem(
                            icon: isDarkMode
                                ? Image.asset('assets/search_dark.png')
                                : Image.asset('assets/search.png'),
                          ),
                          TabItem(
                            title: '차트',
                            icon: Image.asset('assets/chart.png', width: 50),
                          ),
                        ],
                        onTap: (int){},
                        height: 80,
                        style: TabStyle.fixedCircle,
                        curveSize: 100,
                        elevation: 2.0,
                        backgroundColor: isDarkMode ? Colors.black : Colors.white,
                      )
                  ),
                  appBar: AppBar(
                    backgroundColor: isDarkMode
                        ? const Color.fromRGBO(47, 47, 47, 1)
                        : const Color.fromRGBO(244, 245, 247, 1),
                    title: Image.asset(
                      isDarkMode ? 'assets/logo_dark.png' : 'assets/logo_light.png',
                      height: 25,
                    ),
                    automaticallyImplyLeading: false,
                    leading: IconButton(
                      icon: Image.asset('assets/x_icon.png', width: 20,
                        // color: isTransParent ? isDarkMode ? Colors.white : Colors.grey : Colors.transparent
                      ),
                      splashColor: Colors.transparent,
                      onPressed: () {
                      },
                    ),
                    centerTitle: true,
                    toolbarHeight: 90,
                    elevation: 0.0,
                  ),
                  body: Container(
                      width: double.infinity,
                      color: isDarkMode
                          ? const Color.fromRGBO(47, 47, 47, 1)
                          : const Color.fromRGBO(244, 245, 247, 1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                              height: c_height * 0.55,
                              padding: const EdgeInsets.only(bottom: 50),
                              decoration: isPad
                                  ? BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(isDarkMode
                                          ? 'assets/BG_dark.gif'
                                          : 'assets/BG_light.gif'),
                                      alignment: const Alignment(0, -1.8),
                                      fit: BoxFit.cover,
                                      colorFilter: _background))
                                  : BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(isDarkMode
                                          ? 'assets/BG_dark.gif'
                                          : 'assets/BG_light.gif'),
                                      alignment: isFlip
                                          ? const Alignment(0, 1)
                                          : const Alignment(0, 3),
                                      colorFilter: _background)),
                              child: Center(
                                  child: Column(children: <Widget>[
                                    Center(
                                        child: Container(
                                          margin: const EdgeInsets.only(bottom: 20),
                                          child: RichText(
                                              text: isDarkMode
                                                  ? const TextSpan(
                                                  text: '노래 분석중',
                                                  style: TextStyle(
                                                      color: Color.fromRGBO(43, 226, 193, 1),
                                                      fontSize: 17,
                                                      fontWeight: FontWeight.bold
                                                  ))
                                                  : const TextSpan(
                                                text: '노래 분석중',
                                                style: TextStyle(
                                                    color: Color.fromRGBO(43, 226, 193, 1),
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.bold),
                                              )
                                          ),
                                        )),
                                    IconButton(
                                        icon: isDarkMode
                                            ? Image.asset('assets/_prizm_dark.png')
                                            : Image.asset('assets/_prizm.png'),
                                        padding: const EdgeInsets.only(bottom: 30),
                                        iconSize: 220,
                                        onPressed: () async {}),
                                  ])
                              )
                          ),
                        ],
                      )
                  ),
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
                return Scrollbar(
                  child: SizedBox(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Material(
                          color: isDarkMode ? Colors.black : Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  Center(
                                    child: isFlip
                                        ? SizedBox(
                                        child: Image.network(
                                          '${image}',
                                          height: c_height * 0.57,
                                          fit: BoxFit.fill,
                                          errorBuilder: (context, error, stackTrace) {
                                            return SizedBox(
                                              child: Image.asset(
                                                'assets/no_image.png',
                                                height: c_height * 0.57,
                                                fit: BoxFit.fill,
                                              ),
                                            );
                                          },
                                        )
                                    )
                                        : isPad
                                        ? SizedBox(
                                        child: Image.network(
                                          '${image}',
                                          height: c_height * 0.5,
                                          fit: BoxFit.fill,
                                          errorBuilder: (context, error, stackTrace) {
                                            return SizedBox(
                                              child: Image.asset(
                                                'assets/no_image.png',
                                                height: c_height * 0.5,
                                                fit: BoxFit.fill,
                                              ),
                                            );
                                          },
                                        )
                                    )
                                        : isPlus
                                        ?SizedBox(
                                        child: Image.network(
                                          '${image}',
                                          height: c_height * 0.4,
                                          fit: BoxFit.fill,
                                          errorBuilder: (context, error, stackTrace) {
                                            return SizedBox(
                                              child: Image.asset(
                                                'assets/no_image.png',
                                                height: c_height * 0.4,
                                                fit: BoxFit.fill,
                                              ),
                                            );
                                          },
                                        )
                                    )
                                        : isUltra
                                        ? SizedBox(
                                        child: Image.network(
                                          '${image}',
                                          height: c_height * 0.5,
                                          fit: BoxFit.fill,
                                          errorBuilder: (context, error, stackTrace) {
                                            return SizedBox(
                                              child: Image.asset(
                                                'assets/no_image.png',
                                                height: c_height * 0.5,
                                                fit: BoxFit.fill,
                                              ),
                                            );
                                          },
                                        )
                                    )
                                        : isNormal
                                        ?SizedBox(
                                        child: Image.network(
                                          '${image}',
                                          height: c_height * 0.6,
                                          fit: BoxFit.fill,
                                          errorBuilder: (context, error, stackTrace) {
                                            return SizedBox(
                                              child: Image.asset(
                                                'assets/no_image.png',
                                                height: c_height * 0.6,
                                                fit: BoxFit.fill,
                                              ),
                                            );
                                          },
                                        )
                                    )
                                        : SizedBox(
                                        child: Image.network(
                                          '${image}',
                                          height: c_height * 0.55,
                                          fit: BoxFit.fill,
                                          errorBuilder: (context, error, stackTrace) {
                                            return SizedBox(
                                              child: Image.asset(
                                                'assets/no_image.png',
                                                height: c_height * 0.5,
                                                fit: BoxFit.fill,
                                              ),
                                            );
                                          },
                                        )
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        gradient: isDarkMode
                                            ? const LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [Colors.black12, Colors.black],
                                            stops: [.40, .75])
                                            : const LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [Colors.white10, Colors.white],
                                            stops: [.40, .75])
                                    ),
                                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            IconButton(
                                              icon:
                                              const Icon(Icons.arrow_back_ios_sharp),
                                              color: isImage
                                                  ? isDarkMode ? Colors.white : Colors.black
                                                  : isPad
                                                  ? isDarkMode ? Colors.white : Colors.black
                                                  : isDarkMode ? Colors.black : Colors.black,
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => TabPage()),
                                                );
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.share_outlined,
                                                size: 30,
                                              ),
                                              color: isImage
                                                  ? isDarkMode ? Colors.white : Colors.black
                                                  : isPad
                                                  ? isDarkMode ? Colors.white : Colors.black
                                                  : isDarkMode ? Colors.black : Colors.black,
                                              onPressed: () {
                                                _onShare(context);
                                              },
                                            )
                                          ],
                                        ),
                                        Container(
                                            margin: EdgeInsets.only(top: isPad ? 500 : 400 ),
                                            width: c_width * 0.9,
                                            child: RichText(
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              strutStyle: const StrutStyle(fontSize: 30),
                                              text: TextSpan(children: [
                                                TextSpan(
                                                  text: '${title}',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 30,
                                                      overflow: TextOverflow.ellipsis,
                                                      color: isDarkMode ? Colors.white : Colors.black),
                                                )
                                              ]),
                                            )
                                        ),
                                        Container(
                                            padding: const EdgeInsets.only(right: 10),
                                            child: Row(
                                              children: [
                                                Flexible(
                                                    child: RichText(
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                      strutStyle: const StrutStyle(fontSize: 17),
                                                      text: TextSpan(children: [
                                                        TextSpan(
                                                          text: artist,
                                                          style: TextStyle(
                                                            fontSize: 17,
                                                            color: isDarkMode ? Colors.white : Colors.black,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                            text: ' · ',
                                                            style: TextStyle(
                                                                color: isDarkMode ? Colors.grey : Colors.black.withOpacity(0.4), fontSize: 17)),
                                                        TextSpan(
                                                          text: album,
                                                          style: TextStyle(
                                                              color: isDarkMode
                                                                  ? Colors.grey
                                                                  : Colors.black
                                                                  .withOpacity(0.4),
                                                              overflow: TextOverflow.ellipsis,
                                                              fontSize: 17),
                                                        )
                                                      ]),
                                                    ))
                                              ],
                                            )
                                        ),
                                        Container(
                                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 50),
                                          child: Row(
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.only(right: 20),
                                                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(20),
                                                    color: const Color.fromRGBO(51, 211, 180, 1)),
                                                child: Text(
                                                  '${date_}',
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                              Image.asset('assets/result_search.png', width: 15, color: Colors.grey),
                                              Text(' ${count}',
                                                  style: const TextStyle(color: Colors.grey, overflow: TextOverflow.ellipsis)),
                                              const Text('회', style: TextStyle(color: Colors.grey))
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                  margin: const EdgeInsets.only(right: 20, left: 20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        color: isDarkMode ? Colors.black : Colors.white,
                                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                                        child: const Text('최신 방송 재생정보',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20)),
                                      ),
                                      SizedBox(
                                          height: 250,
                                          child: Container(
                                              child: isExist
                                                  ? Center(
                                                  child: Text('최신 방송 재생정보가 없습니다.',
                                                      style: TextStyle(
                                                          color: isDarkMode ? Colors.white : Colors.black,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 20))
                                              )
                                                  : Row(
                                                children: [_listView(programs)],
                                              )
                                          )
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                              margin: const EdgeInsets.only(bottom: 30),
                                              child: const Text(
                                                '프리즘차트',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20),
                                              )
                                          ),
                                          isCNTS
                                              ? ChartContainer(
                                            color: isDarkMode
                                                ? Colors.black
                                                : Colors.white,
                                            chart: line_chart(song_cnts),
                                          )
                                              : const SizedBox(
                                              height: 200,
                                              child: Center(
                                                  child: Text('차트 정보가 없습니다.',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 20))))
                                        ],
                                      ),
                                      Container(
                                        margin:
                                        const EdgeInsets.only(left: 00, right: 10),
                                        decoration: BoxDecoration(
                                            color: isDarkMode
                                                ? const Color.fromRGBO(42, 42, 42, 1)
                                            // : const Color.fromRGBO(239, 239, 239, 1)),
                                                : const Color.fromRGBO(250, 250, 250, 1)
                                        ),
                                        height: 100,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Image.asset('assets/result_search.png',
                                                width: 20),
                                            Container(
                                              margin: const EdgeInsets.only(left: 10, right: 10),
                                              child: Text('총 검색 : ',
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      color: isDarkMode
                                                          ? const Color.fromRGBO(
                                                          151, 151, 151, 1)
                                                          : Colors.black)),
                                            ),
                                            Text('${count}',
                                                style: const TextStyle(fontSize: 17)
                                            ),
                                            const Text('회',
                                                style: TextStyle(fontSize: 17)
                                            )
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          _onBackKey();
                                        },
                                        child: Container(
                                          padding:
                                          const EdgeInsets.symmetric(horizontal: 100),
                                          height: 70,
                                          margin:
                                          const EdgeInsets.fromLTRB(0, 30, 10, 40),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 1,
                                                  color: isDarkMode
                                                      ? Colors.grey.withOpacity(0.3)
                                                      : Colors.black.withOpacity(0.1)
                                              )
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                  padding:
                                                  const EdgeInsets.only(right: 10),
                                                  child: const Text(
                                                    '홈으로',
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16
                                                    ),
                                                  )
                                              ),
                                              Icon(
                                                Icons.arrow_forward_ios_sharp,
                                                size: 17,
                                                color: isDarkMode
                                                    ? const Color.fromRGBO(125, 125, 125, 1)
                                                    : const Color.fromRGBO(208, 208, 208, 1),
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                              )
                            ],
                          )
                      ),
                    ),
                  ),
                );
              }
            }
        ),
      );
  }

  Widget _listView(programs) {
    return Expanded(
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: programs == null ? 0 : programs.length,
          itemBuilder: (context, index) {
            final program = programs[index];

            String programDate = program['F_DATE'];
            String parseProgramDate = DateFormat('yyyy.MM.dd').format(DateTime.parse(programDate)).toString();

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
                          // : const Color.fromRGBO(228, 228, 228, 1),
                              :Colors.black.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox.fromSize(
                          child: Image.network(
                            // program['F_IMAGE'],
                            program['F_LOGO'],
                            width: 140,
                            height: 140,
                            errorBuilder: (context, stackTrace, error) {
                              return SizedBox(
                                  width: 140,
                                  height: 140,
                                  child: Image.asset('assets/no_image.png'));
                            },
                          ),
                        ),
                      )
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(children: [
                          Container(
                            margin: const EdgeInsets.only(right: 0),
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color.fromRGBO(51, 211, 180, 1)
                            ),
                            child: Text(
                              program['F_TYPE'],
                              style: const TextStyle(
                                  color: Colors.white,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ),
                          Container(
                              margin: const EdgeInsets.only(left: 10),
                              width: 65,
                              height: 22,
                              child: Text(program['CL_NM'],
                                  style: TextStyle(
                                      fontSize: 16,
                                      overflow: TextOverflow.ellipsis,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black)
                              )
                            // child: Image.network(
                            //   program['F_LOGO'],
                            //   width: 50,
                            //   height: 22,
                            //   errorBuilder: (context, error, stackTrace) {
                            //     return SizedBox(
                            //         width: 65,
                            //         height: 22,
                            //         child: Text(program['CL_NM'],
                            //             style: TextStyle(
                            //                 fontSize: 16,
                            //                 overflow: TextOverflow.ellipsis,
                            //                 fontWeight: FontWeight.bold,
                            //                 color: isDarkMode
                            //                     ? Colors.white
                            //                     : Colors.black)
                            //         )
                            //     );
                            //   },
                            // ),
                          )
                        ]),
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 3, 0, 10),
                          width: 135,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 3),
                                child: Text(program['F_NAME'],
                                    style: const TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                              ),
                              Text(parseProgramDate,
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.grey.withOpacity(0.8)
                                          : Colors.black.withOpacity(0.3))),
                            ],
                          ),
                        )
                      ])
                ],
              )
            ]);
          }),
    );
  }

  Future<bool> _onBackKey() async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return TabPage();
        });
  }

  void _onShare(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    if (Platform.isIOS) {
      await Share.share(
        // 'www.oneidlab.kr/app_check.html',
          'https://oneidlab.page.link/prizmios',
          subject: 'Prizm',
          sharePositionOrigin:
          Rect.fromLTRB(0, 0, MediaQuery.of(context).size.width, MediaQuery.of(context).size.height * 0.5)
      );
    } else if (Platform.isAndroid) {
      await Share.share('https://oneidlab.page.link/prizm', subject: 'Prizm');
    }
  }

  late String text;

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    text = '';

    try {
      int i = 1;
      dateList = [];
      for (i; i < 13; i++) {
        dateTime = DateTime(now.year, now.month - i, 1);
        date = DateFormat('MM').format(dateTime);
        year = DateFormat('yy').format(now);
// print(dateTime);

        dateList.add(date);
      }
    } catch (e) {
      print('bottom title : $e');
    }
    reversedDate = [];
    reversedDate = List.from(dateList.reversed);

    switch (value.toInt()) {
      case 1:
        text = reversedDate[0];
        break;
      case 2:
        text = reversedDate[1];
        break;
      case 3:
        text = reversedDate[2];
        break;
      case 4:
        text = reversedDate[3];
        break;
      case 5:
        text = reversedDate[4];
        break;
      case 6:
        text = reversedDate[5];
        break;
      case 7:
        text = reversedDate[6];
        break;
      case 8:
        text = reversedDate[7];
        break;
      case 9:
        text = reversedDate[8];
        break;
      case 10:
        text = reversedDate[9];
        break;
      case 11:
        text = reversedDate[10];
        break;
      default:
        text = reversedDate[11];
        break;
    }
    return SideTitleWidget(axisSide: meta.axisSide, child: Text(text));
  }

  Widget line_chart(song_cnts) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    List<FlSpot> FlSpotData = [];
    FlSpotData.addAll(FlSpotDataAll);
    final minCnt = listY.last >= 50;

    var result = LineChart(LineChartData(
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
                y: 0,
                color: isDarkMode
                    ? Colors.grey.withOpacity(0.6)
                    : Colors.grey.withOpacity(0.3)
            )
          ],
        ),
        baselineY: 0,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
            getDrawingHorizontalLine: (value) {
              return FlLine(
                  strokeWidth: 1,
                  color: isDarkMode
                      ? Colors.grey.withOpacity(0.6)
                      : Colors.grey.withOpacity(0.3)
              );
            },
            drawVerticalLine: false,
            drawHorizontalLine: true,
            horizontalInterval: minCnt ? avgY / 8 : 30
        ),
        minX: 1,
        minY: 0,
        maxX: 12,
        maxY: double.parse((listY.last).toString()) + 100,
        lineBarsData: [
          LineChartBarData(
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                        radius: 3.0,
                        color: const Color.fromRGBO(51, 211, 180, 1),
                        strokeColor:
                        isDarkMode ? Colors.white : Colors.grey.shade200,
                        strokeWidth: 5.0
                    ),
              ),
              color: const Color.fromRGBO(51, 211, 180, 1),
              isCurved: true,
              curveSmoothness: 0.1,
              barWidth: 3,
              isStrokeCapRound: true,
              isStrokeJoinRound: true,
              belowBarData: BarAreaData(
                show: true,
                gradient: isDarkMode
                    ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromRGBO(51, 215, 180, 1),
                      Colors.white12
                    ]
                )
                    : const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromRGBO(51, 215, 180, 1),
                      Colors.white24
                    ]
                ),
              ), spots: FlSpotData
          )
        ],
        titlesData: FlTitlesData(
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: bottomTitleWidgets
                )
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)
            )
        ),
        lineTouchData: LineTouchData(enabled: true)
    )
    );
    return result;
  }
}