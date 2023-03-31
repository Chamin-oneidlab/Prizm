import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:platform_device_id/platform_device_id.dart';
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

  var maps;
  List programs = [];

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
      http.Response response = await http.get(
          Uri.parse('http://dev.przm.kr/przm_api/get_song_search/json?id=WA0632182001001&uid=d99df16f4105e7bd7'));
          // Uri.parse('http://${MyApp.search}/json?id=${widget.id}&uid=$uid'));
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
    final isArtistNull = maps['ARTIST'] == null; // Artist 의 정보가 없을경우
    // final isAlbumNull = maps['ALBUM'] == null; // Album 의 정보가 없을경우

    return WillPopScope(
      onWillPop: _onBackKey,
      child: Stack(children: [
        Container(
          alignment: Alignment.bottomCenter,
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
