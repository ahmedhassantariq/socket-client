import 'dart:async';


import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  final List<String> _messages = [];
  late Socket socket;
  @override
  void initState() {
    super.initState();
    initializeSocket();
  }


  // test() async{
  //   // await install();
  //   await groupTest();
  // }
  //Socket connection
  void initializeSocket() {
    // const host = "https://socket-server-production-4d79.up.railway.app/";
    const host = "http://localhost:8080";

    socket = io(host,OptionBuilder()
        .setTransports(['websocket'])
        .setExtraHeaders({'id': "atariq344", 'name': "shazam"})
        .disableAutoConnect()
        .enableReconnection()
        .setQuery({"query":{"sdsxyz"}})
        .build());

    //SOCKET EVENTS
    // --> listening for connection
    socket.on('connect', (data) {
      // print(socket.id);
      _textEditingController.text=socket.id!;
      // print("Connected");
    });

    //listen for incoming messages from the Server.
    socket.on('message', (data) {
      // print(data['sentAt']);
      setState(() {
        _messages.add(data['message']);
      });
    });

    //listens when the client is disconnected from the Server
    socket.on('disconnect', (data) {
      // print('disconnect $data}');
    });

  }
  sendMessage(String message) {
    socket.emit(
      "message",
      {
        "receiverID":_textEditingController.text,
        "id": socket.id,
        "message": message, //--> message to be sent
        "sentAt": DateTime.now().toString()
      },
    );
  }

  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode(canRequestFocus: true);

  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
        actions: [

          TextButton(
              onPressed: () async {

                socket.disconnect();
                setState(() {
                  _messages.clear();
                });
              },
              child: const Text("Disconnect")),
          TextButton(
              onPressed: () async {
                socket.connect();

              },
              child: const Text("Connect")),

        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        controller: _scrollController,
          children: [
            TextField(
              controller: _textEditingController,
              decoration: const InputDecoration(
                  hintText: "SocketID"
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _messageController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                  hintText: "Message",
                suffixIcon: IconButton(
                  onPressed: (){
                    if(_messageController.text.isNotEmpty) {
                      sendMessage(_messageController.text);
                      _messageController.clear();
                    }
                    _focusNode.requestFocus();
                  },
                  icon: const Icon(Icons.send),
                )
              ),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: _messages.length,
                      itemBuilder: (context, index){
                      return Text(_messages[index].toString());
                  }),


      ]),
    );
  }
}
