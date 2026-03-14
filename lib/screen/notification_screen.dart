import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/app_theme.dart';
import 'package:hunt_property/cubit/notification_cubit.dart';
import 'package:hunt_property/cubit/notification_state.dart';
import 'package:hunt_property/repositories/notification_repository.dart';
import 'package:hunt_property/services/notification_service.dart';
import 'package:hunt_property/services/storage_service.dart';
import 'package:hunt_property/models/notification_models.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int selectedTab = 0;

  // "property" = Property Alerts, "plan" = Plan
  NotificationCubit? _notificationCubit;
  List<NotificationModel> notifications = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  String _currentTab = 'all';

  @override
  void initState() {
    super.initState();
    _notificationCubit = NotificationCubit(NotificationRepository(service: NotificationService()));
    _loadNotifications();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadNotifications({String tab = 'all'}) async {
    final userId = await StorageService.getUserId();
    if (userId == null || userId.isEmpty) return;
    _currentTab = tab;
    await _notificationCubit?.fetchNotifications(userId: userId, tab: tab, page: 1, limit: 20, append: false);
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    final userId = await StorageService.getUserId();
    if (userId == null || userId.isEmpty) return;
    final state = _notificationCubit?.state;
    if (state is! NotificationLoaded) return;
    if (!state.hasNext) return;

    setState(() => _isLoadingMore = true);
    final nextPage = state.page + 1;
    await _notificationCubit?.fetchNotifications(userId: userId, tab: _currentTab, page: nextPage, limit: state.limit, append: true);
    if (mounted) setState(() => _isLoadingMore = false);
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    // kept for compatibility but actual data comes from cubit
    return notifications.map((n) {
      return {
        "id": n.id,
        "type": n.type,
        "title": n.title,
        "subtitle": n.body ?? '',
        "time": _timeAgo(n.createdAt),
        "cta": n.actionText ?? '',
        "read": n.read,
      };
    }).toList();
  }

  void _removeNotification(String id) {
    // delegate to cubit
    _notificationCubit?.deleteNotification(id);
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
            child: BlocBuilder<NotificationCubit, NotificationState>(
              bloc: _notificationCubit,
              builder: (context, state) {
                if (state is NotificationLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is NotificationLoaded) {
                  notifications = state.notifications;
                  final list = notifications;
                  if (list.isEmpty) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No notifications'),
                    ));
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: list.length + (state.hasNext || _isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= list.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final item = list[index];
                      return Dismissible(
                        key: ValueKey(item.id),
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
                        onDismissed: (_) => _notificationCubit?.deleteNotification(item.id),
                        child: _notificationCardFromModel(item),
                      );
                    },
                  );
                } else if (state is NotificationError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox.shrink();
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
              onTap: () {
                setState(() => selectedTab = i);
                final tab = (i == 0) ? 'all' : (i == 1 ? 'property_alerts' : 'plan');
                _loadNotifications(tab: tab);
              },
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

  Widget _notificationCardFromModel(NotificationModel item) {
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
          // Unread indicator - green dot top right (only when unread)
          if (!item.read)
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
                      item.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.body ?? '',
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
                          _timeAgo(item.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        _greenCta(item.actionText ?? ''),
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
 
  String _timeAgo(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }

  @override
  void dispose() {
    _notificationCubit?.close();
    super.dispose();
  }
}
