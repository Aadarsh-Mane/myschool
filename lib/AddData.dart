import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddData extends StatefulWidget {
  const AddData({super.key});

  @override
  State<AddData> createState() => _AddDataState();
}

class _AddDataState extends State<AddData> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  AddData(String title, String desc) async {
    if (title == "" && desc == "") {
      log("cede" as num);
    } else {
      FirebaseFirestore.instance
          .collection("User")
          .doc(title)
          .set({"Title": title, "Desc": desc}).then(
              (value) => log("data inseted" as num));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("aDD DTA"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: TextField(
              controller: titleController,
              decoration: InputDecoration(hintText: "Enter a title"),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: TextField(
              controller: descController,
              decoration: InputDecoration(hintText: "Enter a desc"),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          ElevatedButton(
              onPressed: () {
                AddData(titleController.text.toString(),
                    descController.text.toString());
              },
              child: Text("save data"))
        ],
      ),
    );
  }
}
