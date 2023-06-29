import 'package:flutter/material.dart';
import 'package:recordmmend/model/vinyl.dart';
import 'package:recordmmend/screens/vinylpage.dart';

class VinylCard extends StatelessWidget {
  final Vinyl vinyl;
  final String artistName;

  VinylCard({required this.vinyl, required this.artistName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Card(
        child: ListTile(
          leading: Image.network(
            vinyl.albumCover,
            width: 50,
            height: 50,
          ),
          title: Flexible(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VinylPage(vinyl: vinyl),
                  ),
                );
              },
              child: Text(
                vinyl.albumName,
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          subtitle: Text(
            artistName != null ? artistName : 'Unknown Artist',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          trailing: Text('\$${vinyl.price.toStringAsFixed(2)}'),
        ),
      ),
    );
  }
}
