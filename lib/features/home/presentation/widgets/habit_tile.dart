import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HabitTile extends StatelessWidget {
  final String title;
  final String streak;
  final bool isCompleted;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const HabitTile({
    super.key,
    required this.title,
    required this.streak,
    required this.isCompleted,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isCompleted
                  ? color.withValues(alpha: 0.5)
                  : AppColors.surfaceHighlight,
          width: 1,
        ),
        boxShadow:
            isCompleted
                ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ]
                : [],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color:
                isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          '$streak streak',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        trailing: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? color : Colors.transparent,
            border: Border.all(
              color: isCompleted ? color : AppColors.textSecondary,
              width: 2,
            ),
          ),
          child:
              isCompleted
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : null,
        ),
      ),
    );
  }
}
