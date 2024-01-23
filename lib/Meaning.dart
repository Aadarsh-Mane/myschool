import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myschool/Dictionary.dart';
import 'package:shimmer/shimmer.dart';

class MeaningScreen1 extends StatefulWidget {
  @override
  _MeaningScreen1State createState() => _MeaningScreen1State();
}

class _MeaningScreen1State extends State<MeaningScreen1> {
  Future<List<Map<String, String>>> fetchData() async {
    final response =
        await http.get(Uri.parse("https://meaning-api.onrender.com/news"));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<Map<String, String>> meanings = [];

      for (var item in data) {
        if (item is Map<String, dynamic>) {
          meanings.add({
            'word': item['word'] ?? '',
            'meaning': item['meaning'] ?? '',
          });
        }
      }

      return meanings;
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Word Meanings'),
          backgroundColor: Colors.blue,
          actions: [
            IconButton(
              icon: Icon(Icons.navigate_next),
              onPressed: () {
                // Navigate to the desired screen here
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MeaningScreen()),
                );
              },
            )
          ]),
      body: FutureBuilder(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: _buildShimmerListView(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            List<Map<String, String>> meanings =
                snapshot.data as List<Map<String, String>>;

            return ListView.builder(
              itemCount: meanings.length,
              itemBuilder: (context, index) {
                return _buildMeaningCard(meanings[index]['word'] ?? '',
                    meanings[index]['meaning'] ?? '');
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildShimmerListView() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5, // Number of shimmer items
        itemBuilder: (context, index) {
          return _buildShimmerCard();
        },
      ),
    );
  }

  Widget _buildMeaningCard(String word, String meaning) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Word: $word',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Meaning: $meaning',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 120,
              height: 20,
              color: Colors.white,
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 16,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
