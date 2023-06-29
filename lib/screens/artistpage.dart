import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recordmmend/widgets/vinylcard.dart';
import 'package:recordmmend/model/vinyl.dart';

class ArtistPage extends StatefulWidget {
  final String artistId;

  ArtistPage({required this.artistId});

  @override
  _ArtistPageState createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Artist Page'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('artist')
            .doc(widget.artistId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.exists) {
            final artistData = snapshot.data!.data() as Map<String, dynamic>;
            final artistName = artistData['artistName'];
            final artistImage = artistData['artistImage'];
            final List<DocumentReference> vinylRefs =
                List<DocumentReference>.from(artistData['vinyls'] ?? []);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 16),
                CircleAvatar(
                  backgroundImage: NetworkImage(artistImage),
                  radius: 50,
                ),
                SizedBox(height: 16),
                Text(
                  artistName,
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(height: 16),
                Text(
                  'Our Collection:',
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('vinyl')
                        .where(FieldPath.documentId,
                            whereIn: vinylRefs.map((ref) => ref.id).toList())
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final List<DocumentSnapshot> documents =
                            snapshot.data!.docs;
                        return ListView.builder(
                          itemCount: documents.length,
                          itemBuilder: (context, index) {
                            final vinyl = Vinyl.fromSnapshot(documents[index]);
                            return VinylCard(
                              vinyl: vinyl,
                              artistName: artistName,
                            );
                          },
                        );
                      }
                      return CircularProgressIndicator();
                    },
                  ),
                ),
              ],
            );
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}
