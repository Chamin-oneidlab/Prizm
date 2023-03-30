import 'package:flutter/material.dart';

import 'Home.dart';
import 'Watch_Search_Result.dart';

class Watch_Result_Swipe extends StatefulWidget {
  final String id;

  const Watch_Result_Swipe({Key? key,required this.id}) : super(key: key);

  @override
  State<Watch_Result_Swipe> createState() => _Watch_Result_SwipeState();
}

class _Watch_Result_SwipeState extends State<Watch_Result_Swipe> {
  int _selectedIndex = 0; // 처음에 나올 화면 지정
  final List _pages = [const Watch_Result(id: Widget.id), Home()];

  PageController pageController = PageController(
    initialPage: 1,
  );


  Widget buildPageView() {
    return PageView(
      controller: pageController,
      children: <Widget>[_pages[0], _pages[1]],
    );
  }

  void pageChanged(int index) {
    if(!mounted) {
      return;
    }
    setState(() {
      _selectedIndex = index;
      pageController.animateToPage(index, duration: const Duration(milliseconds: 500), curve: Curves.ease);
      pageController.jumpToPage(_selectedIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: buildPageView(),
    );
  }
}
