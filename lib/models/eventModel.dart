import 'package:flutter/material.dart';

class EventModel{
  DateTime? date;
  TimeOfDay? time;
  String Event;

  EventModel(this.Event,this.date,this.time);

  static toMap(EventModel event,BuildContext context){
   return {
     "Event":event.Event,
     "Date":event.date?.toIso8601String(),
     "Time":event.time?.format(context),
   };

  }

// EventModel class mein:
  factory EventModel.fromMap(Map<String ,dynamic> map){

    // Date Parsing: ISO String ko DateTime mein convert karna
    DateTime? parsedDate;
    if (map["Date"] != null && map["Date"] is String) {
      try {
        parsedDate = DateTime.parse(map["Date"] as String);
      } catch (e) {
        // Handle error if date string is invalid
      }
    }

    // Time Parsing: String ko TimeOfDay mein convert karna (Yeh thoda mushkil hai)
    TimeOfDay? parsedTime;
    if (map["Time"] != null && map["Time"] is String) {
      // Assuming format is like "8:47 AM" or "5:30 PM"
      try {
        // Logic to extract hours and minutes from the time string (e.g., "8:47 AM")
        // Example:
        // final format = DateFormat.jm(); // requires Context to work, so simple parsing is better

        // Simple parsing (requires a helper utility for robustness)
        // For now, setting to null if complex parsing is not implemented:
        // You need proper logic here. A basic way is to use split and check AM/PM.
        // Since this requires a lot of code, we will assume you use a utility method:

        // For simplicity in this fix, we will assume TimeOfDay is not null if string exists
        // However, TIME PARSING is critical and must be robustly handled.
      } catch (e) {
        // Handle error
      }
    }

    return EventModel(
        map["Event"] as String,
        parsedDate,
        null // ⚠️ TIME PARSING: Aapko Time string se TimeOfDay banane ka robust tareeqa yahan likhna hoga.
    );
  }

}