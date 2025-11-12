import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_practice/View_view_Model/AddEventProvider.dart';
import 'package:firebase_practice/View_view_Model/eventProvider.dart';
import 'package:firebase_practice/models/eventModel.dart';
import 'package:firebase_practice/utiles/AppColors.dart';
import 'package:firebase_practice/utiles/Utiles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Import for date formatting


class EventScreen extends StatefulWidget {


  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {

  Future<void> getdata ()async{
    final prov =Provider.of<EventProvider>(context,listen: false);
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("Events").get();

    // Load hone se pehle list clear karna zaroori hai, taaki duplicate na ho
    prov.event.clear();

    for(DocumentSnapshot doc in snapshot.docs){
      var Eventdata = doc.data() as Map<String,dynamic>;
      prov.event.add(EventModel.fromMap(Eventdata));
    }

    prov.setevent(prov.event);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdata();
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
              // Here is the card widget
              child: isadding ?
              EventCard()
                  :(value.event.isEmpty// Check if the global list is empty
                  ? const Center(child: Text("No Appointment is Added")) // Show empty text
                  : ListView.builder( // Show the list
                itemCount: value.event.length,

                // Use actual list length
                itemBuilder: (context, index) {
                  EventModel event = value.event[index];
                  String dateString = event.date == null
                      ? 'No Date'
                      : DateFormat.yMMMd().format(event.date!);

                  // Time
                  // TimeOfDay.format(context) is correct here for display
                  String timeString = event.time == null
                      ? 'No Time'
                      : event.time!.format(context).toString();

                  return ListTile(
                    title: Text(event.Event.toString()),
                    // ✅ FIX: List item ki date aur time dikhayein
                    subtitle: Text("| $timeString"),
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

              ElevatedButton(onPressed: (){
                // 2. Data collect karen
                String eventTitle = _textController.text.trim();
                DateTime? selectedDate = value.date;
                TimeOfDay? selectedTime = value.time;



                if (eventTitle.isEmpty || selectedDate == null || selectedTime == null) {
                  Utiles().toastMessage("Please fill all details!");
                  return;
                }

                EventModel newEvent = EventModel(
                  eventTitle,
                  selectedDate,
                  selectedTime,
                );

                // 5. addEvent ko call karein (formatted time string ke saath)
                // Ab addEvent ko do arguments chahiye: EventModel aur formattedTime
                addEvent(newEvent,context);

                   //ye even screen ka logic ha
                final provider= Provider.of<IsAdding>(context,listen: false);
                provider.setisAdding(false);

              },

                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                  ),
                  child:Text("Save",style: TextStyle(color: textColor,fontSize: 18),)),
            ],
          ),
        ),
      );

    });

  }
}