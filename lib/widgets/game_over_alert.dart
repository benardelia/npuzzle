import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:npuzzle/state_management.dart/app_controller.dart';

class GameOverAlert extends StatefulWidget {
  const GameOverAlert({
    super.key,
    this.onNegativeAction,
    this.onPositiveAction,
    this.message,
    this.title,
    this.positiveActionText,
    this.negativeActionText,
    this.messageSize,
    this.icon,
    this.isDismissible = true,
    this.showCloseButton = false,
  });

  final void Function()? onNegativeAction;
  final void Function()? onPositiveAction;
  final String? message;
  final String? title;
  final String? positiveActionText;
  final String? negativeActionText;
  final double? messageSize;
  final IconData? icon;
  final bool isDismissible;
  final bool showCloseButton;

  @override
  State<GameOverAlert> createState() => _GameOverAlertState();
}

class _GameOverAlertState extends State<GameOverAlert>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();

    return WillPopScope(
      onWillPop: () async => widget.isDismissible,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            content: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: appController.appColor.value.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with icon
                  _buildHeader(appController),

                  // Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        Text(
                          widget.title ?? 'Game Over',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: appController.appColor.value,
                            decoration: TextDecoration.none,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 16),

                        // Message
                        Text(
                          widget.message ??
                              'You have run out of time.\nDo you want to add more time or restart the game?',
                          style: TextStyle(
                            fontSize: widget.messageSize ?? 16,
                            color: Colors.grey.shade700,
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.normal,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 24),

                        // Action buttons
                        _buildActionButtons(appController),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppController appController) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            appController.appColor.value,
            appController.appColor.value.withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: HeaderPatternPainter(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),

          // Icon
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                widget.icon ?? _getDefaultIcon(),
                size: 48,
                color: Colors.white,
              ),
            ),
          ),

          // Close button (optional)
          if (widget.showCloseButton && widget.isDismissible)
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  if (Get.isDialogOpen == true) {
                    Future.delayed(const Duration(milliseconds: 300), () {
                      Get.back();
                    });
                  }
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AppController appController) {
    return Row(
      children: [
        // Negative action button
        Expanded(
          child: _buildButton(
            text: widget.negativeActionText ?? 'Restart',
            onPressed: widget.onNegativeAction,
            isPrimary: false,
            appController: appController,
          ),
        ),

        const SizedBox(width: 12),

        // Positive action button
        Expanded(
          child: _buildButton(
            text: widget.positiveActionText ?? 'Add Time',
            onPressed: widget.onPositiveAction,
            isPrimary: true,
            appController: appController,
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback? onPressed,
    required bool isPrimary,
    required AppController appController,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: isPrimary
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      appController.appColor.value,
                      appController.appColor.value.withOpacity(0.8),
                    ],
                  )
                : null,
            color: isPrimary ? null : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
            border: isPrimary
                ? null
                : Border.all(
                    color: Colors.grey.shade300,
                    width: 1.5,
                  ),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: appController.appColor.value.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isPrimary ? Colors.white : Colors.grey.shade700,
              decoration: TextDecoration.none,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  IconData _getDefaultIcon() {
    // Try to determine icon based on title
    final title = widget.title?.toLowerCase() ?? '';

    if (title.contains('won') || title.contains('congrat')) {
      return Icons.emoji_events;
    } else if (title.contains('lock')) {
      return Icons.lock;
    } else if (title.contains('time') || title.contains('over')) {
      return Icons.timer_off;
    } else if (title.contains('error') || title.contains('fail')) {
      return Icons.error_outline;
    } else {
      return Icons.info_outline;
    }
  }
}

/// Custom painter for header pattern
class HeaderPatternPainter extends CustomPainter {
  final Color color;

  HeaderPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const spacing = 20.0;

    // Draw diagonal lines
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Alternative version with more compact design
class CompactGameOverAlert extends StatelessWidget {
  const CompactGameOverAlert({
    super.key,
    this.onNegativeAction,
    this.onPositiveAction,
    this.message,
    this.title,
    this.positiveActionText,
    this.negativeActionText,
    this.icon,
  });

  final void Function()? onNegativeAction;
  final void Function()? onPositiveAction;
  final String? message;
  final String? title;
  final String? positiveActionText;
  final String? negativeActionText;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: appController.appColor.value.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.info_outline,
                size: 40,
                color: appController.appColor.value,
              ),
            ),

            const SizedBox(height: 16),

            // Title
            Text(
              title ?? 'Game Over',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: appController.appColor.value,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Message
            Text(
              message ?? 'What would you like to do?',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onNegativeAction,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: appController.appColor.value),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      negativeActionText ?? 'Cancel',
                      style: TextStyle(
                        color: appController.appColor.value,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onPositiveAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appController.appColor.value,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      positiveActionText ?? 'Continue',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
