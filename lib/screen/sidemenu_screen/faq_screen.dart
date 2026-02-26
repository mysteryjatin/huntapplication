import 'package:flutter/material.dart';
import 'package:hunt_property/theme/app_theme.dart';
import 'package:hunt_property/screen/add_post_screen.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  int expandedIndex = -1; // none open
  final Duration animDuration = const Duration(milliseconds: 300);
  int menuExpanded = -1;

  List<Map<String, String>> faqList = [
    {
      "q": "Registeration with Huntproperty.com",
      "a":
      "How much do I have to pay to register on Huntproperty.com ?\n"
          "Absolutely free! Registration on Huntproperty.com doesn’t require even a single penny.\n"
          "We do not charge any brokerage.\n"
          "You can click Here to register."
    },
    {
      "q": "How to Post Property on Hunt Property ?",
      "a":
      "Follow the steps below to post property on Hunt Property.com:\n"
          "• Click on 'Post Your Property' on home page.\n"
          "• Fill in the required relevant details regarding your property.\n"
          "• For better response and clarity add property photos.\n"
          "• If you’re a registered user login with your username and password or else register for free.\n"
          "• Once you have filled the entire details click on the Submit button.\n"
          "• In case your subscription of listing package has expired, please contact our Sales Team or you can also renew your subscription or buy a new package online.\n"
          "You can click Here to post property."
    },
    {
      "q": "Forgot Password ?",
      "a":
      "Steps to reset your password:\n"
          "• Click ‘Forgot Password’\n"
          "• Enter Email / Mobile / Username\n"
          "• Reset link will be mailed\n"
          "• If mobile entered, OTP will be sent"
    },
    {
      "q": "How can I view my responses ?",
      "a":
      "To view responses on your property log in to huntproperty.com and click on 'Responses' option under 'My Hunt Property'. The list of all the responses received in the last 3 months on your property will be reflected."
    },
    {
      "q": "Can I create Multiple Accounts with Same Details ?",
      "a": "Unique Email ID & Mobile number required to register."
    },
    {
      "q": "Can same details be used for new account after deactivation ?",
      "a":
      "Yes, same number & email can be used after account deactivation."
    },
    {
      "q": "Account Deactivation",
      "a":
      "Email us from your registered email at support@huntproperty.com."
    },
  ];

  List<String> menuTitles = [
    "Post/Delete/Refresh Property",
    "Search on Hunt Property",
    "Responses",
    "Post Requirements/Alerts",
    "Special Tags with Property",
  ];

  void _toggle(int index) {
    setState(() => expandedIndex = expandedIndex == index ? -1 : index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _appBar(),
              _heading(),
              _bigFaqCard(),
              _menuList(),
              const SizedBox(height: 20),
              _contactSection(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------- APP BAR ----------------------------
  Widget _appBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 22,
            ),
          ),

          const Spacer(), // 🔑 push title to center

          const Text(
            "FAQs",
            style: TextStyle(
              fontSize: 22,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(), // 🔑 keeps title perfectly centered
        ],
      ),
    );
  }



  // --------------------------- HEADING ----------------------------
  Widget _heading() {
    return const Padding(
      padding: EdgeInsets.only(left: 20, top: 6, bottom: 16),
      child: Text(
        "How it Works",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,color: Colors.black),
      ),
    );
  }

  // --------------------------- MAIN CARD ----------------------------
  Widget _bigFaqCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xfff3f8ff),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ListTile(
            title: const Text(
              "User Registration",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            trailing: const Icon(Icons.keyboard_arrow_down),
          ),

          Container(height: 1, color: Colors.grey.shade300),

          const SizedBox(height: 8),

          ...List.generate(
            faqList.length,
                (i) => _faqItem(
              faqList[i]["q"]!,
              faqList[i]["a"]!,
              i,
              isLast: i == faqList.length - 1,
            ),
          )
        ],
      ),
    );
  }

  // --------------------------- FAQ ITEM (Timeline + Animation) ----------------------------
  Widget _faqItem(String q, String a, int index, {required bool isLast}) {
    bool isOpen = expandedIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 18),

          // DOT + LINE
          Column(
            children: [
              // Dot
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                    color: Colors.black, shape: BoxShape.circle),
              ),

              // Smooth expanding line
              AnimatedContainer(
                duration: animDuration,
                width: 2,
                height: isLast ? 0 : (isOpen ? 95 : 55),
                margin: const EdgeInsets.only(top: 2),
                color: Colors.grey.shade400,
              ),
            ],
          ),

          const SizedBox(width: 12),

          // QUESTION + ANSWER
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => _toggle(index),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          q,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                      AnimatedRotation(
                        turns: isOpen ? 0.5 : 0.0,
                        duration: animDuration,
                        child: const Icon(Icons.keyboard_arrow_down),
                      ),
                    ],
                  ),
                ),

                AnimatedSize(
                  duration: animDuration,
                  curve: Curves.easeInOut,
                  child: isOpen
                      ? Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.only(left: 12, right: 8, bottom: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(width: 2, color: Colors.grey.shade300),
                      ),
                    ),
                    child: Text(
                      a,
                      style: TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          color: Colors.grey.shade700),
                    ),
                  )
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: 12),
                Container(height: 1, color: Colors.grey.shade300),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------- MENU LIST ----------------------------
  Widget _menuList() {
    return Column(
      children: List.generate(menuTitles.length, (i) {
        return Column(
          children: [
            InkWell(
              onTap: () => setState(() => menuExpanded = menuExpanded == i ? -1 : i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xfff3f8ff),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(menuTitles[i],
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    Icon(menuExpanded == i ? Icons.keyboard_arrow_down : Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: animDuration,
              curve: Curves.easeInOut,
              child: menuExpanded == i
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
                      child: _menuDetailWidget(i),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      }),
    );
  }

  // --------------------------- MENU DETAIL WIDGET ----------------------------
  Widget _menuDetailWidget(int index) {
    if (index == 0) {
      // Detailed steps for "Post/Delete/Refresh Property"
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "How to Post Property on Hunt Property ?",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text("Follow the steps below to post property on Hunt Property.com:", style: TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            const Text("• Click on 'Post Your Property' on home page."),
            const Text("• Fill in the required relevant details regarding your property."),
            const Text("• For better response and clarity add property photos."),
            const Text("• If you’re a registered user login with your username and password or else register for free."),
            const Text("• Once you have filled the entire details click on the Submit button."),
            const Text("• In case your subscription of listing package has expired, please contact our Sales Team or you can also renew your subscription or buy a new package online."),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  const TextSpan(text: "You can click "),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AddPostScreen()),
                        );
                      },
                      child: const Text(
                        "Here",
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(text: " to post property."),
                ],
              ),
            )
          ],
        ),
      );
    }

    if (index == 1) {
      // Responses details
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Text(
          "To view responses on your property log in to huntproperty.com and click on 'Responses' option under 'My Hunt Property'. The list of all the responses received in the last 3 months on your property will be reflected.",
          style: TextStyle(fontSize: 14),
        ),
      );
    }
    if (index == 2) {
      // Post Requirements / Alerts details
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Text(
          "To post your property requirement on our site, please follow these simple steps:\n\n"
          "• Log in into your Hunt Property user account with your username and password.\n"
          "• Click on 'Requirement' in your dashboard and then click on 'Post Requirement'.\n"
          "• Fill in the details and click on 'Submit'.",
          style: TextStyle(fontSize: 14),
        ),
      );
    }
    if (index == 3) {
      // Special Tags with Property details
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Text(
          "How do I get the 'Verified on Call' tag for my properties as I am an Agent/Builder ?\n\n"
          "Just leave your details at our customer care and we will get in touch with you once this service will be available.\n\n"
          "However, you may still request for 'Verified on Site' tag if your property falls under Residential and Ready to Move in category. We will arrange the Physical Verification of your property within 5 working days from the date of receipt of request.",
          style: TextStyle(fontSize: 14),
        ),
      );
    }

    // default placeholder for other menu items
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Text("Content for this section will be available soon.", style: TextStyle(fontSize: 14)),
    );
  }

  // --------------------------- CONTACT SECTION ----------------------------
  Widget _contactSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _contactItem(
            Icons.call,
            "Call Us",
            "Call us at: 85588 002009",
            greenText: "",
          ),
          const SizedBox(height: 26),

          _contactItem(
            Icons.mail_outline,
            "Mail Us",
            "Mail us for Sales/Service/Enquires",
            greenText:
            "info@huntproperty.com\ncustomercare@huntproperty.com",
          ),
          const SizedBox(height: 26),

          _contactItem(
            Icons.info_outline,
            "For More Information",
            "",
            greenText: "Continue with Customer Services",
          ),
        ],
      ),
    );
  }


  Widget _contactItem(
      IconData icon,
      String title,
      String subtitle, {
        required String greenText,
      }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left circular faded icon background
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: Colors.grey.shade600,
          ),
        ),

        const SizedBox(width: 14),

        // Right side text block
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 4),

              // Subtitle Light grey text
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),

              // Green hyperlinks
              if (greenText.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    greenText,
                    style:  TextStyle(
                      fontSize: 14,
                      color: AppColors.primaryColor,
                      height: 1.45,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }


}

