import 'package:cloud_firestore/cloud_firestore.dart';

class Vinyl {
  final String id; // Document ID
  final String albumName;
  final String genre;
  final double price;
  final String albumCover;
  final String artist;
  final double quantity;

  Vinyl({
    required this.id,
    required this.albumName,
    required this.genre,
    required this.price,
    required this.albumCover,
    required this.artist,
    required this.quantity,
  });

  factory Vinyl.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    final artistReference = data['artist'] as DocumentReference;
    final artistId = artistReference.id;

    return Vinyl(
      id: snapshot.id,
      albumName: data['albumName'],
      genre: data['genre'],
      price: data['price'].toDouble(),
      albumCover: data['albumCover'],
      artist: artistId,
      quantity: data['quantity'].toDouble(),
    );
  }

  factory Vinyl.fromMap(Map<String, dynamic> map) {
    return Vinyl(
      id: map['id'],
      albumName: map['albumName'],
      genre: map['genre'],
      price: map['price'].toDouble(),
      albumCover: map['albumCover'],
      artist: map['artist'],
      quantity: map['quantity'].toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'albumCover': albumCover,
      'albumName': albumName,
      'artist': artist,
      'genre': genre,
      'price': price,
      'quantity': quantity,
    };
  }
}
