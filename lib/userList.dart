import 'dart:async';
import 'dart:typed_data';


import 'package:encrypt/encrypt_io.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:encrypt/encrypt.dart' as enc;

class UserList extends StatefulWidget {
  final String email;
  final String receiverEmail;
  const UserList({super.key, required this.email, required this.receiverEmail});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  final List<String> _messages = [];
  late Socket socket;
  final StreamController<Uint8List> _streamController = StreamController();
  final key = enc.Key.fromUtf8('my 32 length key................');
  final iv = enc.IV.fromLength(16);

  @override
  void initState() {
    super.initState();
    initializeSocket();






  }
  late String _isOnline= "";


  // test() async{
  //   // await install();
  //   await groupTest();
  // }
  //Socket connection
  void initializeSocket() {
    // const host = "https://socket-server-production-4d79.up.railway.app/";
    const host = "ws://localhost:8080/hello";

    socket = io(host,OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .enableReconnection()
        // .setQuery({"a":"admin@gmail.com"})
    .setAuth({
      "userID":widget.email,
      'receiverID':widget.receiverEmail
    })
        .build());

    //SOCKET EVENTS
    // --> listening for connection
    socket.on('connect', (data) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Connected to Server"),duration: Duration(milliseconds: 300),));
    });

    //listen for incoming messages from the Server.
    socket.on('message', (data) {
      setState(() {
        _messages.add(data['message']);
      });
    });


    socket.on('data', (data) {
      Uint8List list = Uint8List.fromList(data['message']);

      _streamController.add(list);

    });

    socket.on('connectionOK', (data) {
      setState(() {
        data['isOnline']?_isOnline="Online":_isOnline="Offline";
      });
    });

    //listens when the client is disconnected from the Server
    socket.on('disconnect', (data) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Disconnected from Server"),duration: Duration(milliseconds: 300),));
    });

  }


  _loadImage() async{
    final ImagePicker picker = ImagePicker();
    final file = await picker.pickMedia();
    final encrypter = enc.Encrypter(enc.AES(key));

    if(file!=null){

      final Uint8List bytes = await file.readAsBytes();
      // final encryptedBytes = encrypter.encryptBytes(bytes,iv: iv);
      socket.emit(
        "data",
        {
          "receiverID":widget.receiverEmail,
          "id": socket.id,
          "message": bytes, //--> message to be sent
          "sentAt": DateTime.now().toString()
        },
      );

    }
  }


  sendMessage(String message) {
    socket.emit(
      "message",
      {
        "receiverID":widget.receiverEmail,
        "id": socket.id,
        "message": message, //--> message to be sent
        "sentAt": DateTime.now().toString()
      },
    );
  }

  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode(canRequestFocus: true);

  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat: ${widget.receiverEmail} is $_isOnline"),
        actions: [
          TextButton(
              onPressed: () {
                _loadImage();
              },
              child: const Text("Select")),
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
            StreamBuilder<Uint8List>(
                stream: _streamController.stream,

                builder: (context, snapshot){
                  if(snapshot.hasError){
                    print(snapshot.error);
                    return const Text("Error");
                  }
                  if(snapshot.connectionState==ConnectionState.waiting){
                    return const LinearProgressIndicator();
                  }
                  return Image.memory(snapshot.requireData,errorBuilder: (a,b,c)=>const Text("No Image"),);
                }),
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
