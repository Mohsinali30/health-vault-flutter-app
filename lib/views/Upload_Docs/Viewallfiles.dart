import 'package:firebase_practice/View_view_Model/provider.dart';
import 'package:firebase_practice/utiles/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../Supabase_services/bucketoperations.dart';

class Viewallfiles extends StatefulWidget {

   Viewallfiles();

  @override
  State<Viewallfiles> createState() => _ViewallfilesState();
}
class _ViewallfilesState extends State<Viewallfiles> {
  final supaBaseRef = Supabase.instance.client;

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    final provider= Provider.of<Loadingstate>( context,listen: false);
    provider.showFiles(context, provider.category);
}

  @override
  Widget build(BuildContext context) {
   // final provider= Provider.of<Loadingstate>(context,listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryGreen,
        title: const Text(
          'Medical Record',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,

      ),
      body: Consumer<Loadingstate>(
        builder: (context, provider, child) {
          final files = provider.allFiles
              .where((files) => !files.name.contains('.emptyFolderPlaceholder'))
              .toList();
          // List ki lambai (length) ko use karein
          return
            Column(children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Thodi padding di
                physics: const BouncingScrollPhysics(), // Smooth scroll
                child: Row(
                  children: [
                    // 1. Diagnostics
                    _buildCategoryChip(context, provider, 'Diagnostics', 'diagnostics'),

                    const SizedBox(width: 10),

                    // 2. Medication
                    _buildCategoryChip(context, provider, 'Medications', 'medication'),

                    const SizedBox(width: 10),

                    // 3. Visits
                    _buildCategoryChip(context, provider, 'Consultations', 'visits'),

                    const SizedBox(width: 10),

                    // 4. Surgeries
                    _buildCategoryChip(context, provider, 'Surgeries', 'surgeries'),

                    const SizedBox(width: 10),

                    // 5. Vaccinations
                    _buildCategoryChip(context, provider, 'Vaccinations', 'vaccinations'),

                    const SizedBox(width: 10),

                    // 6. Others
                    _buildCategoryChip(context, provider, 'Others', 'other'),
                  ],
                ),
              ),

          Expanded(
            child:
            files.isEmpty
                ? Center(
              child: Text(
                '📁 No files uploaded yet in "${provider.category}" folder.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            )
                :
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child:
              ListView.builder(
                shrinkWrap: true,
                itemCount: files.length,
                physics: const BouncingScrollPhysics(), // Agar parent scrollable hai to ye zaroori hai
                itemBuilder: (context, index) {
                  final file = files[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Card(
                      elevation: 4, // Shadow effect
                      shadowColor: Colors.grey.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16), // Gol kinare
                      ),
                      color: Colors.white, // Clean white background
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: GestureDetector(
                          onTap:() => BucketOperation().DownloadAndOpen('${provider.category}/${file.name}'),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),

                            // 1. LEADING ICON (File Icon with Green Background)
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: primaryGreen.withOpacity(0.1), // Light Green Circle
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.insert_drive_file_outlined, color: primaryGreen, size: 24),
                            ),

                            // 2. FILE NAME (Bold & Clean)
                            title: Text(
                              file.name ?? 'Unknown File',
                              maxLines: 1, // Sirf 1 line taake layout na toote
                              overflow: TextOverflow.ellipsis, // Lambe naam ke liye "..."
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: textColor, // Aapka defined text color
                              ),
                            ),

                            // 3. SUBTITLE (Optional - File Type text)
                            subtitle: Text(
                              "Document", // Aap yahan file size ya date bhi dikha sakte hain
                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                            ),

                            // 4. ACTIONS (Download & Delete Icons)
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min, // Zaroori hai taake overflow na ho
                              children: [

                                // --- DOWNLOAD BUTTON ---
                                IconButton(
                                  tooltip: "Download",
                                  icon: const Icon(Icons.download_rounded, color: Colors.blueAccent),
                                  onPressed: () => BucketOperation().DownloadAndOpen('${provider.category}/${file.name}'),
                                ),

                                // --- DELETE BUTTON ---
                                IconButton(
                                  tooltip: "Delete",
                                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                                  onPressed: () => BucketOperation().DeleteFile('${provider.category}/${file.name}'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          )
          ],) ;

        },
      ),
    );





  }

// Helper Widget for Category Buttons
  Widget _buildCategoryChip(BuildContext context, dynamic provider, String label, String categoryId) {
    // Check: Kya ye button selected hai?
    bool isSelected = provider.category == categoryId;

    return InkWell(
      onTap: () {
        provider.setcategory(categoryId);
        provider.showFiles(context, provider.category);
      },
      borderRadius: BorderRadius.circular(30), // Ripple effect gol ho
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          // Agar Select hai to Green, warna White
          color: isSelected ? primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(30), // Pill Shape
          border: Border.all(
            // Agar Select nahi hai to Grey border dikhaye
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: primaryGreen.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ]
              : [], // Sirf active button ka shadow
        ),
        child: Text(
          label,
          style: TextStyle(
            // Agar Select hai to Text White, warna Grey
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }


}

  


