import 'package:flutter/material.dart';

class OpportunityCard extends StatelessWidget {

  final String company;
  final String position;
  final String location;

  const OpportunityCard({
    super.key,
    required this.company,
    required this.position,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(bottom: 15),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            Row(
              children: [

                CircleAvatar(
                  radius: 24,
                  child: Icon(Icons.business),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Text(
                        position,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      Text(company),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              children: [

                const Icon(
                  Icons.location_on,
                  size: 18,
                ),

                Text(location),

                const Spacer(),

                ElevatedButton(
                  onPressed: () {},

                  child: const Text("Apply"),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}