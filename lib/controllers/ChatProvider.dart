import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatProvider with ChangeNotifier {
  List<BardModel> _historyList = [
    BardModel(system: "user", message: "What can you do for me?"),
    BardModel(
        system: "bard",
        message: "I can help you with various tasks and answer questions."),
  ];
  List<BardModel> get historyList => _historyList;

  bool _isTyping = false;
  bool get isTyping => _isTyping;

  final String _apiKey =
      'AIzaSyDkJjdP4M_w7kTIaLHFyMuM8SuWZhnuuuc'; // Replace with your actual API key

  ChatProvider() {
    _scheduleCleanup();
  }

  void sendPrompt(String prompt) async {
    var newHistory = BardModel(system: "user", message: prompt);
    _historyList.add(newHistory);
    _cleanUpOldMessages(); // Clean up old messages
    notifyListeners();

    _isTyping = true;
    notifyListeners();

    final body = {
      'prompt': {
        'text': prompt,
      },
    };

    try {
      final request = await http.post(
        Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta2/models/text-bison-001:generateText?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      final response = jsonDecode(request.body);
      final bardReplay = response["candidates"][0]["output"];
      var newHistory2 = BardModel(system: "bard", message: bardReplay);
      _historyList.add(newHistory2);
      _cleanUpOldMessages(); // Clean up old messages
      notifyListeners();
    } catch (error) {
      _historyList.add(
          BardModel(system: "bard", message: "Error: Could not get response."));
      _cleanUpOldMessages(); // Clean up old messages
      notifyListeners();
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  void _cleanUpOldMessages() {
    DateTime now = DateTime.now();
    _historyList = _historyList.where((message) {
      return now.difference(message.timestamp).inHours < 24;
    }).toList();
  }

  void _scheduleCleanup() {
    Timer.periodic(Duration(hours: 1), (timer) {
      _cleanUpOldMessages();
      notifyListeners();
    });
  }
}

class BardModel {
  String? system;
  String? message;
  DateTime timestamp; // Add a timestamp field

  BardModel({this.system, this.message, DateTime? timestamp})
      : timestamp = timestamp ?? DateTime.now(); // Initialize timestamp

  BardModel.fromJson(Map<String, dynamic> json)
      : system = json["system"] as String?,
        message = json["message"] as String?,
        timestamp = DateTime.parse(json["timestamp"] as String);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["system"] = system;
    data["message"] = message;
    data["timestamp"] =
        timestamp.toIso8601String(); // Convert timestamp to string
    return data;
  }
}
