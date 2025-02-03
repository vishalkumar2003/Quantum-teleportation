import 'package:blue/dragdrop1.dart';
import 'package:blue/radio_button_screen.dart';
import 'package:flutter/material.dart';
import 'package:all_bluetooth/all_bluetooth.dart';
import 'package:permission_handler/permission_handler.dart'; // Import your DragDropCircuitScreen

void main() {
  runApp(const MyApp());
}

final allBluetooth = AllBluetooth();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomeScreen(),
      theme: ThemeData(
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final bondedDevices = ValueNotifier<List<BluetoothDevice>>([]);
  bool isListening = false;
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  bool _isConnecting = false;
  BluetoothDevice? _currentDevice;
  bool isFirstDevice = true; // Flag to identify if it's the first device

  @override
  void initState() {
    super.initState();
    _requestPermissions();

    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: Colors.blue,
      end: Colors.purple,
    ).animate(_controller);

    _initializeBluetooth();

    allBluetooth.listenForConnection.listen((event) {
      if (event.state == true) {
        _currentDevice = event.device;
        _navigateToCorrectScreen();
      }
    });

    // Custom implementation for listening to signals
    allBluetooth.listenForData.listen((data) {
      String signal = String.fromCharCodes(
          data as Iterable<int>); // Convert byte data to string
      _handleReceivedSignal(signal);
    });
  }
  

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    final permissions = [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ];

    final results = await permissions.request();
    if (results[Permission.bluetooth] == PermissionStatus.granted &&
        results[Permission.bluetoothScan] == PermissionStatus.granted &&
        results[Permission.bluetoothConnect] == PermissionStatus.granted) {
      _initializeBluetooth();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bluetooth permissions not granted")),
      );
    }
  }

  void _initializeBluetooth() async {
    await allBluetooth.startBluetoothServer();
    setState(() {
      isListening = true;
    });

    allBluetooth.streamBluetoothState.listen((bluetoothOn) {
      if (bluetoothOn) {
        _fetchBondedDevices();
      }
      setState(() {});
    });
  }

  void _fetchBondedDevices() async {
    final devices = await allBluetooth.getBondedDevices();
    bondedDevices.value = devices;
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    if (_isConnecting) return;

    setState(() {
      _isConnecting = true;
    });

    try {
      if (!mounted) return;
      final scaffold = ScaffoldMessenger.of(context);
      scaffold.showSnackBar(
        const SnackBar(content: Text("Connecting to device...")),
      );

      bool connected = false;
      int retryCount = 0;

      while (!connected && retryCount < 3) {
        try {
          await allBluetooth.connectToDevice(device.address);
          connected = true;

          final connectionStatus =
              await allBluetooth.listenForConnection.firstWhere(
            (event) =>
                event.state == true && event.device?.address == device.address,
          );

          scaffold.hideCurrentSnackBar();

          if (connectionStatus.state == true) {
            _currentDevice = device;
            _navigateToCorrectScreen();
          } else {
            scaffold.showSnackBar(
              const SnackBar(content: Text("Failed to connect to the device")),
            );
          }
        } catch (e) {
          retryCount++;
          if (retryCount == 3) {
            scaffold.showSnackBar(
              SnackBar(
                  content:
                      Text("Failed to connect after $retryCount attempts")),
            );
          }
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to connect to the device: $e")),
      );
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  void _navigateToCorrectScreen() {
    if (_currentDevice != null) {
      // Open RadioButtonScreen on one device and DragDropCircuitScreen on the other
      if (isFirstDevice) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RadioButtonScreen(device: _currentDevice!),
          ),
        );
        // Send a signal to the other device to open DragDropCircuitScreen
        _sendSignal("open_drag_drop");
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                 QuantumCircuitDesignerHome(getdata: '',),
          ),
        );
        // Send a signal to the other device to open RadioButtonScreen
        _sendSignal("open_radio_button");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unknown device type connected")),
      );
    }
  }

  // Custom method to send a signal to the connected device
  void _sendSignal(String signal) async {
    if (_currentDevice != null) {
      await allBluetooth.sendData(signal.codeUnits);
    }
  }

  // Handle received signals
  void _handleReceivedSignal(String signal) {
    if (signal == "open_radio_button") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RadioButtonScreen(device: _currentDevice!),
        ),
      );
    } else if (signal == "open_drag_drop") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>  QuantumCircuitDesignerHome(getdata: '',),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bluetooth Connect"),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _colorAnimation.value!,
                      Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              );
            },
          ),
          StreamBuilder<bool>(
            stream: allBluetooth.streamBluetoothState,
            builder: (context, snapshot) {
              final bluetoothOn = snapshot.data ?? false;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          bluetoothOn ? "ON" : "OFF",
                          style: TextStyle(
                            color: bluetoothOn ? Colors.green : Colors.red,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: bluetoothOn ? _fetchBondedDevices : null,
                          child: const Text("Bonded Devices"),
                        ),
                      ],
                    ),
                  ),
                  if (!bluetoothOn)
                    const Center(
                      child: Text("Turn Bluetooth on"),
                    ),
                  Expanded(
                    child: ValueListenableBuilder<List<BluetoothDevice>>(
                      valueListenable: bondedDevices,
                      builder: (context, devices, child) {
                        return ListView.builder(
                          itemCount: devices.length,
                          itemBuilder: (context, index) {
                            final device = devices[index];
                            return ListTile(
                              title: Text(device.name),
                              subtitle: Text(device.address),
                              onTap: () {
                                _connectToDevice(device);
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (!isListening) {
            await allBluetooth.startBluetoothServer();
            setState(() {
              isListening = true;
            });
          } else {
            await allBluetooth.closeConnection();
            setState(() {
              isListening = false;
            });
          }
        },
        backgroundColor:
            isListening ? Theme.of(context).primaryColor : Colors.grey,
        child: Icon(isListening ? Icons.stop : Icons.bluetooth),
      ),
    );
  }
}

extension on AllBluetooth {
  sendData(List<int> codeUnits) {}
}
