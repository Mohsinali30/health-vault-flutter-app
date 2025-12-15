class EventModel {
  bool isreminder ;
  String? docId;
  String Event;
  String? date; // Ab ye String hai
  String? time; // Ab ye String hai
  String? userId;


  EventModel({this.isreminder= false,required this.Event, this.date, this.time,this.userId,this.docId});

  // Map mein convert karte waqt simple strings jayenge
  static Map<String, dynamic> toMap(EventModel event) {
    return {
      "isreminder":event.isreminder,
      "Event": event.Event,
      "Date": event.date,
      "Time": event.time,
      "userId": event.userId,
    };
  }

  // Firebase se data late waqt direct String uthayenge
  factory EventModel.fromMap(Map<String, dynamic> map,String id) {
    return EventModel(
      isreminder: map["isreminder"] ?? false,
      Event: map["Event"] ?? "No title",
      date :map["Date"], // Direct String
     time:  map["Time"],
      userId: map["userId"],
      docId: id,
    );
  }
}