import 'package:firebase_practice/View_view_Model/eventProvider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/eventModel.dart';
import '../../utiles/AppColors.dart';
import '../../utiles/Utiles.dart';
import '../../utiles/event_notification.dart';
import 'package:firebase_practice/View_view_Model/bioProvider.dart';

class ReminderView extends StatefulWidget {
  const ReminderView({super.key});

  @override
  State<ReminderView> createState() => _ReminderViewState();
}

class _ReminderViewState extends State<ReminderView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<EventProvider>(context, listen: false);
      final bioProv = Provider.of<BioProvider>(context, listen: false);

      // --- FIX: NULL CHECK BEFORE ACCESSING ---
      if (bioProv.activeProfile != null && bioProv.activeProfile!.docId != null) {
        prov.getdata(bioProv.activeProfile!.docId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bioProvider = Provider.of<BioProvider>(context);
    final activeProfile = bioProvider.activeProfile;
    // Create instance of Notification Service
    NotificationService NS = NotificationService();

    // --- FIX: RETURN ERROR UI IF NULL (Prevents Red Screen) ---
    if (activeProfile == null || activeProfile.docId == null) {
      return Scaffold(
        backgroundColor: Colors.grey[50], // Light background for contrast
        appBar: AppBar(title: const Text("My Reminders",style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ), backgroundColor: Colors.green),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.person_off_outlined, size: 60, color: Colors.grey),
              SizedBox(height: 10),
              Text("No Profile Selected", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("Please go back and select a family member."),
            ],
          ),
        ),
      );
    }

    // Since we returned above if null, 'profileId' is safe here
    String profileId = activeProfile.docId!;

    return Consumer<EventProvider>(
      builder: (context, value, child) {
        return Scaffold(
          backgroundColor: Colors.grey[50], // Light background for contrast
          appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios,color: Colors.white,),
                onPressed: () {
                  Navigator.pop(context); // Navigates back
                },
              ),
              title: Text("${activeProfile.fullname}:Reminders",style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.green
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("UserBio")
                .doc(profileId)
                .collection("Events")
                .where('isreminder', isEqualTo: true) // Only show Active Reminders
                .snapshots(),
            builder: (context, snapshot) {

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.notifications_off_outlined, size: 50, color: Colors.grey),
                      SizedBox(height: 10),
                      Text("No Active Reminders"),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  EventModel event = EventModel.fromMap(data, snapshot.data!.docs[index].id);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.notifications_active, color: primaryGreen, size: 24),
                        ),
                        title: Text(
                          event.Event,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text("${event.date} | ${event.time}"),
                        trailing: SizedBox(
                          width: 96,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // --- TURN OFF REMINDER BUTTON ---
                              IconButton(
                                tooltip: "Turn Off Reminder",
                                icon: const Icon(Icons.notifications_off_outlined, color: Colors.orange),
                                onPressed: () async {
                                  try {
                                    // 1. Cancel Local Notification
                                    // Using hashCode of ID ensures unique ID for cancellation
                                    await NS.cancelNotification(event.docId.hashCode);

                                    // 2. Database Update (Set isreminder to FALSE)
                                    await FirebaseFirestore.instance
                                        .collection("UserBio")
                                        .doc(profileId)
                                        .collection("Events")
                                        .doc(event.docId)
                                        .update({"isreminder": false});

                                    Utiles().toastMessage("Reminder Stopped");
                                  } catch (e) {
                                    Utiles().toastMessage("Error: $e");
                                  }
                                },
                              ),

                              // --- DELETE EVENT BUTTON ---
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                                onPressed: () async {
                                  // 1. Cancel Notification first
                                  await NS.cancelNotification(event.docId.hashCode);

                                  // 2. Delete from Database
                                  value.deleteEvent(event.docId.toString(), profileId);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}