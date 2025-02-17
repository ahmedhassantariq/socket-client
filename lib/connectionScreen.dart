import 'package:flutter/material.dart';
import 'package:sockerio/userList.dart';

class ConnectionScreen extends StatelessWidget {
  const ConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    final TextEditingController emailController = TextEditingController();
    final TextEditingController receiverEmailController = TextEditingController();
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
        TextField(
          controller: emailController,
          decoration: const InputDecoration(
            hintText: "Your Email"
          ),
        ),
        TextField(
          controller: receiverEmailController,
          decoration: const InputDecoration(
              hintText: "Receiver's Email"
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(onPressed: (){
          if(emailController.text.isEmpty||receiverEmailController.text.isEmpty){
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter email addresses")));
          }else{
            Navigator.push(context, MaterialPageRoute(builder: (context)=>UserList(email: emailController.text, receiverEmail: receiverEmailController.text)));
          }
        }, child: const Text("Initialize Socket"))
      ]),
    );
  }
}
