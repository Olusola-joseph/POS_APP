import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:posmap/models/pos_operator.dart';
import 'package:posmap/services/registration_service.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';

class RegistrationWizard extends StatefulWidget {
  const RegistrationWizard({super.key});

  @override
  State<RegistrationWizard> createState() => _RegistrationWizardState();
}

class _RegistrationWizardState extends State<RegistrationWizard> {
  final PageController _pageController = PageController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final RegistrationService _registrationService = RegistrationService();
  
  // Controllers for form fields
  final TextEditingController _operatorNameController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _locationLandmarkController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _whatsappNumberController = TextEditingController();
  final TextEditingController _exactAddressController = TextEditingController();
  
  // Images captured during registration
  File? _selfieImage;
  File? _businessSignageImage;
  File? _idDocumentImage;
  
  // Selected values
  String? _selectedTier;
  String? _selectedOperatingSpace;
  String? _selectedNumTerminals;
  List<String> _selectedBanks = [];
  Position? _currentPosition;
  Placemark? _currentPlace;
  
  // Signature controllers
  final SignatureController _operatorSignatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
  );
  
  final SignatureController _agentSignatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
  );
  
  // Current step
  int _currentPage = 0;
  final int _totalPages = 5; // Step 1-5 as per requirements
  
  @override
  void dispose() {
    _pageController.dispose();
    _operatorNameController.dispose();
    _shopNameController.dispose();
    _locationLandmarkController.dispose();
    _phoneNumberController.dispose();
    _whatsappNumberController.dispose();
    _exactAddressController.dispose();
    _operatorSignatureController.dispose();
    _agentSignatureController.dispose();
    super.dispose();
  }

  // Step 1: Get location
  Future<bool> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permissions are permanently denied.')),
      );
      return false;
    }

    try {
      setState(() {
        _currentPosition = null;
      });
      
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        _currentPlace = placemarks.first;
      }
      
      setState(() {
        _currentPosition = position;
      });
      
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
      return false;
    }
  }

  // Step 2: Capture images
  Future<void> _captureImage(ImageSource source, String type) async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: source,
        maxHeight: 800,
        maxWidth: 800,
      );
      
      if (image != null) {
        setState(() {
          switch (type) {
            case 'selfie':
              _selfieImage = File(image.path);
              break;
            case 'signage':
              _businessSignageImage = File(image.path);
              break;
            case 'id':
              _idDocumentImage = File(image.path);
              break;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error capturing image: $e')),
      );
    }
  }

  // Step 3: Validate phone numbers
  bool _isValidPhoneNumber(String phone) {
    // Remove spaces and special characters
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    
    // Check if it starts with +234 or 0 and has 11 digits
    if (cleanPhone.startsWith('+234') && cleanPhone.length == 13) {
      return true;
    } else if (cleanPhone.startsWith('0') && cleanPhone.length == 11) {
      return true;
    }
    
    return false;
  }

  // Navigation methods
  void _goToNextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POS Operator Registration'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Save draft functionality
            },
            child: const Text(
              'Save Draft',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentPage + 1) / _totalPages,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Step ${_currentPage + 1} of $_totalPages',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            
            // Main content area
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  // Step 1: Geolocation
                  _buildGeolocationStep(),
                  
                  // Step 2: Biometrics & Identity
                  _buildBiometricsStep(),
                  
                  // Step 3: Business Details
                  _buildBusinessDetailsStep(),
                  
                  // Step 4: Contact & Tiering
                  _buildContactTieringStep(),
                  
                  // Step 5: Signatures & Submission
                  _buildSubmissionStep(),
                ],
              ),
            ),
            
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    ElevatedButton(
                      onPressed: _goToPreviousPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Previous'),
                    )
                  else
                    const SizedBox.shrink(),
                  
                  if (_currentPage < _totalPages - 1)
                    ElevatedButton(
                      onPressed: () {
                        // Validation logic for each step
                        if (_currentPage == 0) { // Geolocation step
                          if (_currentPosition == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enable GPS and get location'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                        }
                        
                        _goToNextPage();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Next'),
                    )
                  else
                    ElevatedButton(
                      onPressed: _submitRegistration,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Submit Registration'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Step 1: Geolocation
  Widget _buildGeolocationStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Step 1: Location Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'We need to capture your current location to register the POS operator.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          
          // Get Location Button
          Center(
            child: ElevatedButton.icon(
              onPressed: _getLocation,
              icon: Icon(
                _currentPosition != null ? Icons.location_on : Icons.location_off,
                color: _currentPosition != null ? Colors.green : Colors.red,
              ),
              label: Text(
                _currentPosition != null ? 'Location Captured' : 'Get Current Location',
                style: TextStyle(
                  color: _currentPosition != null ? Colors.green : null,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: _currentPosition != null ? Colors.green[100] : Colors.blue,
                foregroundColor: _currentPosition != null ? Colors.green : Colors.white,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Location Details
          if (_currentPosition != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Location:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Latitude: ${_currentPosition!.latitude}'),
                    Text('Longitude: ${_currentPosition!.longitude}'),
                    if (_currentPlace != null) ...[
                      const SizedBox(height: 8),
                      Text('Address: ${_currentPlace!.thoroughfare ?? ''}, ${_currentPlace!.subLocality ?? ''}, ${_currentPlace!.locality ?? ''}'),
                    ],
                  ],
                ),
              ),
            ),
          ] else ...[
            Card(
              color: Colors.yellow[50],
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '⚠️ Please enable GPS and tap the button above to capture location before proceeding.',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Step 2: Biometrics & Identity
  Widget _buildBiometricsStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Step 2: Biometrics & Identity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Capture images to verify the POS operator identity.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          
          // Selfie Image
          _buildImageCaptureSection(
            'Operator Selfie',
            'Take a clear photo of the POS operator',
            _selfieImage,
            'selfie',
          ),
          
          const SizedBox(height: 16),
          
          // Business Signage
          _buildImageCaptureSection(
            'Business Signage',
            'Capture the business signage or shop front',
            _businessSignageImage,
            'signage',
          ),
          
          const SizedBox(height: 16),
          
          // ID Document
          _buildImageCaptureSection(
            'ID Document',
            'Capture NIN, BVN, or Voters ID',
            _idDocumentImage,
            'id',
          ),
        ],
      ),
    );
  }

  // Helper method to build image capture sections
  Widget _buildImageCaptureSection(
    String title,
    String subtitle,
    File? image,
    String type,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            if (image != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: FileImage(image),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _captureImage(ImageSource.camera, type),
                  icon: const Icon(Icons.camera),
                  label: const Text('Camera'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _captureImage(ImageSource.gallery, type),
                  icon: const Icon(Icons.image),
                  label: const Text('Gallery'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Step 3: Business Details
  Widget _buildBusinessDetailsStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Step 3: Business Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Provide details about the POS business.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            
            // Shop Name
            TextFormField(
              controller: _shopNameController,
              decoration: const InputDecoration(
                labelText: 'Shop Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter shop name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Location/Landmark
            TextFormField(
              controller: _locationLandmarkController,
              decoration: const InputDecoration(
                labelText: 'Exact Location/Landmark',
                hintText: 'e.g., Opposite Chief\'s Palace',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter location landmark';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Operating Space
            const Text(
              'Operating Space Size',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedOperatingSpace,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: '1-Table', child: Text('1-Table')),
                DropdownMenuItem(value: 'Kiosk', child: Text('Kiosk')),
                DropdownMenuItem(value: 'Shop', child: Text('Shop')),
                DropdownMenuItem(value: 'Store', child: Text('Store')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedOperatingSpace = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select operating space';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Number of Terminals
            const Text(
              'Number of POS Terminals',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedNumTerminals,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: '1', child: Text('1 Terminal')),
                DropdownMenuItem(value: '2', child: Text('2 Terminals')),
                DropdownMenuItem(value: '3', child: Text('3 Terminals')),
                DropdownMenuItem(value: '4+', child: Text('4+ Terminals')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedNumTerminals = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select number of terminals';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Banks Serviced
            const Text(
              'Banks Serviced',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (String bank in ['GTB', 'Access', 'Opay', 'Palmpay', 'UBA', 'First Bank', 'Zenith', 'Fidelity'])
                  FilterChip(
                    label: Text(bank),
                    selected: _selectedBanks.contains(bank),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedBanks.add(bank);
                        } else {
                          _selectedBanks.remove(bank);
                        }
                      });
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Step 4: Contact & Tiering
  Widget _buildContactTieringStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Step 4: Contact & Tiering',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Contact information and classification.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            
            // Operator Name
            TextFormField(
              controller: _operatorNameController,
              decoration: const InputDecoration(
                labelText: 'Operator Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter operator name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Phone Number
            TextFormField(
              controller: _phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: 'e.g. 8012345678',
                prefixText: '+234',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone number';
                }
                if (!_isValidPhoneNumber('+234$value')) {
                  return 'Please enter a valid Nigerian phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // WhatsApp Number
            TextFormField(
              controller: _whatsappNumberController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'WhatsApp Number (optional)',
                hintText: 'e.g. 8012345678',
                prefixText: '+234',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Tier Classification
            const Text(
              'Tier Classification',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedTier,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Tier 1', child: Text('Tier 1: High Volume')),
                DropdownMenuItem(value: 'Tier 2', child: Text('Tier 2: Medium Volume')),
                DropdownMenuItem(value: 'Tier 3', child: Text('Tier 3: Rural/Low Volume')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedTier = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a tier';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  // Step 5: Signatures & Submission
  Widget _buildSubmissionStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Step 5: Signatures & Confirmation',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Both operator and field agent need to sign to confirm registration.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          
          // Operator Signature
          const Text(
            'Operator Signature',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Signature(
              controller: _operatorSignatureController,
              height: 180,
              backgroundColor: Colors.grey[100],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _operatorSignatureController.clear(),
                child: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Agent Signature
          const Text(
            'Field Agent Signature',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Signature(
              controller: _agentSignatureController,
              height: 180,
              backgroundColor: Colors.grey[100],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _agentSignatureController.clear(),
                child: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Summary Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Registration Summary',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text('Operator: ${_operatorNameController.text}'),
                  Text('Shop: ${_shopNameController.text}'),
                  Text('Location: ${_currentPlace?.subLocality ?? 'N/A'}'),
                  Text('Tier: $_selectedTier'),
                  Text('Terminals: $_selectedNumTerminals'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Submit registration
  Future<void> _submitRegistration() async {
    if (_operatorSignatureController.isEmpty ||
        _agentSignatureController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please both operator and agent signatures'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create POS operator object
    final posOperator = PosOperator(
      id: null,
      operatorName: _operatorNameController.text,
      shopName: _shopNameController.text,
      latitude: _currentPosition?.latitude ?? 0.0,
      longitude: _currentPosition?.longitude ?? 0.0,
      locationLandmark: _locationLandmarkController.text,
      operatingSpace: _selectedOperatingSpace ?? '',
      numTerminals: _selectedNumTerminals ?? '',
      banksServiced: _selectedBanks.join(','),
      phoneNumber: '+234${_phoneNumberController.text}',
      whatsappNumber: _whatsappNumberController.text.isEmpty 
          ? null 
          : '+234${_whatsappNumberController.text}',
      tier: _selectedTier ?? '',
      selfieImage: _selfieImage?.path,
      businessSignageImage: _businessSignageImage?.path,
      idDocumentImage: _idDocumentImage?.path,
      operatorSignature: null, // Will be handled separately
      agentSignature: null, // Will be handled separately
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      setState(() {
        // Show loading indicator
      });

      // Save registration
      await _registrationService.saveRegistration(posOperator);

      // Show success message
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success!'),
              content: const Text('POS operator registration completed successfully.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(); // Close registration wizard
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting registration: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}