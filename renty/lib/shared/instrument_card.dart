import 'package:flutter/material.dart';

class InstrumentCard extends StatelessWidget {
  final String name;
  final String price;
  final String imageUrl;
  final bool isForRent;

  const InstrumentCard({
    super.key,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.isForRent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
              const Center(child: Icon(Icons.error)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$$price',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.deepPurple,
                      ),
                    ),
                    if (isForRent)
                      const Chip(
                        label: Text('For Rent'),
                        backgroundColor: Colors.deepPurple,
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}