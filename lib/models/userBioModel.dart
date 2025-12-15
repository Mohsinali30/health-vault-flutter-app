class BioModel {
  String? docId;
  String fullname;
  String? email;
  String? dob;
  String? gender;
  String? bgroup;
  String? userId;
  String? Profileimage;
  String? Relation;


  BioModel({this.docId,required this.fullname, this.email, this.dob, this.gender,this.bgroup,this.userId,this.Profileimage,this.Relation});

  // Map mein convert karte waqt simple strings jayenge
  static Map<String, dynamic> toMap(BioModel bio,  context) {
    return {
      "FullName":bio.fullname,
      "Email":bio.email,
      "DOB": bio.dob,
      "Gender": bio.gender,
      "BloodGroup": bio.bgroup,
      "userId": bio.userId,
      "ProfileImage":bio.Profileimage,
      "Relation":bio.Relation,
    };
  }

  // Firebase se data late waqt direct String uthayenge
  factory BioModel.fromMap(Map<String, dynamic> map,String idFromFirestore) {
    return BioModel(
        docId:idFromFirestore,
        fullname: map["FullName"] ?? "No Name",
      email: map["Email"] ?? "No email",
      dob :map["DOB"], // Direct String
      gender:  map["Gender"],
      bgroup: map["BloodGroup"],
      userId: map["userId"],
        Profileimage: map["ProfileImage"],
        Relation: map["Relation"]
    );
  }
}