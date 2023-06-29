import 'package:cloud_firestore/cloud_firestore.dart';

class Artist {
  final String artistName;
  final String artistImage;
  final List<DocumentReference> vinyls;

  Artist({
    required this.artistName,
    required this.artistImage,
    required this.vinyls,
  });

  factory Artist.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    final artistName = data['artistName'] as String;
    final artistImage = data['artistImage'] as String;
    final vinylRefs = List<DocumentReference>.from(data['vinyls'] ?? []);
    return Artist(
      artistName: artistName,
      artistImage: artistImage,
      vinyls: vinylRefs,
    );
  }
}
