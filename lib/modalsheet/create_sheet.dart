import 'package:flutter/material.dart';
import 'package:myschool/api/sheets/user_sheet_api.dart';
import 'package:myschool/modalsheet/button_widget.dart';
import 'package:myschool/modalsheet/user.dart';

class CreatSheetPage extends StatelessWidget {
  const CreatSheetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(32),
        child: ButtonWidget(
          text: 'save',
          onClicked: () async {
            final user = User(
              rollno: 1,
              name: 'paul',
              email: 'ona@gmail.com',
              isBeginner: true,
            );
            await UserSheetsApi.insert([user.toJson()]);
          },
        ),
      ),
    );
  }
}
