import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ListTileWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? leadingIconColor;
  final Color? leadingBackgroundColor;

  const ListTileWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.trailing,
    this.onTap,
    this.leadingIconColor,
    this.leadingBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: leadingIcon != null
          ? Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: leadingBackgroundColor ??
                    AppColors.primaryContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                leadingIcon,
                color: leadingIconColor ?? AppColors.primary,
                size: 20,
              ),
            )
          : null,
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall,
            )
          : null,
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right_rounded,
                  color: AppColors.outline)
              : null),
    );
  }
}
