import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'animated_auth_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final _database = FirebaseDatabase.instance.ref();

    void _storeNumber(String number) {
      if (user != null) {
        _database.child('users').child(user.uid).push().set({'number': number});
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (ctx) => const AnimatedAuthScreen()),
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Press a number to store it:', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 2),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
              itemCount: 15,
              itemBuilder: (ctx, index) {
                final number = (index + 1).toString();
                return ElevatedButton(
                  onPressed: () => _storeNumber(number),
                  child: Text(number, style: const TextStyle(fontSize: 30)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
