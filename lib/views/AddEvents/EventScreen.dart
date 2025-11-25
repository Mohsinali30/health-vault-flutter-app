import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_practice/View_view_Model/AddEventProvider.dart';
import 'package:firebase_practice/View_view_Model/eventProvider.dart';
import 'package:firebase_practice/models/eventModel.dart';
import 'package:firebase_practice/utiles/AppColors.dart';
import 'package:firebase_practice/utiles/Utiles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Import for date formatting


///Event Display Screen
class EventScreen extends StatefulWidget {
  const EventScreen({super.key});
  @override
  State<EventScreen> createState() => _EventScreenState();
}
class _EventScreenState extends State<EventScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    final prov=  Provider.of<EventProvider>(context, listen: false);
    prov.getdata();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider= Provider.of<IsAdding>(context);
    bool isadding = provider.isadding;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Appointment'),
        actions: [GestureDetector(
            onTap: (){
              provider.setisAdding(true);
            },
            child: Icon(Icons.add,color: Colors.white,size: 28,))],
        backgroundColor: Colors.green,
      ),
      body:  Consumer<EventProvider>(builder: (context,value,child){
        return
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: isadding ?
              EventCard()
                  :(value.event.isEmpty
                  ? const Center(child: Text("No Appointment is Added"))
                  : ListView.builder(
                itemCount: value.event.length,
                itemBuilder: (context, index) {
                  EventModel event = value.event[index];
                  String dateString = event.date == null
                      ? 'No Date'
                      : event.date.toString();

                  // Time
                  // TimeOfDay.format(context) is correct here for display
                  String timeString = event.time == null
                      ? 'No Time'
                      : event.time.toString();

                  return ListTile(
                    title: Text(event.Event.toString()),
                    // ✅ FIX: List item ki date aur time dikhayein
                    subtitle: Text("$dateString| $timeString"),
                    leading:Icon(Icons.access_time,color: primaryGreen,size: 28,),
                    trailing: IconButton(onPressed: (){
                      value.deleteEvent(event.docId.toString());
                    }, icon: Icon(Icons.delete_outline_outlined,color: Colors.black,size: 28,)),
                  );

                },
              )
              ),

            ),
          );

      }));




  }
}

/// A stateful widget that manages its own edit/display state.
/// ADD Event Screen and Manage date time
class EventCard extends StatefulWidget {
  const EventCard({super.key});

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  // State variables

  final TextEditingController _textController = TextEditingController();


  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// Toggles between editing and saving.
  void _toggleEditSave() {
    final eventProvider =Provider.of<EventProvider>(context,listen: false);
    // Get the CURRENT state
    final wasEditing = eventProvider.isEditing;
      eventProvider.setisEditing(!wasEditing);
    if(wasEditing){
      // "Save" action was pressed
      // In a real app, you would save this data to your database
      // or state management solution.
      print('Saved: ${_textController.text.toString()}');
      print('Date: ${eventProvider.date}');
      print('Time: ${eventProvider.time}');

    }
  }

  /// Shows the date picker dialog.
  Future<void> _pickDate(BuildContext context) async {
    final eventProvider =Provider.of<EventProvider>(context,listen: false);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: eventProvider.date ?? DateTime.now(),
      firstDate: DateTime(DateTime.now().day),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != eventProvider.date) {
     eventProvider.setDate(picked);
    }
  }

  /// Shows the time picker dialog.
  Future<void> _pickTime(BuildContext context) async {
    final eventProvider =Provider.of<EventProvider>(context,listen: false);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: eventProvider.time ?? TimeOfDay.now(),
    );
    if (picked != null && picked != eventProvider.time) {
      eventProvider.setTime(picked);
    }
  }

  void addEvent(EventModel event,BuildContext context)async{
     FirebaseFirestore db= FirebaseFirestore.instance;
       try {
         await db.collection("Events").doc(DateTime
             .now()
             .millisecondsSinceEpoch
             .toString()).set(
             EventModel.toMap(event,context)
         ).then((value) =>
         {
           Utiles().toastMessage("Added Successfully"),
         });
       }catch(e){
         Utiles().toastMessage(e.toString());
       }
  }
  @override
  Widget build(BuildContext context) {
    return
      Consumer<EventProvider>(builder: (context,value,child){
      bool isEditing= value.isEditing;
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Make the card wrap its content
            children: [
              // Row for Text Field and Edit/Save Button
              Row(
                children: [
                  // The main text input
                  Expanded(
                    child: isEditing
                        ? TextField(
                      controller: _textController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Enter your event title...',
                        border: OutlineInputBorder(),

                      ),
                    )
                        : Text(
                      _textController.text.isEmpty
                          ? 'No Event Title'
                          : _textController.text,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  // The Edit/Save icon button
                  IconButton(
                    icon: Icon(isEditing ? Icons.save : Icons.edit,color: primaryGreen,),
                    onPressed: _toggleEditSave,
                    tooltip: isEditing ? 'Save' : 'Edit',
                  ),
                ],
              ),
              const Divider(),
              // Row for Calendar Picker
              ListTile(
                leading: const Icon(Icons.calendar_today,color: primaryGreen,),
                title: Text(
                  value.date == null
                      ? 'Pick Date'
                      : DateFormat.yMMMd().format(value.date!), // 'Nov 7, 2025'
                ),
                onTap: isEditing ? () => _pickDate(context) : null,
                enabled: isEditing,
              ),
              // Row for Time Picker
              ListTile(
                leading: const Icon(Icons.access_time,color: primaryGreen,),
                title: Text(
                  value.time == null
                      ? 'Pick Time'
                      : value.time!.format(context), // '9:44 PM'
                ),
                onTap: isEditing ? () => _pickTime(context) : null,
                enabled: isEditing,
              ),
              const Divider(),
              SizedBox(height: 8,),

              ElevatedButton(
                onPressed: () {
                  // 1. Data collect karen
                  String eventTitle = _textController.text.trim();

                  // Provider se DateTime aur TimeOfDay le rahe hain
                  DateTime? selectedDate = value.date;
                  TimeOfDay? selectedTime = value.time;

                  // Check validation
                  if (eventTitle.isEmpty || selectedDate == null || selectedTime == null) {
                    Utiles().toastMessage("Please fill all details!");
                    return;
                  }

                  // 1. Current User ki ID nikalein
                  User? user = FirebaseAuth.instance.currentUser;

                  if (user == null) {
                    Utiles().toastMessage("User not logged in!");
                    return;
                  }

                  // 2. CONVERSION (Yahan magic hoga)
                  // DateTime ko String banaya (e.g., "Nov 25, 2025")
                  String formattedDate = DateFormat.yMMMd().format(selectedDate);

                  // TimeOfDay ko String banaya (e.g., "8:30 PM")
                  String formattedTime = selectedTime.format(context);

                  // 3. Model Create (Ab hum String pass kar rahe hain)
                  EventModel newEvent = EventModel(
                    eventTitle,
                    formattedDate, // String
                    formattedTime, // String
                      userId:user.uid,
                  );

                  // 4. Save to Firebase
                  addEvent(newEvent, context);

                  // 5. Close screen / logic
                  final provider = Provider.of<IsAdding>(context, listen: false);
                  provider.setisAdding(false);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                ),
                child: Text(
                  "Save",
                  style: TextStyle(color: textColor, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      );

    });

  }
}