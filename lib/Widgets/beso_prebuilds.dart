import 'package:besodatahub/Theme/theme.dart';
import 'package:besodatahub/Widgets/Prebuilds/iconbutton.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class BesoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;
  const BesoAppBar({super.key, required this.title, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AppBar(
      actions: actions,
      title: SizedBox(
        width: 90.w,
        child: Text(
          title,
          style: TextStyle(
              fontSize: 5.sp, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      backgroundColor: theme.colorScheme.primary,
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class BesoPopup extends StatelessWidget {
  final String title;
  final String tooltip;
  final double? width;
  final double? height;
  final Widget child;
  final VoidCallback? onFloatingActionButtonPressed;
  const BesoPopup({
    super.key,
    required this.child,
    required this.title,
    this.tooltip = "",
    this.width,
    this.height,
    this.onFloatingActionButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: themeData.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Stack(
        children: [
          SizedBox(
            width: width ?? 50.w,
            height: height ?? 80.h,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 16),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: themeData.colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    MyIconButton(
                      icondata: Icons.close,
                      iconColor: themeData.colorScheme.primary,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Divider(color: themeData.colorScheme.primary),
                Expanded(child: child),
              ],
            ),
          ),
          if (onFloatingActionButtonPressed != null)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                tooltip: tooltip,
                shape: const CircleBorder(),
                onPressed: onFloatingActionButtonPressed,
                backgroundColor: themeData.colorScheme.primary,
                child: const Icon(Icons.add),
              ),
            ),
        ],
      ),
    );
  }
}

class BesoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? height;
  final double? width;

  const BesoCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.color,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    return Card(
      margin: margin ?? const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(16),
        ),
        side: BorderSide(
          color: colors.outline,
          width: 1,
        ),
      ),
      color: color ?? colors.primaryContainer,
      child: Container(
        height: height,
        width: width,
        padding: padding ?? const EdgeInsets.all(8.0),
        child: child,
      ),
    );
  }
}

class BesoToolbar extends StatelessWidget {
  final List<Widget> actions;
  const BesoToolbar({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(16),
        ),
        side: BorderSide(
          color: colors.primary,
          width: 1.5,
        ),
      ),
      elevation: 8,
      color: colors.surface,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: actions,
        ),
      ),
    );
  }
}
