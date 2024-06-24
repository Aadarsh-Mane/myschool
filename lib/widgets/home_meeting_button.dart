import 'package:flutter/material.dart';

class HomeMeetingButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String text;
  const HomeMeetingButton(
      {super.key,
      required this.onPressed,
      required this.icon,
      required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(children: [
        Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                  // blurRadius: 10,
                  // color: Colors.black,
                  offset: Offset(0, 4))
            ]),
            width: 60,
            height: 60,
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
            )),
        const SizedBox(
          height: 10,
        ),
        Text(text, style: const TextStyle(color: Colors.grey))
      ]),
    );
  }
}
