import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'Home.dart';
import 'chart/chart_container.dart';
import 'main.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Watch_Result extends StatefulWidget {
  final String id;

  const Watch_Result({Key? key, required this.id}) : super(key: key);

  @override
  State<Watch_Result> createState() => _Watch_Result();
}

class _Watch_Result extends State<Watch_Result> {

  String url = 'https://oneidlab.page.link/prizm'; // url Default 값
  Future<void> remoteconfig() async {
    final FirebaseRemoteConfig remoteConfig =
        await FirebaseRemoteConfig.instance;
    remoteConfig.setDefaults({'shareUrl': url});
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: Duration.zero));
    await remoteConfig.fetchAndActivate();
    String shareUrl = remoteConfig.getString('shareUrl');
    url = shareUrl;
  }

  var maps;
  List programs = [];
  List song_cnts = [];

  void fetchData() async {
    if (!mounted) {
      return;
    }
    String? uid;
    var deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        uid = await PlatformDeviceId.getDeviceId;
      } else if (Platform.isIOS) {
        var iosInfo = await deviceInfoPlugin.iosInfo;
        uid = iosInfo.identifierForVendor!;
      }
    } on PlatformException {
      uid = 'Failed to get Id';
      rethrow;
    }

    try {
      http.Response response = await http.get(
          Uri.parse('http://dev.przm.kr/przm_api/get_song_search/json?id=WA0632182001001&uid=11B9E7C3-4BF1-465B-B522-6158756CC737'));
          // Uri.parse('http://${MyApp.search}/json?id=${widget.id}&uid=$uid'));
      String jsonData = response.body;
      Map<String, dynamic> map = jsonDecode(jsonData);

      maps = map;
      song_cnts = maps['song_cnts'];
      setState(() {});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logSetscreen() async {
    await MyApp.analytics.setCurrentScreen(screenName: '검색결과');
  }

  @override
  void initState() {
    remoteconfig();
    logSetscreen();
    fetchData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _onBackKey() async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return TabPage();
        });
  }

  @override
  Widget build(BuildContext context) {
    double c_height = MediaQuery.of(context).size.height; // 화면상의 전체 높이
    double c_width = MediaQuery.of(context).size.width; // 화면상의 전치 너비
    final isArtistNull = maps['ARTIST'] == null; // Artist 의 정보가 없을경우
    // final isAlbumNull = maps['ALBUM'] == null; // Album 의 정보가 없을경우

    return WillPopScope(
      onWillPop: _onBackKey,
      child: Stack(children: [
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
          decoration: BoxDecoration(
              gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black],
                  stops: [.50, .75])),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                child: Text(
                  '${maps['TITLE']}',
                  style: TextStyle(
                    color: Colors.lightBlueAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Text(
                  isArtistNull ? 'Various Artist' : maps['ARTIST'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
