import 'package:flutter/material.dart';

class VehicleDetailsPage extends StatefulWidget {
  final String licensePlate;
  final Map<String, dynamic> vehicleDetails;

  const VehicleDetailsPage({
    Key? key,
    required this.licensePlate,
    required this.vehicleDetails,
  }) : super(key: key);

  @override
  _VehicleDetailsPageState createState() => _VehicleDetailsPageState();
}

class _VehicleDetailsPageState extends State<VehicleDetailsPage>
    with SingleTickerProviderStateMixin {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ownerInfo = widget.vehicleDetails;

    if (ownerInfo.isEmpty) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              'No vehicle details available.',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back,
                    color: Colors.white), // White back arrow
                onPressed: () {
                  Navigator.pop(context); // Go back to the previous screen
                },
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.only(
                    top: 48.0), // Space for the back arrow
                decoration: BoxDecoration(
                  color: Colors.white, // White background for details
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'License Plate: ${widget.licensePlate}',
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black), // Adjusted font size
                        ),
                        const SizedBox(height: 20),
                        _buildDetailRow('Owner Name:', ownerInfo['owner_name']),
                        _buildDetailRow(
                            'Owner Address:', ownerInfo['owner_address']),
                        _buildDetailRow(
                            'Contact Number:', ownerInfo['contact_number']),
                        _buildDetailRow(
                            'Vehicle Details:', ownerInfo['vehicle_details']),
                        _buildDetailRow(
                            'Vehicle Make:', ownerInfo['vehicle_make']),
                        _buildDetailRow(
                            'Vehicle Model:', ownerInfo['vehicle_model']),
                        _buildDetailRow('Model Year:', ownerInfo['model_year']),
                        _buildDetailRow(
                            'Vehicle Color:', ownerInfo['vehicle_color']),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(16.0), // Increased padding for better spacing
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: RichText(
          text: TextSpan(
            text: title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black), // Adjusted font size
            children: [
              TextSpan(
                text:
                    ' ${value != null && value.toString().isNotEmpty ? value : 'N/A'}',
                style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 18,
                    color: Colors.black), // Adjusted font size
              ),
            ],
          ),
        ),
      ),
    );
  }
}
