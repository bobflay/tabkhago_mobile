import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
import '../services/dish_service.dart';
import '../services/order_service.dart';
import '../models/user.dart';
import '../models/dish.dart';
import '../models/order.dart';
import '../utils/theme.dart';
import '../widgets/dish_card.dart';
import '../widgets/order_card.dart';
import 'login_screen.dart';
import 'mothers_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _dishService = DishService();
  final _orderService = OrderService();
  User? _currentUser;
  List<Dish> _dishes = [];
  List<Order> _orders = [];
  bool _isLoading = false;
  bool _isLoadingOrders = false;
  String? _error;
  String? _ordersError;
  int _selectedIndex = 0;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
    // Load dishes after a small delay to ensure the screen renders first
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _loadDishes();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = await _authService.getUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  Future<void> _loadDishes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dishesResponse = await _dishService.getDishes();
      if (mounted && dishesResponse != null) {
        setState(() {
          _dishes = dishesResponse.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
        
        if (e.toString().contains('Authentication failed')) {
          _logout();
        }
      }
    }
  }

  Future<void> _searchDishes(String query) async {
    if (query.isEmpty) {
      _loadDishes();
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dishesResponse = await _dishService.searchDishes(query);
      if (mounted && dishesResponse != null) {
        setState(() {
          _dishes = dishesResponse.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      print('Attempting to launch URL: $url');
      
      // Try to launch the URL directly first
      bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      
      if (launched) {
        print('URL launched successfully');
      } else {
        print('Failed to launch URL');
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not open link. Please check your internet connection.',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: AppTheme.lebanonRed,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Copy Link',
              textColor: Colors.white,
              onPressed: () {
                // Optional: add clipboard functionality here
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _requestAccountDeletion() async {
    // Show confirmation dialog first
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                'Delete Account',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This will open WhatsApp to contact our support team for account deletion assistance.',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Important Notice',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Account deletion is permanent and cannot be undone. All your data, orders, and preferences will be permanently removed.',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: GoogleFonts.montserrat(
                  color: AppTheme.textLight,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lebanonGreen,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.message, size: 18),
              label: Text(
                'Contact Support',
                style: GoogleFonts.montserrat(),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        final phoneNumber = '96176731039';
        final message = Uri.encodeComponent(
          'Hello TabkhaGo Support Team,\n\n'
          'I would like to request the deletion of my TabkhaGo account.\n\n'
          'Account Details:\n'
          '- Email: ${_currentUser?.email ?? 'Not available'}\n'
          '- Name: ${_currentUser?.name ?? 'Not available'}\n\n'
          'Please proceed with deleting my account and all associated data.\n\n'
          'Thank you.'
        );
        
        final whatsappUrl = 'https://wa.me/$phoneNumber?text=$message';
        print('Opening WhatsApp with URL: $whatsappUrl');
        
        final Uri uri = Uri.parse(whatsappUrl);
        bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        
        if (launched) {
          print('WhatsApp opened successfully');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'WhatsApp opened. Please send the message to our support team.',
                        style: GoogleFonts.montserrat(),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppTheme.lebanonGreen,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        } else {
          throw 'Could not open WhatsApp';
        }
      } catch (e) {
        print('Error opening WhatsApp: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Could not open WhatsApp',
                          style: GoogleFonts.montserrat(),
                        ),
                        Text(
                          'Please contact support directly at: +96176731039',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Load orders when Orders tab is selected
    if (index == 1 && _orders.isEmpty) {
      _loadOrders();
    }
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoadingOrders = true;
      _ordersError = null;
    });

    try {
      final orders = await _orderService.getUserOrders();
      if (mounted && orders != null) {
        setState(() {
          _orders = orders;
          _isLoadingOrders = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _ordersError = e.toString();
          _isLoadingOrders = false;
        });
        
        if (e.toString().contains('Authentication failed')) {
          _logout();
        }
      }
    }
  }

  Future<void> _cancelOrder(int orderId) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppTheme.lebanonRed),
                const SizedBox(width: 20),
                Text(
                'Cancelling order...',
                style: GoogleFonts.montserrat(),
              ),
              ],
            ),
          ),
        );
      },
    );

    try {
      final result = await _orderService.cancelOrder(orderId);
      
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        if (result['success']) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result['message'] ?? 'Order cancelled successfully!',
                      style: GoogleFonts.montserrat(),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppTheme.lebanonGreen,
              duration: const Duration(seconds: 3),
            ),
          );
          
          // Refresh orders list to reflect the cancellation
          _loadOrders();
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result['message'] ?? 'Failed to cancel order',
                      style: GoogleFonts.montserrat(),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () => _cancelOrder(orderId),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Network error: ${e.toString()}',
                    style: GoogleFonts.montserrat(),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _cancelOrder(orderId),
            ),
          ),
        );
        
        if (e.toString().contains('Authentication failed')) {
          _logout();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TabkhaGo',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600, // bolder weight
            fontSize: 20,                // adjust size if you want
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                title: Text(
                  'Logout',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                content: Text(
                  'Are you sure you want to logout?',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                  ),
                ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                      'Cancel',
                      style: GoogleFonts.montserrat(),
                    ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _logout();
                      },
                      child: Text(
                      'Logout',
                      style: GoogleFonts.montserrat(),
                    ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Home Tab - Dishes List
          Column(
            children: [
              // Search Bar
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: TextField(
                controller: _searchController,
                style: GoogleFonts.montserrat(), // Text input style
                decoration: InputDecoration(
                  hintText: 'Search for dishes...',
                  hintStyle: GoogleFonts.montserrat(
                    color: Colors.grey, // or any color you prefer
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _loadDishes();
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  // Debounce search
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (_searchController.text == value) {
                      _searchDishes(value);
                    }
                  });
                },
              ),
              ),
              // Dishes List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadDishes,
                  color: AppTheme.lebanonRed,
                  child: _buildDishesContent(),
                ),
              ),
            ],
          ),
          // Orders Tab
          _buildOrdersContent(),
          // Mothers Tab
          const MothersScreen(),
          // About Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // App Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.lebanonRed,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                // App Title
              Text(
                'TabkhaGo',
                style: GoogleFonts.montserrat(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  Text(
                    'Made',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: AppTheme.textLight,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                    Text(
                      ' in Lebanon',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: AppTheme.textLight,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Developer Highlight - Main Focus
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.lebanonRed.withValues(alpha: 0.1),
                        AppTheme.lebanonGreen.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.lebanonRed.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Developer Avatar
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [AppTheme.lebanonRed, AppTheme.lebanonGreen],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.lebanonRed.withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Developer Name
                        Text(
                          'Ralph Kahkedjian',
                          style: GoogleFonts.montserrat(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // University
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.school,
                              color: AppTheme.lebanonGreen,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                              Text(
                                'NDU University',
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  color: AppTheme.textDark,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Internship Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.lebanonGreen,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Xpertbot Intern Developer',
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Description
                        Text(
                          'Passionate Flutter developer crafting beautiful mobile experiences. This app represents dedication to connecting Lebanese home cooks with food lovers, celebrating our rich culinary heritage.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            color: AppTheme.textDark,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Social Links
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // LinkedIn
                            Expanded(
                              child: InkWell(
                                onTap: () => _launchUrl('https://www.linkedin.com/in/ralph-kahkedjian-b88361336/'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0077B5),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF0077B5).withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'LinkedIn',
                                        style: GoogleFonts.montserrat(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // About App Section - Secondary
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppTheme.lebanonRed,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'About TabkhaGo',
                              style: GoogleFonts.montserrat(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'TabkhaGo connects home cooks (mothers) with customers who want to order homemade dishes. The platform celebrates Lebanese culinary traditions by allowing mothers to share their authentic home-cooked meals with food lovers.',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            color: AppTheme.textDark,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Xpertbot Section - Supporting
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.rocket_launch,
                              color: AppTheme.lebanonGreen,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Powered by Xpertbot Academy',
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Developed during the Xpertbot Internship program, empowering the next generation of Lebanese developers to create innovative solutions.',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            color: AppTheme.textDark,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Xpertbot Link
                        InkWell(
                          onTap: () => _launchUrl('https://xpertbotacademy.online/app'),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.lebanonGreen,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.lebanonGreen.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.launch,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Visit Xpertbot Academy',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Account Management Section
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.settings,
                              color: AppTheme.textDark,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Account Management',
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Need help with your account? Contact our support team directly.',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            color: AppTheme.textDark,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Delete Account Button
                        InkWell(
                          onTap: () => _requestAccountDeletion(),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.delete_forever,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Request Account Deletion',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'This will open WhatsApp to contact our support team for account deletion assistance.',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: AppTheme.textLight,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Version Info
                Text(
                  'Version 1.0.0',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '© 2025 TabkhaGo. All rights reserved.',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
     bottomNavigationBar: BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant),
          label: 'Mothers',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info),
          label: 'About',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: AppTheme.lebanonRed,
      selectedLabelStyle: GoogleFonts.montserrat(
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      unselectedLabelStyle: GoogleFonts.montserrat(
        fontWeight: FontWeight.w400,
        fontSize: 12,
      ),
      onTap: _onItemTapped,
    ),
    );
  }

  Widget _buildDishesContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppTheme.lebanonRed),
            const SizedBox(height: 16),
            Text(
              'Loading delicious dishes...',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: AppTheme.textLight,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 100,
              color: AppTheme.textLight.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!.replaceAll('Exception: ', ''),
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: AppTheme.textLight,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDishes,
              icon: const Icon(Icons.refresh),
              label: Text(
                'Try Again',
                style: GoogleFonts.montserrat(),
              ),
            ),
          ],
        ),
      );
    }

    if (_dishes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 100,
              color: AppTheme.textLight.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No dishes found',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Try searching with different keywords'
                  : 'Check back later for new dishes!',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: AppTheme.textLight,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _dishes.length,
      itemBuilder: (context, index) {
        return DishCard(
          dish: _dishes[index],
          onTap: () {
            // TODO: Navigate to dish details
          },
        );
      },
    );
  }

  Widget _buildOrdersContent() {
    if (_isLoadingOrders) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppTheme.lebanonRed),
            const SizedBox(height: 16),
            Text(
              'Loading your orders...',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: AppTheme.textLight,
              ),
            ),
          ],
        ),
      );
    }

    if (_ordersError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 100,
              color: AppTheme.textLight.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load orders',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _ordersError!.replaceAll('Exception: ', ''),
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: AppTheme.textLight,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadOrders,
              icon: const Icon(Icons.refresh),
              label: Text(
              'Try Again',
              style: GoogleFonts.montserrat(),
            ),
            ),
          ],
        ),
      );
    }

    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 100,
              color: AppTheme.textLight.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No orders yet',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start browsing dishes to place your first order!',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedIndex = 0; // Switch to dishes tab
                });
              },
              icon: const Icon(Icons.restaurant_menu),
              label: Text(
                'Browse Dishes',
                style: GoogleFonts.montserrat(),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lebanonRed,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: AppTheme.lebanonRed,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          return OrderCard(
            order: _orders[index],
            onTap: () {
              // TODO: Navigate to order details
            },
            onCancel: (orderId) => _cancelOrder(orderId),
          );
        },
      ),
    );
  }

}