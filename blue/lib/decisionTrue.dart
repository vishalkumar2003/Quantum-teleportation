import 'package:blue/darg.dart';
import 'package:flutter/material.dart';

class TrueScreen extends StatefulWidget {
  const TrueScreen({Key? key}) : super(key: key);

  @override
  _TrueScreenState createState() => _TrueScreenState();
}

class _TrueScreenState extends State<TrueScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Circuit Validation Successful'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              'Your Quantum Circuit is Valid!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Drag2Home(
                            initialQubit: '',
                            getdata: '',
                          )),
                );
              },
              child: const Text('Back to Circuit'),
            )
          ],
        ),
      ),
    );
  }
}
