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
  final String title;
  final String artist;

  const Watch_Result({Key? key, required this.id, required this.title,required this.artist}) : super(key: key);

  @override
  State<Watch_Result> createState() => _Watch_Result(title,artist);
}

class _Watch_Result extends State<Watch_Result> {
  late dynamic _background = const ColorFilter.mode(Colors.transparent, BlendMode.clear);
  late Future myFuture;
  var maps;
  List programs = [];
  List song_cnts = [];

  var image;
  var title;
  var artist;
  _Watch_Result(String title_, String artist_){
    title = title_;
    artist = artist_;
  }

  Future<String> fetchData() async {
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
          // Uri.parse('http://dev.przm.kr/przm_api/get_song_search/json?id=WA0632182001001&uid=d99df16f4105e7bd7'));
          Uri.parse('http://${MyApp.search}/json?id=${widget.id}&uid=$uid'));
      String jsonData = response.body;
      Map<String, dynamic> map = jsonDecode(jsonData);

      maps = map;
      setState(() {});
    } catch (e) {
      rethrow;
    }
    return 'done';
  }


  @override
  void initState() {
    myFuture = fetchData();
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
    final isArtistNull = artist == null; // Artist 의 정보가 없을경우
    // final isAlbumNull = maps['ALBUM'] == null; // Album 의 정보가 없을경우

    return WillPopScope(
      onWillPop: _onBackKey,
      child: FutureBuilder(
          future: myFuture,
          builder: (BuildContext context, AsyncSnapshot snapshot){
            if(snapshot.hasData == false){
              return Container(
                // height: double.infinity,
                //   width: double.infinity, //
                  color: const Color.fromRGBO(244, 245, 247, 1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        // margin: EdgeInsets.only(top: 30),
                        //   height: c_height,
                        // width: double.infn b inity,
                          padding: EdgeInsets.only(bottom: 40),
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('assets/BG_light.gif'),
                                  colorFilter: _background,
                                  // fit: BoxFit.fill,
                                  alignment: const Alignment(0 , 3)
                              )
                          ),
                          child: Center(
                              child: Column(
                                  children: <Widget>[
                                    IconButton(
                                        padding: EdgeInsets.only(top: 30),
                                        icon:Image.asset('assets/_prizm.png'),
                                        iconSize: 150,
                                        onPressed: () async {
                                        }
                                    ),
                                  ]
                              )
                          )
                      ),
                    ],
                  )
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
              return Container(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: Text(
                        title,
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
                        isArtistNull ? 'Various Artist' : artist,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          }
      ),
    );
  }
}
