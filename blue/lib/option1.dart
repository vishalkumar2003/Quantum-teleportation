import 'package:blue/Roleselection.dart';
import 'package:flutter/material.dart';
import 'package:all_bluetooth/all_bluetooth.dart';

// ignore: camel_case_types
class option1 extends StatefulWidget {
  final BluetoothDevice device; // Add this line
  final String selectedoption;

  const option1(
      {super.key,
      required this.device,
      required this.selectedoption}); // Add device to constructor

  @override
  State<option1> createState() => _option1State();
}

// ignore: camel_case_types
class _option1State extends State<option1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  width: 200.0,
                  height: 200.0,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/3preview.png', // Replace with your image path
                          width: 180, // Set the desired width
                          height: 180, // Set the desired height
                        ),
                        Text(widget.selectedoption),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () {
                    // Navigate to DragDropCircuitApp with device
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectionScreen(
                          data: widget.selectedoption,
                        ), // Pass the device
                      ),
                    );
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
