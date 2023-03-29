// ignore_for_file: avoid_print, prefer_const_constructors, curly_braces_in_flow_control_structures, avoid_single_cascade_in_expression_statements, slash_for_doc_comments
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'History_Bottom.dart';
import 'Home.dart';
import 'PlayInfo.dart';
import 'Settings.dart';
import 'main.dart';
import 'package:korea_regexp/korea_regexp.dart';

/*
 * 모든 리스트들은 Widget 으로 밖에서 생성하여 따로 관리
 * 변경에 용이하고 관리가 간편함
 */
class History extends StatefulWidget {
  const History({super.key});

  @override
  _History createState() => _History();
}

class _History extends State<History> {
  Future<void> logSetscreen() async {
    await MyApp.analytics.setCurrentScreen(screenName: 'History');
  }

  TextEditingController txtQuery = TextEditingController();

  String? _deviceId;
  String? uid;
  late Timer timer = Timer(Duration(seconds: 2), () { // 2초동안 데이터 받아오고 없으면 검색기록 없다는 메세지로 넘김
    if(!mounted) return;
    setState(() {});
  });

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
      uid = _deviceId;
    });
  }

  static RegExp basicReg = (RegExp(r'[ㄱ-ㅎ|ㅏ-ㅣ|가-힣|ᆞ|ᆢ|ㆍ|ᆢ|ᄀᆞ|ᄂᆞ|ᄃᆞ|ᄅᆞ|ᄆᆞ|ᄇᆞ|ᄉᆞ|ᄋᆞ|ᄌᆞ|ᄎᆞ|ᄏᆞ|ᄐᆞ|ᄑᆞ|ᄒᆞ|a-z|A-Z|0-9|\s|~!@#$%^&*()_+=:`,./><?{}*\-]'));
  List song_info = [];
  List original = [];
  List info = [];
  String _songid = '';

  fetchData() async {
    _deviceId = await PlatformDeviceId.getDeviceId;

    try {
      http.Response response = await http.get(Uri.parse('http://${MyApp.history}/json?uid=$uid'));
      String jsonData = response.body;
      song_info = jsonDecode(jsonData.toString());
      original = song_info;
      setState(() {});
    } catch (e) {
      NetworkToast();
      rethrow;
    }
  }

  void search(String query) {
    if (query.isEmpty) {  // 검색창이 비었을시 전체 history 데이터
      song_info = original;
      setState(() {});
      return;
    } else {
      song_info = original;
      setState(() {});
    }

    query = query.toLowerCase();
    List result = [];
    for (var p in song_info) {
      var title = p['TITLE'].toString().replaceAll(RegExp('\\s'), '').toLowerCase();  // 공백제거
      var title1 = p['TITLE'].toString().toLowerCase();
      var artist = p["ARTIST"].toString().replaceAll(RegExp('\\s'),'').toLowerCase();
      var artist1 = p['ARTIST'].toString().toLowerCase();
      var album = p['ALBUM'].toString().replaceAll(RegExp('\\s'), '').toLowerCase();
      var album1 = p['ALBUM'].toString().toLowerCase();

      var options = RegExpOptions(initialSearch: true);   // 초성검색

      /**
       * 초성검색 옵션 추가 완료. 테스트 더 필요하기때문에 원래코드 주석
       * 검색 중 공백 제거 완료
       *
       * 공백이 있을때와 없을때를 둘다 잡기 위해 toString 만 한 것과 replaceAll 둘다 변수로 선언
       * artist, album 이 null 일때 various artist, album 으로 변경
       */
      
      
      if (p['ARTIST'] == null) {  // UI상 Various Artists 로 나오지만 데이터는 null 이므로 null 을 Various Artists 로 변경
        artist = p['ARTIST'].toString().replaceAll(RegExp('null'), 'Various Artists').replaceAll(RegExp('\\s'), '').toLowerCase();
        artist1 = p['ARTIST'].toString().replaceAll(RegExp('null'), 'Various Artists').toLowerCase();
      }
      if(p['ALBUM'] == null) {
        album = p['ALBUM'].toString().replaceAll(RegExp('null'), 'Various Album').replaceAll(RegExp('\\s'), '').toLowerCase();
        album1 = p['ALBUM'].toString().replaceAll(RegExp('null'), 'Various Album').toLowerCase();
      }


      if(title.contains(getRegExp(query, options))) {
        result.add(p);
      } else if(title1.contains(getRegExp(query, options))) {
        result.add(p);
      } else if(artist.contains(getRegExp(query, options))) {
        result.add(p);
      } else if(artist1.contains(getRegExp(query, options))) {
        result.add(p);
      } else if (album.contains(getRegExp(query, options))) {
        result.add(p);
      } else if (album1.contains(getRegExp(query, options))) {
        result.add(p);
      }
    }

    song_info = result;
    setState(() {});
  }

  final duplicateItems = List<String>.generate(10000, (i) => "Item $i");

  var items = <String>[];

  _printLatestValue() {
    List<String> SearchList = <String>[];
    SearchList.addAll(duplicateItems);
  }

  @override
  void initState() {
    logSetscreen();
    items.addAll(duplicateItems);
    txtQuery.addListener(_printLatestValue);
    initPlatformState();
    fetchData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void filterSearchResults(String query) {
    List<String> SearchList = <String>[];
    SearchList.addAll(duplicateItems);
    if(!mounted) {
      return;
    }
    if (query.isNotEmpty) {
      List<String> ListData = <String>[];
      //SearchList.forEach((item) {
      for (var item in SearchList) {
        if (item.contains(query)) {
          ListData.add(item);
        }
      }
      setState(() {
        items.clear();
        items.addAll(ListData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(duplicateItems);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    int len = song_info.length;
    final isExist = len == 0;
    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    return WillPopScope(
        onWillPop: () async {
          return _onBackKey();
        },
        child: Scaffold(
            appBar: AppBar(
              shape: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.3))),
              title: Text('히스토리',
                style: (isDarkMode
                    ? const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                    : const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
                ),
              ),
              centerTitle: true,
              backgroundColor: isDarkMode ? Colors.black : Colors.white,
              toolbarHeight: 70,
              elevation: 0.0,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: ImageIcon(Image.asset('assets/settings.png').image),
                  color: isDarkMode ? Colors.white : Colors.black,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Settings()));
                  },
                )
              ],
            ),
            body: Container(
              color: isDarkMode ? Colors.black : Colors.white,
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
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Row(
                              children: [
                                const Text('발견한 노래 ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20
                                    )
                                ),
                                Text(' $len',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20
                                    )
                                ),
                                const Text(' 곡',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20
                                    )
                                ),
                              ],
                            )
                        ),
                        TextField(
                            controller: txtQuery,
                            inputFormatters: [FilteringTextInputFormatter.allow(basicReg)],
                            onChanged: search,
                            textInputAction: TextInputAction.search, // 키보드에 검색 아이콘 추가
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(vertical: 20),
                                labelText: '곡/가수/앨범명으로 검색해주세요',
                                labelStyle: TextStyle(
                                    color: isDarkMode ? Colors.grey.withOpacity(0.8) : Colors.black.withOpacity(0.2),
                                    fontSize: 15
                                ),
                                enabledBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                    borderSide: BorderSide(color: Colors.greenAccent)),
                                focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.greenAccent)),
                                prefixIcon: const Icon(Icons.search, color: Colors.greenAccent),
                                suffixIcon: txtQuery.text.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(Icons.clear, // TextField 입력시 우측끝에 X 아이콘 생성
                                            color: isDarkMode ? Colors.grey.withOpacity(0.8) : Colors.black.withOpacity(0.2)
                                        ),
                                        onPressed: () async {
                                          txtQuery.text = '';
                                          search(txtQuery.text);
                                        },
                                      )
                                    : null
                            )
                        ),
                      ],
                    ),
                  ),
                  isExist ? loading() : _listView(song_info)
                ],
              ),
            )
        )
    );
  }

  Future<bool> _onBackKey() async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return TabPage();
        });
  }

  loading() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if(timer.isActive) {  // Timer 가 활성화 상태일때  gif 호출
      return Column(  // 리스트가 있다면 listview 로 알아서 넘어감
        children: [
          Container(
                margin: const EdgeInsets.only(bottom: 30, top: 100),
                child: Center(
                  child: Image.asset('assets/loading.gif',
                    width: 40,
                    color: isDarkMode ? Colors.white : Colors.black
                  ),
                ),
              ),
          Center(
            child: Text(
              '검색 내역을 불러오고 있습니다.',
              style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22
              ),
            ),
          ),
        ],
      );
    } else {  // 위에 설정한 2초 뒤 리스트가 없다면 else 컨테이너 return
      return Container(
          margin: EdgeInsets.only(top: 170),
          child: Center(
            child: Text('최근 검색 기록이 없습니다.',
              style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22
              ),
            ),
          )
      );
    }
  }

  Widget _listView(song_info) {
    return Expanded(
        child: ListView.builder(
            itemCount: song_info == null ? 0 : song_info.length,  // 출력할 리스트의 갯수 null 이 아닐경우 데이터의 길이만큼 출력
            itemBuilder: (context, index) {
              double c_width = MediaQuery.of(context).size.width;
              final info = song_info[index];
              final isDarkMode = Theme.of(context).brightness == Brightness.dark;
              final isArtistNull = info['ARTIST'] == null;
              final isAlbumNull = info['ALBUM'] == null;

              return GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (BuildContext context) {
                        final deviceId = _deviceId;
                        return SizedBox(  // 곡 상세정보 BottomModal
                            width: c_width,
                            height: 300,
                            child: ListView.builder(
                                itemCount: 1,
                                itemBuilder: (context, index) {
                                  String Id = deviceId!;
                                  String title = info['TITLE'];
                                  String image = info['IMAGE'];
                                  String artist = isArtistNull ? 'Various Artists' : info['ARTIST'];  // Artist 정보가 없을경우 Null 로 찍히기때문에 Various Artist 로 변환
                                  String song_id = info['SONG_ID'];
                                  _songid = song_id;
                                  double c_width = MediaQuery.of(context).size.width;
                                  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
                                  return Container(
                                    width: c_width,
                                    padding: const EdgeInsets.only(top: 14),
                                    decoration: BoxDecoration(
                                        color: isDarkMode ? const Color.fromRGBO(36, 36, 36, 1) : const Color.fromRGBO(250, 250, 250, 2),
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
                                            color: isDarkMode ? const Color.fromRGBO(36, 36, 36, 1) : const Color.fromRGBO(250, 250, 250, 2),
                                            child: Row(
                                              children: [
                                                Container(
                                                    margin: EdgeInsets.only(left: 10, bottom: 10),
                                                    padding: EdgeInsets.all(1),
                                                    decoration: BoxDecoration(
                                                      color: isDarkMode ? const Color.fromRGBO(189, 189, 189, 1) : Colors.black.withOpacity(0.3),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(8),
                                                        child: SizedBox.fromSize(
                                                          child: Image.network(info['IMAGE'],
                                                            width: 90,
                                                            height: 90,
                                                            errorBuilder: (context, error, stackTrace) {
                                                              return SizedBox(
                                                                width: 90,
                                                                height: 90,
                                                                child: Image.asset('assets/no_image.png')
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
                                                        width: c_width * 0.55,
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Padding(
                                                                padding: const EdgeInsets.only(left: 15),
                                                                child: RichText(
                                                                    overflow: TextOverflow.ellipsis,
                                                                    maxLines: 2,
                                                                    strutStyle: const StrutStyle(fontSize: 18),
                                                                    text: TextSpan(text: info['TITLE'],
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight.bold,
                                                                            fontSize: 18,
                                                                            color: isDarkMode ? Colors.white : Colors.black
                                                                        )
                                                                    )
                                                                )
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 20, top: 10),
                                                              child: Text(
                                                                  isArtistNull ? 'Various Artists' : info['ARTIST'],
                                                                  style: TextStyle(
                                                                      color: isDarkMode ? Colors.grey.withOpacity(0.8) : Colors.black.withOpacity(0.4)
                                                                  ),
                                                                  overflow: TextOverflow.ellipsis
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
                                                              Navigator.pop(context);
                                                            }),
                                                      )
                                                    ])
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            color: isDarkMode ? Colors.black : Colors.white,
                                            height: 156,
                                            padding: const EdgeInsets.all(20),
                                            child: Column(
                                              children: [
                                                GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  PlayInfo(deviceId: Id, title: title, image: image, artist: artist, song_id: song_id)
                                                          )
                                                      );
                                                    },
                                                    child: Column(children: [
                                                      Container(
                                                          color: isDarkMode ? Colors.black : Colors.white,
                                                          child: Row(
                                                            children: [
                                                              IconButton(
                                                                padding:
                                                                    const EdgeInsets.only(right: 20),
                                                                icon: ImageIcon(Image.asset('assets/list.png').image, size: 30),
                                                                color: const Color.fromRGBO(64, 220, 196, 1),
                                                                onPressed: () {
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
                                                                      fontWeight: FontWeight.w300,
                                                                      color: isDarkMode ? Colors.white : Colors.black
                                                                  )
                                                              )
                                                            ]
                                                          )
                                                      )
                                                    ])
                                                ),
                                                GestureDetector(
                                                    onTap: () {
                                                      showDialogPop();
                                                    },
                                                    child: Container(
                                                      color: isDarkMode ? Colors.black : Colors.white,
                                                      padding:
                                                          const EdgeInsets.only(top: 20),
                                                      child: Row(
                                                        children: [
                                                          IconButton(
                                                              padding: const EdgeInsets.only(right: 30),
                                                              icon: ImageIcon(Image.asset('assets/trash.png').image, size: 40),
                                                              color: const Color.fromRGBO(64, 220, 196, 1),
                                                              onPressed: () {
                                                                showDialogPop();
                                                              }),
                                                          Text(
                                                            '히스토리에서 삭제',
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight: FontWeight.w300,
                                                                color: isDarkMode ? Colors.white : Colors.black
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                )
                                              ],
                                            ),
                                          )
                                        ]
                                    ),
                                  );
                                })
                        );
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
                        padding: EdgeInsets.all(1),
                        margin: EdgeInsets.only(right: 10, left: 20),
                        height: 100,
                        decoration: BoxDecoration(
                            color: isDarkMode ? const Color.fromRGBO(189, 189, 189, 1) : Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8)
                        ),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox.fromSize(
                              size: Size.fromRadius(48),
                              child: Image.network(info['IMAGE'],
                                errorBuilder: (context, error, stackTrace) {
                                  return SizedBox(
                                    child: Image.asset('assets/no_image.png'),
                                  );
                                },
                              ),
                            )
                        ),
                      ),
                      Flexible(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: c_width * 0.54,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(info['TITLE'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(
                                      child: Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                    child: isArtistNull
                                        ? Text('Various Artists',
                                            style: TextStyle(color: isDarkMode ? Colors.grey.withOpacity(0.8) : Colors.black.withOpacity(0.4))
                                        )
                                        : Text(info['ARTIST'],
                                            style: TextStyle(color: isDarkMode ? Colors.grey.withOpacity(0.8) : Colors.black.withOpacity(0.4)),
                                            overflow: TextOverflow.ellipsis
                                        ),
                                      )
                                  ),
                                  isAlbumNull
                                      ? Text('Various Album',
                                          style: TextStyle(
                                              color: isDarkMode ? Colors.grey.withOpacity(0.8) : Colors.black.withOpacity(0.4),
                                              overflow: TextOverflow.ellipsis
                                          ),
                                        )
                                      : Text(
                                          info['ALBUM'],
                                          style: TextStyle(
                                              color: isDarkMode ? Colors.grey.withOpacity(0.8) : Colors.black.withOpacity(0.4),
                                              overflow: TextOverflow.ellipsis
                                          ),
                                        ),
                                  Text(
                                    info['SCH_DATE'],
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.greenAccent.withOpacity(0.8) : Colors.greenAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                                margin: EdgeInsets.only(right: 5),
                                width: c_width * 0.09,
                                child: const Icon(
                                    Icons.more_vert_sharp,
                                    color: Colors.grey,
                                    size: 30
                                )
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            })
    );
  }

  void showDialogPop() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    double c_width = MediaQuery.of(context).size.width;
    double c_height = MediaQuery.of(context).size.height;
    showDialog(
      context: context,
      barrierDismissible: false, //다이얼로그 바깥을 터치 시에 닫히도록 하는지 여부 (true: 닫힘, false: 닫히지않음)
      builder: (BuildContext context) {
        return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Container(
              width: c_width * 0.8,
              height: c_height * 0.18,
              margin: const EdgeInsets.only(top: 20, bottom: 20),
              color: isDarkMode ? const Color.fromRGBO(66, 66, 66, 1) : Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: c_height * 0.115,
                    child: Center(
                      child: Text('이 항목을 삭제하시겠습니까?',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                      ),
                    ),
                  ),
                  Container(
                      decoration: BoxDecoration(
                          border: Border(
                              top: BorderSide(
                                  color: isDarkMode ? const Color.fromRGBO(94, 94, 94, 1) : Colors.black.withOpacity(0.1)
                              )
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
                                            color: isDarkMode ? const Color.fromRGBO(94, 94, 94, 1) : Colors.black.withOpacity(0.1)
                                        )
                                    )
                                ),
                                margin: const EdgeInsets.only(left: 20),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('취소',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: isDarkMode ? Color.fromRGBO(151, 151, 151, 1) : Colors.black.withOpacity(0.3),
                                    ),
                                  ),
                                )
                            ),
                          ),
                          Container(
                            width: c_width * 0.345,
                            height: c_height * 0.08,
                            margin: const EdgeInsets.only(right: 20),
                            color: isDarkMode ? const Color.fromRGBO(66, 66, 66, 1) : Colors.white,
                            child: TextButton(
                              onPressed: () async {
                                /**
                                 * url 뒤에 uid 값과 songId 값을 보내 해당 곡만 삭제처리
                                 * proc=del 을 같이 보내야 삭제 없을시 history 내역 json
                                 */
                                Response response = await http.get(Uri.parse('http://${MyApp.history}/json?uid=$uid&id=$_songid&proc=del'));
                                if (response.statusCode == 200) {
                                  showToast();
                                } else {
                                  failToast();
                                  throw "failed to delete history";
                                }
                                if(!mounted){
                                  return;
                                }
                                setState(() {
                                  /**
                                   * main 의 ConvexBottomBar 와 같은 화면이지만 selectedIndex 만 0번인 화면
                                   * 삭제 후 push 를 하지 않으면 history 리스트 refresh 가 되지 않고
                                   * History 로 push 를 하면 BottomBar 가 표시되지 않음
                                   * 삭제 후 삭제 된 새로운 리스트를 가져오기 위해 Bottom 으로 push
                                   */
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Bottom()));
                                });
                              },
                              child: const Text('삭제',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Color.fromRGBO(64, 220, 196, 1)
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                  )
                ],
              ),
            )
        );
      },
    );
  }
}

void showToast() {
  Fluttertoast.showToast(
      msg: '검색내역 삭제 완료',
      backgroundColor: Colors.grey,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER
  );
}

void failToast() {
  Fluttertoast.showToast(
      msg: '검색내역 삭제 실패',
      backgroundColor: Colors.grey,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER
  );
}
void imsiToast() {
  Fluttertoast.showToast(
      msg: '임시파일 삭제 완료',
      backgroundColor: Colors.grey,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER
  );
}

void imsiFailToast() {
  Fluttertoast.showToast(
      msg: '임시파일 삭제 실패',
      backgroundColor: Colors.grey,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER
  );
}
