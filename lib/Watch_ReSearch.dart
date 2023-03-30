import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
      decoration: BoxDecoration(
          gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black],
              stops: [.50, .75])),
      child: Center(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  child: Image.asset(
                    'assets/splash_image/_splash_logo.png', width: 30,),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    '다시 검색하기',
                    style: TextStyle(
                      color: Colors.lightBlueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
