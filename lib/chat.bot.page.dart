import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatBotPage extends StatefulWidget {
  ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  List messages = [
    {"message": 'hello', "type": "user"},
    {"message": 'how can i help you', "type": "assistant"},

  ];

  TextEditingController queryController = TextEditingController();
  ScrollController scrollController = new ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "Chat Bot",
          style: TextStyle(color: Theme.of(context).indicatorColor),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                controller: scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  bool isUser = messages[index]['type'] == 'user';
                  return Column(
                    children: [ 
                        ListTile(
                          leading: isUser? Icon(Icons.person) : null,
                          trailing: !isUser? Icon(Icons.support_agent) : null,
                          title: Row(
                            children: [
                              SizedBox(
                                width: isUser? 100 : 0,
                              ),
                              Expanded(
                                child: Container(
                                  child: Text(
                                    messages[index]["message"],
                                    style: Theme.of(context).textTheme.headlineSmall,
                                  ),
                                  color: isUser?
                                    Color.fromARGB(99, 7, 132, 7) :
                                    Colors.white,
                                  padding: EdgeInsets.all(10),
                                ),
                              ),
                              SizedBox(
                                width: isUser? 0 :100,
                              )
                            ],
                          ),
                        ),
                        Divider(
                          height: 1,
                          color: Colors.grey,
                        ),
                    ]
                  );
                }
              ),
            )
            
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: queryController,
                    decoration: InputDecoration(
                      // icon: Icon(Icons.lock),
                      suffixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 1, color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    String query = queryController.text;
                    var openAiLLMUri = Uri.https("api.openai.com", "/v1/chat/completions");
                    Map<String, String> headers = {
                      "Content-Type": "application/json",
                      "Authorization": "Bearer sKey"
                    };
                    
                    var prompt = {
                      "model": "gpt-3.5-turbo",
                      "messages": [{"role": "user", "content": query}],
                      "temperature": 0
                    };
              
                    http.post(openAiLLMUri, headers: headers, body: json.encode(prompt)).then((res) {
                      var resBody = res.body;
                      var aiRes = json.decode(resBody);
                      String resContent = aiRes['choices'][0]['message']['content'];
                      setState(() {
                        messages.add({"message": query, "type": "user"});
                        messages.add({"message": resContent, "type": "assistant"});
                        scrollController.jumpTo(
                          scrollController.position.maxScrollExtent + 200
                        );
                      });    
                    }, onError: (err) {
                        print("Error sending message: ${err.toString()}");
                      });                
                    },
                  icon: Icon(Icons.send)
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
