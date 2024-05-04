import 'package:flutter/material.dart';

class McqsCard extends StatelessWidget {
  const McqsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          color: Colors.deepPurpleAccent.shade100,
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  "How many time you eat toaday ?",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
