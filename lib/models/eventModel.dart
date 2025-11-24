class EventModel {
  String Event;
  String? date; // Ab ye String hai
  String? time; // Ab ye String hai
  String? userId;
  EventModel(this.Event, this.date, this.time,{this.userId});

  // Map mein convert karte waqt simple strings jayenge
  static Map<String, dynamic> toMap(EventModel event,  context) {
    return {
      "Event": event.Event,
      "Date": event.date,
      "Time": event.time,
      "userId": event.userId,
    };
  }

  // Firebase se data late waqt direct String uthayenge
  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      map["Event"],
      map["Date"], // Direct String
      map["Time"], // Direct String
      userId: map["userId"],
    );
  }
}