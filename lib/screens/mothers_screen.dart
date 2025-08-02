import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/mother_service.dart';
import '../services/auth_service.dart';
import '../models/mother.dart';
import '../utils/theme.dart';
import '../widgets/mother_card.dart';
import 'login_screen.dart';
import 'mother_detail_screen.dart';

class MothersScreen extends StatefulWidget {
  const MothersScreen({super.key});

  @override
  State<MothersScreen> createState() => _MothersScreenState();
}

class _MothersScreenState extends State<MothersScreen> {
  final _motherService = MotherService();
  final _authService = AuthService();
  List<Mother> _mothers = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMorePages = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMothers();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoading &&
        _hasMorePages) {
      _loadMoreMothers();
    }
  }

  Future<void> _loadMothers() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _currentPage = 1;
      _mothers.clear();
    });

    try {
      final mothersResponse = await _motherService.getMothers(page: 1);
      if (mounted && mothersResponse != null) {
        setState(() {
          _mothers = mothersResponse.data;
          _hasMorePages = mothersResponse.meta['current_page'] < mothersResponse.meta['last_page'];
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

  Future<void> _loadMoreMothers() async {
    if (_isLoading || !_hasMorePages) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final mothersResponse = await _motherService.getMothers(page: nextPage);
      if (mounted && mothersResponse != null) {
        setState(() {
          _mothers.addAll(mothersResponse.data);
          _currentPage = nextPage;
          _hasMorePages = mothersResponse.meta['current_page'] < mothersResponse.meta['last_page'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load more mothers: ${e.toString()}',
                style: GoogleFonts.montserrat()),
            backgroundColor: AppTheme.lebanonRed,
          ),
        );
        
        if (e.toString().contains('Authentication failed')) {
          _logout();
        }
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

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadMothers,
      color: AppTheme.lebanonRed,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading && _mothers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppTheme.lebanonRed),
            const SizedBox(height: 16),
            Text(
              'Loading our wonderful mothers...',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: AppTheme.textLight,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null && _mothers.isEmpty) {
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
              onPressed: _loadMothers,
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

    if (_mothers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: 100,
              color: AppTheme.textLight.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No mothers found',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new home cooks!',
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
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _mothers.length + (_hasMorePages || _isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _mothers.length) {
          // Loading indicator for pagination
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.lebanonRed),
            ),
          );
        }

        return MotherCard(
          mother: _mothers[index],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MotherDetailScreen(
                  mother: _mothers[index],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
