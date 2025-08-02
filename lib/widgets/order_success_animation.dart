import 'package:flutter/material.dart';
import '../models/order.dart';
import '../utils/theme.dart';

class OrderSuccessAnimation extends StatefulWidget {
  final Order order;
  final VoidCallback? onClose;

  const OrderSuccessAnimation({
    super.key,
    required this.order,
    this.onClose,
  });

  @override
  State<OrderSuccessAnimation> createState() => _OrderSuccessAnimationState();
}

class _OrderSuccessAnimationState extends State<OrderSuccessAnimation>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _checkController;
  
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    
    // Scale animation for the success circle
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Slide animation for content
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Check mark animation
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _checkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations in sequence
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();
    
    await Future.delayed(const Duration(milliseconds: 300));
    _slideController.forward();
    _checkController.forward();
    
    // Auto close after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _closeAnimation();
      }
    });
  }

  void _closeAnimation() {
    if (widget.onClose != null) {
      widget.onClose!();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          child: Card(
            elevation: 12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Success Circle
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.lebanonGreen,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.lebanonGreen.withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: AnimatedBuilder(
                        animation: _checkAnimation,
                        builder: (context, child) {
                          return CustomPaint(
                            size: const Size(120, 120),
                            painter: CheckMarkPainter(_checkAnimation.value),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Animated Content
                  SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        // Success Title
                        const Text(
                          'Order Placed Successfully!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        
                        // Order Details
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundGray,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Order ID: ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.textLight,
                                    ),
                                  ),
                                  Text(
                                    '#${widget.order.id}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Text(
                                    'Dish: ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.textLight,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      widget.order.dish.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Text(
                                    'Total: ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.textLight,
                                    ),
                                  ),
                                  Text(
                                    '\$${widget.order.priceTotalAsDouble.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.lebanonRed,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Status Message
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.lebanonGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.lebanonGreen.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 20,
                                color: AppTheme.lebanonGreen,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Your order is being prepared by the cook',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _closeAnimation,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppTheme.lebanonGreen),
                                  foregroundColor: AppTheme.lebanonGreen,
                                ),
                                child: const Text('Continue Shopping'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  // TODO: Navigate to orders tab
                                  _closeAnimation();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.lebanonGreen,
                                ),
                                child: const Text('View Orders'),
                              ),
                            ),
                          ],
                        ),
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
}

class CheckMarkPainter extends CustomPainter {
  final double progress;

  CheckMarkPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    
    // Define check mark path
    final path = Path();
    path.moveTo(center.dx - 20, center.dy);
    path.lineTo(center.dx - 5, center.dy + 15);
    path.lineTo(center.dx + 20, center.dy - 15);

    // Calculate the length to draw based on progress
    final pathMetrics = path.computeMetrics();
    for (final pathMetric in pathMetrics) {
      final extractPath = pathMetric.extractPath(
        0.0,
        pathMetric.length * progress,
      );
      canvas.drawPath(extractPath, paint);
    }
  }

  @override
  bool shouldRepaint(CheckMarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
