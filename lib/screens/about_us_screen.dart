import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("About Us"),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Card(
            color: Color(0xff343a40),
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  InfoRow(
                    icon: Icons.location_on,
                    label: "Our Address",
                    value: "856 Cordia Extension Apt. 356, Lake, United State",
                  ),
                  const SizedBox(height: 20),
                  InfoRow(
                    icon: Icons.email,
                    label: "Email Address",
                    value: "info.colorlib@gmail.com",
                  ),
                  const SizedBox(height: 20),
                  InfoRow(
                    icon: Icons.phone,
                    label: "Phone",
                    value: "(12) 345 67890",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xffF9B236),),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 13, color: Colors.white),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
