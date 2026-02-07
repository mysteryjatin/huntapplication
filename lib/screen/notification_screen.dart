import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int selectedTab = 0;

  // "property" = Property Alerts, "plan" = Plan
  late List<Map<String, dynamic>> notifications;

  @override
  void initState() {
    super.initState();
    notifications = [
      {
        "id": "1",
        "type": "property",
        "title": "Price dropped by \$20k!",
        "subtitle":
            "Modern Villa with Pool in Beverly Hills is now available at a lower price...",
        "time": "2 MINS AGO",
        "cta": "View Details",
      },
      {
        "id": "2",
        "type": "property",
        "title": "New Listing in Austin",
        "subtitle": "A 3 BHK Apartment just went live in your area...",
        "time": "15 mins ago",
        "cta": "Book Visit",
      },
      {
        "id": "3",
        "type": "plan",
        "title": "Subscription Expiring",
        "subtitle": "Your Gold Plan subscription will expire in 3 days",
        "time": "3 hours ago",
        "cta": "Renew Now",
      },
      {
        "id": "4",
        "type": "property",
        "title": "Plot available near Airport",
        "subtitle": "A new plot is available near the airport...",
        "time": "5 hours ago",
        "cta": "View Details",
      },
    ];
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    if (selectedTab == 0) return notifications; // All
    if (selectedTab == 1) {
      return notifications.where((n) => n["type"] == "property").toList();
    }
    return notifications.where((n) => n["type"] == "plan").toList(); // Plan
  }

  void _removeNotification(String id) {
    setState(() {
      notifications.removeWhere((n) => n["id"] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
      ),
      body: Column(
        children: [
          _filterChips(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _filteredNotifications.length,
              itemBuilder: (context, index) {
                final item = _filteredNotifications[index];
                return Dismissible(
                  key: ValueKey(item["id"]),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                  ),
                  confirmDismiss: (_) => _showDeleteDialog(context),
                  onDismissed: (_) => _removeNotification(item["id"] as String),
                  child: _notificationCard(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- FILTER TABS ----------------

  Widget _filterChips() {
    const labels = ["All", "Property Alerts", "Plan"];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(labels.length, (i) {
          final isSelected = selectedTab == i;
          return Padding(
            padding: EdgeInsets.only(right: i < labels.length - 1 ? 10 : 0),
            child: GestureDetector(
              onTap: () => setState(() => selectedTab = i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryColor : AppColors.primaryColor.withOpacity(0.6),
                    width: 1,
                  ),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.primaryColor,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ---------------- NOTIFICATION CARD ----------------

  Widget _notificationCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.06), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Unread indicator - green dot top right
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left circular icon - house outline
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.home_outlined,
                  size: 22,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item["title"] as String? ?? "",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item["subtitle"] as String? ?? "",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 6),
                        Text(
                          item["time"] as String? ?? "",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        _greenCta(item["cta"] as String? ?? ""),
                      ],
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

  // ---------------- GREEN CTA BUTTON ----------------

  Widget _greenCta(String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward, size: 14, color: Colors.white),
          ],
        ),
      ),
    );
  }

  // ---------------- DELETE DIALOG ----------------

  Future<bool> _showDeleteDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text("Delete notification?"),
        content: const Text("Are you sure you want to delete this notification?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    ) ?? false;
  }
}
