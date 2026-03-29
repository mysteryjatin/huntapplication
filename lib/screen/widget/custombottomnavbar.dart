import 'package:flutter/material.dart';
import 'dart:math' as math;

class CustomBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
  late int _previousIndex;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.selectedIndex;
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _waveAnimation = CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(covariant CustomBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _previousIndex = oldWidget.selectedIndex;
      _waveController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    // Keeps the bar above the Android system nav (3-button) / home indicator.
    // On full-gesture phones viewPadding.bottom is usually 0 → same layout as before.
    final double bottomInset = MediaQuery.of(context).viewPadding.bottom;
    double itemWidth = MediaQuery.of(context).size.width / 5;
    double currentX =
        (itemWidth * widget.selectedIndex) + (itemWidth / 2) - 36;
    double previousX =
        (itemWidth * _previousIndex) + (itemWidth / 2) - 36;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: 90,
        child: Stack(
        clipBehavior: Clip.none,
        children: [
          // MAIN BOTTOM BAR
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 70,
              decoration: const BoxDecoration(
                color: Color(0xFF2FED9A),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(26),
                  topRight: Radius.circular(26),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem(Icons.home, "Home", 0),
                  _navItem(Icons.search, "Search", 1),
                  _navItem(Icons.add, "Add", 2),
                  _navItem(Icons.favorite, "Shortlist", 3),
                  _navItem(Icons.person, "Profile", 4),
                ],
              ),
            ),
          ),

          // OUTGOING ICON WAVE (previously active)
          AnimatedBuilder(
            animation: _waveAnimation,
            builder: (context, child) {
              if (_previousIndex == widget.selectedIndex ||
                  _waveController.isDismissed) {
                return const SizedBox.shrink();
              }

              // Reverse wave: sink slightly while shrinking and fading
              final t = _waveAnimation.value;
              final dy = 8 * math.sin(math.pi * t);
              final scale = 1.0 - 0.6 * t;
              final opacity = 1.0 - t;

              return Positioned(
                top: -22 + dy,
                left: previousX,
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 62,
                          height: 62,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2FED9A),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _icons[_previousIndex],
                            color: Colors.black.withOpacity(0.7),
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // FLOATING SELECTED ICON WITH "WAVE" ANIMATION (incoming / active)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            top: -22,
            left: currentX,
            child: AnimatedBuilder(
              animation: _waveAnimation,
              builder: (context, child) {
                // Simple vertical wave: float up and down once on tab change
                final dy = -8 * math.sin(math.pi * _waveAnimation.value);
                return Transform.translate(
                  offset: Offset(0, dy),
                  child: child,
                );
              },
              child: GestureDetector(
                // Even if same tab selected (e.g. Home), tapping big circle
                // should still trigger onItemSelected to allow reset logic.
                onTap: () => widget.onItemSelected(widget.selectedIndex),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 300),
                      scale: 1.1,
                      curve: Curves.easeOutBack,
                      child: Container(
                        width: 62,
                        height: 62,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2FED9A),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _icons[widget.selectedIndex],
                          color: Colors.black,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  // NAV ITEM WIDGET (NO TEXT JUMP)
  Widget _navItem(IconData icon, String label, int index) {
    final bool isSelected = widget.selectedIndex == index;

    return GestureDetector(
      onTap: () => widget.onItemSelected(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isSelected ? 0.0 : 1.0, // fade instead of remove
            child: Icon(
              icon,
              color: Colors.black,
              size: 26,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(isSelected ? 1 : 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ICON LIST
const List<IconData> _icons = [
  Icons.home,
  Icons.search,
  Icons.add,
  Icons.favorite,
  Icons.person,
];
