import 'dart:ffi';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:myschool/Consta.dart';
import 'package:myschool/controllers/ChatProvider.dart';
import 'package:myschool/views/user/YoutubeWatchScreen.dart';
import 'package:provider/provider.dart';

class MyMyMyChatScreen extends StatefulWidget {
  const MyMyMyChatScreen({super.key});

  @override
  State<MyMyMyChatScreen> createState() => _MyMyMyChatScreenState();
}

class _MyMyMyChatScreenState extends State<MyMyMyChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // backgroundColor: Color(0xFFF5EEE6),

      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            child: TweenAnimationBuilder(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 1500),
                child: MyChatScreen(),
                builder: (context, value, child) {
                  return ShaderMask(
                    shaderCallback: (bounds) {
                      return RadialGradient(
                              radius: value * 5,
                              colors: [
                                Colors.white,
                                Colors.white,
                                Colors.transparent,
                                Colors.transparent
                              ],
                              stops: [0.0, 0.55, 0.6, 1.0],
                              center: FractionalOffset(0.95, 0.90))
                          .createShader(bounds);
                    },
                    child: child,
                  );
                }),
          );
        },
      ),
    );
  }
}

// class UserMyMyChatScreen extends StatefulWidget {
//   const UserMyMyChatScreen({Key? key}) : super(key: key);

//   @override
//   State<UserMyMyChatScreen> createState() => _UserMyMyChatScreenState();
// }

// class _UserMyMyChatScreenState extends State<UserMyMyChatScreen> {
//   final ChatUser _currentUser =
//       ChatUser(id: '1', firstName: "addy", lastName: "mane");

//   final _openAI = OpenAI.instance.build(
//     token: API_KEY,
//     baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 15)),
//     enableLog: true,
//   );
//   final ChatUser _gpttUser =
//       ChatUser(id: '2', firstName: "chat", lastName: "gpt");

//   List<ChatMessage> _messages = <ChatMessage>[];
//   List<ChatUser> _typingUser = <ChatUser>[];
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         FocusScope.of(context).requestFocus(FocusNode());
//       },
//       child: Scaffold(
//         // backgroundColor: Colors.,
//         backgroundColor: Color(0xFFF5EEE6),

//         body: DashChat(
//           currentUser: _currentUser,
//           typingUsers: _typingUser,
//           messageOptions: const MessageOptions(
//               currentUserContainerColor: Colors.red,
//               containerColor: Color.fromARGB(0, 166, 126, 1),
//               textColor: Colors.green),
//           onSend: (ChatMessage m) {
//             getChatResponse(m);
//           },
//           messages: _messages,
//         ),
//       ),
//     );
//   }

//   Future<void> getChatResponse(ChatMessage m) async {
//     setState(() {
//       _messages.insert(0, m);
//       _typingUser.add(_gpttUser);
//     });
//     List<Messages> _messagesHistory = _messages.reversed.map((m) {
//       if (m.user == _currentUser) {
//         return Messages(role: Role.user, content: m.text);
//       } else {
//         return Messages(role: Role.assistant, content: m.text);
//       }
//     }).toList();
//     final request = ChatCompleteText(
//         model: GptTurbo0301ChatModel(),
//         messages: _messagesHistory,
//         maxToken: 100);
//     final response = await _openAI.onChatCompletion(request: request);
//     for (var element in response!.choices) {
//       if (element.message != null) {
//         setState(() {
//           _messages.insert(
//               0,
//               ChatMessage(
//                   user: _gpttUser,
//                   createdAt: DateTime.now(),
//                   // text: "Test Message",
//                   // ));
//                   text: element.message!.content));
//         });
//       }
//     }
//     print("Updated Messages: $_messages");
//     setState(() {
//       _typingUser.remove(_gpttUser);
//     });
//   }
// }

// class MyChatScreen extends StatelessWidget {
//   final TextEditingController _controller = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     final chatProvider = Provider.of<ChatProvider>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chat with Bard'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: chatProvider.historyList.length,
//               itemBuilder: (context, index) {
//                 final message = chatProvider.historyList[index];
//                 return ListTile(
//                   title: Text(message.message ?? ''),
//                   subtitle: Text(message.system == "user" ? 'You' : 'Bard'),
//                   tileColor: message.system == "user"
//                       ? Colors.blue[50]
//                       : Colors.grey[200],
//                 );
//               },
//             ),
//           ),
//           if (chatProvider.isLoading)
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: CircularProgressIndicator(),
//             ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: InputDecoration(
//                       hintText: 'Type a message...',
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.send),
//                   onPressed: () async {
//                     final message = _controller.text;
//                     if (message.isNotEmpty) {
//                       chatProvider.sendPrompt(message);
//                       _controller.clear();
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
class MyChatScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with Bard'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chatProvider.historyList.length +
                  (chatProvider.isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == chatProvider.historyList.length &&
                    chatProvider.isTyping) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bard is typing...',
                            style: TextStyle(color: Colors.grey)),
                        TypingIndicator()
                      ],
                    ),
                  );
                } else {
                  final message = chatProvider.historyList[index];
                  return ListTile(
                    title: Text(message.message ?? ''),
                    subtitle: Text(message.system == "user" ? 'You' : 'Bard'),
                    tileColor: message.system == "user"
                        ? Colors.blue[50]
                        : Colors.grey[200],
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    final message = _controller.text;
                    if (message.isNotEmpty) {
                      chatProvider.sendPrompt(message);
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
