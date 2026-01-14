import 'package:flutter/material.dart';
import 'package:hunt_property/theme/app_theme.dart';

class AiVaastuAnalysisNewScreen extends StatelessWidget {
  const AiVaastuAnalysisNewScreen({super.key});

  static const Color kGreen = Color(0xFF2EE59D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Ai Vaastu Analysis',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🤖 AI INTRO
            ganeshAiMessageCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "I'm your personal AI Vaastu consultant. I'll guide you step-by-step to analyze your home.",
                    style: TextStyle(fontSize: 13),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'How This Works (5–7 minutes total)',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 8),
                  Text('• Phase 1: Direction Setup'),
                  Text('• Phase 2: Room Mapping'),
                  Text('• Phase 3: Vaastu Analysis'),
                ],
              ),
            ),

            const SizedBox(height: 14),

            /// 🧭 PHASE 1
            ganeshAiMessageCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Phase 1: Direction Setup ⏱️',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 8),
                  Text('Great! I can see your floor plan.'),
                  SizedBox(height: 6),
                  Text(
                    'Before we analyze, please tell me which direction is NORTH in your image.',
                    style:
                        TextStyle(color: AppColors.primaryColor, fontSize: 12),
                  ),
                  SizedBox(height: 8),
                  Text('👇 Select the North direction below:',
                      style: TextStyle(
                          color: AppColors.primaryColor, fontSize: 12)),
                ],
              ),
            ),

            const SizedBox(height: 14),

            /// 🧭 WHERE IS NORTH CARD (❌ DO NOT REMOVE)
            whereIsNorthCard(),

            const SizedBox(height: 14),

            /// ⚙️ ANALYZING STATUS
            analyzingStatusCard(),

            const SizedBox(height: 14),

            /// 🧭 SELECT DIRECTION (8 DIRECTIONS)
            selectDirectionCard(),

            const SizedBox(height: 20),

            /// ⭐ OVERALL VAASTU (FULL SECTION)
            overallVaastuBorderCard(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Row(
            children: [
              /// REPORT BUTTON
              Expanded(
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3FAFF), // light bluish bg
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      // TODO: report action
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.download, size: 20, color: Colors.black),
                        SizedBox(width: 8),
                        Text(
                          'REPORT',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              /// ASK AI BUTTON
              Expanded(
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: AiVaastuAnalysisNewScreen.kGreen,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      // TODO: ask ai action
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.chat_bubble_outline,
                            size: 20, color: Colors.black),
                        SizedBox(width: 8),
                        Text(
                          'ASK AI',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }

  // ================= GANESH + AI MESSAGE BASE =================

  Widget ganeshAiMessageCard({required Widget child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset('assets/images/ganesha_vaastu_ai.png',
            height: 34, width: 34),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kGreen),
            ),
            child: child,
          ),
        ),
      ],
    );
  }

  // ================= WHERE IS NORTH CARD =================

  Widget whereIsNorthCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AiVaastuAnalysisNewScreen.kGreen),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP ROW (IMAGE + TEXT)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 80,
                width: 80,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Image.asset(
                  'assets/images/floor_plan.png', // change if needed
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Where is North in your image?',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.black),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Select the side of the image that faces North',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// BUTTON GRID (2x2)
          Row(
            children: const [
              Expanded(
                child: _NorthOptionCard(
                  title: 'Top',
                  subtitle: 'North is at the top',
                  icon: Icons.arrow_upward,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _NorthOptionCard(
                  title: 'Right',
                  subtitle: 'North is at the right',
                  icon: Icons.arrow_forward,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(
                child: _NorthOptionCard(
                  title: 'Bottom',
                  subtitle: 'North is at the bottom',
                  icon: Icons.arrow_downward,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _NorthOptionCard(
                  title: 'Left',
                  subtitle: 'North is at the left',
                  icon: Icons.arrow_back,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= ANALYZING =================

  Widget analyzingStatusCard() {
    return ganeshAiMessageCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analyzing with North at Top of image 🧭',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Processing: ',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                TextSpan(
                  text: 'Detecting rooms and analyzing structure...',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Time: ',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                TextSpan(
                  text: 'This will take about 10 seconds',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Text('Next: We’ll show you the detected rooms',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  // ================= SELECT DIRECTION (8) =================

  Widget selectDirectionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AiVaastuAnalysisNewScreen.kGreen),
      ),
      child: Column(
        children: [
          const Text(
            'Select Direction',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.6,
            // ⭐ IMPORTANT (height balanced)
            children: const [
              _DirectionTile(Icons.arrow_upward, 'North'),
              _DirectionTile(Icons.north_east, 'Northeast'),
              _DirectionTile(Icons.arrow_downward, 'South'),
              _DirectionTile(Icons.south_west, 'Southwest'),
              _DirectionTile(Icons.arrow_forward, 'East'),
              _DirectionTile(Icons.south_east, 'Southeast'),
              _DirectionTile(Icons.arrow_back, 'West'),
              _DirectionTile(Icons.north_west, 'Northwest'),
            ],
          ),
        ],
      ),
    );
  }

  // ================= OVERALL VAASTU =================

  Widget overallVaastuBorderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kGreen),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3FBF7), // light mint bg
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// TOP ROW
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          /// LEFT TEXT
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'OVERALL VASTU SCORE',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '62',
                                        style: TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '/100',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// RIGHT ICON
                          Image.asset('assets/images/overall_vastu_score_icon_opacity.png')
                          // Container(
                          //   height: 56,
                          //   width: 56,
                          //   decoration: BoxDecoration(
                          //     shape: BoxShape.circle,
                          //     border: Border.all(
                          //       color: AiVaastuAnalysisNewScreen.kGreen
                          //           .withOpacity(0.4),
                          //       width: 4,
                          //     ),
                          //   ),
                          //   child: Center(
                          //     child: Icon(
                          //       Icons.navigation,
                          //       size: 26,
                          //       color: AiVaastuAnalysisNewScreen.kGreen,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      /// STATUS PILL
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCFF5D6),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text(
                            'NEEDS IMPROVEMENT HARMONY',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                height: 22,
                width: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: const Icon(
                  Icons.navigation,
                  size: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'DIRECTIONAL ANALYSIS',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          directionalAnalysisGrid(),
          const SizedBox(height: 20),
          roomAnalysisSection(),
          const SizedBox(height: 20),
          roomAnalysisDoshSection(),
          const SizedBox(height: 20),
          positiveAspectsSection(),
          const SizedBox(height: 10),
          recommendationsSection(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              '"By following these Vastu principles, the energy in the house can be optimized for better harmony and prosperity."',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.grey.shade600,
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget directionalAnalysisGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.95,
      children: [
        _DirectionCard(
          title: 'North',
          desc:
              'Abundance of open space and balconies in the North promotes prosperity.',
          iconPath: 'assets/images/north.png',
        ),
        _DirectionCard(
          title: 'North-East',
          desc:
              'A toilet in the North-East is a major Vastu defect, impacting health and mental peace.',
         iconPath: 'assets/images/north_east.png',

        ),
        _DirectionCard(
          title: 'East',
          desc:
              'Abundance of open space and balconies in the East promotes prosperity.',
          iconPath: 'assets/images/east.png',
        ),
        _DirectionCard(
          title: 'South-East',
          desc:
              'The entrance/foyer is located here; while active, it displaces the ideal fire zone.',
          iconPath: 'assets/images/south_east.png',
        ),
        _DirectionCard(
          title: 'South',
          desc: 'Solid walls and the placement of a bedroom provide stability.',
          iconPath: 'assets/images/south.png',
        ),
        _DirectionCard(
          title: 'South-West',
          desc:
              'Bedroom placement in the South-West corner is excellent for the head of the family.',
          iconPath: 'assets/images/south_west.png',
        ),
        _DirectionCard(
          title: 'West',
          desc:
              'The kitchen is in the West; while manageable, it is not the primary Agni (fire) zone.',
          iconPath: 'assets/images/west.png',
        ),
        _DirectionCard(
          title: 'North-West',
          desc:
              'The toilet and sit-out are acceptable as per Vayu corner principles.',
          iconPath: 'assets/images/north_west.png',
        ),
      ],
    );
  }

  Widget roomAnalysisSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// HEADER
        Row(
          children: [
            Icon(Icons.grid_view, size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              'ROOM ANALYSIS',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        /// LIST
        roomAnalysisCard(
          title: 'Master Bedroom (SW)',
          subtitle: 'Perfectly placed in the South-West ...',
          score: '9/10',
        ),
        roomAnalysisCard(
          title: 'Kitchen',
          subtitle: 'West placement is neutral; ideally',
          score: '5/10',
        ),
        roomAnalysisCard(
          title: 'Puja Room',
          subtitle: 'Placed near the South/Center; should',
          score: '3/10',
        ),
        roomAnalysisCard(
          title: 'Dining Area',
          subtitle: 'Central placement is convenient and',
          score: '7/10',
        ),
      ],
    );
  }

  Widget roomAnalysisDoshSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// HEADER
        Row(
          children: [
            Icon(Icons.grid_view, size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              'ROOM ANALYSIS',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        /// CARD 1
        doshInfoCard(
          title: 'Ishanya Toilet Dosh',
          description:
              'The presence of a toilet in the North-East (Ishanya) corner is a severe violation, believed to drain positive energy and cause health issues.',
        ),

        /// CARD 2
        doshInfoCard(
          title: 'Improper Puja Placement',
          description:
              'The Puja/Store is located towards the South, which is the zone of Yama; it should be moved to the Ishanya corner for spiritual growth.',
        ),
      ],
    );
  }

  Widget positiveAspectsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// HEADER
        Row(
          children: [
            Icon(Icons.check_circle_outline,
                size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              'POSITIVE ASPECTS',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        /// CARD 1
        positiveAspectCard(
          title: 'Nairutya Stability',
          description:
              'The heaviest room (Master Bedroom) is in the South-West, ensuring financial and emotional stability.',
        ),

        /// CARD 2
        positiveAspectCard(
          title: 'Northern Ventilation',
          description:
              'Large balconies in the North and West allow for good airflow and light.',
        ),
      ],
    );
  }

  Widget recommendationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// HEADER
        Row(
          children: [
            Icon(Icons.lightbulb_outline,
                size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              'RECOMMENDATIONS',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        /// CARD 1
        recommendationCard(
          title: 'Relocate Puja Room',
          description:
              'Shift the Puja room to the North-East corner of the house for better spiritual alignment.',
        ),

        /// CARD 2
        recommendationCard(
          title: 'North-East Toilet Remedy',
          description:
              'If the toilet in the North-East cannot be moved, keep it closed at all times and use sea salt/Vastu pyramids to neutralize negative energy.',
        ),

        /// CARD 3
        recommendationCard(
          title: 'Kitchen Color Palette',
          description:
              'Since the kitchen is in the West, use white or yellow tones to balance the elements.',
        ),
      ],
    );
  }
}

// ================= SUB WIDGETS =================

class _NorthOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _NorthOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AiVaastuAnalysisNewScreen.kGreen,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= SUB Direction ANALYSIS WIDGETS =================
class _DirectionTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DirectionTile(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90, // ⭐ FIXED HEIGHT (prevents overflow)
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AiVaastuAnalysisNewScreen.kGreen,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 18, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= SUB ROOM ANALYSIS WIDGETS =================
Widget roomAnalysisCard({
  required String title,
  required String subtitle,
  required String score,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /// LEFT TEXT
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        /// RIGHT SCORE
        Text(
          score,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2EE59D),
          ),
        ),
      ],
    ),
  );
}
// ================= SUB ROOM ANALYSIS 2 WIDGETS =================

Widget doshInfoCard({
  required String title,
  required String description,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    decoration: BoxDecoration(
      color: const Color(0xFFF3FAFF), // light blue bg
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// TITLE
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),

        /// DESCRIPTION
        Text(
          description,
          style: TextStyle(
            fontSize: 12.5,
            color: Colors.grey.shade700,
            height: 1.35,
          ),
        ),
      ],
    ),
  );
}

// ================= SUB POSITIVE ASPECTS WIDGETS =================
Widget positiveAspectCard({
  required String title,
  required String description,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFF3FAFF), // light blue bg
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// LEFT ICON (GANESH / BADGE)
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Image.asset(
              'assets/images/positive_aspects _bullets.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(width: 12),

        /// TEXT
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.grey.shade700,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
// ================= SUB RECOMMENDATIONS  WIDGETS =================

Widget recommendationCard({
  required String title,
  required String description,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    decoration: BoxDecoration(
      color: const Color(0xFFF3FAFF), // light blue bg
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// TITLE
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),

        /// DESCRIPTION
        Text(
          description,
          style: TextStyle(
            fontSize: 12.5,
            color: Colors.grey.shade700,
            height: 1.35,
          ),
        ),
      ],
    ),
  );
}

class _DirectionCard extends StatelessWidget {
  final String title;
  final String desc;
  final String iconPath;

  const _DirectionCard({
    required this.title,
    required this.desc,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                height: 30,
                width: 30,
                child: Image.asset(
                  iconPath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image_not_supported, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
