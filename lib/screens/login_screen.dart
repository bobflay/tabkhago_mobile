import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.montserrat(), // Added Montserrat here too
        ),
        backgroundColor: isError ? Colors.red : AppTheme.lebanonGreen,
      ),
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Test API connectivity first
      print('LoginScreen: Testing API connectivity...');
      final isConnected = await _authService.testApiConnectivity();
      print('LoginScreen: API connectivity: $isConnected');

      if (!isConnected) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar(
            'Unable to connect to server. Please check your internet connection.');
        return;
      }

      print('LoginScreen: Calling AuthService.login()');
      final result = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      print('LoginScreen: AuthService returned result: $result');

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        if (result['success']) {
          print('LoginScreen: Login successful, navigating to HomeScreen');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {
          print('LoginScreen: Login failed with message: ${result['message']}');
          _showSnackBar(result['message']);
        }
      }
    } else {
      print('LoginScreen: Form validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Logo and App Name
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.lebanonRed,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.lebanonRed.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'TabkhaGo',
                      style: GoogleFonts.montserrat(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Homemade Lebanese dishes delivered to you',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              // Login Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        hintStyle: GoogleFonts.montserrat(),
                      ),
                      style: GoogleFonts.montserrat(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        hintStyle: GoogleFonts.montserrat(),
                      ),
                      style: GoogleFonts.montserrat(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Login',
                              style: GoogleFonts.montserrat(),
                            ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password
                      },
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.montserrat(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: GoogleFonts.montserrat(
                      color: AppTheme.textLight,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Sign Up',
                      style: GoogleFonts.montserrat(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
