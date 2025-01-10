import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddOwnerPage extends StatefulWidget {
  final String licensePlate;

  const AddOwnerPage({Key? key, required this.licensePlate}) : super(key: key);

  @override
  _AddOwnerPageState createState() => _AddOwnerPageState();
}

class _AddOwnerPageState extends State<AddOwnerPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _ownerNameController = TextEditingController();
  final _ownerAddressController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _vehicleDetailsController = TextEditingController();
  final _vehicleMakeController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _modelYearController = TextEditingController();
  final _vehicleColorController = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _ownerNameController.dispose();
    _ownerAddressController.dispose();
    _contactNumberController.dispose();
    _vehicleDetailsController.dispose();
    _vehicleMakeController.dispose();
    _vehicleModelController.dispose();
    _modelYearController.dispose();
    _vehicleColorController.dispose();
    super.dispose();
  }

  Future<void> _submitOwnerDetails() async {
    if (_formKey.currentState!.validate()) {
      var data = {
        'licensePlateNumber': widget.licensePlate,
        'ownerName': _ownerNameController.text,
        'ownerAddress': _ownerAddressController.text,
        'contactNumber': _contactNumberController.text,
        'vehicleDetails': _vehicleDetailsController.text,
        'vehicleMake': _vehicleMakeController.text,
        'vehicleModel': _vehicleModelController.text,
        'modelYear': _modelYearController.text,
        'vehicleColor': _vehicleColorController.text,
      };

      print(data); // Log the data being sent

      var response = await http.post(
        Uri.parse(
            'http://172.20.10.2:5000/add_owner'), // Replace with your backend URL
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Owner details added successfully!')),
        );
        Navigator.of(context).pop(); // Close the page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to add owner details: ${response.body}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, // Ensures it takes the full width
        height: double.infinity, // Ensures it takes the full height
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple,
              Colors.purpleAccent
            ], // Gradient background
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            // Add scroll view to prevent overflow
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Back button with reduced spacing
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                SizedBox(height: 0), // Reduced space after back button
                Container(
                  width: double.infinity,
                  margin:
                      const EdgeInsets.only(top: 20.0), // Margin for spacing
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white, // White overlay
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enter Owner Details',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(_ownerNameController, 'Owner Name'),
                        const SizedBox(height: 16),
                        _buildTextField(
                            _ownerAddressController, 'Owner Address'),
                        const SizedBox(height: 16),
                        _buildTextField(
                            _contactNumberController, 'Contact Number'),
                        const SizedBox(height: 16),
                        _buildTextField(
                            _vehicleDetailsController, 'Vehicle Details'),
                        const SizedBox(height: 16),
                        _buildTextField(_vehicleMakeController, 'Vehicle Make'),
                        const SizedBox(height: 16),
                        _buildTextField(
                            _vehicleModelController, 'Vehicle Model'),
                        const SizedBox(height: 16),
                        _buildTextField(
                          _modelYearController,
                          'Model Year',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                            _vehicleColorController, 'Vehicle Color'),
                        const SizedBox(height: 20),
                        Center(
                          // Center the button
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.deepPurple,
                                  Colors.purpleAccent
                                ], // Same gradient as background
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: ElevatedButton(
                              onPressed: _submitOwnerDetails,
                              child: const Text('Submit',
                                  style: TextStyle(
                                      color: Colors
                                          .white)), // White text for button
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(15),
                                backgroundColor: Colors
                                    .transparent, // Keep button background transparent
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0, // Remove button shadow
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.deepPurple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.deepPurple),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.deepPurpleAccent),
        ),
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }
}
