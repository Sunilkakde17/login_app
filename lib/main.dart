import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

void _saveNumberToDatabase(String number) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final databaseRef = FirebaseDatabase.instance.ref(); // Updated reference method
    await databaseRef.child('users/${user.uid}/numbers').push().set({
      'number': number,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyAjdFuParCMcaYrHlcPBTKu6QJrtoBarNw",
      authDomain: "loginapp-1048d.firebaseapp.com",
      projectId: "loginapp-1048d",
      storageBucket: "loginapp-1048d.appspot.com",
      messagingSenderId: "121948004204",
      appId: "1:121948004204:web:d00cac0acbfe59f8b85d49",
      measurementId: "G-GZVZ51LPDH",
      databaseURL: "https://loginapp-1048d-default-rtdb.firebaseio.com/", // Correct Database URL
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AnimatedAuthScreen(),
    );
  }
}
class AnimatedAuthScreen extends StatefulWidget {
  @override
  _AnimatedAuthScreenState createState() => _AnimatedAuthScreenState();
}

class _AnimatedAuthScreenState extends State<AnimatedAuthScreen>
    with SingleTickerProviderStateMixin {
  bool isLogin = true;
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController(); // Add username controller
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose(); // Dispose username controller
    super.dispose();
  }

  Future<void> _submit() async {
    try {
      if (isLogin) {
        // Login logic
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        // Register logic
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Save username to Firebase Realtime Database
        final databaseRef = FirebaseDatabase.instance.ref();
        await databaseRef.child('users/${userCredential.user!.uid}').set({
          'username': _usernameController.text, // Save username
          'email': _emailController.text,
        });
      }

      // Redirect to HomePage after successful login/register
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (ctx) => HomePage()),
      );
    } catch (e) {
      print(e);
      // Show an error message if authentication fails
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Authentication failed!'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: SingleChildScrollView(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: 350,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                  tag: 'auth-logo',
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/logo.png'),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  isLogin ? 'Login' : 'Register',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                if (!isLogin)
                  TextField(
                    controller: _usernameController, // Username input
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),
                SizedBox(height: 12),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent, // Set button background color to green
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                child: Text(
                    isLogin ? 'Login' : 'Register',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      isLogin = !isLogin;
                    });
                  },
                  child: Text(

                    isLogin
                        ? "Don't have an account? Register"
                        : "Already have an account? Login",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final DatabaseReference _database = FirebaseDatabase.instance.reference();
  final User? user = FirebaseAuth.instance.currentUser;

  void _storeNumber(String number) {
    if (user != null) {
      _database.child('users').child(user!.uid).push().set({'number': number});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculator'),
        actions: [
          IconButton(
            icon: Text("Logout"),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (ctx) => AnimatedAuthScreen()),
              );
            },
          )
        ],
        titleTextStyle: TextStyle(fontSize: 30),  // Use titleTextStyle instead of textStyle
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Press a number to store it:',
              style: TextStyle(fontSize: 40),
            ),
            SizedBox(height: 5),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 4,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemCount: 12,
              itemBuilder: (ctx, index) {
                return ElevatedButton(
                  onPressed: () => _storeNumber(index.toString()),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(5),
                  ),
                  child: Text(
                    index.toString(),
                    style: TextStyle(fontSize: 30),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
