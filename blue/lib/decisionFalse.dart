import 'package:blue/darg.dart';
import 'package:flutter/material.dart';

class FalseScreen extends StatefulWidget {
  const FalseScreen({Key? key}) : super(key: key);

  @override
  _FalseScreenState createState() => _FalseScreenState();
}

class _FalseScreenState extends State<FalseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Circuit Validation Failed'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error,
              color: Colors.red,
              size: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              'Invalid Circuit for this Qubit State',
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
