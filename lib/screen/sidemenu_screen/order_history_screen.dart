import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hunt_property/cubit/order_history_cubit.dart';
import 'package:hunt_property/models/order_history_models.dart';
import 'package:hunt_property/services/order_history_service.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late final OrderHistoryCubit _cubit;
  final ScrollController _scrollController = ScrollController();
  final List<String> _tabs = ['All', 'Pending', 'Success', 'Invalid'];
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _cubit = OrderHistoryCubit(OrderHistoryService());
    _cubit.load(status: _statusForIndex(0));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 200) {
      _cubit.loadMore();
    }
  }

  String _statusForIndex(int index) {
    switch (index) {
      case 1:
        return 'pending';
      case 2:
        return 'success';
      case 3:
        return 'invalid';
      case 0:
      default:
        return 'all';
    }
  }

  void _onTabTap(int index) {
    setState(() => _selectedTabIndex = index);
    _cubit.load(status: _statusForIndex(index));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            onPressed: () => Navigator.pop(context),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter tabs
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SizedBox(
                  height: 42,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _tabs.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedTabIndex == index;
                      return GestureDetector(
                        onTap: () => _onTabTap(index),
                            child: Container(
                              margin: EdgeInsets.only(
                                left: index == 0 ? 0 : 8,
                                right: index == _tabs.length - 1 ? 0 : 0,
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF6A87C8)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF6A87C8)
                                      : Colors.black.withOpacity(0.15),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _tabs[index],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                ),
              ),

              // Order list
              Expanded(
                child: BlocBuilder<OrderHistoryCubit, OrderHistoryState>(
                  builder: (context, state) {
                    if (state is OrderHistoryLoading ||
                        state is OrderHistoryInitial) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF6A87C8),
                        ),
                      );
                    }

                    if (state is OrderHistoryError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      );
                    }

                    if (state is OrderHistoryLoaded &&
                        state.orders.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.description_outlined,
                              size: 80,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No orders found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is OrderHistoryLoaded) {
                      final orders = state.orders;
                      return ListView.builder(
                        controller: _scrollController,
                        itemCount:
                            orders.length + (state.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= orders.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF6A87C8),
                                ),
                              ),
                            );
                          }
                          return OrderCard(order: orders[index]);
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ------------------------
/// ORDER CARD WIDGET
/// ------------------------

class OrderCard extends StatelessWidget {
  final OrderItem order;

  const OrderCard({super.key, required this.order});

  static ({Color bg, Color text}) _statusColors(String status) {
    final s = status.toLowerCase();
    if (s == 'success') {
      return (bg: const Color(0xFFD8F5DD), text: const Color(0xFF4CAF50));
    }
    if (s == 'pending') {
      return (bg: const Color(0xFFFFE6E6), text: const Color(0xFFE57373));
    }
    if (s == 'invalid') {
      return (bg: const Color(0xFFF4D7CE), text: const Color(0xFFBC6F63));
    }
    return (bg: const Color(0xFFE9F1FF), text: const Color(0xFF6A87C8));
  }

  static String _formatStatus(String status) {
    if (status.isEmpty) return status;
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final statusColors = _statusColors(order.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F7FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.black.withOpacity(0.08),
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
          Row(
            children: [
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
                  order.title,
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
          Container(
            height: 1,
            color: Colors.black.withOpacity(0.1),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
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
                    _formatDate(order.createdAt),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColors.bg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _formatStatus(order.status),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColors.text,
                  ),
                ),
              ),
              const SizedBox(width: 10),
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
