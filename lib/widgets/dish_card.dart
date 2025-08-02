import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/dish.dart';
import '../utils/theme.dart';
import 'order_dialog.dart';

class DishCard extends StatelessWidget {
  final Dish dish;
  final VoidCallback? onTap;

  const DishCard({
    super.key,
    required this.dish,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dish Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    color: AppTheme.backgroundGray,
                    child: dish.photo != null
                        ? Image.network(
                            dish.photo!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: AppTheme.lebanonRed,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 60,
                                  color: AppTheme.textLight,
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Icon(
                              Icons.restaurant,
                              size: 60,
                              color: AppTheme.textLight,
                            ),
                          ),
                  ),
                  // Price Badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.lebanonRed,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '\$${dish.priceAsDouble.toStringAsFixed(2)}',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  // Availability Badge
                  if (dish.availableQuantity <= 3)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: dish.availableQuantity == 0
                              ? Colors.red
                              : Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          dish.availableQuantity == 0
                              ? 'Sold Out'
                              : 'Few Left',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Dish Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dish Name
                  Text(
                    dish.name,
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Dish Description
                  Text(
                    dish.description,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: AppTheme.textLight,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Mother Info
                  Row(
                    children: [
                      // Mother Profile Picture
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.lebanonGreen,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: dish.mother.profilePicture != null
                              ? Image.network(
                                  dish.mother.profilePicture!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person,
                                      color: AppTheme.lebanonGreen,
                                      size: 24,
                                    );
                                  },
                                )
                              : Icon(
                                  Icons.person,
                                  color: AppTheme.lebanonGreen,
                                  size: 24,
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Mother Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    dish.mother.kitchenName,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textDark,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (dish.mother.isVerified)
                                  const Icon(
                                    Icons.verified,
                                    size: 16,
                                    color: AppTheme.lebanonGreen,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: AppTheme.textLight,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    dish.mother.location,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 12,
                                      color: AppTheme.textLight,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  dish.ratingAsDouble.toStringAsFixed(1),
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: dish.availableQuantity > 0
                          ? () => _showOrderDialog(context)
                          : null,
                      icon: Icon(
                        dish.availableQuantity > 0
                            ? Icons.restaurant
                            : Icons.remove_shopping_cart,
                      ),
                      label: Text(
                        dish.availableQuantity > 0
                            ? 'Place Order'
                            : 'Out of Stock',
                        style: GoogleFonts.montserrat(),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: dish.availableQuantity > 0
                            ? AppTheme.lebanonGreen
                            : Colors.grey,
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

  void _showOrderDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => OrderDialog(dish: dish),
    );

    // Handle the result if needed
    if (result == true && context.mounted) {
      // Order was placed successfully, could refresh data or show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Order placed for ${dish.name}!',
                  style: GoogleFonts.montserrat(),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.lebanonGreen,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
