import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  User? user = FirebaseAuth.instance.currentUser;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // List email = [];
  List listViewData = [];

  fetchAllData() async {
    // List email = [];

    // String uid = user!.uid;
    QuerySnapshot<Map<String, dynamic>> documentSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    print(documentSnapshot.docs);
    print(documentSnapshot.docs.length);
    print(documentSnapshot.docs.first.data());
    // print(documentSnapshot.docs.map((e) => e.data()).toList());
    print(documentSnapshot.docs.elementAt(2).data());
    print(documentSnapshot.docs);

    listViewData = documentSnapshot.docs.map((e) => e.data()).toList();
    print(listViewData);

    // documentSnapshot.docs.map((e) {
    //   print(e);
    // });
  }

  @override
  void initState() {
    super.initState();
    fetchAllData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Authenticate User'),
          ),
          body: ListView.builder(
              itemCount: listViewData.length,
              itemBuilder: (BuildContext context, int index) {
                print(listViewData[index]);
                print(listViewData[index]['email']);
                return ListTile(
                    title: Text("fullName: ${listViewData[index]['fullName']}"),
                    subtitle: Text("email:  ${listViewData[index]['email']}"),
                );

              })),
    );
  }
}
