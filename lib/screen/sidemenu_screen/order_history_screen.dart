import 'package:flutter/material.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Order History",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: const [
            OrderCard(
              title: "Owner-Metal-0 / 114107135936",
              date: "2025-11-20 19:32:59",
              status: "Invalid",
              statusColor: Color(0xFFF4D7CE),
              statusTextColor: Color(0xFFBC6F63),
            ),
            SizedBox(height: 16),
            OrderCard(
              title: "Owner-Gold -3500 /",
              date: "2025-11-20 19:33:07",
              status: "Pending",
              statusColor: Color(0xFFFFE6E6),
              statusTextColor: Color(0xFFE57373),
            ),
            SizedBox(height: 16),
            OrderCard(
              title: "Owner-Gold -5200 /",
              date: "2025-11-20 11:33:07",
              status: "Success",
              statusColor: Color(0xFFD8F5DD),
              statusTextColor: Color(0xFF4CAF50),
            ),
          ],
        ),
      ),
    );
  }
}

/// ------------------------
/// ORDER CARD WIDGET
/// ------------------------

class OrderCard extends StatelessWidget {
  final String title;
  final String date;
  final String status;
  final Color statusColor;
  final Color statusTextColor;

  const OrderCard({
    super.key,
    required this.title,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.statusTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F7FF), // light blue background
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.black.withOpacity(0.08), // light grey border
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header Row
          Row(
            children: [
              // Icon bubble
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFE9F1FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: Color(0xFF6A87C8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// Divider
          Container(
            height: 1,
            color: Colors.black.withOpacity(0.1),
          ),

          const SizedBox(height: 16),

          /// Bottom Row
          Row(
            children: [
              /// Date section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Date",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              /// Status Chip
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusTextColor,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              /// Download icon
              const Icon(
                Icons.download_rounded,
                size: 22,
                color: Color(0xFF6A87C8),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

