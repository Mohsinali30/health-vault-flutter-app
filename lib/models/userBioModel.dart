class BioModel {
  String fullname;
  String? email;
  String? dob;
  String? gender;
  String? bgroup;
  String? userId;


  BioModel({required this.fullname, this.email, this.dob, this.gender,this.bgroup,this.userId});

  // Map mein convert karte waqt simple strings jayenge
  static Map<String, dynamic> toMap(BioModel bio,  context) {
    return {
      "FullName":bio.fullname,
      "Email":bio.email,
      "DOB": bio.dob,
      "Gender": bio.gender,
      "BloodGroup": bio.bgroup,
      "userId": bio.userId,
    };
  }

  // Firebase se data late waqt direct String uthayenge
  factory BioModel.fromMap(Map<String, dynamic> map) {
    return BioModel(
      fullname: map["FullName"] ?? "No Name",
      email: map["Email"] ?? "No email",
      dob :map["DOB"], // Direct String
      gender:  map["Gender"],
      bgroup: map["BloodGroup"],
      userId: map["userId"]
    );
  }
}