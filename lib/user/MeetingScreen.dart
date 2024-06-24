import 'package:flutter/material.dart';
import 'package:myschool/widgets/home_meeting_button.dart';

class MeetingScreen extends StatefulWidget {
  const MeetingScreen({super.key});

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  int _page = 0;
  onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('meet & chat'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 102, 79, 77),
      ),
      body: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            HomeMeetingButton(
              onPressed: () {},
              icon: Icons.videocam,
              text: 'Mew Meeting',
            ),
            HomeMeetingButton(
              onPressed: () {},
              icon: Icons.add_box_rounded,
              text: 'Join Meeting',
            ),
            HomeMeetingButton(
              onPressed: () {},
              icon: Icons.calendar_today,
              text: 'Mew Meeting',
            ),
            HomeMeetingButton(
              onPressed: () {},
              icon: Icons.arrow_upward_rounded,
              text: 'Mew Meeting',
            ),
          ],
        ),
        Expanded(child: Text('Creat or join meeting'))
      ]),
      bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Color.fromARGB(255, 88, 173, 210),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.black,
          onTap: onPageChanged,
          currentIndex: _page,
          unselectedFontSize: 14,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.comment_bank), label: 'meet & char'),
            BottomNavigationBarItem(
                icon: Icon(Icons.lock_clock), label: 'meeting'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outlined), label: 'meet & char'),
            BottomNavigationBarItem(
                icon: Icon(Icons.comment_bank), label: 'meet & char'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined), label: 'meet & char'),
          ]),
    );
  }
}
