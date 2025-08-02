import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.montserrat(),
        ),
        backgroundColor: isError ? Colors.red : AppTheme.lebanonGreen,
      ),
    );
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final result = await _authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        if (result['success']) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {
          _showSnackBar(result['message']);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Account',
          style: GoogleFonts.montserrat(
            color: AppTheme.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.textDark,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.lebanonGreen,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.lebanonGreen.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_add,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Join TabkhaGo',
                      style: GoogleFonts.montserrat(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create an account to start ordering',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Registration Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: 'Full Name',
                        prefixIcon: const Icon(Icons.person_outline),
                        hintStyle: GoogleFonts.montserrat(),
                      ),
                      style: GoogleFonts.montserrat(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        if (value.length < 3) {
                          return 'Name must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
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
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'Phone Number',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        hintStyle: GoogleFonts.montserrat(),
                      ),
                      style: GoogleFonts.montserrat(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (value.length < 8) {
                          return 'Please enter a valid phone number';
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
                          return 'Please enter a password';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        hintText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        hintStyle: GoogleFonts.montserrat(),
                      ),
                      style: GoogleFonts.montserrat(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.lebanonGreen,
                      ),
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
                              'Create Account',
                              style: GoogleFonts.montserrat(),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: GoogleFonts.montserrat(
                      color: AppTheme.textLight,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Login',
                      style: GoogleFonts.montserrat(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Terms and Conditions
              Text(
                'By creating an account, you agree to our\nTerms of Service and Privacy Policy',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: AppTheme.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
