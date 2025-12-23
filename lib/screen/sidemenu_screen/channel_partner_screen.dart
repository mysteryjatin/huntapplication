import 'package:flutter/material.dart';

class ChannelPartnerScreen extends StatefulWidget {
  const ChannelPartnerScreen({super.key});

  @override
  State<ChannelPartnerScreen> createState() => _ChannelPartnerScreenState();
}

class _ChannelPartnerScreenState extends State<ChannelPartnerScreen> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController mobileCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController companyCtrl = TextEditingController();
  final TextEditingController industryCtrl = TextEditingController();
  final TextEditingController messageCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _appBar(context),
              const SizedBox(height: 10),
              _topCard(),
              const SizedBox(height: 20),
              _bottomDescription(),
            ],
          ),
        ),
      ),
    );
  }

  // -----------------------------------------
  // TOP BACK BUTTON + HEADING
  // -----------------------------------------
  Widget _appBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xfff1f7ff),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  size: 16, color: Colors.black),
            ),
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Text(
              "Channel Partner",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  // -----------------------------------------
  // UPPER CARD WITH FORM
  // -----------------------------------------
  Widget _topCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.only(bottom: 20,top: 10,left: 10,right: 10),
      decoration: BoxDecoration(
        color: const Color(0xfff2f8ff),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // IMAGE
          ClipRRect(
            borderRadius: const BorderRadius.all( Radius.circular(20)),
            child: Image.asset(
              "assets/images/chalneparthner.png",
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 16),

          // TITLE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Channel Partner",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700,color: Colors.black),
                ),
                SizedBox(height: 4),
                Text(
                  "Boost your business by becoming Hunt Property partner",
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // FORM FIELDS
          _inputField("Name", nameCtrl),
          _inputField("Mobile No.", mobileCtrl),
          _inputField("Email", emailCtrl),
          _inputField("Company Name", companyCtrl),
          _inputField("Industry Type", industryCtrl),
          _inputField("Your Message", messageCtrl, maxLines: 4),

          const SizedBox(height: 10),

          // SUBMIT BUTTON
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1EF4A3),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                "Submit",
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------
  // INPUT FIELD DESIGN
  // -----------------------------------------
  Widget _inputField(String label, TextEditingController ctrl,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 14, color: Colors.grey.shade700)),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            maxLines: maxLines,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------
  // BOTTOM DESCRIPTION SECTION
  // -----------------------------------------
  Widget _bottomDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Channel Partner",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700,color: Colors.black),
          ),
          SizedBox(height: 10),
          Text(
            "Hunt Property operates with a vision to provide multi-dimensional realty solutions. Even after going through so many ups and down...",
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
          SizedBox(height: 10),
          Text(
            "We are a team player and believe in working as a team...",
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
          SizedBox(height: 10),
          Text(
            "There are many more things that we can learn when we come under an association.",
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
          SizedBox(height: 10),
          Text(
            "For further details you can reach us:\nchannelpartner@huntproperty.com",
            style: TextStyle(fontSize: 13),
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}
