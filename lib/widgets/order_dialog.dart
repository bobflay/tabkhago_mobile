import 'package:flutter/material.dart';
import '../models/dish.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import '../utils/theme.dart';
import 'order_success_animation.dart';

class OrderDialog extends StatefulWidget {
  final Dish dish;

  const OrderDialog({
    super.key,
    required this.dish,
  });

  @override
  State<OrderDialog> createState() => _OrderDialogState();
}

class _OrderDialogState extends State<OrderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _orderService = OrderService();
  
  int _quantity = 1;
  String _paymentMethod = 'Cash on Delivery';
  bool _isLoading = false;

  final List<String> _paymentMethods = [
    'Cash on Delivery',
    'Credit Card',
    'Mobile Payment',
  ];

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppTheme.lebanonGreen,
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  Future<void> _placeOrder() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final orderRequest = OrderRequest(
        dishId: widget.dish.id,
        quantity: _quantity,
        paymentMethod: _paymentMethod,
        deliveryAddress: _addressController.text.trim(),
        notes: _notesController.text.trim().isEmpty 
            ? null 
            : _notesController.text.trim(),
      );

      final result = await _orderService.placeOrder(orderRequest);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        if (result['success']) {
          // Close the order dialog first
          Navigator.pop(context, true);
          
          // Show success animation if order object is available
          if (result['order'] != null) {
            _showSuccessAnimation(result['order']);
          } else {
            _showSnackBar('Order placed successfully!', isError: false);
          }
        } else {
          _showSnackBar(result['message']);
        }
      }
    }
  }

  void _showSuccessAnimation(Order order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => OrderSuccessAnimation(
        order: order,
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.dish.priceAsDouble * _quantity;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.lebanonRed,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Place Order',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.dish.name,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: AnimatedOpacity(
                opacity: _isLoading ? 0.6 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: AbsorbPointer(
                    absorbing: _isLoading,
                    child: Form(
                      key: _formKey,
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dish Info
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 60,
                              height: 60,
                              color: AppTheme.backgroundGray,
                              child: widget.dish.photo != null
                                  ? Image.network(
                                      widget.dish.photo!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.restaurant);
                                      },
                                    )
                                  : const Icon(Icons.restaurant),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.dish.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'by ${widget.dish.mother.kitchenName}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textLight,
                                  ),
                                ),
                                Text(
                                  '\$${widget.dish.priceAsDouble.toStringAsFixed(2)} each',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.lebanonRed,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Quantity
                      const Text(
                        'Quantity',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: _quantity > 1
                                  ? () => setState(() => _quantity--)
                                  : null,
                              icon: const Icon(Icons.remove),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                '$_quantity',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _quantity < widget.dish.availableQuantity
                                  ? () => setState(() => _quantity++)
                                  : null,
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Payment Method
                      const Text(
                        'Payment Method',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _paymentMethod,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: _paymentMethods.map((method) {
                          return DropdownMenuItem(
                            value: method,
                            child: Text(method),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _paymentMethod = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      // Delivery Address
                      const Text(
                        'Delivery Address',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          hintText: 'Enter your full delivery address',
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your delivery address';
                          }
                          if (value.trim().length < 10) {
                            return 'Please enter a complete address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      // Notes (Optional)
                      const Text(
                        'Special Instructions (Optional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          hintText: 'Any special instructions for the cook or delivery',
                          prefixIcon: Icon(Icons.note),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),
                      
                      // Total Price
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.lebanonGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.lebanonGreen.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.lebanonGreen,
                              ),
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
            ),
            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _isLoading ? Colors.grey : null,
                        side: BorderSide(
                          color: _isLoading ? Colors.grey : AppTheme.lebanonGreen,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _placeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isLoading 
                            ? Colors.grey 
                            : AppTheme.lebanonGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.restaurant_menu),
                      label: Text(
                        _isLoading ? 'Placing Order...' : 'Place Order',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
