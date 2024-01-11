import 'package:flutter/material.dart';
import 'package:myschool/pages/home_page.dart';
import 'package:myschool/pages/time_table_page.dart';

class ButtonPage extends StatelessWidget {
  const ButtonPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Button Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomePage()));
              },
              child: const Text('Announments'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Action for the second button
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TimetablePage()));
              },
              child: const Text('Time Table'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Action for the third button
              },
              child: const Text('Events '),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Action for the fourth button
              },
              child: const Text('Notice'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Action for the fifth button
              },
              child: const Text(''),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Action for the sixth button
              },
              child: const Text('Button 6'),
            ),
          ],
        ),
      ),
    );
  }
}
