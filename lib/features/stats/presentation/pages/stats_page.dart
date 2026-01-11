import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/theme_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  AppThemeColors get colors => Provider.of<ThemeService>(context).colors;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final colors = themeService.colors;

        return Container(
          color:
              colors
                  .background, // Was hardcoded colors.background (which was static)
          child: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: () async {
                // TODO: Implement actual data fetching
                await Future.delayed(const Duration(milliseconds: 1500));
              },
              color: colors.primary,
              backgroundColor: colors.surface,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(), // Internal widgets still refer to AppColors, may need refactor if they are static
                    const SizedBox(height: 24),
                    _buildMoodChart(),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _buildProdScoreCard()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildAvgMoodCard()),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildBlockerCard(),
                    const SizedBox(height: 120), // Bottom Nav Clearance
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights, size: 14, color: colors.accent),
                const SizedBox(width: 4),
                Text(
                  "WEEKLY REPORT",
                  style: TextStyle(
                    color: colors.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    shadows: [
                      BoxShadow(
                        color: colors.accent.withValues(alpha: 0.4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              "Sync Insights",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "Oct 18 - Oct 24",
              style: TextStyle(
                color: colors.textSubtle,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.trending_up, size: 14, color: colors.primary),
                const SizedBox(width: 4),
                Text(
                  "+12% vs last week",
                  style: TextStyle(
                    color: colors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMoodChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Mood vs. Output",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Row(
                children: [
                  _buildLegendDot("Output", colors.primary),
                  const SizedBox(width: 12),
                  _buildLegendDot("Mood", colors.accent),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: Stack(
              children: [
                // Grid Lines
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    4,
                    (index) => Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                // Chart Content
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildChartDay("MON", 0.4, 0.6),
                    _buildChartDay("TUE", 0.55, 0.5),
                    _buildChartDay("WED", 0.65, 0.4),
                    _buildChartDay("THU", 0.85, 0.2, isActive: true),
                    _buildChartDay("FRI", 0.7, 0.35),
                    _buildChartDay("SAT", 0.45, 0.45),
                    _buildChartDay("SUN", 0.3, 0.25),
                  ],
                ),
                // Overlay Line Chart (CustomPaint)
                Positioned.fill(
                  child: CustomPaint(painter: _ChartPainter(colors: colors)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 4),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: colors.textSubtle, fontSize: 12)),
      ],
    );
  }

  Widget _buildChartDay(
    String label,
    double heightFactor,
    double secondaryHeight, {
    bool isActive = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 10,
          height: 140 * heightFactor,
          decoration: BoxDecoration(
            color:
                isActive
                    ? colors.primary
                    : colors.primary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
            boxShadow:
                isActive
                    ? [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ]
                    : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : colors.textSubtle,
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProdScoreCard() {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.bolt, color: colors.primary, size: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "PROD. SCORE",
                    style: TextStyle(
                      color: colors.textSubtle,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        "92",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          shadows: [
                            BoxShadow(
                              color: colors.primary.withValues(alpha: 0.4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        "%",
                        style: TextStyle(
                          color: colors.textSubtle,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      "Top 5%",
                      style: TextStyle(
                        color: colors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ).blur(20),
          ),
        ],
      ),
    );
  }

  Widget _buildAvgMoodCard() {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.sentiment_satisfied,
                      color: colors.accent,
                      size: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "AVG MOOD",
                    style: TextStyle(
                      color: colors.textSubtle,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Flow State",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 4,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: colors.accent,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: colors.accent.withValues(alpha: 0.6),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "14h in deep work",
                    style: TextStyle(
                      color: colors.textSubtle,
                      fontSize: 10,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            right: -20,
            bottom: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ).blur(20),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: colors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colors.error.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Icon(Icons.block, color: colors.error, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "TOP BLOCKER",
                            style: TextStyle(
                              color: colors.textSubtle,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "Digital Distractions",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "-4.5h",
                        style: TextStyle(
                          color: colors.error,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Total Loss",
                        style: TextStyle(
                          color: colors.textSubtle,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildBlockerItem(
                "Social Media",
                "2h 15m",
                0.6,
                colors.error.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 16),
              _buildBlockerItem(
                "Slack / Comms",
                "1h 45m",
                0.45,
                colors.error.withValues(alpha: 0.5),
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 150,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    colors.error.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockerItem(
    String label,
    String time,
    double progress,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: colors.textSubtle,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              time,
              style: TextStyle(
                color: colors.textSubtle,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 5),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChartPainter extends CustomPainter {
  final AppThemeColors colors;

  _ChartPainter({required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = colors.accent
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;

    final path = Path();
    final width = size.width;
    final height = size.height;

    // Generate smooth curve points based on data
    path.moveTo(0, height * 0.7);

    // Hardcoded control points for smoother curve - matching design
    // In a real app these would be calculated from data points
    path.cubicTo(
      width * 0.2,
      height * 0.8,
      width * 0.3,
      height * 0.4,
      width * 0.5,
      height * 0.5,
    );

    path.cubicTo(
      width * 0.7,
      height * 0.6,
      width * 0.8,
      height * 0.3,
      width,
      height * 0.4,
    );

    // Shadow for line
    canvas.drawShadow(path, colors.accent.withValues(alpha: 0.5), 3.0, true);

    canvas.drawPath(path, paint);

    // Draw dots
    final dotPaint = Paint()..color = colors.surface;
    final dotStroke =
        Paint()
          ..color = colors.accent
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;

    // Draw a few data points
    final points = [
      Offset(width * 0.5, height * 0.5),
      Offset(width, height * 0.4),
    ];

    for (var point in points) {
      canvas.drawCircle(point, 4, dotPaint);
      canvas.drawCircle(point, 4, dotStroke);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

extension _StatsBlurExt on Widget {
  Widget blur(double sigma) {
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: this,
    );
  }
}
