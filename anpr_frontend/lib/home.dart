import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'add_owner.dart'; // Import page to add owner details
import 'vehicle_details.dart'; // Import page for vehicle owner details

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String _outputText = '';
  String? _detectedLicensePlate;

  // Method to pick image from gallery
  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedFile;
    });
  }

  // Method to capture image from camera
  Future<void> _captureImageFromCamera() async {
    final capturedFile = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = capturedFile;
    });
  }

  // Method to send image to backend
  Future<void> _sendImageToBackend() async {
    if (_image == null) {
      setState(() {
        _outputText = "No image selected";
        _detectedLicensePlate = null; // Reset detected license plate
      });
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
          'http://172.20.10.2:5000/upload'), // Replace with your backend URL
    );

    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        var jsonData = json.decode(responseData.body);

        if (jsonData['license_plate'] != null) {
          _detectedLicensePlate = jsonData['license_plate'];
          setState(() {
            _outputText = "Detected License Plate: $_detectedLicensePlate";
          });
        } else {
          setState(() {
            _outputText = "Failed to detect license plate";
            _detectedLicensePlate = null; // Reset detected license plate
          });
        }
      } else {
        setState(() {
          _outputText = "Failed to detect license plate";
          _detectedLicensePlate = null; // Reset detected license plate
        });
      }
    } catch (e) {
      setState(() {
        _outputText = "Error: $e";
        _detectedLicensePlate = null; // Reset detected license plate
      });
    }
  }

  // Updated method to fetch vehicle details from the backend
  Future<Map<String, dynamic>> _fetchVehicleDetails(String licensePlate) async {
    try {
      var response = await http
          .get(Uri.parse('http://172.20.10.2:5000/check/$licensePlate'));

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        print("Response Data: $jsonData");

        if (jsonData.containsKey('exists') && jsonData['exists'] == true) {
          return jsonData['owner_info'] as Map<String, dynamic>;
        } else {
          setState(() {
            _outputText = "Vehicle not found in database.";
          });
          return {};
        }
      } else {
        setState(() {
          _outputText = "Vehicle not found in database.";
        });
        return {};
      }
    } catch (e) {
      setState(() {
        _outputText = "Exception occurred: $e";
      });
      return {};
    }
  }

  // Updated method to check if the license plate exists in the database
  Future<void> _checkLicensePlateInDatabase() async {
    if (_detectedLicensePlate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please detect a license plate first!')),
      );
      return;
    }

    // Fetch the vehicle details based on the detected license plate
    Map<String, dynamic> vehicleDetails =
        await _fetchVehicleDetails(_detectedLicensePlate!);

    if (vehicleDetails.isNotEmpty) {
      // License plate exists, navigate to VehicleDetailsPage
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VehicleDetailsPage(
            licensePlate: _detectedLicensePlate!,
            vehicleDetails: vehicleDetails,
          ),
        ),
      );
    } else {
      // License plate not found, show alert dialog to add vehicle details
      _showAddVehicleDialog();
    }
  }

  // Method to show alert dialog to add vehicle
  void _showAddVehicleDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("License Plate Not Found"),
          content: Text("Do you want to save the vehicle details?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddOwnerPage(
                      licensePlate: _detectedLicensePlate!,
                    ),
                  ),
                );
              },
              child: Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("No"),
            ),
          ],
        );
      },
    );
  }

  // Method to clear all results and images
  void _clearAll() {
    setState(() {
      _image = null;
      _outputText = '';
      _detectedLicensePlate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),

        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.deepPurple,
                const Color.fromARGB(255, 123, 2, 144)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
        // White text color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Welcome to Automatic License Plate Recognition',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Please click or insert an image of the Vehicle to get started.',
                style: TextStyle(fontSize: 18, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _image != null
                  ? Image.file(
                      File(_image!.path),
                      height: 200,
                    )
                  : Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.image,
                        size: 100,
                        color: Colors.grey,
                      ),
                    ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickImageFromGallery,
                icon: const Icon(Icons.upload),
                label: const Text('Upload Image from Gallery'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  backgroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _captureImageFromCamera,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Capture Image from Camera'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  backgroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _sendImageToBackend,
                icon: const Icon(Icons.send),
                label: const Text('Send Image to Backend'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  backgroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              if (_outputText.isNotEmpty)
                Text(
                  _outputText,
                  style: TextStyle(
                    fontSize: 19,
                    color: _detectedLicensePlate != null
                        ? Colors.green
                        : Colors.red,
                    fontWeight: _detectedLicensePlate != null
                        ? FontWeight.bold
                        : FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple,
                          const Color.fromARGB(255, 123, 2, 144)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(
                          30), // Adjust the radius as needed
                    ),
                    child: ElevatedButton(
                      onPressed: _checkLicensePlateInDatabase,
                      child: const Text(
                        'Click to Get Vehicle Details!',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors
                            .transparent, // Remove shadow for a clean look
                        padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10), // Adjust padding if necessary
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _clearAll,
                    child: const Text(
                      'Clear',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 180, 12, 0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
