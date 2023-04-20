import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  final signUpFormKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        centerTitle: true,
      ),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(30),
          shrinkWrap: true,
          children: [
            Form(
              key: signUpFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: fullNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person),
                        hintText: 'John',
                        labelText: 'First Name',
                        labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor))),
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    controller: emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email address';
                      } else {
                        if (!isEmail(emailController.text.trim())) {
                          return 'email is not valid';
                        } else {
                          return null;
                        }
                      }
                    },
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email_outlined),
                        hintText: 'abc@gmail.com',
                        labelText: 'Email',
                        labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor))),
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    controller: passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.password_sharp),
                        hintText: '*********',
                        labelText: 'Password',
                        labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor))),
                    obscureText: true,
                  ),
                  const SizedBox(height: 30.0),
                  SizedBox(
                    height: 40,
                    child: GestureDetector(
                      onTap: () async {
                        if (signUpFormKey.currentState!.validate()) {

                          try {
                            await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                email: emailController.text,
                                password: passwordController.text,
                            );
                            await addItem(
                                fullName: fullNameController.text,
                                email: emailController.text,
                                password: passwordController.text);
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'weak-password') {
                              print('The password provided is too weak.');
                            } else if (e.code == 'email-already-in-use') {
                              print('The account already exists for that email.');
                            }
                          } catch (e) {
                            print(e);
                          }
                          var snackBar =
                              const SnackBar(content: Text('sign up successful'));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          Navigator.pushNamed(context, '/home');
                        }
                      },
                      child: Material(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context).primaryColor,
                        shadowColor: Colors.blueAccent,
                        elevation: 7.0,
                        child: const Center(
                          child: Text('Sign Up',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              )),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have account ?',
                          style: TextStyle(
                            fontSize: 16.0,
                          )),
                      const SizedBox(width: 10.0),
                      InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/signin');
                          },
                          child: Text('Sign In',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                                decoration: TextDecoration.underline,
                              ))),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }


  bool isEmail(String? string) {
    // Null or empty string is invalid
    if (string == null || string.isEmpty) {
      return false;
    }

    const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    final regExp = RegExp(pattern);

    if (!regExp.hasMatch(string)) {
      return false;
    }
    return true;
  }

  Future<void> addItem({
    required String fullName,
    required String email,
    required String password,
  }) async {

    String uid = (FirebaseAuth.instance.currentUser)!.uid;

    DocumentReference documentReferencer =
    FirebaseFirestore.instance.collection('users').doc(uid);


    Map<String, dynamic> data = <String, dynamic>{
      "fullName": fullName,
      "email": email,
      "password": password
    };

    await documentReferencer
        .set(data)
        .whenComplete(() => print("Notes item added to the database"))
        .catchError((e) => print(e));
  }
}
