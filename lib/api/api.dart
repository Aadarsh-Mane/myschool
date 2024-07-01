import 'dart:convert';

import 'package:myschool/models/ResponseModel.dart';
import 'package:http/http.dart' as http;

class API {
  static const baseUrl = "https://api.dictionaryapi.dev/api/v2/entries/en/";

  static Future<ResponseModel> fetchMeaning(String word) async {
    final response = await http.get(Uri.parse("$baseUrl$word"));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ResponseModel.fromJson(data[0]);
    } else {
      throw new Exception("Invalid response");
    }
  }
}
