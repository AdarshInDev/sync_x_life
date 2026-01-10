import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';

class DateStrip extends StatelessWidget {
  const DateStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Generate dates for the current week centered around today (or just next 5 days etc)
    // For simplicity, let's show Today + next 4 days
    final dates = List.generate(5, (index) => now.add(Duration(days: index)));

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final date = dates[index];
          final isToday = index == 0;

          return Container(
            width: 65,
            decoration: BoxDecoration(
              color: isToday ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isToday ? AppColors.primary : AppColors.surfaceHighlight,
              ),
              boxShadow:
                  isToday
                      ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                      : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('E').format(date).toUpperCase(), // Mon, Tue
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isToday ? Colors.white : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  date.day.toString(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isToday ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
