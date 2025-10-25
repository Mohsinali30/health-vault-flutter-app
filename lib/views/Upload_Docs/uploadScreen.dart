import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_practice/Supabase_services/bucketoperations.dart';
import 'package:firebase_practice/View_view_Model/provider.dart';
import 'package:firebase_practice/utiles/Utiles.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../../utiles/AppColors.dart';

enum HealthCategory {
  diagnostics,
  medication,
  visits,
  surgeries,
  vaccinations,
  other,
}
extension CategoryExtension on HealthCategory {
  String get friendlyName {
    switch (this) {
      case HealthCategory.diagnostics:
        return 'Diagnostics (Lab Reports)';
      case HealthCategory.medication:
        return 'Medication / Prescriptions';
      case HealthCategory.visits:
        return 'Visits / Consultations';
      case HealthCategory.surgeries:
        return 'Surgeries / Procedures';
      case HealthCategory.vaccinations:
        return 'Vaccination Certificates';
      case HealthCategory.other:
        return 'Other';
    }
  }
}

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  PlatformFile? _selectedFile;
  //hold the selected category (will be used for API)
  HealthCategory? _selectedCategory;
 final databaseref= FirebaseDatabase.instance.ref('documents');

// Get a reference your Supabase client
  final supabaseRef = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _selectedCategory = HealthCategory.diagnostics;
    BucketOperation.Createbucket();
  }
  // --- METHODS ---
  // 1. File Picker Logic
  Future<void> _pickFile() async {
    final provider= Provider.of<Loadingstate>( context,);
    // Reset file and set loading state
    setState(() {
      _selectedFile = null;
    });
    provider.setloading(true);

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        // We only requested a single file, so take the first one
        PlatformFile file = result.files.first;

        setState(() {
          _selectedFile = file;
        });
        provider.setloading(false);
      } else {
        // User canceled the picker
        provider.setloading(false);
      }
    } catch (e) {
      print("File picking error: $e");
      provider.setloading(false);
      // Show user feedback for error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }
  // 2. Upload Logic (Simulated)
  void _startUpload() {
    final provider= Provider.of<Loadingstate>( context,);
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file first.')),
      );
      return;
    }

    // The variables we would send to the API:
    debugPrint('--- Starting Upload ---');
    debugPrint('File Name: ${_selectedFile!.name}');
    debugPrint('File Path: ${_selectedFile!.path}'); // Use this path to read the bytes for API upload
    debugPrint('Selected Category: ${_selectedCategory!.name}'); // This is the value used in the back-end

   provider.setloading(true);

    // Simulate API delay
    Future.delayed(const Duration(seconds: 3), () {
      provider.setloading(false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File Upload Simulation Complete!')),
        );
        // Clear the form after successful upload
        setState(() {
          _selectedFile = null;
          _selectedCategory = HealthCategory.diagnostics;
        });
      }
    });
  }
  // --- UI BUILDING BLOCKS ---
  // Displays the selected file's summary
  Widget _buildFileSummary() {
    if (_selectedFile == null) {
      return Container();
    }

    // Convert file size from bytes to a human-readable format (MB or KB)
    String fileSize = _selectedFile!.size >= 1024 * 1024
        ? '${(_selectedFile!.size / (1024 * 1024)).toStringAsFixed(2)} MB'
        : '${(_selectedFile!.size / 1024).toStringAsFixed(2)} KB';

    String fileExtension = _selectedFile!.extension?.toUpperCase() ?? 'N/A';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(
          fileExtension == 'PDF' ? Icons.picture_as_pdf : Icons.image,
          color: primaryGreen,
          size: 40,
        ),
        title: Text(
          _selectedFile!.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Type: $fileExtension | Size: $fileSize'),
        trailing: IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () {
            setState(() {
              _selectedFile = null;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
bool _isLoading= Loadingstate().isLoading;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryGreen,
        title: const Text(
          'Upload Health Record',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children:[


            const Card(
              color: lightGreen,
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '1. Select the document category.\n2. Tap "Select File" to browse and choose your document (PDF, JPG, etc.).\n3. Tap "Upload" to secure your record.',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Category Selection Label
            const Text(
              'Select Document Category',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // Dropdown Button
            _buildCategoryDropdown(),

            const SizedBox(height: 30),

            // Select File Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _pickFile,
              icon: const Icon(Icons.folder_open),
              label: Text(_selectedFile == null ? 'Select File' : 'Change File'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),

            // Pre-upload UI: File Summary
            _buildFileSummary(),
            const SizedBox(height: 40),

            // Upload Button (Conditional)
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: primaryGreen),
                    SizedBox(height: 10),
                    Text('Processing file...'),
                  ],
                ),
              )
            else
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _selectedFile != null ? _startUpload : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedFile != null ? primaryGreen : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    'Upload Record',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  // Main Category Dropdown Widget
  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: primaryGreen, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<HealthCategory>(
          isExpanded: true,
          value: _selectedCategory,
          icon: const Icon(Icons.arrow_drop_down, color: primaryGreen),
          style: const TextStyle(color: Colors.black87, fontSize: 16),
          onChanged: (HealthCategory? newValue) {
            setState(() {
              // Save the selected category value
              _selectedCategory = newValue;
            });
            print('Selected Category Value: $_selectedCategory');
          },
          items: HealthCategory.values.map<DropdownMenuItem<HealthCategory>>(
                (HealthCategory category) {
              return DropdownMenuItem<HealthCategory>(
                // The value is the enum member itself (e.g., HealthCategory.diagnostics)
                value: category,
                // The child is the user-friendly text
                child: Text(category.friendlyName),
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}