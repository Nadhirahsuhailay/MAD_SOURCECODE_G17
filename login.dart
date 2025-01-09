import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymtrainer1/pages/forgotpassword.dart';
import 'package:gymtrainer1/pages/signup.dart';
//import 'package:carifoody/pages/welcomepage.dart';
import 'package:gymtrainer1/widget/widget_support.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:carifoody/homepage/homepage.dart';
import 'package:gymtrainer1/main.dart';
import 'package:gymtrainer1/trainerdashboard.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {

String email="", password="";

final _formkey= GlobalKey<FormState>();

TextEditingController useremailcontroller= new TextEditingController();
TextEditingController userpasswordcontroller= new TextEditingController();

userLogin() async {
  try {
    // Log in the user
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    // Get user ID (UID)
    String uid = userCredential.user!.uid;

    // Fetch user role from Firestore
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (!userDoc.exists) {
      throw Exception("User document not found");
    }

    // Get role from the document
    String role = userDoc['role'];

    // Navigate based on role
    if (role == "user") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()), // User homepage
      );
    } else if (role == "trainer") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TrainerHomePage()), // Trainer page
      );
    } else {
      throw Exception("Unknown role: $role");
    }
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "No user found for that Email",
            style: TextStyle(fontSize: 18.0, color: Colors.black),
          ),
        ),
      );
    } else if (e.code == 'wrong-password') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Wrong Password Provided by User",
            style: TextStyle(fontSize: 18.0, color: Colors.black),
          ),
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Error: $e",
          style: TextStyle(fontSize: 18.0, color: Colors.black),
        ),
      ),
    );
  }
}






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height/2.5,
          decoration: const BoxDecoration(gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
            Color(0xFF00072D),
             Color(0xFF000000),
          ])),
        ),
Container(
  margin: EdgeInsets.only(top: MediaQuery.of(context).size.height/3),
  height: MediaQuery.of(context).size.height/1.2,
  width: MediaQuery.of(context).size.width,
  decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
  child: const Text(""),
),
Container(
  margin: const EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0 ),
  child: Column(children: [
    Center(child: Image.asset("images/uniquepluslogo.png", width: MediaQuery.of(context).size.width/2.2,fit: BoxFit.cover)),
    const SizedBox(height:30.0, ),
    Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height/2,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Form(
          key: _formkey,
          child: Column(children: [
            const SizedBox(height: 30.0,),
            Text(
              "Login", 
              style: AppWidget.HeadlineTextFieldStyle(),
              ),
              const SizedBox(height: 30.0,),
              TextFormField(
                controller: useremailcontroller,
                validator: (value){
                    if (value==null|| value.isEmpty) {
                      return 'Please Enter Email';
                    }
                    return null;
                },
                decoration: InputDecoration(hintText: 'Email', hintStyle: AppWidget.semiBoldTextFieldStyle(), prefixIcon: const Icon(Icons.email_outlined)),
              ),
              const SizedBox(height: 30.0,),
              TextFormField(
                controller: userpasswordcontroller,
                validator: (value){
                    if (value==null|| value.isEmpty) {
                      return 'Please Enter Password';
                    }
                    return null;
                },
                obscureText: true,
                decoration: InputDecoration(hintText: 'Password', hintStyle: AppWidget.semiBoldTextFieldStyle(), prefixIcon: const Icon(Icons.password_outlined)),
              ),
              const SizedBox(height: 20.0,),
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPassword()));
                },
                child: Container(
                  alignment: Alignment.topRight,
                  child: Text("Forgot Password?", style: AppWidget.semiBoldTextFieldStyle())),
              ),
                const SizedBox(height: 80.0,),
                GestureDetector(
                  onTap: (){
                      if (_formkey.currentState!.validate()) {
                        setState(() {
                          email= useremailcontroller.text;
                          password= userpasswordcontroller.text;
                        });
                      }
                      userLogin();
                  },
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      width: 200,
                      decoration: BoxDecoration(color: const Color(0xFF000000), borderRadius: BorderRadius.circular(20)),
                      child: const Center(
                        child: Text("LOGIN", style: TextStyle(color: Colors.white, fontSize: 18.0, fontFamily: 'Poppins1', fontWeight: FontWeight.bold),
                        
                        )
                      ),
                    ),
                  ),
                ),
          
          ],),
        ),
      ),
    ),
          const SizedBox(height: 70.0),
          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUp(),));
            },
        child: Text("Dont have an account? Sign up", style: AppWidget.semiBoldTextFieldStyle())),
  ],),
)
      ],),),
    );
  }
}
