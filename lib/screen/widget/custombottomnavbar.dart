import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    double itemWidth = MediaQuery.of(context).size.width / 5;
    double startX = (itemWidth * widget.selectedIndex) + (itemWidth / 2) - 36;

    return SizedBox(
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

          // FLOATING SELECTED ICON WITH ANIMATION
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic, // Animation effect
            top: -22,
            left: startX,
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
        ],
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
