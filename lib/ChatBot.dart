import 'dart:ffi';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:myschool/Consta.dart';
import 'package:myschool/user/YoutubeWatchScreen.dart';

class MyChatScreen extends StatefulWidget {
  const MyChatScreen({super.key});

  @override
  State<MyChatScreen> createState() => _MyChatScreenState();
}

class _MyChatScreenState extends State<MyChatScreen> {
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
                child: UserChatScreen(),
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

class UserChatScreen extends StatefulWidget {
  const UserChatScreen({Key? key}) : super(key: key);

  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  final ChatUser _currentUser =
      ChatUser(id: '1', firstName: "addy", lastName: "mane");

  final _openAI = OpenAI.instance.build(
    token: API_KEY,
    baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 15)),
    enableLog: true,
  );
  final ChatUser _gpttUser =
      ChatUser(id: '2', firstName: "chat", lastName: "gpt");

  List<ChatMessage> _messages = <ChatMessage>[];
  List<ChatUser> _typingUser = <ChatUser>[];
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        // backgroundColor: Colors.,
        backgroundColor: Color(0xFFF5EEE6),

        body: DashChat(
          currentUser: _currentUser,
          typingUsers: _typingUser,
          messageOptions: const MessageOptions(
              currentUserContainerColor: Colors.red,
              containerColor: Color.fromARGB(0, 166, 126, 1),
              textColor: Colors.green),
          onSend: (ChatMessage m) {
            getChatResponse(m);
          },
          messages: _messages,
        ),
      ),
    );
  }

  Future<void> getChatResponse(ChatMessage m) async {
    setState(() {
      _messages.insert(0, m);
      _typingUser.add(_gpttUser);
    });
    List<Messages> _messagesHistory = _messages.reversed.map((m) {
      if (m.user == _currentUser) {
        return Messages(role: Role.user, content: m.text);
      } else {
        return Messages(role: Role.assistant, content: m.text);
      }
    }).toList();
    final request = ChatCompleteText(
        model: GptTurbo0301ChatModel(),
        messages: _messagesHistory,
        maxToken: 100);
    final response = await _openAI.onChatCompletion(request: request);
    for (var element in response!.choices) {
      if (element.message != null) {
        setState(() {
          _messages.insert(
              0,
              ChatMessage(
                  user: _gpttUser,
                  createdAt: DateTime.now(),
                  // text: "Test Message",
                  // ));
                  text: element.message!.content));
        });
      }
    }
    print("Updated Messages: $_messages");
    setState(() {
      _typingUser.remove(_gpttUser);
    });
  }
}
