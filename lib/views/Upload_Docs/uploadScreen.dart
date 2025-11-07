import 'package:firebase_practice/Supabase_services/bucketoperations.dart';
import 'package:firebase_practice/View_view_Model/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utiles/AppColors.dart';
import 'dart:io';
import '../../utiles/Utiles.dart';

enum HealthCategory   {
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
  File? _selectedFile;
  HealthCategory? _selectedCategory;
// Get a reference your Supabase client
  final supaBaseRef = Supabase.instance.client;
  final String bucketName = 'files';

  @override
  void initState() {
    super.initState();
    _selectedCategory = HealthCategory.diagnostics;
    final provider= Provider.of<Loadingstate>( context,listen: false);
    provider.showFiles(context, provider.category);
  }
  // --- METHODS ---

  void handleUpload() {
    if (_selectedCategory == null) {
      Utiles().toastMessage("Please select a file category.");
      return;
    }

    // ✅ CORRECT WAY: Value is accessed and used inside the function body
    final HealthCategory category = _selectedCategory!;
    final String folderName = category.name;


  }


  // 1. File Picker Logic
  Future<void> _pickFile() async {
    final provider= Provider.of<Loadingstate>( context,listen: false);
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
        File file = File(result.files.single.path!);
        setState(() {
          _selectedFile = file;
        });
        provider.setloading(false);
      } else {
        // User canceled the picker
        provider.setloading(false);
      }
    } catch (e) {
      debugPrint("File picking error: ${e.toString()}");
      provider.setloading(false);
      // Show user feedback for error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  void _startUpload() async
  {
    final provider = Provider.of<Loadingstate>(context, listen: false);
    if (_selectedCategory == null) {
      Utiles().toastMessage("Please select a file category.");
      return;
    }

    // ✅ CORRECT WAY: Value is accessed and used inside the function body
    final HealthCategory category = _selectedCategory!;
    final String folderName = category.name;

    final fileToUpload= _selectedFile;
    provider.setloading(true);

    final String file = fileToUpload!.path;
    final fileName = fileToUpload.path.split('/').last;
    final String filpathname = '$folderName/${DateTime.now().microsecondsSinceEpoch}_$fileName';
    if (fileToUpload == null) {
      //here ican callback to fetchallfiles function for auto update in instate fun
      provider.showFiles(context, provider.category);
      provider.setloading(false);
      Utiles().toastMessage("Error: File path is not accessible.");
      return;
    }

    // Create a unique file path within the bucket
    // Format: category/filename_timestamp.ext
    //  final fileExtension = fileToUpload.extension ?? 'bin';
    // final storagePath = '${categoryName}/${DateTime.now().microsecondsSinceEpoch}.${fileMimeType}';

    try {
      await supaBaseRef.storage.from('files').upload(filpathname, fileToUpload);

      if (mounted) {
        Utiles().toastMessage('File Upload Successful!  ${filpathname.toString()}');
        provider.showFiles(context, provider.category);
        setState(() {
          _selectedFile = null; // Clear file selection
          _selectedCategory = HealthCategory.diagnostics;
        });
      }

    } on StorageException catch (e) {
      // Catch Supabase-specific storage errors (e.g., policy violations)
      Utiles().toastMessage("Storage Error: ${e.message}");
    } catch (e) {
      // Catch general file system or network errors
      Utiles().toastMessage("Upload failed: ${e.toString()}");
    } finally {
      // 5. Stop Loading
      provider.setloading(false);
    }
  }
  // --- UI BUILDING BLOCKS ---
  // Displays the selected file's summary
  // Update the function signature
  Widget _buildFileSummary() {
    if (_selectedFile == null) {
      return Container();
    }

    // File ka naam extract karne ke liye 'path' library use karna behtar hai.
    // Yahan hum sirf path ka aakhri hissa (file name) lenge.
    // Ya phir aap ek naya state variable bana sakte the (e.g., _selectedFileName).
    // Abhi hum path se naam nikal rahe hain.
    final fileName = _selectedFile!.path.split('/').last;

    return Card(

      // ... baaki UI code wahi rahega
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(
          Icons.drive_file_move_rounded,color: primaryGreen,
          size: 40,
        ),
        title: Text(
          fileName, // <--- File ka Naam
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        // subtitle: Text('Path: ${_selectedFile!.path}'), // <--- Path dikhane ke liye
        trailing: IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () {
            setState(() {
              _selectedFile = null; // File clear karein
            });
          },
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryGreen,
        title: const Text(
          'Upload Health Record',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,

      ),
      body: Consumer<Loadingstate>(
          builder: (context, value, child) {
            bool _isLoading = value.isLoading; // Read the state correctly

            return SingleChildScrollView(
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
           //   _buildFileSummary(),
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
          ),);}
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