import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const TabPage()));
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 25),
                child: Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 10),
                          child: Image.asset(
                              'assets/splash_image/_splash_logo.png',
                              width: 20),
                        ),
                        const Text(
                          '다시 검색하기',
                          style: TextStyle(
                            color: Colors.lightBlueAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
