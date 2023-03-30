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
      child: Center(
        child: Stack(
          children: [
            Opacity(
              opacity: 0.3,
              child: Container(
                color: Colors.black,
              ),

            )
          ],
        ),
      ),
    );
  }
}
