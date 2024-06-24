import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ShareMe extends StatelessWidget {
  const ShareMe({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("SharePlus Package"),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: NetworkImage(
                        "https://images.unsplash.com/photo-1619980296991-5c0d64b23950?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=687&q=80"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  const url = "https://www.youtube.com/watch?v=PLP_WiB7QgA";
                  await Share.share('Checkout Flutter Tutorial $url');
                },
                child: const Text("Share Text"),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  const urlImage =
                      "https://images.unsplash.com/photo-1619980296991-5c0d64b23950?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=687&q=80";
                  final url = Uri.parse(urlImage);
                  final response = await http.get(url);
                  final bytes = response.bodyBytes;

                  final temp = await getTemporaryDirectory();
                  final path = "${temp.path}/image.jpg";
                  File(path).writeAsBytesSync(bytes);
                  await Share.shareXFiles([XFile(path)],
                      text: "Picture of Beautiful Puppy");
                },
                child: const Text("Share Image"),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  final image = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (image == null) return;

                  await Share.shareXFiles([XFile(image.path)]);
                },
                child: const Text("Pick From Gallery"),
              )
            ],
          ),
        ),
      );
}
