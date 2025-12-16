import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_practice/View_view_Model/bioProvider.dart';
import 'package:firebase_practice/View_view_Model/AddEventProvider.dart';
import 'package:firebase_practice/View_view_Model/eventProvider.dart';
import 'package:firebase_practice/models/eventModel.dart';
import 'package:firebase_practice/utiles/Utiles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../utiles/event_notification.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bioProvider = Provider.of<BioProvider>(context, listen: false);
      final eventProvider = Provider.of<EventProvider>(context, listen: false);

      // SAFE INIT: Only fetch data if a profile is selected
      if (bioProvider.activeProfile != null && bioProvider.activeProfile!.docId != null) {
        eventProvider.getdata(bioProvider.activeProfile!.docId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bioProvider = Provider.of<BioProvider>(context);
    final provider = Provider.of<IsAdding>(context);

    // 1. Notification Service ko aik baar define karein (Duplicate remove kar diya)
    final NotificationService NS = NotificationService();
    bool isadding = provider.isadding;

    // --- FIX START: CRASH PREVENTION ---
    // Pehle check karein, agar null hai to return kar dein
    if (bioProvider.activeProfile == null || bioProvider.activeProfile!.docId == null) {
      return Scaffold(
        backgroundColor: Colors.grey[50], // Light background for contrast

        appBar: AppBar(title: const Text("Events"), backgroundColor: Colors.green),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.person_off, size: 60, color: Colors.grey),
              SizedBox(height: 20),
              Text("No Family Member Selected", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("Please go back and select a profile."),
            ],
          ),
        ),
      );
    }
    // --- FIX END ---

    //  AB HUM SAFE HAIN: Ab profileId define karein
    final activeProfile = bioProvider.activeProfile!;
    String profileId = activeProfile.docId!; // Ab ye crash nahi karega

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,color: Colors.white,),
          onPressed: () {
            Navigator.pop(context); // Navigates back
          },
        ),
        title: Text('${activeProfile.fullname}: Appointments',          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        actions: [
          GestureDetector(
            onTap: () {
              provider.setisAdding(true);
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(Icons.add, color: Colors.white, size: 28),
            ),
          )
        ],
      ),
      body: Consumer<EventProvider>(builder: (context, value, child) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: isadding
                ? const EventCard()
                : (value.event.isEmpty
                ? const Center(child: Text("No Appointments Added"))
                : ListView.builder(
              itemCount: value.event.length,
              itemBuilder: (context, index) {
                EventModel event = value.event[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.withOpacity(0.1),
                        child: const Icon(Icons.access_time_filled, color: Colors.green),
                      ),
                      title: Text(event.Event,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("${event.date} | ${event.time}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: "Set Reminder",
                            icon: Icon(
                              event.isreminder == true ? Icons.notifications_active : Icons.notifications_none,
                              color: event.isreminder == true ? Colors.green : Colors.grey,
                            ),
                            onPressed: () async {
                              try {
                                DateTime datePart = DateFormat.yMMMd().parse(event.date!);
                                // Farz karein event.time = "1:56 AM" hai
                                DateFormat timeFormat = DateFormat("h:mm a"); // Format match karein apne data se
                                DateTime timePart = timeFormat.parse(event.time!);

                                // TODO: Aap yahan time bhi parse kar sakte hain
                                DateTime fullScheduledTime = DateTime(
                                    datePart.year,
                                    datePart.month,
                                    datePart.day,
                                    timePart.hour,
                                    timePart.minute,
                                );
                                // 4. Past Check (Agar time guzar chuka hai to notification nahi bajegi)
                                if (fullScheduledTime.isBefore(DateTime.now())) {
                                  // Agar time guzar gaya hai to agle din ke liye set karein ya error dikhayen
                                  // fullScheduledTime = fullScheduledTime.add(const Duration(days: 1));
                                  Utiles().toastMessage("Warning: Scheduled time is in the past!");
                                }

                                print("Scheduling for: $fullScheduledTime");

                                NS.scheduleNotification(
                                  id: event.docId.toString(),
                                  title: "Reminder: ${event.Event}",
                                  body: "You have an appointment today!",
                                  scheduledTime: fullScheduledTime,
                                );

                                await FirebaseFirestore.instance
                                    .collection("UserBio")
                                    .doc(profileId)
                                    .collection("Events")
                                    .doc(event.docId)
                                    .update({"isreminder": true});

                                Utiles().toastMessage("Reminder Scheduled!");

                              } catch (e) {
                                Utiles().toastMessage("Error: ${e.toString()}");

                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () {
                              if (event.docId != null) {
                                value.deleteEvent(event.docId!, profileId);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )),
          ),
        );
      }),
    );
  }}

// Ensure EventCard also checks for null before saving
class EventCard extends StatefulWidget {
  const EventCard({super.key});

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  final TextEditingController _textController = TextEditingController();

  // ... (Keep your existing toggleEditSave, _pickDate, _pickTime functions) ...

  // NOTE: Simply paste your existing controller/picker logic here or keep the class
  // The important part is the SAVE button below


  Future<void> _pickDate(BuildContext context) async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: eventProvider.date ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) eventProvider.setDate(picked);
  }

  Future<void> _pickTime(BuildContext context) async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final TimeOfDay? picked = await showTimePicker(
        context: context, initialTime: eventProvider.time ?? TimeOfDay.now());
    if (picked != null) eventProvider.setTime(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(builder: (context, value, child) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _textController,
                decoration: const InputDecoration(hintText: 'Enter event title...'),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.green),
                title: Text(value.date == null ? 'Pick Date' : DateFormat.yMMMd().format(value.date!)),
                onTap: () => _pickDate(context),
              ),
              ListTile(
                leading: const Icon(Icons.access_time, color: Colors.green),
                title: Text(value.time == null ? 'Pick Time' : value.time!.format(context)),
                onTap: () => _pickTime(context),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () async {
                  final bioProvider = Provider.of<BioProvider>(context, listen: false);

                  // --- FIX FOR SAVE BUTTON CRASH ---
                  if (bioProvider.activeProfile == null || bioProvider.activeProfile!.docId == null) {
                    Utiles().toastMessage("Error: No Profile Selected");
                    return;
                  }

                  if (_textController.text.isEmpty || value.date == null || value.time == null) {
                    Utiles().toastMessage("Please fill all details");
                    return;
                  }

                  User? user = FirebaseAuth.instance.currentUser;
                  EventModel newEvent = EventModel(
                    isreminder: false,
                    Event: _textController.text.trim(),
                    date: DateFormat.yMMMd().format(value.date!),
                    time: value.time!.format(context),
                    userId: user!.uid,
                  );

                  await value.addEvent(newEvent, bioProvider.activeProfile!.docId!);

                  Provider.of<IsAdding>(context, listen: false).setisAdding(false);
                },
                child: const Text("Save Event", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      );
    });
  }
}