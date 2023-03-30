import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class Watch_ReSurch extends StatefulWidget {
  const Watch_ReSurch({Key? key}) : super(key: key);

  @override
  State<Watch_ReSurch> createState() => _Watch_ReSurchState();
}

class _Watch_ReSurchState extends State<Watch_ReSurch> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black],
              stops: [.50, .75])),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: Image.asset(
                    'assets/splash_image/_splash_logo.png', width: 20),
                ),
                TextButton(
                    child:  const Text(
                      '다시 검색하기',
                      style: TextStyle(
                        color: Colors.lightBlueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const TabPage()));
                })
                //
                //
                //
                //
                //
                //
                //
                //
              ],
            ),
          ],
        ),
      ),
    );
  }
}
