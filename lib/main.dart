import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyAjdFuParCMcaYrHlcPBTKu6QJrtoBarNw",
        authDomain: "loginapp-1048d.firebaseapp.com",
        projectId: "loginapp-1048d",
        storageBucket: "loginapp-1048d.firebasestorage.app",
        messagingSenderId: "121948004204",
        appId: "1:121948004204:web:d00cac0acbfe59f8b85d49",
        measurementId: "G-GZVZ51LPDH"
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
  late Animation<Offset> _slideAnimation;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, 0.5),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    if (isLogin) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      isLogin = !isLogin;
    });
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
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
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
                if (!isLogin)
                  AnimatedOpacity(
                    opacity: isLogin ? 0 : 1,
                    duration: Duration(milliseconds: 300),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                  ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
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
                  onPressed: _toggleAuthMode,
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (ctx) => AnimatedAuthScreen()),
              );
            },
          )
        ],
      ),
      body: Center(
        child: Text(
          'Welcome to Home Page!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
