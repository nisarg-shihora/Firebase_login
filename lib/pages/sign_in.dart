import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  var signInFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Sign In'),
        centerTitle: true,
      ),
      body: Center(
        child: ListView(padding: const EdgeInsets.all(30), shrinkWrap: true,
            // padding: EdgeInsets.symmetric(vertical: 150, horizontal: 50),
            children: [
              Form(
                key: signInFormKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your email address';
                        }
                        if (!isEmail(emailController.text.trim())) {
                          return 'Email is not valid';
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email_outlined),
                          hintText: 'abc@gmail.com',
                          labelText: 'Email',
                          labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor))),
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                      controller: passwordController,
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.password_sharp),
                          hintText: '*********',
                          labelText: 'Password',
                          labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor))),
                      obscureText: true,
                    ),
                    const SizedBox(height: 30.0),
                    SizedBox(
                        height: 40.0,
                        child: GestureDetector(
                          onTap: () async {
                            if (signInFormKey.currentState!.validate()) {
                              await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                email: emailController.text,
                                password: passwordController.text,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Sign in successful')));
                              Navigator.pushNamed(context, '/home');
                            }
                          },
                          child: Material(
                            borderRadius: BorderRadius.circular(20),
                            color: Theme.of(context).primaryColor,
                            shadowColor: Colors.greenAccent,
                            elevation: 7.0,
                            child: const Center(
                              child: Text('Sign In',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  )),
                            ),
                          ),
                        )),
                    const SizedBox(height: 15.0),
                    InkWell(
                      onTap: () async {
                        UserCredential user = await signInWithGoogle();
                        print(user.user?.uid);
                        print(user.user?.phoneNumber);
                        print(user.user?.email);
                        print(user.user?.displayName);
                        addUserData(user);
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //     const SnackBar(
                        //         content: Text('Sign in with google successful')));
                        Navigator.pushNamed(context, '/home');
                      },
                      child: Text('SignIn with google ',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                            decoration: TextDecoration.underline,
                          )),
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () async {
                        UserCredential user = await signInWithGoogle();
                        updateUser(user);
                        Navigator.pushNamed(context, '/home');
                      },
                      child: Text(
                        'update profile',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('New to app ?',
                            style: TextStyle(
                              fontSize: 16.0,
                            )),
                        const SizedBox(width: 5.0),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ]),
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

  void addUserData(UserCredential credential) async {
    // UserCredential user = await signInWithGoogle();

    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('users')
        .doc(credential.user!.uid);
    print(documentReference);

    return documentReference.set(
      {
        'uid': credential.user!.uid,
        'email': credential.user!.email,
        'displayName': credential.user!.displayName,
        'lastSeen': DateTime.now()
      },
    );
  }

  Future<void> updateUser(UserCredential credential) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(credential.user!.uid)
        .update({'displayName': 'SHIHORA NISARG'})
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      print(e.message);
      throw e;
    }
  }
}
