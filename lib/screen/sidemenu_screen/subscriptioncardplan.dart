import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hunt_property/screen/widget/subscriptioncard.dart';

class MySubscriptionCardScreen extends StatelessWidget {
  const MySubscriptionCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,

        title: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFF2F4F7),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: Colors.black,
                ),
              ),
            ),

            const Spacer(),

            Text(
              "My Subscription",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),

            const Spacer(),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: const [
            SizedBox(height: 10),

            SubscriptionCard(
              planName: "Gold PLAN",
              planId: "586425",
              expiryDate: "Oct 24, 2026",
              daysRemaining: 120,
              isActive: true,
            ),

            SubscriptionCard(
              planName: "Gold PLAN",
              planId: "584425",
              expiryDate: "Oct 24, 2025",
              daysRemaining: 0,
              isActive: false,
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
