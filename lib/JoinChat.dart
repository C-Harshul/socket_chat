import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';

class Joinchat extends StatefulWidget {
  
  @override
  _JoinchatState createState() => _JoinchatState();
}
  SocketIO socketIO;
class _JoinchatState extends State<Joinchat> {

  @override
  void initState() {
 
    //Creating the socket
    socketIO = SocketIOManager().createSocketIO(
      'https://real-chat-12345.herokuapp.com',
      '/',
    );
    //Call init before doing anything with socket
    socketIO.init();
    //Connect to the socket
    socketIO.connect();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: FlatButton(
        onPressed: () async {
         socketIO.sendMessage(
              'join', json.encode({'usertype':'provider','uid':'xyz','pid':'abc'}));
            Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatPage()),
                  );
        },
         child: Text('Join Chat'))
        ),
    );
  }
}


class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  //SocketIO socketIO;
  List<Map<String,String>> messages;
  double height, width;
  TextEditingController textController;
  ScrollController scrollController;

  @override
  void initState() {
    //Initializing the message list
    messages = List<Map<String,String>>();
    //Initializing the TextEditingController and ScrollController
    textController = TextEditingController();
    scrollController = ScrollController();
    socketIO.subscribe('receive_message', (jsonData) {
      print('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');

      //Convert the JSON data received into a Map
      Map<String, dynamic> data = json.decode(jsonData);
      print('\n\n\n $data\n\n\n');
      this.setState(() {messages.add({"message":data['text']['message'],"senderType":data['usertype']});print(data);});
      print(messages);
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 600),
        curve: Curves.ease,
      );
    });
    super.initState();
  }

  Widget buildSingleMessage(int index) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        margin: const EdgeInsets.only(bottom: 20.0, left: 20.0),
        decoration: BoxDecoration(
          color: messages[index]['senderType'] != "provider"?Colors.deepPurple:Colors.black,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          messages[index]['message'],
          style: TextStyle(color: Colors.white, fontSize: 15.0),
        ),
      ),
    );
  }

  Widget buildMessageList() {
    return Container(
      height: height * 0.8,
      width: width,
      child: ListView.builder(
        controller: scrollController,
        itemCount: messages.length,
        itemBuilder: (BuildContext context, int index) {
          return buildSingleMessage(index);
        },
      ),
    );
  }

  Widget buildChatInput() {
    return Container(
      width: width * 0.7,
      padding: const EdgeInsets.all(2.0),
      margin: const EdgeInsets.only(left: 40.0),
      child: TextField(
        decoration: InputDecoration.collapsed(
          hintText: 'Send a message...',
        ),
        controller: textController,
      ),
    );
  }

  Widget buildSendButton() {
    return FloatingActionButton(
      backgroundColor: Colors.deepPurple,
      onPressed: () {
        //Check if the textfield has text or not
        if (textController.text.isNotEmpty) {
          //Send the message as JSON data to send_message event
          socketIO.sendMessage(
              'send_message', json.encode({'message': textController.text}));
          //Add the message to the list
          this.setState(() => messages.add({"message":textController.text,"senderType":"provider"}));
          textController.text = '';
          //Scrolldown the list to show the latest message
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 600),
            curve: Curves.ease,
          );
        }
      },
      child: Icon(
        Icons.send,
        size: 30,
      ),
    );
  }

  Widget buildInputArea() {
    return Container(
      height: height * 0.1,
      width: width,
      child: Row(
        children: <Widget>[
          buildChatInput(),
          buildSendButton(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: height * 0.1),
            buildMessageList(),
            buildInputArea(),
          ],
        ),
      ),
    );
  }
}