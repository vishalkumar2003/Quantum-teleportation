import 'package:blue/Roleselection2.dart';
import 'package:blue/bluetooth.dart';
import 'package:blue/option1.dart';
import 'package:blue/option2.dart';
import 'package:blue/option3.dart';
import 'package:blue/option4.dart';
import 'package:flutter/material.dart';
import 'package:all_bluetooth/all_bluetooth.dart';

class RadioButtonScreen extends StatefulWidget {
  final BluetoothDevice device;

  const RadioButtonScreen({super.key, required this.device});

  @override
  _RadioButtonScreenState createState() => _RadioButtonScreenState();
}

class _RadioButtonScreenState extends State<RadioButtonScreen> {
  int? _selectedValue;
  int? _receivedValue;
  bool _showQuantumTeleportation = false;
  bool _showSuperdenseCoding = false;

  @override
  void initState() {
    super.initState();
    _listenForBluetoothMessages();
  }

  void _toggleQuantumTeleportation() {
    setState(() {
      _showQuantumTeleportation = !_showQuantumTeleportation;
      _showSuperdenseCoding = false;
      _selectedValue = null;
    });
  }

  void _toggleSuperdenseCoding() {
    setState(() {
      _showSuperdenseCoding = !_showSuperdenseCoding;
      _showQuantumTeleportation = false;
      _selectedValue = null;
    });
  }

  void _navigateToQuantumScreen() {
    Widget optionScreen;
    switch (_selectedValue) {
      case 1:
        optionScreen = option1(
          device: widget.device,
          selectedoption: '|𝜙+⟩',
        );
        break;
      case 2:
        optionScreen = option2(
          device: widget.device,
          selectedoption: '∣𝜙−⟩',
        );
        break;
      case 3:
        optionScreen = option3(
          device: widget.device,
          selectedoption: '∣𝜓+⟩',
        );
        break;
      case 4:
        optionScreen = option4(
          device: widget.device,
          selectedoption: '∣𝜓-⟩',
        );
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => optionScreen,
      ),
    );
  }

  void _navigateToSuperdenseScreen() {
    Widget optionScreen;
    switch (_selectedValue) {
      case 1:
        optionScreen = SelectionScreen2(
          device: widget.device,
          selectedoption: '00',
        );
        break;
      case 2:
        optionScreen = SelectionScreen2(
          device: widget.device,
          selectedoption: '01',
        );
        break;
      case 3:
        optionScreen = SelectionScreen2(
          device: widget.device,
          selectedoption: '10',
        );
        break;
      case 4:
        optionScreen = SelectionScreen2(
          device: widget.device,
          selectedoption: '11',
        );
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => optionScreen,
      ),
    );
  }

  void _onRadioButtonChanged(int? value) {
    setState(() {
      _selectedValue = value;
      _sendBluetoothMessage(value!);
    });
  }

  void _onSubmit() {
    if (_selectedValue != null && _selectedValue == _receivedValue) {
      if (_showQuantumTeleportation) {
        _navigateToQuantumScreen();
      } else if (_showSuperdenseCoding) {
        _navigateToSuperdenseScreen();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select the same option on both devices."),
        ),
      );
    }
  }

  void _sendBluetoothMessage(int value) {
    allBluetooth.sendMessage(value.toString());
  }

  void _listenForBluetoothMessages() {
    allBluetooth.listenForData.listen((data) {
      setState(() {
        _receivedValue = int.tryParse(data!);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connected to ${widget.device.name}'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Main option buttons
                ElevatedButton(
                  onPressed: _toggleQuantumTeleportation,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromRGBO(33, 150, 243, 1),
                    minimumSize: const Size(150, 50),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Quantum Teleportation'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _toggleSuperdenseCoding,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromRGBO(33, 150, 243, 1),
                    minimumSize: const Size(150, 50),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text("Superdense Coding"),
                ),
                const SizedBox(height: 20),

                // Quantum Teleportation Options
                if (_showQuantumTeleportation) ...[
                  RadioListTile<int>(
                    value: 1,
                    groupValue: _selectedValue,
                    onChanged: _onRadioButtonChanged,
                    title: Row(
                      children: <Widget>[
                        Image.asset('assets/1.3preview.png', height: 30),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                  RadioListTile<int>(
                    value: 2,
                    groupValue: _selectedValue,
                    onChanged: _onRadioButtonChanged,
                    title: Row(
                      children: <Widget>[
                        Image.asset('assets/1.4preview.png', height: 30),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                  RadioListTile<int>(
                    value: 3,
                    groupValue: _selectedValue,
                    onChanged: _onRadioButtonChanged,
                    title: Row(
                      children: <Widget>[
                        Image.asset('assets/1.1preview.png', height: 30),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                  RadioListTile<int>(
                    value: 4,
                    groupValue: _selectedValue,
                    onChanged: _onRadioButtonChanged,
                    title: Row(
                      children: <Widget>[
                        Image.asset('assets/1.2preview.png', height: 30),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                ],

                // Superdense Coding Options
                if (_showSuperdenseCoding) ...[
                  RadioListTile<int>(
                    value: 1,
                    groupValue: _selectedValue,
                    onChanged: _onRadioButtonChanged,
                    title: const Text('00'),
                  ),
                  RadioListTile<int>(
                    value: 2,
                    groupValue: _selectedValue,
                    onChanged: _onRadioButtonChanged,
                    title: const Text('01'),
                  ),
                  RadioListTile<int>(
                    value: 3,
                    groupValue: _selectedValue,
                    onChanged: _onRadioButtonChanged,
                    title: const Text('10'),
                  ),
                  RadioListTile<int>(
                    value: 4,
                    groupValue: _selectedValue,
                    onChanged: _onRadioButtonChanged,
                    title: const Text('11'),
                  ),
                ],

                // Submit Button - shown only if either option is selected
                if (_showQuantumTeleportation || _showSuperdenseCoding) ...[
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _onSubmit,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromRGBO(33, 150, 243, 1),
                      minimumSize: const Size(150, 50),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Submit'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
