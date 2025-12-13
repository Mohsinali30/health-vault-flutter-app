import 'package:firebase_practice/View_view_Model/eventProvider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../models/eventModel.dart';
import '../../utiles/event_notification.dart';
// Apne models aur imports yahan lagayen

class ReminderView extends StatefulWidget {
  const ReminderView({super.key});

  @override
  State<ReminderView> createState() => _ReminderViewState();
}
class _ReminderViewState extends State<ReminderView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   WidgetsBinding.instance.addPostFrameCallback((_){
     final prov=  Provider.of<EventProvider>(context,listen: false);
     prov.getdata();
   });
  }

  @override
  Widget build(BuildContext context) {
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    return
      Consumer<EventProvider>(builder: (context,value,child){
        return Scaffold(
          appBar: AppBar(title: Text("My Reminders"), backgroundColor: Colors.green),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("Events")
                .where('userId', isEqualTo: uid) // Sirf apka data
                .where('isreminder', isEqualTo: true) //  MAGIC FILTER: Sirf Active Reminders
                .snapshots(),
            builder: (context, snapshot) {

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text("No Reminders Set"));
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  // Model mein convert karein
                  EventModel event = EventModel.fromMap(data, snapshot.data!.docs[index].id);

                  // ListView.builder ke andar return karein:

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Bahar ki spacing
                    child: Card(
                      elevation: 4, // Halka sa shadow
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15), // Gol kinare
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0), // Andar ki spacing
                        child: ListTile(
                          // Leading: Green Circle with Icon
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1), // Halka green background
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.notifications_active, color: Colors.green, size: 24),
                          ),

                          // Title: Bold Text
                          title:
                          Text(
                            event.Event,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),

                          // Subtitle: Date with small icon
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Row(children: [
                                  Text(
                                    event.date ?? "No Date",
                                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                  ),
                                  Text("  | "),
                                  Text(
                                    event.time ?? "No Time",
                                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                  ),
                                ],)
                              ],
                            ),
                          ),

                          // Trailing: Delete Button
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            tooltip: 'Remove Reminder',
                            onPressed: () async {
                              // Functionality wahi purani
                              NotificationService().cancelNotification(event.docId.toString().hashCode);
                              value.deleteReminder(event.docId.toString());

                            },
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