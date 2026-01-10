import 'package:flutter/material.dart';

import '../../../../core/models/data_models.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/audio_recorder_widget.dart';
import 'reflection_history_page.dart';

class ReflectionPage extends StatefulWidget {
  const ReflectionPage({super.key});

  @override
  State<ReflectionPage> createState() => _ReflectionPageState();
}

class _ReflectionPageState extends State<ReflectionPage> {
  final _supabaseService = SupabaseService();
  final _highlightController = TextEditingController();
  final _blockerController = TextEditingController();
  final _improvementController = TextEditingController();
  double _moodScore = 7.0;
  double _productivityScore = 75.0;
  bool _isSaving = false;

  // Audio recording data
  String? _recordedAudioPath;
  String? _audioTranscript;

  @override
  void dispose() {
    _highlightController.dispose();
    _blockerController.dispose();
    _improvementController.dispose();
    super.dispose();
  }

  Future<void> _saveReflection() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final user = _supabaseService.currentUser;
      if (user == null) return;

      String? uploadedAudioUrl;

      if (_recordedAudioPath != null) {
        uploadedAudioUrl = await _supabaseService.uploadAudioFile(
          _recordedAudioPath!,
          user.id,
        );
      }

      final reflection = Reflection(
        id: '',
        userId: user.id,
        date: DateTime.now(),
        moodScore: _moodScore.round(),
        productivityScore: _productivityScore.round(),
        title: 'Evening Reflection',
        highlight: _highlightController.text,
        blocker: _blockerController.text,
        improvement: _improvementController.text,
        audioUrl: uploadedAudioUrl,
        blockerNote: _audioTranscript,
      );

      await _supabaseService.saveReflection(reflection);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Reflection saved successfully!'),
            backgroundColor: AppColors.primary,
          ),
        );

        // Clear inputs
        _highlightController.clear();
        _blockerController.clear();
        _improvementController.clear();
        setState(() {
          _moodScore = 7.0;
          _productivityScore = 75.0;
          _recordedAudioPath = null;
          _audioTranscript = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving reflection: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B08), // background-dark from HTML
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildProgressSection(),
              const SizedBox(height: 32),
              _buildInputCard(
                title: "Highlight of the Day",
                icon: Icons.emoji_events,
                color: AppColors.accentYellow,
                hint: "What was your biggest win today?",
                controller: _highlightController,
              ),
              const SizedBox(height: 20),
              _buildInputCard(
                title: "One Blocker",
                icon: Icons.block,
                color: AppColors.error,
                hint: "What stopped you from flowing?",
                controller: _blockerController,
              ),
              const SizedBox(height: 20),
              _buildInputCard(
                title: "1% Better Tomorrow",
                icon: Icons.trending_up,
                color: AppColors.accentBlue,
                hint: "One specific thing to improve tomorrow...",
                controller: _improvementController,
              ),
              const SizedBox(height: 32),
              AudioRecorderWidget(
                onRecordingComplete: (path, transcript) {
                  setState(() {
                    _recordedAudioPath = path;
                    _audioTranscript = transcript;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        '✅ Recording saved! Complete the ritual to upload and save.',
                      ),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                onCancel: () {
                  setState(() {
                    _recordedAudioPath = null;
                    _audioTranscript = null;
                  });
                },
              ),
              const SizedBox(height: 32),
              _buildSyncInsightsCard(),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveReflection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadowColor: AppColors.primary.withValues(alpha: 0.5),
                  elevation: 10,
                ),
                child:
                    _isSaving
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.black,
                            ),
                          ),
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.check_circle_outline),
                            SizedBox(width: 8),
                            Text(
                              "Complete Ritual",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
              ),
              const SizedBox(height: 120), // Bottom Nav Clearance
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.spa, color: AppColors.primary, size: 16),
            const SizedBox(width: 8),
            Text(
              "EVENING RITUAL",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                fontSize: 12,
                shadows: [
                  Shadow(
                    color: AppColors.primary.withValues(alpha: 0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          "The Reflection Ritual",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Space Grotesk',
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Thursday, Oct 24 • 8:00 PM",
          style: TextStyle(color: AppColors.textSubtle, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "Daily Progress",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "33%",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: AppColors.primary, blurRadius: 10)],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B), // slate-800
            borderRadius: BorderRadius.circular(10),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 0.33,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.6),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Keep the streak alive (12 days)",
          textAlign: TextAlign.right,
          style: TextStyle(color: AppColors.textSubtle, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildInputCard({
    required String title,
    required IconData icon,
    required Color color,
    required String hint,
    required TextEditingController controller,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF121413), // card-dark
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.1)),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            maxLines: 4,
            style: const TextStyle(color: Color(0xFFE2E8F0)), // slate-200
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF475569)), // slate-600
              filled: true,
              fillColor: const Color(0xFF080A09), // surface-dark
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF121413), // card-dark
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Voice-to-Sync",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Capture your stream of consciousness.",
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                    ), // slate-400
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF080A09), // surface-dark
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.red, blurRadius: 5),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      "READY",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: Color(0xFFCBD5E1), // slate-300
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Waveform
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Left Bars
              _buildBar(12), const SizedBox(width: 4),
              _buildBar(20), const SizedBox(width: 4),
              _buildBar(8), const SizedBox(width: 4),
              _buildBar(16), const SizedBox(width: 24),

              // Mic Button
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: const Icon(Icons.mic, color: Colors.black, size: 32),
              ),

              const SizedBox(width: 24),
              // Right Bars
              _buildBar(16), const SizedBox(width: 4),
              _buildBar(8), const SizedBox(width: 4),
              _buildBar(24), const SizedBox(width: 4),
              _buildBar(12),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            "CLICK TO RECORD",
            style: TextStyle(
              color: Color(0xFF94A3B8), // slate-400
              fontSize: 10,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncInsightsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF121413),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Sync Insights",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReflectionHistoryPage(),
                    ),
                  );
                },
                child: const Text(
                  "View Report",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            children: [
              _buildLegendItem(Colors.white.withValues(alpha: 0.2), "Mood"),
              const SizedBox(width: 16),
              _buildLegendItem(AppColors.primary, "Output"),
            ],
          ),
          const SizedBox(height: 16),
          // Chart Area
          SizedBox(
            height: 140, // Increased from 128 to fit tall bars + date labels
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    3,
                    (index) => Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildChartBar("MON", 48),
                    _buildChartBar("TUE", 64),
                    _buildChartBar("WED", 80),
                    _buildChartBar("THU", 96, isToday: true),
                    _buildChartBar(
                      "FRI",
                      100,
                    ), // Reduced from 112 to be safe or just let height handle it (100 + 8 + 14 = 122 < 140)
                    _buildChartBar("SAT", 56),
                    _buildChartBar("SUN", 100),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(String day, double height, {bool isToday = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 6,
          height: height,
          decoration: BoxDecoration(
            color:
                isToday
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.4),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
            boxShadow:
                isToday
                    ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.6),
                        blurRadius: 8,
                      ),
                    ]
                    : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            color: isToday ? Colors.white : Colors.grey,
            fontSize: 10,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildBar(double height) {
    return Container(
      width: 4,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
