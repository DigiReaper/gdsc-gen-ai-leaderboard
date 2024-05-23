import 'package:cloud_firestore/cloud_firestore.dart';

class Participant {
  final bool arcade;
  final String email;
  final bool genaiApps;
  final String name;
  final bool promptDesign;
  final bool totalCompletion;
  final String url;

  Participant({
    required this.arcade,
    required this.email,
    required this.genaiApps,
    required this.name,
    required this.promptDesign,
    required this.totalCompletion,
    required this.url,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      arcade: json['arcade'],
      email: json['email'],
      genaiApps: json['genai_apps'],
      name: json['name'],
      promptDesign: json['prompt_design'],
      totalCompletion: json['total_completion'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'arcade': arcade,
      'email': email,
      'genai_apps': genaiApps,
      'name': name,
      'prompt_design': promptDesign,
      'total_completion': totalCompletion,
      'url': url,
    };
  }

    final CollectionReference collection = FirebaseFirestore.instance.collection('user_data');


  Future<List<Participant>> getData() async {
    QuerySnapshot querySnapshot = await collection.get();
    return querySnapshot.docs
        .where((doc) => doc.data() != null)
        .map((doc) => Participant.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

}



  List<Participant> dummyParticipants = [
    Participant(
      arcade: false,
      email: "21211a6636.genai@gmail.com",
      genaiApps: false,
      name: "Avinash Neela",
      promptDesign: false,
      totalCompletion: false,
      url: "https://www.cloudskillsboost.google/public_profiles/9658993d-8a58-405c-93b5-e72963269e1b",
    ),
    Participant(
      arcade: true,
      email: "dummy2@gmail.com",
      genaiApps: true,
      name: "Dummy User 2",
      promptDesign: true,
      totalCompletion: true,
      url: "https://www.example.com/dummy2",
    ),

    
    // Add more dummy data here
  ];