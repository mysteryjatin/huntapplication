import 'package:flutter/material.dart';
import 'package:hunt_property/theme/app_theme.dart';

class SubscriptionCard extends StatelessWidget {
  final String planName;
  final String planId;
  final String expiryDate;
  final int daysRemaining;
  final bool isActive;

  const SubscriptionCard({
    super.key,
    required this.planName,
    required this.planId,
    required this.expiryDate,
    required this.daysRemaining,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    const int maxDays = 120;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0E233A),
            Color(0xFF122B46),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),

      child: Stack(
        children: [
          /// 👑 WATERMARK
          Positioned(
            right: -6,
            top: 20,
            child: Opacity(
              opacity: 0.10,
              child: Icon(
                Icons.workspace_premium_outlined,
                size: 120,
                color: Colors.white,
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ---------- HEADER ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "CURRENT PLAN - ID/$planId",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF16BE72) // Active Green
                          : const Color(0xFFE53935), // Inactive Red
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isActive ? "Active" : "Inactive",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              /// ---------- PLAN NAME ----------
              Text(
                planName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isActive
                      ? AppColors.primaryColor
                      : Colors.white.withOpacity(0.55), // 👈 inactive light
                ),
              ),

              const SizedBox(height: 12),

              /// ---------- EXPIRY ----------
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 14, color: Colors.white.withOpacity(0.7)),
                  const SizedBox(width: 6),
                  Text(
                    "Expires on $expiryDate",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// ---------- DAYS REMAINING ----------
              Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withOpacity(0.08)
                      : Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Days Remaining",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "$daysRemaining Days",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    /// PROGRESS BAR
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final progress =
                          (daysRemaining / maxDays).clamp(0.0, 1.0);

                          return Stack(
                            children: [
                              Container(
                                height: 6,
                                width: double.infinity,
                                color: Colors.white.withOpacity(0.25),
                              ),
                              Container(
                                height: 6,
                                width: constraints.maxWidth * progress,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? const Color(0xFF2FED9A)
                                      : Colors.white.withOpacity(0.35),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
